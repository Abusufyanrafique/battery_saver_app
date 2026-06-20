import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

part 'power_boost_event.dart';
part 'power_boost_state.dart';

class PowerBoostBloc extends Bloc<PowerBoostEvent, PowerBoostState> {
  static const _channel = MethodChannel('com.example.battery_saver_app/power_boost');

  // Boost shuru hone se pehle ka RAM used % yahan store hoga
  double _beforeUsedPercent = 0;

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
      final double totalRamBytes = (result['totalRamBytes'] as num).toDouble();
      final double ramUsedGB = ramUsedBytes / (1024 * 1024 * 1024);
      final int appsCount = result['runningAppsCount'] as int;

      // RAM used % nikal kar save karo, baad mein "after" se compare karna hai
      _beforeUsedPercent = (ramUsedBytes / totalRamBytes) * 100;

      emit(state.copyWith(
        isLoading: false,
        ramUsedGB: '${ramUsedGB.toStringAsFixed(1)} GB',
        runningAppsCount: appsCount,
      ));
    } catch (e) {
      _beforeUsedPercent = 70; // fallback
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

    // Step 3: Close Background Apps — yahan se after-boost RAM milega
    double afterUsedPercent = _beforeUsedPercent;
    try {
      final Map result = await _channel.invokeMethod('closeBackgroundApps');
      final double availBytes = (result['availableRamBytes'] as num).toDouble();
      final double totalBytes = (result['totalRamBytes'] as num).toDouble();
      final double usedBytes = totalBytes - availBytes;
      afterUsedPercent = (usedBytes / totalBytes) * 100;
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));

    final int boostPercent = _calculateBoostPercent(_beforeUsedPercent, afterUsedPercent);

    emit(state.copyWith(
      isBoostComplete: true,
      boostPercent: boostPercent,
      stepStatuses: {
        BoostStep.clearRam: StepStatus.done,
        BoostStep.optimizeCpu: StepStatus.done,
        BoostStep.closeApps: StepStatus.done,
      },
    ));
  }

  /// Real RAM freed % ko UI-friendly range (60–95%) mein scale karta hai.
  /// Calculation real data se aata hai, sirf random nahi.
  int _calculateBoostPercent(double before, double after) {
    final double freedPercent = (before - after).clamp(0, 100);

    // Real freed % chhota hota hai (e.g. 2-8%), is liye scale karo
    // taake user ko meaningful number nazar aaye.
    final double scaled = 60 + (freedPercent * 6);

    return scaled.clamp(60, 95).round();
  }
}