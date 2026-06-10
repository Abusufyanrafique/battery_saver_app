import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'temperature_event.dart';
part 'temperature_state.dart';

class TemperatureBloc extends Bloc<TemperatureEvent, TemperatureState> {
  static const _cpuChannel =
      MethodChannel('com.example.battery_saver_app/cpu_info');

  TemperatureBloc() : super(const TemperatureState()) {
    on<TemperatureStarted>(_onStarted);
    on<TemperatureAutoCoolToggled>(_onAutoCoolToggled);
    on<TemperatureCpuCoolerToggled>(_onCpuCoolerToggled);
    on<TemperatureCoolDownStarted>(_onCoolDownStarted);
    on<TemperatureCoolDownCancelled>(_onCoolDownCancelled);
    on<_TemperatureStepOneCompleted>(_onStepOneCompleted);
    on<_TemperatureStepTwoCompleted>(_onStepTwoCompleted);
    on<_TemperatureStepThreeCompleted>(_onStepThreeCompleted);
  }

  // ── Initial temp fetch ───────────────────────────────────────
  Future<void> _onStarted(
    TemperatureStarted event,
    Emitter<TemperatureState> emit,
  ) async {
    try {
      print('🌡️ TemperatureBloc: Fetching real CPU info...');
      final Map<String, dynamic> cpuMap = await _fetchCpuInfo();
      print('📊 CPU Map: $cpuMap');

      final double tempCelsius =
          (cpuMap['temperature'] as num?)?.toDouble() ?? 32.0;
      final double cpuUsage =
          (cpuMap['cpuUsage'] as num?)?.toDouble() ?? 0.0;
      final int runningApps =
          (cpuMap['runningApps'] as num?)?.toInt() ?? 0;

      emit(state.copyWith(
        tempCelsius: tempCelsius,
        tempValue: _normalize(tempCelsius),
        cpuUsage: cpuUsage,
        runningApps: runningApps,
        isLoading: false,
      ));
      print('✅ Temp loaded: ${tempCelsius}°C | CPU: $cpuUsage% | Apps: $runningApps');
    } on PlatformException catch (e) {
      print('❌ PlatformException in _onStarted: ${e.message}');
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print('❌ Unknown error in _onStarted: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  // ── Cool Down: 3 real sequential steps ───────────────────────
  Future<void> _onCoolDownStarted(
    TemperatureCoolDownStarted event,
    Emitter<TemperatureState> emit,
  ) async {
    if (state.coolingStatus == CoolingStatus.scanning) return;

    emit(state.copyWith(
      coolingStatus: CoolingStatus.scanning,
      completedSteps: 0,
      isCancelled: false,
    ));

    // ── STEP 1: Scan Temperature ──────────────────────────────
    try {
      print('🔍 Step 1: Scanning temperature...');
      final Map<String, dynamic> cpuMap = await _fetchCpuInfo();

      if (state.isCancelled) return;

      final double tempCelsius =
          (cpuMap['temperature'] as num?)?.toDouble() ?? state.tempCelsius;
      final double cpuUsage =
          (cpuMap['cpuUsage'] as num?)?.toDouble() ?? state.cpuUsage;
      final int runningApps =
          (cpuMap['runningApps'] as num?)?.toInt() ?? state.runningApps;

      emit(state.copyWith(
        completedSteps: 1,
        tempCelsius: tempCelsius,
        tempValue: _normalize(tempCelsius),
        cpuUsage: cpuUsage,
        runningApps: runningApps,
      ));
      print('✅ Step 1 done: ${tempCelsius}°C | ${runningApps} apps running');
    } catch (e) {
      print('⚠️ Step 1 error (non-fatal): $e');
      if (state.isCancelled) return;
      emit(state.copyWith(completedSteps: 1));
    }

    // ── STEP 2: Kill Background Apps ──────────────────────────
    try {
      print('🔧 Step 2: Killing background apps...');
      await _cpuChannel.invokeMethod('coolDown');

      if (state.isCancelled) return;

      emit(state.copyWith(completedSteps: 2));
      print('✅ Step 2 done: Background apps killed');
    } catch (e) {
      print('⚠️ Step 2 error (non-fatal): $e');
      if (state.isCancelled) return;
      emit(state.copyWith(completedSteps: 2));
    }

    // ── Wait: CPU ko settle hone do apps kill ke baad ─────────
    // Android ko 6-8 seconds lagte hain CPU load kam karne mein
    print('⏳ Waiting 7s for CPU to settle...');
    await Future.delayed(const Duration(seconds: 7));

    if (state.isCancelled) return;

    // ── STEP 3: Re-measure Cooled Temperature ─────────────────
    try {
      print('🌡️ Step 3: Re-measuring temperature...');
      final Map<String, dynamic> cpuMap = await _fetchCpuInfo();

      if (state.isCancelled) return;

      final double cooledTemp =
          (cpuMap['temperature'] as num?)?.toDouble() ?? state.tempCelsius;
      final double cooledCpuUsage =
          (cpuMap['cpuUsage'] as num?)?.toDouble() ?? state.cpuUsage;
      final int cooledRunningApps =
          (cpuMap['runningApps'] as num?)?.toInt() ?? state.runningApps;

      emit(state.copyWith(
        completedSteps: 3,
        coolingStatus: CoolingStatus.done,
        tempCelsius: cooledTemp,
        tempValue: _normalize(cooledTemp),
        cpuUsage: cooledCpuUsage,
        runningApps: cooledRunningApps,
      ));
      print('✅ Step 3 done — Cooled temp: ${cooledTemp}°C | Apps: $cooledRunningApps');
    } catch (e) {
      print('⚠️ Step 3 error: $e');
      if (state.isCancelled) return;
      emit(state.copyWith(
        completedSteps: 3,
        coolingStatus: CoolingStatus.done,
      ));
    }
  }

  void _onCoolDownCancelled(
    TemperatureCoolDownCancelled event,
    Emitter<TemperatureState> emit,
  ) {
    print('🚫 CoolDown cancelled');
    emit(state.copyWith(
      coolingStatus: CoolingStatus.cancelled,
      completedSteps: 0,
      isCancelled: true,
    ));
  }

  void _onAutoCoolToggled(
    TemperatureAutoCoolToggled event,
    Emitter<TemperatureState> emit,
  ) => emit(state.copyWith(autoCool: event.value));

  void _onCpuCoolerToggled(
    TemperatureCpuCoolerToggled event,
    Emitter<TemperatureState> emit,
  ) => emit(state.copyWith(cpuCooler: event.value));

  void _onStepOneCompleted(_TemperatureStepOneCompleted e, Emitter<TemperatureState> emit) {}
  void _onStepTwoCompleted(_TemperatureStepTwoCompleted e, Emitter<TemperatureState> emit) {}
  void _onStepThreeCompleted(_TemperatureStepThreeCompleted e, Emitter<TemperatureState> emit) {}

  // ── Helpers ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchCpuInfo() async {
    final dynamic raw = await _cpuChannel.invokeMethod('getCpuInfo');
    return Map<String, dynamic>.from(raw as Map);
  }

  /// 20°C = cool end, 60°C = hot end → 0.0–1.0
  double _normalize(double celsius) => ((celsius - 20) / 40).clamp(0.0, 1.0);
}