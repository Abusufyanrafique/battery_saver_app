part of 'power_boost_bloc.dart';

enum BoostStep { clearRam, optimizeCpu, closeApps }

enum StepStatus { pending, inProgress, done }

class PowerBoostState {
  final String ramUsedGB;         // e.g. "1.2 GB"
  final int runningAppsCount;     // e.g. 12
  final bool isLoading;
  final bool isBoostStarted;
  final bool isBoostComplete;
  final Map<BoostStep, StepStatus> stepStatuses;

  const PowerBoostState({
    this.ramUsedGB = '— GB',
    this.runningAppsCount = 0,
    this.isLoading = false,
    this.isBoostStarted = false,
    this.isBoostComplete = false,
    this.stepStatuses = const {
      BoostStep.clearRam: StepStatus.pending,
      BoostStep.optimizeCpu: StepStatus.pending,
      BoostStep.closeApps: StepStatus.pending,
    },
  });

  PowerBoostState copyWith({
    String? ramUsedGB,
    int? runningAppsCount,
    bool? isLoading,
    bool? isBoostStarted,
    bool? isBoostComplete,
    Map<BoostStep, StepStatus>? stepStatuses,
  }) {
    return PowerBoostState(
      ramUsedGB: ramUsedGB ?? this.ramUsedGB,
      runningAppsCount: runningAppsCount ?? this.runningAppsCount,
      isLoading: isLoading ?? this.isLoading,
      isBoostStarted: isBoostStarted ?? this.isBoostStarted,
      isBoostComplete: isBoostComplete ?? this.isBoostComplete,
      stepStatuses: stepStatuses ?? this.stepStatuses,
    );
  }
}