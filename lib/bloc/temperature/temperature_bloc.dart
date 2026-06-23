import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'temperature_event.dart';
part 'temperature_state.dart';

class TemperatureBloc extends Bloc<TemperatureEvent, TemperatureState> {
  static const _cpuChannel =
      MethodChannel('com.example.battery_saver_app/cpu_info');
  static const _autoCoolChannel =
      MethodChannel('com.example.battery_saver_app/auto_cool'); 

  TemperatureBloc() : super(const TemperatureState()) {
    on<TemperatureStarted>(_onStarted);
    on<TemperatureAutoCoolToggled>(_onAutoCoolToggled);
    on<TemperatureCpuCoolerToggled>(_onCpuCoolerToggled);
    on<TemperatureCoolDownStarted>(_onCoolDownStarted);
    on<TemperatureCoolDownCancelled>(_onCoolDownCancelled);
    // ── NEW handlers ──────────────────────────────────────────
    on<TemperatureAutoCoolServiceStarted>(_onAutoCoolServiceStarted);
    on<TemperatureAutoCoolServiceStopped>(_onAutoCoolServiceStopped);
    on<TemperatureCpuCoolerKillTriggered>(_onCpuCoolerKillTriggered);
    // ── Internal ──────────────────────────────────────────────
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
      print(' TemperatureBloc: Fetching real CPU info...');
      final Map<String, dynamic> cpuMap = await _fetchCpuInfo();
      print(' CPU Map: $cpuMap');

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
    } on PlatformException catch (e) {
      print(' PlatformException in _onStarted: ${e.message}');
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print(' Unknown error in _onStarted: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  // ── Auto Cool Toggle → Service Start/Stop ───────────────────
  Future<void> _onAutoCoolServiceStarted(
    TemperatureAutoCoolServiceStarted event,
    Emitter<TemperatureState> emit,
  ) async {
    try {
      print(' Starting AutoCool background service...');
      await _autoCoolChannel.invokeMethod('startAutoCool');
      emit(state.copyWith(
        autoCool: true,
        autoCoolServiceRunning: true,
        serviceError: null,
      ));
      print(' AutoCool service started');
    } on PlatformException catch (e) {
      print(' AutoCool start failed: ${e.message}');
      emit(state.copyWith(
        autoCool: false,
        autoCoolServiceRunning: false,
        serviceError: e.message,
      ));
    }
  }

  Future<void> _onAutoCoolServiceStopped(
    TemperatureAutoCoolServiceStopped event,
    Emitter<TemperatureState> emit,
  ) async {
    try {
      print(' Stopping AutoCool background service...');
      await _autoCoolChannel.invokeMethod('stopAutoCool');
      emit(state.copyWith(
        autoCool: false,
        autoCoolServiceRunning: false,
        serviceError: null,
      ));
      print(' AutoCool service stopped');
    } on PlatformException catch (e) {
      print(' AutoCool stop failed: ${e.message}');
      emit(state.copyWith(serviceError: e.message));
    }
  }

  // ── CPU Cooler Toggle → Immediate Kill ──────────────────────
  Future<void> _onCpuCoolerKillTriggered(
    TemperatureCpuCoolerKillTriggered event,
    Emitter<TemperatureState> emit,
  ) async {
    try {

      // kill heavys apps ============================================================================
      
      print(' CPU Cooler: Killing heavy apps...');
      await _autoCoolChannel.invokeMethod('killHeavyApps');
      emit(state.copyWith(
        cpuCooler: true,
        serviceError: null,
      ));
      print(' Heavy apps killed via CPU Cooler');
    } on PlatformException catch (e) {
      print(' killHeavyApps failed: ${e.message}');
      emit(state.copyWith(serviceError: e.message));
    }
  }

  // ── Auto Cool Toggle (UI toggle handler) ────────────────────
  void _onAutoCoolToggled(
    TemperatureAutoCoolToggled event,
    Emitter<TemperatureState> emit,
  ) {
    // Service start/stop event trigger karo
    if (event.value) {
      add(TemperatureAutoCoolServiceStarted());
    } else {
      add(TemperatureAutoCoolServiceStopped());
    }
  }

  // ── CPU Cooler Toggle (UI toggle handler) ───────────────────
  void _onCpuCoolerToggled(
    TemperatureCpuCoolerToggled event,
    Emitter<TemperatureState> emit,
  ) {
    emit(state.copyWith(cpuCooler: event.value));
    if (event.value) {
      add(TemperatureCpuCoolerKillTriggered()); // ON hote hi kill
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

    // STEP 1: Scan Temperature
    try {
      print(' Step 1: Scanning temperature...');
      final Map<String, dynamic> cpuMap = await _fetchCpuInfo();
      if (state.isCancelled) return;

      emit(state.copyWith(
        completedSteps: 1,
        tempCelsius: (cpuMap['temperature'] as num?)?.toDouble() ?? state.tempCelsius,
        tempValue: _normalize((cpuMap['temperature'] as num?)?.toDouble() ?? state.tempCelsius),
        cpuUsage: (cpuMap['cpuUsage'] as num?)?.toDouble() ?? state.cpuUsage,
        runningApps: (cpuMap['runningApps'] as num?)?.toInt() ?? state.runningApps,
      ));
      print(' Step 1 done');
    } catch (e) {
      if (state.isCancelled) return;
      emit(state.copyWith(completedSteps: 1));
    }

    // STEP 2: Kill Background Apps
    try {
      print(' Step 2: Killing background apps...');
      await _autoCoolChannel.invokeMethod('killHeavyApps'); 
      if (state.isCancelled) return;
      emit(state.copyWith(completedSteps: 2));
      print(' Step 2 done');
    } catch (e) {
      if (state.isCancelled) return;
      emit(state.copyWith(completedSteps: 2));
    }

    // Wait for CPU to settle
    print(' Waiting 7s for CPU to settle...');
    await Future.delayed(const Duration(seconds: 7));
    if (state.isCancelled) return;

    // STEP 3: Re-measure
    try {
      print('Step 3: Re-measuring temperature...');
      final Map<String, dynamic> cpuMap = await _fetchCpuInfo();
      if (state.isCancelled) return;

      emit(state.copyWith(
        completedSteps: 3,
        coolingStatus: CoolingStatus.done,
        tempCelsius: (cpuMap['temperature'] as num?)?.toDouble() ?? state.tempCelsius,
        tempValue: _normalize((cpuMap['temperature'] as num?)?.toDouble() ?? state.tempCelsius),
        cpuUsage: (cpuMap['cpuUsage'] as num?)?.toDouble() ?? state.cpuUsage,
        runningApps: (cpuMap['runningApps'] as num?)?.toInt() ?? state.runningApps,
      ));
      print(' Step 3 done');
    } catch (e) {
      if (state.isCancelled) return;
      emit(state.copyWith(completedSteps: 3, coolingStatus: CoolingStatus.done));
    }
  }

  void _onCoolDownCancelled(
    TemperatureCoolDownCancelled event,
    Emitter<TemperatureState> emit,
  ) {
    print(' CoolDown cancelled');
    emit(state.copyWith(
      coolingStatus: CoolingStatus.cancelled,
      completedSteps: 0,
      isCancelled: true,
    ));
  }

  void _onStepOneCompleted(_TemperatureStepOneCompleted e, Emitter<TemperatureState> emit) {}
  void _onStepTwoCompleted(_TemperatureStepTwoCompleted e, Emitter<TemperatureState> emit) {}
  void _onStepThreeCompleted(_TemperatureStepThreeCompleted e, Emitter<TemperatureState> emit) {}

  // ── Helpers ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchCpuInfo() async {
    final dynamic raw = await _cpuChannel.invokeMethod('getCpuInfo');
    return Map<String, dynamic>.from(raw as Map);
  }

  double _normalize(double celsius) => ((celsius - 20) / 40).clamp(0.0, 1.0);
}