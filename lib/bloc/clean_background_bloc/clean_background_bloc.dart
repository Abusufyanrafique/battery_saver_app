import 'dart:async';
import 'dart:typed_data';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_info2/system_info2.dart';

enum CleanPhase { idle, scanning, cleanReady, cleaning, completed }

// ═══════════════════════════════════
// MODELS
// ═══════════════════════════════════

class RunningAppInfo {
  final String packageName;
  final String appName;
  final String sizeFormatted;
  final Uint8List? iconBytes;

  const RunningAppInfo({
    required this.packageName,
    required this.appName,
    required this.sizeFormatted,
    this.iconBytes,
  });
}

class CleanResultData {
  final String junkRemoved;
  final String appsClosed;
  final String cacheCleared;
  final String residualFiles;
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
}

class PerformanceData {
  final String speedImproved;
  final String ramFreed;
  final String batterySaved;

  const PerformanceData({
    required this.speedImproved,
    required this.ramFreed,
    required this.batterySaved,
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
  final PerformanceData? performanceData;
  final int freeRamKbBeforeCleaning;

  // Jo apps actually clean/remove hui unki real list (summary screen ke liye)
  final List<RunningAppInfo> cleanedApps;

  final CleanResultData? finalCleanResult;

  const CleanBackgroundState({
    required this.phase,
    required this.scanProgress,
    required this.runningApps,
    required this.appsSelected,
    required this.allSelected,
    this.cleanResult,
    this.performanceData,
    this.freeRamKbBeforeCleaning = 0,
    this.cleanedApps = const [],
    this.finalCleanResult,
  });

  factory CleanBackgroundState.initial() => const CleanBackgroundState(
        phase: CleanPhase.idle,
        scanProgress: 0.0,
        runningApps: [],
        appsSelected: [],
        allSelected: false,
        cleanResult: null,
        performanceData: null,
        freeRamKbBeforeCleaning: 0,
        cleanedApps: [],
        finalCleanResult: null,
      );

  CleanBackgroundState copyWith({
    CleanPhase? phase,
    double? scanProgress,
    List<RunningAppInfo>? runningApps,
    List<bool>? appsSelected,
    bool? allSelected,
    CleanResultData? cleanResult,
    PerformanceData? performanceData,
    int? freeRamKbBeforeCleaning,
    List<RunningAppInfo>? cleanedApps,
    CleanResultData? finalCleanResult,
  }) {
    return CleanBackgroundState(
      phase: phase ?? this.phase,
      scanProgress: scanProgress ?? this.scanProgress,
      runningApps: runningApps ?? this.runningApps,
      appsSelected: appsSelected ?? this.appsSelected,
      allSelected: allSelected ?? this.allSelected,
      cleanResult: cleanResult ?? this.cleanResult,
      performanceData: performanceData ?? this.performanceData,
      freeRamKbBeforeCleaning:
          freeRamKbBeforeCleaning ?? this.freeRamKbBeforeCleaning,
      cleanedApps: cleanedApps ?? this.cleanedApps,
      finalCleanResult: finalCleanResult ?? this.finalCleanResult,
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
        performanceData,
        freeRamKbBeforeCleaning,
        cleanedApps,
        finalCleanResult,
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
  static const _channel =
      MethodChannel('com.example.battery_saver_app/device');

  // Bytes -> GB ke liye sahi divisor (1024^3)
  static const double _bytesToGB = 1024 * 1024 * 1024;

  List<RunningAppInfo> _realApps = [];
  int _totalRamBytes = 0;
  int _usedRamBytesSnap = 0;

  CleanBackgroundBloc() : super(CleanBackgroundState.initial()) {
    on<StartScanningEvent>(_onStartScanning);
    on<_ScanTickEvent>(_onScanTick);
    on<ToggleAppSelectionEvent>(_onToggleApp);
    on<ToggleSelectAllAppsEvent>(_onToggleAll);
    on<StartCleaningEvent>(_onStartCleaning);
    on<_CleaningTickEvent>(_onCleaningTick); // ✅ NEW
    on<CleanAgainEvent>(_onCleanAgain);
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
    _totalRamBytes = 0;
    _usedRamBytesSnap = 0;

    emit(CleanBackgroundState.initial().copyWith(
      phase: CleanPhase.scanning,
    ));

    try {
      _totalRamBytes = SysInfo.getTotalPhysicalMemory();
      final freeBytes = SysInfo.getFreePhysicalMemory();
      _usedRamBytesSnap = _totalRamBytes - freeBytes;
    } catch (_) {}

    try {
      final List result = await _channel.invokeMethod('getRunningApps');

      _realApps = result.map((e) {
        final map = Map<String, dynamic>.from(e);

        final sizeMb = (map['sizeMb'] as num).toDouble();
        final sizeStr = sizeMb >= 1024
            ? '${(sizeMb / 1024).toStringAsFixed(1)} GB'
            : '${sizeMb.toStringAsFixed(0)} MB';

        Uint8List? icon;
        final raw = map['iconBytes'];
        if (raw is List && raw.isNotEmpty) {
          icon = Uint8List.fromList(raw.cast<int>());
        }

        return RunningAppInfo(
          packageName: map['packageName'] ?? '',
          appName: map['appName'] ?? '',
          sizeFormatted: sizeStr,
          iconBytes: icon,
        );
      }).toList();
    } catch (_) {
      _realApps = [];
    }

    final selected = List<bool>.filled(_realApps.length, true);

    emit(state.copyWith(
      runningApps: _realApps,
      appsSelected: selected,
      allSelected: selected.isNotEmpty && selected.every((e) => e),
    ));

    _scanTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      add(const _ScanTickEvent());
    });
  }

  // ═══════════════════════════
  // SCAN TICK
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

    final totalRamGB = _totalRamBytes / _bytesToGB;
    final usedRamGB = _usedRamBytesSnap / _bytesToGB;

    final junk = (usedRamGB * progress * 0.2);
    final cache = (usedRamGB * progress * 0.15);
    final residual = (usedRamGB * progress * 0.1);

    String fmt(double gb) =>
        gb >= 1 ? '${gb.toStringAsFixed(1)} GB' : '${(gb * 1024).toInt()} MB';

    final result = CleanResultData(
      junkRemoved: fmt(junk),
      appsClosed: '${visible.length} Apps',
      cacheCleared: fmt(cache),
      residualFiles: fmt(residual),
      beforeGB: usedRamGB,
      afterGB: (usedRamGB - junk - cache).clamp(0, usedRamGB),
      totalGB: totalRamGB,
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

    if (event.index < list.length) {
      list[event.index] = !list[event.index];
    }

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
  // CLEANING — grid values animate ho ke 0 tak countdown karte hain
  // ═══════════════════════════

  Future<void> _onStartCleaning(
    StartCleaningEvent event,
    Emitter<CleanBackgroundState> emit,
  ) async {
    _cancelTimers();

    // Step 1: Selected apps ko "removed" list mein nikal lo,
    //    unselected apps ko remainingApps mein rakho.
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

    final selectedCount = removedApps.length;
    final totalScannedCount = state.runningApps.length; // cleaning shuru hone se pehle ka total
    final freedMb = selectedCount * 50;

    final scanResult = state.cleanResult ??
        CleanResultData(
          junkRemoved: '0 MB',
          appsClosed: '$selectedCount Apps',
          cacheCleared: '0 MB',
          residualFiles: '0 MB',
          beforeGB: 0,
          afterGB: 0,
          totalGB: 0,
        );

    final selectionRatio = totalScannedCount > 0
        ? (selectedCount / totalScannedCount).clamp(0.0, 1.0)
        : 0.0;

    final scanJunkGb = _parseToGB(scanResult.junkRemoved);
    final scanCacheGb = _parseToGB(scanResult.cacheCleared);
    final scanResidualGb = _parseToGB(scanResult.residualFiles);

    final finalResult = CleanResultData(
      junkRemoved: _fmtGB(scanJunkGb * selectionRatio),
      appsClosed: '$selectedCount Apps',
      cacheCleared: _fmtGB(scanCacheGb * selectionRatio),
      residualFiles: _fmtGB(scanResidualGb * selectionRatio),
      beforeGB: scanResult.beforeGB,
      afterGB: (scanResult.beforeGB -
              (scanJunkGb * selectionRatio) -
              (scanCacheGb * selectionRatio))
          .clamp(0, scanResult.beforeGB),
      totalGB: scanResult.totalGB,
    );

    final startResult = scanResult;

    // Step 3: "cleaning" phase emit karo — list khali, lekin grid abhi
    //    purani values dikhayega (countdown yahan se start hoga).
    //    finalCleanResult yahin LOCK ho jata hai — aage kabhi nahi badlega.
    emit(state.copyWith(
      phase: CleanPhase.cleaning,
      runningApps: remainingApps,
      appsSelected: List<bool>.filled(remainingApps.length, false),
      allSelected: false,
      cleanResult: startResult,
      cleanedApps: removedApps,
      finalCleanResult: finalResult,
    ));

    // Step 4: Countdown animation — startResult se 0 tak, ~14 steps
    //    (80ms * 14 ≈ 1.1s, jo overall cleaning delay ke barabar hai)
    const totalSteps = 14;
    const stepDuration = Duration(milliseconds: 80);

    final startJunkGb = _parseToGB(startResult.junkRemoved);
    final startCacheGb = _parseToGB(startResult.cacheCleared);
    final startResidualGb = _parseToGB(startResult.residualFiles);
    final startAppsCount = selectedCount; // apps count bhi 0 tak girega

    int step = 0;

    final completer = Completer<void>();

    _cleaningTimer = Timer.periodic(stepDuration, (timer) {
      step++;
      final remainingRatio = (1 - (step / totalSteps)).clamp(0.0, 1.0);

      final stepResult = CleanResultData(
        junkRemoved: _fmtGB(startJunkGb * remainingRatio),
        appsClosed: '${(startAppsCount * remainingRatio).round()} Apps',
        cacheCleared: _fmtGB(startCacheGb * remainingRatio),
        residualFiles: _fmtGB(startResidualGb * remainingRatio),
        beforeGB: startResult.beforeGB,
        afterGB: startResult.afterGB,
        totalGB: startResult.totalGB,
      );

      if (!isClosed) {
        add(_CleaningTickEvent(stepResult));
      }

      if (step >= totalSteps) {
        timer.cancel();
        _cleaningTimer = null;
        if (!completer.isCompleted) completer.complete();
      }
    });

    await completer.future;

    if (isClosed) return;

    // Step 5: Final zero state — guarantee ke sab 0 ho (rounding errors avoid)
    emit(state.copyWith(
      cleanResult: CleanResultData.zero().copyWith(
        appsClosed: '0 Apps',
      ),
    ));

    // Chota sa pause taake user "0" state dekh sake before navigation
    await Future.delayed(const Duration(milliseconds: 400));

    if (isClosed) return;

    // Step 6: "completed" emit karo — listener navigation trigger karega
    emit(state.copyWith(
      phase: CleanPhase.completed,
      performanceData: PerformanceData(
        speedImproved: '+25%',
        ramFreed: '+${(freedMb / 1024).toStringAsFixed(2)} GB',
        batterySaved: '+40m',
      ),
      cleanedApps: removedApps,
      finalCleanResult: finalResult,
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

  static double _parseToGB(String formatted) {
    final clean = formatted.trim();
    if (clean.endsWith('GB')) {
      return double.tryParse(clean.replaceAll('GB', '').trim()) ?? 0.0;
    } else if (clean.endsWith('MB')) {
      final mb = double.tryParse(clean.replaceAll('MB', '').trim()) ?? 0.0;
      return mb / 1024;
    }
    return 0.0;
  }

  static String _fmtGB(double gb) =>
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

// ✅ NEW: CleanResultData ke liye chota copyWith helper (zero() ke sath use ke liye)
extension on CleanResultData {
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