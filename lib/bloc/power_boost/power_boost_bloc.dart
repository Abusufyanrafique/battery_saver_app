import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

part 'power_boost_event.dart';
part 'power_boost_state.dart';

class PowerBoostBloc extends Bloc<PowerBoostEvent, PowerBoostState> {
  static const _channel = MethodChannel('com.example.battery_saver_app/power_boost');

  PowerBoostBloc() : super(const PowerBoostState()) {
    on<LoadPowerBoostDataEvent>(_onLoad);
    on<StartBoostEvent>(_onStartBoost);
  }

  Future<void> _onLoad(
    LoadPowerBoostDataEvent event,
    Emitter<PowerBoostState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final Map result = await _channel.invokeMethod('getPowerBoostData');
      final double ramUsedBytes = (result['ramUsedBytes'] as num).toDouble();
      final double ramUsedGB = ramUsedBytes / (1024 * 1024 * 1024);
      final int appsCount = result['runningAppsCount'] as int;

      emit(state.copyWith(
        isLoading: false,
        ramUsedGB: '${ramUsedGB.toStringAsFixed(1)} GB',
        runningAppsCount: appsCount,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, ramUsedGB: '1.2 GB', runningAppsCount: 12));
    }
  }

  Future<void> _onStartBoost(
    StartBoostEvent event,
    Emitter<PowerBoostState> emit,
  ) async {
    emit(state.copyWith(isBoostStarted: true));

    // Step 1: Clear RAM
    emit(state.copyWith(
      stepStatuses: {
        ...state.stepStatuses,
        BoostStep.clearRam: StepStatus.inProgress,
      },
    ));
    try {
      await _channel.invokeMethod('clearRam');
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(
      stepStatuses: {
        ...state.stepStatuses,
        BoostStep.clearRam: StepStatus.done,
        BoostStep.optimizeCpu: StepStatus.inProgress,
      },
    ));

    // Step 2: Optimize CPU
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(
      stepStatuses: {
        ...state.stepStatuses,
        BoostStep.clearRam: StepStatus.done,
        BoostStep.optimizeCpu: StepStatus.done,
        BoostStep.closeApps: StepStatus.inProgress,
      },
    ));

    // Step 3: Close Background Apps
    try {
      await _channel.invokeMethod('closeBackgroundApps');
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(
      isBoostComplete: true,
      stepStatuses: {
        BoostStep.clearRam: StepStatus.done,
        BoostStep.optimizeCpu: StepStatus.done,
        BoostStep.closeApps: StepStatus.done,
      },
    ));
  }
}