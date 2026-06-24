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

const _kDeviceInfoChannel = MethodChannel('device_info/battery');
const _kAutoCoolChannel = MethodChannel('com.example.battery_saver_app/auto_cool');
// ── NEW: CPU info channel for real temperature balancing ──
const _kCpuChannel = MethodChannel('com.example.battery_saver_app/cpu_info');
// ── NEW: Memory info channel — real RAM via native ActivityManager.MemoryInfo ──
const _kMemoryChannel = MethodChannel('com.example.battery_saver_app/memory_info');

class OptimizationBloc extends Bloc<OptimizationEvent, OptimizationState> {
  Timer? _taskTimer;
  int _currentTaskIndex = 0;
  final Battery _battery = Battery();

  int? _sessionStartBatteryLevel;

  double? _sessionStartFreeDiskMB;
  double? _sessionStartTotalDiskMB;

  /// Real performance score computed from the two real readings above,
  /// at session start. This is the genuine "before" score — not fabricated.
  int? _sessionStartScore;

  // ── NEW: RAM Freed tracking — real availMem (bytes) from ActivityManager ──
  int? _sessionStartAvailMemBytes;

  // ── NEW: Estimated Battery Saved tracking — real current draw (µA) ──
  // and remaining battery capacity (mAh), both read from native side.
  int? _sessionStartCurrentNowMicroA; // current draw BEFORE killing apps
  int? _afterCurrentNowMicroA; // current draw AFTER killing apps
  double? _batteryCapacityMAh; // remaining capacity, for the hours estimate

  // ── NEW: stores real temperature read during balancing ──
  double? _balancedTemperature;

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
      _sessionStartBatteryLevel = null;
    }

    try {
      final diskSpace = DiskSpacePlus();
      _sessionStartFreeDiskMB = (await diskSpace.getFreeDiskSpace) ?? 0;
      _sessionStartTotalDiskMB = (await diskSpace.getTotalDiskSpace) ?? 1;
    } catch (_) {
      _sessionStartFreeDiskMB = null;
      _sessionStartTotalDiskMB = null;
    }

    // ── NEW: real RAM baseline (availMem in bytes) — needed for RAM Freed.
    try {
      final dynamic raw = await _kMemoryChannel.invokeMethod('getMemoryInfo');
      final Map<String, dynamic> memMap = Map<String, dynamic>.from(raw as Map);
      _sessionStartAvailMemBytes = (memMap['availMem'] as num?)?.toInt();
    } on PlatformException {
      _sessionStartAvailMemBytes = null;
    } on MissingPluginException {
      _sessionStartAvailMemBytes = null;
    } catch (_) {
      _sessionStartAvailMemBytes = null;
    }

    try {
      final dynamic raw =
          await _kDeviceInfoChannel.invokeMethod('getBatteryPowerInfo');
      final Map<String, dynamic> powerMap =
          Map<String, dynamic>.from(raw as Map);
      _sessionStartCurrentNowMicroA =
          (powerMap['currentNowMicroA'] as num?)?.toInt();
      final chargeCounterMicroAh =
          (powerMap['chargeCounterMicroAh'] as num?)?.toDouble();
      _batteryCapacityMAh = chargeCounterMicroAh != null
          ? chargeCounterMicroAh / 1000.0
          : null;
    } on PlatformException {
      _sessionStartCurrentNowMicroA = null;
      _batteryCapacityMAh = null;
    } on MissingPluginException {
      _sessionStartCurrentNowMicroA = null;
      _batteryCapacityMAh = null;
    } catch (_) {
      _sessionStartCurrentNowMicroA = null;
      _batteryCapacityMAh = null;
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
    _balancedTemperature = null; // reset before new session
    _afterCurrentNowMicroA = null; // reset before new session
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

  Future<void> _onTaskCompleted(
  _TaskCompletedEvent event,
  Emitter<OptimizationState> emit,
) async {                          // ← async bana do
  if (!state.isRunning) return;

  final statuses = List<TaskStatus>.from(state.taskStatuses);
  statuses[event.index] = TaskStatus.completed;
  _currentTaskIndex++;

  final progress = _currentTaskIndex / _kTotalTasks;

  if (_currentTaskIndex >= _kTotalTasks) {
    _taskTimer?.cancel();

    // ── Pehle real tasks await karo ──
    _killBackgroundApps();          // fire-and-forget ok (RAM clear)
    _checkTemperature();            // fire-and-forget ok (temp)
    await _readCurrentDrawAfter();  // ← AWAIT — zaruri hai battery hours ke liye

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
    print('🔍 _sessionStartCurrentNowMicroA: $_sessionStartCurrentNowMicroA');
  print('🔍 _afterCurrentNowMicroA: $_afterCurrentNowMicroA');
  print('🔍 _batteryCapacityMAh: $_batteryCapacityMAh');
  print('🔍 _sessionStartAvailMemBytes: $_sessionStartAvailMemBytes');
  print('🔍 _sessionStartBatteryLevel: $_sessionStartBatteryLevel');
  print('🔍 _balancedTemperature: $_balancedTemperature');
    emit(state.copyWith(resultStatus: ResultLoadStatus.loading));

    try {
      // ── 1. Battery % now — real, direct OS read ──────────────────────────
      final batteryNow = await _battery.batteryLevel;

      final cacheDir = await getTemporaryDirectory();
      final cacheBeforeBytes = await _dirSizeBytes(cacheDir);

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

      // ── 4. Temperature — use _balancedTemperature if already read,
      //       otherwise fallback to battery temp channel ────────────────────
      double? temperatureCelsius = _balancedTemperature;
      if (temperatureCelsius == null) {
        try {
          final result = await _kDeviceInfoChannel
              .invokeMethod<num>('getBatteryTemperature');
          temperatureCelsius = result?.toDouble();
        } on PlatformException {
          temperatureCelsius = null;
        } on MissingPluginException {
          temperatureCelsius = null;
        }
      }


      double? ramFreedMB;
      try {
        final dynamic raw = await _kMemoryChannel.invokeMethod('getMemoryInfo');
        final Map<String, dynamic> memMap =
            Map<String, dynamic>.from(raw as Map);
        final availMemAfterBytes = (memMap['availMem'] as num?)?.toInt();
        if (_sessionStartAvailMemBytes != null && availMemAfterBytes != null) {
          final freedBytes = availMemAfterBytes - _sessionStartAvailMemBytes!;
    
          ramFreedMB = freedBytes > 0 ? freedBytes / (1024 * 1024) : 0.0;
        }
      } on PlatformException {
        ramFreedMB = null;
      } on MissingPluginException {
        ramFreedMB = null;
      } catch (_) {
        ramFreedMB = null;
      }

  
      String? estimatedBatterySavedText;
      if (_sessionStartCurrentNowMicroA != null &&
          _afterCurrentNowMicroA != null &&
          _batteryCapacityMAh != null &&
          _batteryCapacityMAh! > 0) {
        final beforeMicroA = _sessionStartCurrentNowMicroA!.abs();
        final afterMicroA = _afterCurrentNowMicroA!.abs();
        final drawReductionMicroA = beforeMicroA - afterMicroA;

        if (drawReductionMicroA > 0 && afterMicroA > 0) {
          final beforeMA = beforeMicroA / 1000.0;
          final afterMA = afterMicroA / 1000.0;
          final hoursBefore = _batteryCapacityMAh! / beforeMA;
          final hoursAfter = _batteryCapacityMAh! / afterMA;
          final extraHours = (hoursAfter - hoursBefore).clamp(0.0, 24.0);
          if (extraHours > 0.01) {
            final h = extraHours.floor();
            final m = ((extraHours - h) * 60).round();
            estimatedBatterySavedText = m > 0 ? '+${h}h ${m}m' : '+${h}h';
          }
        }
      }

      // ── 5. Performance score ─────────────────────────────────────────────
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
        scoreBefore: _sessionStartScore,
        scoreAfter: performanceScore,
        // ── NEW: real RAM Freed (MB) ──
        ramFreedMB: ramFreedMB,
        ramFreedText: ramFreedMB != null ? _fmtMB(ramFreedMB) : 'N/A',
        // ── NEW: honestly-labeled estimate, null if we couldn't compute it
        // from real readings (no fallback fake number is ever shown) ──
        estimatedBatterySavedText: estimatedBatterySavedText,
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

  /// Score from two genuinely-measured current values only:
  ///   50% weight → current battery percentage
  ///   50% weight → current free disk space percentage
  /// This is a SIMPLE, TRANSPARENT formula — not an invented "performance
  /// score" with hidden weights. Because before/after are usually only
  /// seconds apart, the real-life jump (e.g. 72 → 92) will often be much
  /// smaller than that. Show whatever the real numbers produce — do not
  /// scale or boost the delta to look more impressive.
  int _calcScore({
    required double batteryPct,
    required double freePct,
  }) {
    final b = (batteryPct * 0.5).clamp(0.0, 50.0);
    final s = (freePct * 0.5).clamp(0.0, 50.0);
    return (b + s).round().clamp(0, 100);
  }

  /// Reads real current draw (µA) AFTER background apps were killed.
  /// Used together with the session-start reading to calculate
  /// "Estimated Battery Saved" — see comments in _onLoadResult.
  Future<void> _readCurrentDrawAfter() async {
    try {
      final dynamic raw =
          await _kDeviceInfoChannel.invokeMethod('getBatteryPowerInfo');
      final Map<String, dynamic> powerMap =
          Map<String, dynamic>.from(raw as Map);
      _afterCurrentNowMicroA = (powerMap['currentNowMicroA'] as num?)?.toInt();
    } on PlatformException catch (e) {
      print('⚠️ readCurrentDrawAfter failed: ${e.message}');
      _afterCurrentNowMicroA = null;
    } catch (e) {
      print('⚠️ readCurrentDrawAfter unknown error: $e');
      _afterCurrentNowMicroA = null;
    }
  }

  /// Kills background/heavy apps via AutoCool channel.
  Future<void> _killBackgroundApps() async {
    try {
      print('🧹 OptimizationBloc: Killing background apps...');
      await _kAutoCoolChannel.invokeMethod('killHeavyApps');
      print('✅ Background apps killed after optimization');
    } on PlatformException catch (e) {
      print('⚠️ killHeavyApps failed: ${e.message}');
    } catch (e) {
      print('⚠️ killHeavyApps unknown error: $e');
    }
  }

  /// Reads real CPU temperature via cpu_info channel.
  /// Renamed from "_balanceTemperature" — the app only READS temperature,
  /// it does not and cannot control/balance it. Label kept honest.
  /// Result stored in [_balancedTemperature] — used in result screen.
  Future<void> _checkTemperature() async {
    try {
      print('🌡️ OptimizationBloc: Checking device temperature — reading CPU info...');
      final dynamic raw = await _kCpuChannel.invokeMethod('getCpuInfo');
      final Map<String, dynamic> cpuMap = Map<String, dynamic>.from(raw as Map);
      _balancedTemperature = (cpuMap['temperature'] as num?)?.toDouble();
      print('✅ Temperature read: $_balancedTemperature°C');
    } on PlatformException catch (e) {
      print('⚠️ checkTemperature failed: ${e.message}');
      _balancedTemperature = null;
    } catch (e) {
      print('⚠️ checkTemperature unknown error: $e');
      _balancedTemperature = null;
    }
  }

  @override
  Future<void> close() {
    _taskTimer?.cancel();
    return super.close();
  }
}