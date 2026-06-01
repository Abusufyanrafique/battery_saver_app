import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

part 'cpu_cooler_event.dart';
part 'cpu_cooler_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Method Channel — name must match MainActivity.kt exactly
// ─────────────────────────────────────────────────────────────────────────────
const _channel = MethodChannel('com.example.battery_saver_app/cpu_info');

Future<Map<String, dynamic>> _fetchRealData() async {
  try {
    final result =
        await _channel.invokeMapMethod<String, dynamic>('getCpuInfo');
    return result ?? {};
  } on PlatformException catch (e) {
    debugPrint('❌ MethodChannel error: ${e.message}');
    return {};
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────────────────────────────────────────
class CpuCoolerBloc extends Bloc<CpuCoolerEvent, CpuCoolerState> {
  Timer? _pollingTimer;

  CpuCoolerBloc() : super(const CpuCoolerState()) {
    on<CpuCoolerStartMonitoring>(_onStartMonitoring);
    on<CpuCoolerRefreshStats>(_onRefreshStats);
    on<CpuCoolerCoolDownRequested>(_onCoolDownRequested);
    on<CpuCoolerStopMonitoring>(_onStopMonitoring);
  }

  Future<void> _onStartMonitoring(
    CpuCoolerStartMonitoring event,
    Emitter<CpuCoolerState> emit,
  ) async {
    await _fetchAndEmit(emit, status: CpuCoolerStatus.monitoring);
    _startTimer();
  }

  Future<void> _onRefreshStats(
    CpuCoolerRefreshStats event,
    Emitter<CpuCoolerState> emit,
  ) async {
    if (state.status == CpuCoolerStatus.coolingDown) return;
    await _fetchAndEmit(emit, status: CpuCoolerStatus.monitoring);
  }

  Future<void> _onCoolDownRequested(
    CpuCoolerCoolDownRequested event,
    Emitter<CpuCoolerState> emit,
  ) async {
    _pollingTimer?.cancel();

    emit(state.copyWith(
      status: CpuCoolerStatus.coolingDown,
      statusMessage: 'Cooling down...',
    ));

    // Tell native side to run ActivityManager.killBackgroundProcesses
    try {
      await _channel.invokeMethod('coolDown');
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 3));

    await _fetchAndEmit(
      emit,
      status: CpuCoolerStatus.cooled,
      statusMessage: 'System cooled!',
    );

    _startTimer();
  }

  void _onStopMonitoring(
    CpuCoolerStopMonitoring event,
    Emitter<CpuCoolerState> emit,
  ) {
    _pollingTimer?.cancel();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _startTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      add(const CpuCoolerRefreshStats());
    });
  }

  Future<void> _fetchAndEmit(
    Emitter<CpuCoolerState> emit, {
    required CpuCoolerStatus status,
    String? statusMessage,
  }) async {
    try {
      final data = await _fetchRealData();

      final cpu  = (data['cpuUsage']    as num?)?.toDouble() ?? 0.0;
      final temp = (data['temperature'] as num?)?.toDouble() ?? 0.0;
      //  cast safely — native may return Int or Long
      final apps = (data['runningApps'] as num?)?.toInt()   ?? 0;

      emit(state.copyWith(
        status: status,
        cpuUsage: cpu,
        temperature: temp,
        runningApps: apps,
        statusMessage: statusMessage ??
            (temp > 60 ? 'CPU is running hot!' : 'Monitoring...'),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CpuCoolerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}