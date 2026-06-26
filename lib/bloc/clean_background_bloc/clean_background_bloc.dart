import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:battery_plus/battery_plus.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_info2/system_info2.dart';

enum CleanPhase { idle, scanning, cleanReady, cleaning, completed }

const _kCleanerChannel = MethodChannel('com.example.battery_saver_app/cleaner');
const _kDeviceInfoChannel = MethodChannel('device_info/battery');

// ═══════════════════════════════════
// MODELS
// ═══════════════════════════════════

class RunningAppInfo {
  final String packageName;
  final String appName;
  final String sizeFormatted;
  final int cacheBytes; // real, from StorageStatsManager. -1 = unmeasurable, 0 = default/unknown source.
  final bool recentlyUsed;
  final Uint8List? iconBytes;

  const RunningAppInfo({
    required this.packageName,
    required this.appName,
    required this.sizeFormatted,
    this.cacheBytes = 0,
    this.recentlyUsed = false,
    this.iconBytes,
  });
}


class CleanResultData {
  final String junkRemoved; // real: own app's temp dir delta
  final String appsClosed; // real: count actually attempted via trimBackgroundApps
  final String cacheCleared; // real: sum of selected apps' real cacheBytes (FOUND, not force-deleted)
  final String residualFiles; // real: own app's leftover orphaned files (.tmp/.log/.bak), NOT a fake formula
  final double beforeGB;
  final double afterGB;
  final double totalGB;

  const CleanResultData({
    required this.junkRemoved,
    required this.appsClosed,
    required this.cacheCleared,
    required this.residualFiles,
    required this.beforeGB,
    required this.afterGB,
    required this.totalGB,
  });

  factory CleanResultData.zero() => const CleanResultData(
        junkRemoved: '0 MB',
        appsClosed: '0 Apps',
        cacheCleared: '0 MB',
        residualFiles: '0 MB',
        beforeGB: 0,
        afterGB: 0,
        totalGB: 0,
      );

  CleanResultData copyWith({
    String? junkRemoved,
    String? appsClosed,
    String? cacheCleared,
    String? residualFiles,
    double? beforeGB,
    double? afterGB,
    double? totalGB,
  }) {
    return CleanResultData(
      junkRemoved: junkRemoved ?? this.junkRemoved,
      appsClosed: appsClosed ?? this.appsClosed,
      cacheCleared: cacheCleared ?? this.cacheCleared,
      residualFiles: residualFiles ?? this.residualFiles,
      beforeGB: beforeGB ?? this.beforeGB,
      afterGB: afterGB ?? this.afterGB,
      totalGB: totalGB ?? this.totalGB,
    );
  }
}


class PerformanceData {
  final String speedImproved; // intentionally '' — no real metric exists
  final String ramFreed; // real, from SysInfo before/after delta
  final String batterySaved; // real estimate, same pattern as OptimizationBloc

  const PerformanceData({
    this.speedImproved = '',
    this.ramFreed = '',
    this.batterySaved = '',
  });
}

// ═══════════════════════════════════
// EVENTS
// ═══════════════════════════════════

abstract class CleanBackgroundEvent {
  const CleanBackgroundEvent();
}

class StartScanningEvent extends CleanBackgroundEvent {
  const StartScanningEvent();
}

class _ScanTickEvent extends CleanBackgroundEvent {
  const _ScanTickEvent();
}

class ToggleAppSelectionEvent extends CleanBackgroundEvent {
  final int index;
  const ToggleAppSelectionEvent(this.index);
}

class ToggleSelectAllAppsEvent extends CleanBackgroundEvent {
  const ToggleSelectAllAppsEvent();
}

class StartCleaningEvent extends CleanBackgroundEvent {
  const StartCleaningEvent();
}

class _CleaningTickEvent extends CleanBackgroundEvent {
  final CleanResultData result;
  const _CleaningTickEvent(this.result);
}

class CleanAgainEvent extends CleanBackgroundEvent {
  const CleanAgainEvent();
}

/// User ko Settings se wapas aane ke baad permission re-check karne ke liye.
class RecheckPermissionEvent extends CleanBackgroundEvent {
  const RecheckPermissionEvent();
}

// ═══════════════════════════════════
// STATE
// ═══════════════════════════════════

class CleanBackgroundState extends Equatable {
  final CleanPhase phase;
  final double scanProgress;
  final List<RunningAppInfo> runningApps;
  final List<bool> appsSelected;
  final bool allSelected;
  final CleanResultData? cleanResult;
  final CleanResultData? finalCleanResult;
  final PerformanceData? performanceData;
  final List<RunningAppInfo> cleanedApps;

  /// false = Usage Access permission missing. UI should show a prompt
  /// instead of silently showing an empty/wrong list.
  final bool permissionGranted;

  const CleanBackgroundState({
    required this.phase,
    required this.scanProgress,
    required this.runningApps,
    required this.appsSelected,
    required this.allSelected,
    this.cleanResult,
    this.finalCleanResult,
    this.performanceData,
    this.cleanedApps = const [],
    this.permissionGranted = true,
  });

  factory CleanBackgroundState.initial() => const CleanBackgroundState(
        phase: CleanPhase.idle,
        scanProgress: 0.0,
        runningApps: [],
        appsSelected: [],
        allSelected: false,
        cleanResult: null,
        finalCleanResult: null,
        performanceData: null,
        cleanedApps: [],
        permissionGranted: true,
      );

  CleanBackgroundState copyWith({
    CleanPhase? phase,
    double? scanProgress,
    List<RunningAppInfo>? runningApps,
    List<bool>? appsSelected,
    bool? allSelected,
    CleanResultData? cleanResult,
    CleanResultData? finalCleanResult,
    PerformanceData? performanceData,
    List<RunningAppInfo>? cleanedApps,
    bool? permissionGranted,
  }) {
    return CleanBackgroundState(
      phase: phase ?? this.phase,
      scanProgress: scanProgress ?? this.scanProgress,
      runningApps: runningApps ?? this.runningApps,
      appsSelected: appsSelected ?? this.appsSelected,
      allSelected: allSelected ?? this.allSelected,
      cleanResult: cleanResult ?? this.cleanResult,
      finalCleanResult: finalCleanResult ?? this.finalCleanResult,
      performanceData: performanceData ?? this.performanceData,
      cleanedApps: cleanedApps ?? this.cleanedApps,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        scanProgress,
        runningApps,
        appsSelected,
        allSelected,
        cleanResult,
        finalCleanResult,
        performanceData,
        cleanedApps,
        permissionGranted,
      ];
}

// ═══════════════════════════════════
// BLOC
// ═══════════════════════════════════

class CleanBackgroundBloc
    extends Bloc<CleanBackgroundEvent, CleanBackgroundState> {
  Timer? _scanTimer;
  Timer? _cleaningTimer;
  final Battery _battery = Battery();

  static const double _bytesToGB = 1024 * 1024 * 1024;

  List<RunningAppInfo> _realApps = [];

  // Real before/after snapshots — same honest pattern as OptimizationBloc.
  int? _ramFreeBeforeBytes;
  int? _currentNowMicroABefore;
  int? _currentNowMicroAAfter;
  double? _batteryCapacityMAh;
  double? _diskFreeBeforeMB;
  double? _diskTotalMB;

  // Real PREVIEW sizes — measured (not deleted) during scanning, so the
  // scan screen can show a real number instead of '—'. Actual delete still
  // only happens in _onStartCleaning.
  double _junkPreviewMB = 0;
  double _residualPreviewMB = 0;

  CleanBackgroundBloc() : super(CleanBackgroundState.initial()) {
    on<StartScanningEvent>(_onStartScanning);
    on<_ScanTickEvent>(_onScanTick);
    on<ToggleAppSelectionEvent>(_onToggleApp);
    on<ToggleSelectAllAppsEvent>(_onToggleAll);
    on<StartCleaningEvent>(_onStartCleaning);
    on<_CleaningTickEvent>(_onCleaningTick);
    on<CleanAgainEvent>(_onCleanAgain);
    on<RecheckPermissionEvent>(_onRecheckPermission);
  }

  // ═══════════════════════════
  // PERMISSION HELPERS
  // ═══════════════════════════

  Future<bool> _hasUsageAccess() async {
    try {
      final granted =
          await _kCleanerChannel.invokeMethod<bool>('hasUsageAccessPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Settings page kholta hai — user manually permission grant karega.
  /// UI se yeh call karo jab permissionGranted == false ho.
  Future<void> openUsageAccessSettings() async {
    try {
      await _kCleanerChannel.invokeMethod('openUsageAccessSettings');
    } catch (_) {}
  }

  Future<void> _onRecheckPermission(
    RecheckPermissionEvent event,
    Emitter<CleanBackgroundState> emit,
  ) async {
    final granted = await _hasUsageAccess();
    emit(state.copyWith(permissionGranted: granted));
    if (granted && state.phase == CleanPhase.idle) {
      add(const StartScanningEvent());
    }
  }

  // ═══════════════════════════
  // START SCANNING
  // ═══════════════════════════

  Future<void> _onStartScanning(
    StartScanningEvent event,
    Emitter<CleanBackgroundState> emit,
  ) async {
    _cancelTimers();
    _realApps = [];

    emit(CleanBackgroundState.initial().copyWith(phase: CleanPhase.scanning));

    // ── Real disk + RAM baseline (needed for the result screen later) ──
    try {
      final diskSpace = DiskSpacePlus();
      _diskFreeBeforeMB = (await diskSpace.getFreeDiskSpace) ?? 0;
      _diskTotalMB = (await diskSpace.getTotalDiskSpace) ?? 1;
    } catch (_) {
      _diskFreeBeforeMB = null;
      _diskTotalMB = null;
    }

    try {
      _ramFreeBeforeBytes = SysInfo.getFreePhysicalMemory();
    } catch (_) {
      _ramFreeBeforeBytes = null;
    }

    // ── Real PREVIEW of junk + residual size — measured, NOT deleted yet.
    // This lets the scanning screen show a real number (matching the
    // screenshot's "Junk Files 512 MB" / "Residual Files 102 MB" cards)
    // instead of '—'. Actual deletion still happens only on Clean Now. ──
    try {
      final tempDir = await getTemporaryDirectory();
      final tempBytes = await _dirSizeBytes(tempDir);
      _junkPreviewMB = tempBytes / (1024 * 1024);
    } catch (_) {
      _junkPreviewMB = 0;
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      _residualPreviewMB = await _orphanedFilesSizeBytes(docsDir) / (1024 * 1024);
    } catch (_) {
      _residualPreviewMB = 0;
    }

    // ── Real current-draw baseline for the battery-saved estimate ──
    try {
      final dynamic raw =
          await _kDeviceInfoChannel.invokeMethod('getBatteryPowerInfo');
      final map = Map<String, dynamic>.from(raw as Map);
      _currentNowMicroABefore = (map['currentNowMicroA'] as num?)?.toInt();
      final chargeCounterMicroAh =
          (map['chargeCounterMicroAh'] as num?)?.toDouble();
      _batteryCapacityMAh =
          chargeCounterMicroAh != null ? chargeCounterMicroAh / 1000.0 : null;
    } catch (_) {
      _currentNowMicroABefore = null;
      _batteryCapacityMAh = null;
    }

    // ── Real app + cache scan ──
    final hasPermission = await _hasUsageAccess();
    if (!hasPermission) {
      emit(state.copyWith(
        phase: CleanPhase.cleanReady,
        permissionGranted: false,
        runningApps: [],
        appsSelected: [],
      ));
      return;
    }

    try {
      final dynamic raw =
          await _kCleanerChannel.invokeMethod('getRunningAppsWithRealCache');
      final map = Map<String, dynamic>.from(raw as Map);
      final List apps = (map['apps'] as List?) ?? [];

      _realApps = apps.map((e) {
        final m = Map<String, dynamic>.from(e);
        final cacheBytes = (m['cacheBytes'] as num?)?.toInt() ?? 0;
        final sizeMb = (m['sizeMb'] as num?)?.toDouble() ?? 0.0;
        final sizeStr = cacheBytes < 0
            ? 'N/A'
            : (sizeMb >= 1024
                ? '${(sizeMb / 1024).toStringAsFixed(1)} GB'
                : '${sizeMb.toStringAsFixed(0)} MB');

        Uint8List? icon;
        final rawIcon = m['iconBytes'];
        if (rawIcon is List && rawIcon.isNotEmpty) {
          icon = Uint8List.fromList(rawIcon.cast<int>());
        }

        return RunningAppInfo(
          packageName: m['packageName'] ?? '',
          appName: m['appName'] ?? '',
          sizeFormatted: sizeStr,
          cacheBytes: cacheBytes,
          recentlyUsed: m['recentlyUsed'] == true,
          iconBytes: icon,
        );
      }).toList();
    } catch (_) {
      _realApps = [];
    }

    final selected = List<bool>.filled(_realApps.length, true);
    emit(state.copyWith(
      permissionGranted: true,
      runningApps: _realApps,
      appsSelected: selected,
      allSelected: selected.isNotEmpty && selected.every((e) => e),
    ));

    _scanTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      add(const _ScanTickEvent());
    });
  }

  // ═══════════════════════════
  // SCAN TICK — purely a reveal animation over already-fetched real data.
  // No numbers are invented here; we just progressively show _realApps
  // and the REAL summed cache total, growing as more apps "appear".
  // ═══════════════════════════

  void _onScanTick(
    _ScanTickEvent event,
    Emitter<CleanBackgroundState> emit,
  ) {
    final progress = (state.scanProgress + 0.02).clamp(0.0, 1.0);
    final count =
        (_realApps.length * progress).ceil().clamp(0, _realApps.length);
    final visible = _realApps.take(count).toList();
    final selected = List<bool>.filled(visible.length, true);

    // Real cumulative cache total of apps revealed so far.
    final cacheBytesSum = visible
        .where((a) => a.cacheBytes > 0)
        .fold<int>(0, (sum, a) => sum + a.cacheBytes);
    final cacheGB = cacheBytesSum / _bytesToGB;

    final usedRamGB = _ramFreeBeforeBytes != null
        ? (SysInfo.getTotalPhysicalMemory() - _ramFreeBeforeBytes!) / _bytesToGB
        : 0.0;

    String fmt(double gb) =>
        gb >= 1 ? '${gb.toStringAsFixed(1)} GB' : '${(gb * 1024).toInt()} MB';

    final result = CleanResultData(
      // Real preview, revealed proportionally with scan progress —
      // same real total as will be cleaned, just animated like a reveal.
      junkRemoved: fmt(_junkPreviewMB / 1024 * progress),
      appsClosed: '${visible.length} Apps',
      cacheCleared: fmt(cacheGB),
      residualFiles: fmt(_residualPreviewMB / 1024 * progress),
      beforeGB: usedRamGB,
      afterGB: usedRamGB,
      totalGB: _diskTotalMB != null ? _diskTotalMB! / 1024 : 0,
    );

    if (progress >= 1.0) {
      _cancelScanTimer();
      emit(state.copyWith(
        phase: CleanPhase.cleanReady,
        scanProgress: 1.0,
        runningApps: visible,
        appsSelected: selected,
        allSelected: true,
        cleanResult: result,
      ));
    } else {
      emit(state.copyWith(
        phase: CleanPhase.scanning,
        scanProgress: progress,
        runningApps: visible,
        appsSelected: selected,
        allSelected: true,
        cleanResult: result,
      ));
    }
  }

  // ═══════════════════════════
  // TOGGLE
  // ═══════════════════════════

  void _onToggleApp(
    ToggleAppSelectionEvent event,
    Emitter<CleanBackgroundState> emit,
  ) {
    final list = List<bool>.from(state.appsSelected);
    if (event.index < list.length) list[event.index] = !list[event.index];
    emit(state.copyWith(
      appsSelected: list,
      allSelected: list.every((e) => e),
    ));
  }

  void _onToggleAll(
    ToggleSelectAllAppsEvent event,
    Emitter<CleanBackgroundState> emit,
  ) {
    final newVal = !state.allSelected;
    emit(state.copyWith(
      allSelected: newVal,
      appsSelected: List<bool>.filled(state.runningApps.length, newVal),
    ));
  }

  // ═══════════════════════════
  // CLEANING
  // ═══════════════════════════

  Future<void> _onStartCleaning(
    StartCleaningEvent event,
    Emitter<CleanBackgroundState> emit,
  ) async {
    _cancelTimers();

    final remainingApps = <RunningAppInfo>[];
    final removedApps = <RunningAppInfo>[];

    for (int i = 0; i < state.runningApps.length; i++) {
      final isSelected = i < state.appsSelected.length && state.appsSelected[i];
      if (isSelected) {
        removedApps.add(state.runningApps[i]);
      } else {
        remainingApps.add(state.runningApps[i]);
      }
    }

    // ── REAL action: actually call killBackgroundProcesses for selected
    // apps. attemptedPackages reflects what the OS actually accepted a
    // call for — not a number we made up. ──
    List<String> attemptedPackages = [];
    try {
      final dynamic raw = await _kCleanerChannel.invokeMethod(
        'trimBackgroundApps',
        {'packageNames': removedApps.map((a) => a.packageName).toList()},
      );
      attemptedPackages = (raw as List?)?.cast<String>() ?? [];
    } catch (_) {
      attemptedPackages = [];
    }

    // Give the OS a moment to actually reclaim memory before measuring.
    await Future.delayed(const Duration(milliseconds: 600));

    // ── Real own-app temp/cache cleanup (the only cache we can actually
    // delete — other apps' cache cannot be force-cleared without root) ──
    double junkClearedMB = 0;
    try {
      final cacheDir = await _ownTempDir();
      final before = await _dirSizeBytes(cacheDir);
      await _clearDir(cacheDir);
      final after = await _dirSizeBytes(cacheDir);
      junkClearedMB =
          (before - after).clamp(0, double.maxFinite).toDouble() / (1024 * 1024);
    } catch (_) {
      junkClearedMB = 0;
    }

    // ── Real "residual files" — own app's orphaned leftover files
    // (.tmp / .log / .bak / .old) inside the app's own documents dir.
    // This is the ONLY directory we're allowed to scan+delete in; we are
    // not scanning the whole device (scoped storage forbids that). ──
    double residualClearedMB = 0;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      residualClearedMB = await _clearOrphanedFiles(docsDir);
    } catch (_) {
      residualClearedMB = 0;
    }

    // Real cache total of the apps the user selected (FOUND, not deleted —
    // we are honest that we can't force-clear other apps' cache).
    final selectedCacheBytes = removedApps
        .where((a) => a.cacheBytes > 0)
        .fold<int>(0, (sum, a) => sum + a.cacheBytes);
    final selectedCacheGB = selectedCacheBytes / _bytesToGB;

    final scanResult = state.cleanResult ?? CleanResultData.zero();

    final finalResult = CleanResultData(
      junkRemoved: _fmtMB(junkClearedMB),
      appsClosed: '${attemptedPackages.length} Apps',
      cacheCleared: _fmtGB(selectedCacheGB),
      residualFiles: _fmtMB(residualClearedMB),
      beforeGB: scanResult.beforeGB,
      afterGB: scanResult.afterGB,
      totalGB: scanResult.totalGB,
    );

    emit(state.copyWith(
      phase: CleanPhase.cleaning,
      runningApps: remainingApps,
      appsSelected: List<bool>.filled(remainingApps.length, false),
      allSelected: false,
      cleanResult: scanResult,
      cleanedApps: removedApps,
      finalCleanResult: finalResult,
    ));

    // ── Countdown animation — purely visual, counting down from the real
    // finalResult numbers to 0. No new fake data introduced here. ──
    const totalSteps = 14;
    const stepDuration = Duration(milliseconds: 80);
    final startCacheGb = selectedCacheGB;
    final startJunkMb = junkClearedMB;
    final startResidualMb = residualClearedMB;
    final startAppsCount = attemptedPackages.length;

    int step = 0;
    final completer = Completer<void>();

    _cleaningTimer = Timer.periodic(stepDuration, (timer) {
      step++;
      final remainingRatio = (1 - (step / totalSteps)).clamp(0.0, 1.0);
      final stepResult = CleanResultData(
        junkRemoved: _fmtMB(startJunkMb * remainingRatio),
        appsClosed: '${(startAppsCount * remainingRatio).round()} Apps',
        cacheCleared: _fmtGB(startCacheGb * remainingRatio),
        residualFiles: _fmtMB(startResidualMb * remainingRatio),
        beforeGB: scanResult.beforeGB,
        afterGB: scanResult.afterGB,
        totalGB: scanResult.totalGB,
      );
      if (!isClosed) add(_CleaningTickEvent(stepResult));
      if (step >= totalSteps) {
        timer.cancel();
        _cleaningTimer = null;
        if (!completer.isCompleted) completer.complete();
      }
    });

    await completer.future;
    if (isClosed) return;

    emit(state.copyWith(cleanResult: CleanResultData.zero()));
    await Future.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;

    // ── Real RAM-freed measurement (after/before delta) ──
    // Empty string = couldn't measure (honest), NOT a fabricated number.
    String ramFreedText = '';
    try {
      final ramAfterBytes = SysInfo.getFreePhysicalMemory();
      if (_ramFreeBeforeBytes != null) {
        final freedBytes = ramAfterBytes - _ramFreeBeforeBytes!;
        final freedMB = freedBytes > 0 ? freedBytes / (1024 * 1024) : 0.0;
        ramFreedText = '+${_fmtMB(freedMB)}';
      }
    } catch (_) {
      ramFreedText = '';
    }

    // ── Real battery-saved estimate (same honest pattern as
    // OptimizationBloc — empty if we can't measure it, never guessed) ──
    String batterySavedText = '';
    try {
      final dynamic raw =
          await _kDeviceInfoChannel.invokeMethod('getBatteryPowerInfo');
      final map = Map<String, dynamic>.from(raw as Map);
      _currentNowMicroAAfter = (map['currentNowMicroA'] as num?)?.toInt();

      if (_currentNowMicroABefore != null &&
          _currentNowMicroAAfter != null &&
          _batteryCapacityMAh != null &&
          _batteryCapacityMAh! > 0) {
        final beforeMicroA = _currentNowMicroABefore!.abs();
        final afterMicroA = _currentNowMicroAAfter!.abs();
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
            batterySavedText = m > 0 ? '+${h}h ${m}m' : '+${h}h';
          }
        }
      }
    } catch (_) {
      batterySavedText = '';
    }

    // Real disk space after — for the Storage Comparison card.
    double? diskFreeAfterMB;
    try {
      final diskSpace = DiskSpacePlus();
      diskFreeAfterMB = (await diskSpace.getFreeDiskSpace) ?? 0;
    } catch (_) {
      diskFreeAfterMB = null;
    }

    final updatedFinalResult = (diskFreeAfterMB != null && _diskTotalMB != null)
        ? finalResult.copyWith(
            beforeGB: _diskFreeBeforeMB != null
                ? (_diskTotalMB! - _diskFreeBeforeMB!) / 1024
                : finalResult.beforeGB,
            afterGB: (_diskTotalMB! - diskFreeAfterMB) / 1024,
            totalGB: _diskTotalMB! / 1024,
          )
        : finalResult;

    emit(state.copyWith(
      phase: CleanPhase.completed,
      // speedImproved intentionally left at default '' — no real metric
      // exists for it; the UI's own estimate fallback handles display.
      performanceData: PerformanceData(
        ramFreed: ramFreedText,
        batterySaved: batterySavedText,
      ),
      cleanedApps: removedApps,
      finalCleanResult: updatedFinalResult,
    ));
  }

  void _onCleaningTick(
    _CleaningTickEvent event,
    Emitter<CleanBackgroundState> emit,
  ) {
    emit(state.copyWith(cleanResult: event.result));
  }

  void _onCleanAgain(
    CleanAgainEvent event,
    Emitter<CleanBackgroundState> emit,
  ) {
    _cancelTimers();
    emit(CleanBackgroundState.initial());
    add(const StartScanningEvent());
  }

  // ═══════════════════════════
  // HELPERS
  // ═══════════════════════════

  Future<Directory> _ownTempDir() async {
    // Apni app ka real temp/cache directory — yahi delete karna safe aur
    // legal hai (doosri apps ka cache force-clear NAHI ho sakta).
    return await getTemporaryDirectory();
  }

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

  /// Real "preview" version: measures orphaned files' total size WITHOUT
  /// deleting anything. Used during scanning so the scan screen can show a
  /// real number; actual deletion happens later via _clearOrphanedFiles.
  Future<int> _orphanedFilesSizeBytes(Directory dir) async {
    const orphanExtensions = ['.tmp', '.log', '.bak', '.old'];
    int totalBytes = 0;
    try {
      if (dir.existsSync()) {
        await for (final e in dir.list(recursive: true, followLinks: false)) {
          if (e is File) {
            final path = e.path.toLowerCase();
            final isOrphan = orphanExtensions.any((ext) => path.endsWith(ext));
            if (isOrphan) {
              try {
                totalBytes += await e.length();
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}
    return totalBytes;
  }

  /// Real residual-files cleanup: deletes orphaned leftover files
  /// (.tmp / .log / .bak / .old) inside the app's OWN documents directory
  /// only. Returns the actual MB freed. We never scan or touch other apps'
  /// storage — scoped storage forbids that, and we don't fake the number.
  Future<double> _clearOrphanedFiles(Directory dir) async {
    const orphanExtensions = ['.tmp', '.log', '.bak', '.old'];
    int freedBytes = 0;
    try {
      if (dir.existsSync()) {
        await for (final e in dir.list(recursive: true, followLinks: false)) {
          if (e is File) {
            final path = e.path.toLowerCase();
            final isOrphan = orphanExtensions.any((ext) => path.endsWith(ext));
            if (isOrphan) {
              try {
                final size = await e.length();
                await e.delete();
                freedBytes += size;
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}
    return freedBytes / (1024 * 1024);
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

  String _fmtGB(double gb) =>
      gb >= 1 ? '${gb.toStringAsFixed(1)} GB' : '${(gb * 1024).toInt()} MB';

  void _cancelScanTimer() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  void _cancelTimers() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _cleaningTimer?.cancel();
    _cleaningTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}