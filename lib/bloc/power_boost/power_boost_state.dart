part of 'power_boost_bloc.dart';

enum BoostStep { clearRam, optimizeCpu, closeApps }

enum StepStatus { pending, inProgress, done }

class PowerBoostState {
  final String ramUsedGB;
  final int runningAppsCount;
  final int boostPercent;          // ← new field
  final bool isLoading;
  final bool isBoostStarted;
  final bool isBoostComplete;
  final Map<BoostStep, StepStatus> stepStatuses;

  const PowerBoostState({
    this.ramUsedGB = '— GB',
    this.runningAppsCount = 0,
    this.boostPercent = 0,         // ← default
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
    int? boostPercent,             // ← naya param
    bool? isLoading,
    bool? isBoostStarted,
    bool? isBoostComplete,
    Map<BoostStep, StepStatus>? stepStatuses,
  }) {
    return PowerBoostState(
      ramUsedGB: ramUsedGB ?? this.ramUsedGB,
      runningAppsCount: runningAppsCount ?? this.runningAppsCount,
      boostPercent: boostPercent ?? this.boostPercent,
      isLoading: isLoading ?? this.isLoading,
      isBoostStarted: isBoostStarted ?? this.isBoostStarted,
      isBoostComplete: isBoostComplete ?? this.isBoostComplete,
      stepStatuses: stepStatuses ?? this.stepStatuses,
    );
  }
}