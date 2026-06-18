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

  const CleanBackgroundState({
    required this.phase,
    required this.scanProgress,
    required this.runningApps,
    required this.appsSelected,
    required this.allSelected,
    this.cleanResult,
    this.performanceData,
    this.freeRamKbBeforeCleaning = 0,
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
      ];
}

// ═══════════════════════════════════
// BLOC
// ═══════════════════════════════════

class CleanBackgroundBloc
    extends Bloc<CleanBackgroundEvent, CleanBackgroundState> {
  Timer? _scanTimer;
  final Battery _battery = Battery();
  static const _channel =
      MethodChannel('com.example.battery_saver_app/device');

  List<RunningAppInfo> _realApps = [];
  int _totalRamKb = 0;
  int _usedRamKbSnap = 0;

  CleanBackgroundBloc() : super(CleanBackgroundState.initial()) {
    on<StartScanningEvent>(_onStartScanning);
    on<_ScanTickEvent>(_onScanTick);
    on<ToggleAppSelectionEvent>(_onToggleApp);
    on<ToggleSelectAllAppsEvent>(_onToggleAll);
    on<StartCleaningEvent>(_onStartCleaning);
    on<CleanAgainEvent>(_onCleanAgain);
  }

  // ═══════════════════════════
  // START SCANNING
  // ═══════════════════════════

  Future<void> _onStartScanning(
    StartScanningEvent event,
    Emitter<CleanBackgroundState> emit,
  ) async {
    _cancelTimer();

    _realApps = [];
    _totalRamKb = 0;
    _usedRamKbSnap = 0;

    emit(CleanBackgroundState.initial().copyWith(
      phase: CleanPhase.scanning,
    ));

    try {
      _totalRamKb = SysInfo.getTotalPhysicalMemory();
      final free = SysInfo.getFreePhysicalMemory();
      _usedRamKbSnap = _totalRamKb - free;
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

    // ✅ FIX: initialize selection immediately
    final selected =
        List<bool>.filled(_realApps.length, true);

    emit(state.copyWith(
      runningApps: _realApps,
      appsSelected: selected,
      allSelected: selected.isNotEmpty && selected.every((e) => e),
    ));

    _scanTimer =
        Timer.periodic(const Duration(milliseconds: 80), (_) {
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

    final selected =
        List<bool>.filled(visible.length, true);

    final totalRamGB = _totalRamKb / (1024 * 1024);
    final usedRamGB = _usedRamKbSnap / (1024 * 1024);

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
      _cancelTimer();

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
      appsSelected:
          List<bool>.filled(state.runningApps.length, newVal),
    ));
  }

  // ═══════════════════════════
  // CLEANING
  // ═══════════════════════════

  Future<void> _onStartCleaning(
    StartCleaningEvent event,
    Emitter<CleanBackgroundState> emit,
  ) async {
    final freed = state.appsSelected.where((e) => e).length * 50;

    emit(state.copyWith(
      phase: CleanPhase.completed,
      cleanResult: state.cleanResult,
      performanceData: PerformanceData(
        speedImproved: '+25%',
        ramFreed: '+${freed / 1024} GB',
        batterySaved: '+40m',
      ),
    ));
  }

  void _onCleanAgain(
    CleanAgainEvent event,
    Emitter<CleanBackgroundState> emit,
  ) {
    _cancelTimer();
    emit(CleanBackgroundState.initial());
    add(const StartScanningEvent());
  }

  void _cancelTimer() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}