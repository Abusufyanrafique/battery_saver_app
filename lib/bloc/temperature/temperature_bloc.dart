import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'temperature_event.dart';
part 'temperature_state.dart';

class TemperatureBloc extends Bloc<TemperatureEvent, TemperatureState> {
  Timer? _scanTimer;
  static const int _totalSteps = 3;

  // ── Native Channels ──────────────────────────────────────────
  static const _cpuChannel =
      MethodChannel('com.example.battery_saver_app/cpu_info');
  static const _boostChannel =
      MethodChannel('com.example.battery_saver_app/phone_boost');

  TemperatureBloc() : super(const TemperatureState()) {
    on<TemperatureStarted>(_onStarted);
    on<TemperatureAutoCoolToggled>(_onAutoCoolToggled);
    on<TemperatureCpuCoolerToggled>(_onCpuCoolerToggled);
    on<TemperatureCoolDownStarted>(_onCoolDownStarted);
    on<TemperatureScanStepCompleted>(_onScanStepCompleted);
    on<TemperatureCoolDownCancelled>(_onCoolDownCancelled);
  }

  // ── Real Native Data ─────────────────────────────────────────
  Future<void> _onStarted(
    TemperatureStarted event,
    Emitter<TemperatureState> emit,
  ) async {
    try {
      print('🌡️ TemperatureBloc: Fetching real CPU info...');

      // cpu_info channel → getCpuInfo
      // Returns: { cpuUsage: double, temperature: double, runningApps: int }
      final dynamic raw = await _cpuChannel.invokeMethod('getCpuInfo');
      final Map<String, dynamic> cpuMap = Map<String, dynamic>.from(raw as Map);

      print('📊 CPU Map: $cpuMap');

      final double tempCelsius =
          (cpuMap['temperature'] as num?)?.toDouble() ?? 32.0;

      // 20°C = cool, 60°C = very hot — normalize to 0.0–1.0
      final double normalized = ((tempCelsius - 20) / 40).clamp(0.0, 1.0);

      emit(state.copyWith(
        tempCelsius: tempCelsius,
        tempValue: normalized,
        isLoading: false,
      ));

      print('✅ Real temp loaded: ${tempCelsius}°C (normalized: $normalized)');
    } on PlatformException catch (e) {
      print('❌ PlatformException in TemperatureBloc: ${e.message}');
      // Fallback: state mein jo default hai woh raho
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print('❌ Unknown error in TemperatureBloc: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onAutoCoolToggled(
    TemperatureAutoCoolToggled event,
    Emitter<TemperatureState> emit,
  ) {
    emit(state.copyWith(autoCool: event.value));
  }

  void _onCpuCoolerToggled(
    TemperatureCpuCoolerToggled event,
    Emitter<TemperatureState> emit,
  ) {
    emit(state.copyWith(cpuCooler: event.value));
  }

  // ── Cool Down: background apps kill + re-measure temp ────────
  void _onCoolDownStarted(
    TemperatureCoolDownStarted event,
    Emitter<TemperatureState> emit,
  ) {
    emit(state.copyWith(
      coolingStatus: CoolingStatus.scanning,
      completedSteps: 0,
    ));

    _scanTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(TemperatureScanStepCompleted());
    });
  }

  Future<void> _onScanStepCompleted(
    TemperatureScanStepCompleted event,
    Emitter<TemperatureState> emit,
  ) async {
    final nextStep = state.completedSteps + 1;

    if (nextStep >= _totalSteps) {
      _scanTimer?.cancel();

      // Step 3 complete: CPU coolDown call karo (background apps kill)
      try {
        await _cpuChannel.invokeMethod('coolDown');
        print('✅ coolDown method called — background apps killed');
      } catch (e) {
        print('⚠️ coolDown error (non-fatal): $e');
      }

      // Real temp dobara fetch karo cooling ke baad
      double cooledTemp = state.tempCelsius;
      try {
        final dynamic raw = await _cpuChannel.invokeMethod('getCpuInfo');
        final Map<String, dynamic> cpuMap =
            Map<String, dynamic>.from(raw as Map);
        cooledTemp = (cpuMap['temperature'] as num?)?.toDouble() ??
            (state.tempCelsius - 2).clamp(20.0, 60.0);
        print('🌡️ Post-cool temp: ${cooledTemp}°C');
      } catch (e) {
        // Fallback: thoda kam kar do
        cooledTemp = (state.tempCelsius - 2).clamp(20.0, 60.0);
      }

      final double cooledValue = ((cooledTemp - 20) / 40).clamp(0.0, 1.0);

      emit(state.copyWith(
        completedSteps: _totalSteps,
        coolingStatus: CoolingStatus.done,
        tempCelsius: cooledTemp,
        tempValue: cooledValue,
      ));
    } else {
      emit(state.copyWith(completedSteps: nextStep));
    }
  }

  void _onCoolDownCancelled(
    TemperatureCoolDownCancelled event,
    Emitter<TemperatureState> emit,
  ) {
    _scanTimer?.cancel();
    emit(state.copyWith(
      coolingStatus: CoolingStatus.cancelled,
      completedSteps: 0,
    ));
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    return super.close();
  }
}