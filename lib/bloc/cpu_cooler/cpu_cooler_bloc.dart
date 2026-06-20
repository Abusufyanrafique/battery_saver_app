import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

part 'cpu_cooler_event.dart';
part 'cpu_cooler_state.dart';

const _channel = MethodChannel('com.example.battery_saver_app/cpu_info');

class CpuCoolerBloc extends Bloc<CpuCoolerEvent, CpuCoolerState> {
  Timer? _pollingTimer;
  bool _isFetching = false; // overlap guard

  CpuCoolerBloc() : super(const CpuCoolerState()) {
    on<CpuCoolerStartMonitoring>(_onStartMonitoring);
    on<CpuCoolerRefreshStats>(_onRefreshStats);
    on<CpuCoolerCoolDownRequested>(_onCoolDownRequested);
    on<CpuCoolerStopMonitoring>(_onStopMonitoring);
  }

  // ─────────────────────────────────────────────
  // Data fetch — Kotlin Thread.sleep(500) ke saath safe
  // ─────────────────────────────────────────────
  Future<void> _loadCpuData(Emitter<CpuCoolerState> emit) async {
    if (_isFetching) return; // overlap prevent karo
    _isFetching = true;

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getCpuInfo');
      final data = result ?? {};

      final cpu  = (data['cpuUsage']    as num?)?.toDouble() ?? 0.0;
      final temp = (data['temperature'] as num?)?.toDouble() ?? 0.0;
      final apps = (data['runningApps'] as num?)?.toInt()    ?? 0;

      debugPrint(' CPU: $cpu% | Temp: $temp°C | Apps: $apps');

      emit(state.copyWith(
        status:        CpuCoolerStatus.monitoring,
        cpuUsage:      cpu,
        temperature:   temp,
        runningApps:   apps,
        statusMessage: '',
      ));
    } catch (e) {
      debugPrint('❌ CPU Channel Error: $e');
      emit(state.copyWith(
        status:       CpuCoolerStatus.error,
        errorMessage: e.toString(),
      ));
    } finally {
      _isFetching = false;
    }
  }

  // ─────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────

  Future<void> _onStartMonitoring(
    CpuCoolerStartMonitoring event,
    Emitter<CpuCoolerState> emit,
  ) async {
    emit(state.copyWith(status: CpuCoolerStatus.initial));
    await _loadCpuData(emit);
    _startTimer();
  }

  Future<void> _onRefreshStats(
    CpuCoolerRefreshStats event,
    Emitter<CpuCoolerState> emit,
  ) async {
    // CoolingDown mein refresh mat karo
    if (state.status == CpuCoolerStatus.coolingDown) return;
    await _loadCpuData(emit);
  }

  Future<void> _onCoolDownRequested(
    CpuCoolerCoolDownRequested event,
    Emitter<CpuCoolerState> emit,
  ) async {
    _pollingTimer?.cancel();

    emit(state.copyWith(
      status:        CpuCoolerStatus.coolingDown,
      statusMessage: 'Cooling down...',
    ));

    try {
      await _channel.invokeMethod('coolDown');
    } catch (e) {
      debugPrint('coolDown error: $e');
    }

    // Thoda wait karo taake kill effect ho sake
    await Future.delayed(const Duration(seconds: 2));

    // Fresh data lo
    await _loadCpuData(emit);

    emit(state.copyWith(
      status:        CpuCoolerStatus.cooled,
      statusMessage: 'System cooled!',
    ));

    // 2 sec baad monitoring resume karo
    await Future.delayed(const Duration(seconds: 2));
    _startTimer();
  }

  void _onStopMonitoring(
    CpuCoolerStopMonitoring event,
    Emitter<CpuCoolerState> emit,
  ) {
    _pollingTimer?.cancel();
    _isFetching = false;
  }

  // ─────────────────────────────────────────────
  // TIMER — 5 seconds (Kotlin 500ms sleep + processing time)
  // ─────────────────────────────────────────────
  void _startTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5), // 3 se 5 kiya — overlap avoid
      (_) => add(const CpuCoolerRefreshStats()),
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}