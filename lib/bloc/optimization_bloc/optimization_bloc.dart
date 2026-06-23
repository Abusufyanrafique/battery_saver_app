import 'dart:async';
import 'dart:io';

import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'optimization_event.dart';
part 'optimization_state.dart';

const _kTaskDurationMs = 1400;
const _kTotalTasks = 5;

/// Platform channel for real OS-level battery temperature.
/// Backed by BatteryManager.EXTRA_TEMPERATURE on Android (see MainActivity.kt).
/// Returns null on platforms/devices where this isn't available — the UI
/// must hide the temperature row in that case rather than show a fake value.
const _kDeviceInfoChannel = MethodChannel('device_info/battery');

class OptimizationBloc extends Bloc<OptimizationEvent, OptimizationState> {
  Timer? _taskTimer;
  int _currentTaskIndex = 0;
  final Battery _battery = Battery();

  /// Real battery % captured the moment the optimize session starts.
  /// This is the ONLY valid "before" value — never derived/guessed.
  int? _sessionStartBatteryLevel;

  /// Real free disk space (MB) captured the moment the optimize session
  /// starts — the genuine "before" snapshot for the disk-space half of
  /// the performance score.
  double? _sessionStartFreeDiskMB;
  double? _sessionStartTotalDiskMB;

  /// Real performance score computed from the two real readings above,
  /// at session start. This is the genuine "before" score — not fabricated.
  int? _sessionStartScore;

  OptimizationBloc() : super(OptimizationState.initial(_kTotalTasks)) {
    on<StartOptimizationEvent>(_onStart);
    on<StopOptimizationEvent>(_onStop);
    on<_TaskCompletedEvent>(_onTaskCompleted);
    on<_BatteryPermissionResultEvent>(_onPermissionResult);
    on<LoadResultDataEvent>(_onLoadResult);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  OPTIMIZE SCREEN LOGIC
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onStart(
    StartOptimizationEvent event,
    Emitter<OptimizationState> emit,
  ) async {
    if (state.isRunning) return;

    // Real baseline capture — this is what makes the later "battery saved"
    // AND the "before" performance score genuine instead of fabricated.
    try {
      _sessionStartBatteryLevel = await _battery.batteryLevel;
    } catch (_) {
      _sessionStartBatteryLevel = null; // unavailable — handled later, never guessed
    }

    try {
      final diskSpace = DiskSpacePlus();
      _sessionStartFreeDiskMB = (await diskSpace.getFreeDiskSpace) ?? 0;
      _sessionStartTotalDiskMB = (await diskSpace.getTotalDiskSpace) ?? 1;
    } catch (_) {
      _sessionStartFreeDiskMB = null;
      _sessionStartTotalDiskMB = null;
    }

    // Real "before" score — only computed if both real readings succeeded.
    if (_sessionStartBatteryLevel != null &&
        _sessionStartFreeDiskMB != null &&
        _sessionStartTotalDiskMB != null) {
      final freePercentBefore = (_sessionStartFreeDiskMB! /
              _sessionStartTotalDiskMB! *
              100)
          .clamp(0.0, 100.0)
          .toDouble();
      _sessionStartScore = _calcScore(
        batteryPct: _sessionStartBatteryLevel!.toDouble(),
        freePct: freePercentBefore,
      );
    } else {
      _sessionStartScore = null;
    }

    emit(state.copyWith(
      phase: OptimizationPhase.requestingPermission,
      isRunning: false,
    ));

    try {
      final snapshot =
          await BatteryOptimizationHelper.getBatteryRestrictionSnapshot();

      if (snapshot.isBatteryOptimizationEnabled) {
        final outcome = await BatteryOptimizationHelper
            .ensureOptimizationDisabledDetailed(
          openSettingsIfDirectRequestNotPossible: true,
        );
        add(_BatteryPermissionResultEvent(outcome.status));
      } else {
        add(_BatteryPermissionResultEvent(
            OptimizationOutcomeStatus.alreadyDisabled));
      }
    } catch (_) {
      add(_BatteryPermissionResultEvent(
          OptimizationOutcomeStatus.alreadyDisabled));
    }
  }

  void _onPermissionResult(
    _BatteryPermissionResultEvent event,
    Emitter<OptimizationState> emit,
  ) {
    switch (event.status) {
      case OptimizationOutcomeStatus.alreadyDisabled:
      case OptimizationOutcomeStatus.disabledAfterPrompt:
      case OptimizationOutcomeStatus.unsupported:
        _beginTasks(emit);
        break;

      case OptimizationOutcomeStatus.settingsOpened:
        emit(state.copyWith(
          phase: OptimizationPhase.settingsOpened,
          isRunning: false,
          errorMessage:
              'Please allow background activity in settings, then tap Optimize again.',
        ));
        break;

      case OptimizationOutcomeStatus.failed:
        emit(state.copyWith(
          errorMessage:
              'Battery permission not granted. Tasks may stop in background.',
        ));
        _beginTasks(emit);
        break;
    }
  }

  void _beginTasks(Emitter<OptimizationState> emit) {
    _currentTaskIndex = 0;
    final statuses = List<TaskStatus>.filled(_kTotalTasks, TaskStatus.pending);
    statuses[0] = TaskStatus.inProgress;

    emit(state.copyWith(
      taskStatuses: statuses,
      progress: 0.0,
      isRunning: true,
      isComplete: false,
      phase: OptimizationPhase.running,
      errorMessage: null,
    ));

    _taskTimer?.cancel();
    _taskTimer = Timer.periodic(
      const Duration(milliseconds: _kTaskDurationMs),
      (_) => add(_TaskCompletedEvent(_currentTaskIndex)),
    );
  }

  void _onTaskCompleted(
    _TaskCompletedEvent event,
    Emitter<OptimizationState> emit,
  ) {
    if (!state.isRunning) return;

    final statuses = List<TaskStatus>.from(state.taskStatuses);
    statuses[event.index] = TaskStatus.completed;
    _currentTaskIndex++;

    final progress = _currentTaskIndex / _kTotalTasks;

    if (_currentTaskIndex >= _kTotalTasks) {
      _taskTimer?.cancel();
      emit(state.copyWith(
        taskStatuses: statuses,
        progress: 1.0,
        isRunning: false,
        isComplete: true,
        phase: OptimizationPhase.complete,
      ));
    } else {
      statuses[_currentTaskIndex] = TaskStatus.inProgress;
      emit(state.copyWith(
        taskStatuses: statuses,
        progress: progress,
        phase: OptimizationPhase.running,
      ));
    }
  }

  void _onStop(
    StopOptimizationEvent event,
    Emitter<OptimizationState> emit,
  ) {
    _taskTimer?.cancel();
    final statuses = List<TaskStatus>.from(state.taskStatuses);
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i] == TaskStatus.inProgress) {
        statuses[i] = TaskStatus.pending;
      }
    }
    emit(state.copyWith(
      taskStatuses: statuses,
      isRunning: false,
      phase: OptimizationPhase.stopped,
    ));
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  RESULT SCREEN LOGIC — every value here is independently real-measurable.
  //  Nothing is randomized, guessed, or back-computed from a fake baseline.
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _onLoadResult(
    LoadResultDataEvent event,
    Emitter<OptimizationState> emit,
  ) async {
    emit(state.copyWith(resultStatus: ResultLoadStatus.loading));

    try {
      // ── 1. Battery % now — real, direct OS read ──────────────────────────
      final batteryNow = await _battery.batteryLevel;

      // ── 2. Cache: measure real size, delete it, measure real size again ──
      final cacheDir = await getTemporaryDirectory();
      final cacheBeforeBytes = await _dirSizeBytes(cacheDir);

      // Real free disk space BEFORE clearing, so the disk delta below is
      // a genuine measured difference, not an estimate.
      final diskSpace = DiskSpacePlus();
      final freeDiskBeforeMB = (await diskSpace.getFreeDiskSpace) ?? 0;

      await _clearDir(cacheDir);

      final cacheAfterBytes = await _dirSizeBytes(cacheDir);
      final clearedBytes =
          (cacheBeforeBytes - cacheAfterBytes).clamp(0, double.maxFinite).toDouble();
      final clearedMB = clearedBytes / (1024 * 1024);

      // ── 3. Real free disk space AFTER clearing ───────────────────────────
      final freeDiskAfterMB = (await diskSpace.getFreeDiskSpace) ?? 0;
      final totalDiskMB = (await diskSpace.getTotalDiskSpace) ?? 1;
      final diskFreedMB =
          (freeDiskAfterMB - freeDiskBeforeMB).clamp(0, double.maxFinite).toDouble();

      // ── 4. Real temperature via platform channel. Null if unavailable —
      //       we do NOT fall back to a guessed value. ──────────────────────
      double? temperatureCelsius;
      try {
        final result = await _kDeviceInfoChannel
            .invokeMethod<num>('getBatteryTemperature');
        temperatureCelsius = result?.toDouble();
      } on PlatformException {
        temperatureCelsius = null;
      } on MissingPluginException {
        temperatureCelsius = null; // e.g. running on iOS or channel not wired up
      }

      // ── 5. Performance score — built only from real, current readings.
      //       No fabricated "before" baseline is subtracted. ───────────────
      final freePercentNow =
          (freeDiskAfterMB / totalDiskMB * 100).clamp(0.0, 100.0).toDouble();
      final performanceScore = _calcScore(
        batteryPct: batteryNow.toDouble(),
        freePct: freePercentNow,
      );

      emit(state.copyWith(
        resultStatus: ResultLoadStatus.loaded,
        batteryLevelAtSessionStart: _sessionStartBatteryLevel,
        batteryLevelNow: batteryNow,
        junkClearedMB: clearedMB,
        junkClearedText: _fmtMB(clearedMB),
        diskSpaceFreedMB: diskFreedMB,
        diskSpaceFreedText: _fmtMB(diskFreedMB),
        temperatureCelsius: temperatureCelsius,
        performanceScore: performanceScore,
        scoreBefore: _sessionStartScore, // real, or null if no session started
        scoreAfter: performanceScore,
      ));
    } catch (e) {
      emit(state.copyWith(
        resultStatus: ResultLoadStatus.error,
        errorMessage: 'Could not load device data: $e',
      ));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<int> _dirSizeBytes(Directory dir) async {
    int total = 0;
    try {
      if (dir.existsSync()) {
        await for (final e in dir.list(recursive: true, followLinks: false)) {
          if (e is File) total += await e.length();
        }
      }
    } catch (_) {}
    return total;
  }

  Future<void> _clearDir(Directory dir) async {
    try {
      if (dir.existsSync()) {
        await for (final e in dir.list(recursive: false, followLinks: false)) {
          try {
            if (e is File) {
              await e.delete();
            } else if (e is Directory) {
              await e.delete(recursive: true);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  String _fmtMB(double mb) {
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(1)} GB';
    return '${mb.toStringAsFixed(0)} MB';
  }

  /// Score from two genuinely-measured current values only.
  /// No fabricated baseline, no random variance.
  int _calcScore({
    required double batteryPct,
    required double freePct,
  }) {
    final b = (batteryPct * 0.5).clamp(0.0, 50.0);
    final s = (freePct * 0.5).clamp(0.0, 50.0);
    return (b + s).round().clamp(0, 100);
  }

  @override
  Future<void> close() {
    _taskTimer?.cancel();
    return super.close();
  }
}