import 'dart:async';
import 'dart:ui';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/widgets/temperature_control/result_temperature_screen_widget.dart';

part 'temperature_event.dart';
part 'temperature_state.dart';

class TemperatureBloc extends Bloc<TemperatureEvent, TemperatureState> {
  Timer? _scanTimer;
  static const int _totalSteps = 3;

  TemperatureBloc() : super(const TemperatureState()) {
    on<TemperatureStarted>(_onStarted);
    on<TemperatureAutoCoolToggled>(_onAutoCoolToggled);
    on<TemperatureCpuCoolerToggled>(_onCpuCoolerToggled);
    on<TemperatureCoolDownStarted>(_onCoolDownStarted);
    on<TemperatureScanStepCompleted>(_onScanStepCompleted);
    on<TemperatureCoolDownCancelled>(_onCoolDownCancelled);
  }

  Future<void> _onStarted(
    TemperatureStarted event,
    Emitter<TemperatureState> emit,
  ) async {
    try {
      final androidInfo = await BatteryInfoPlugin().androidBatteryInfo;
      final double? rawTemp = androidInfo?.temperature?.toDouble();
      if (rawTemp != null) {
        final double normalized = ((rawTemp - 20) / 40).clamp(0.0, 1.0);
        emit(state.copyWith(tempCelsius: rawTemp, tempValue: normalized));
      }
    } catch (_) {}
  }

  void _onAutoCoolToggled(
    TemperatureAutoCoolToggled event,
    Emitter<TemperatureState> emit,
  ) => emit(state.copyWith(autoCool: event.value));

  void _onCpuCoolerToggled(
    TemperatureCpuCoolerToggled event,
    Emitter<TemperatureState> emit,
  ) => emit(state.copyWith(cpuCooler: event.value));

  void _onCoolDownStarted(
    TemperatureCoolDownStarted event,
    Emitter<TemperatureState> emit,
  ) {
    emit(state.copyWith(coolingStatus: CoolingStatus.scanning, completedSteps: 0));
    _scanTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(TemperatureScanStepCompleted());
    });
  }

  void _onScanStepCompleted(
    TemperatureScanStepCompleted event,
    Emitter<TemperatureState> emit,
  ) {
    final nextStep = state.completedSteps + 1;
    if (nextStep >= _totalSteps) {
      _scanTimer?.cancel();
      final cooledTemp = (state.tempCelsius - 4).clamp(20.0, 60.0);
      final cooledValue = ((cooledTemp - 20) / 40).clamp(0.0, 1.0);
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
    emit(state.copyWith(coolingStatus: CoolingStatus.cancelled, completedSteps: 0));
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    return super.close();
  }
}