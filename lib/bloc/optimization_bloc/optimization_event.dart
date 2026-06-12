part of 'optimization_bloc.dart';

abstract class OptimizationEvent {}

// ── Optimize Screen Events ───────────────────────────────────────────────────
class StartOptimizationEvent extends OptimizationEvent {}

class StopOptimizationEvent extends OptimizationEvent {}

// Internal — bahar se call mat karo
class _TaskCompletedEvent extends OptimizationEvent {
  final int index;
  _TaskCompletedEvent(this.index);
}

class _BatteryPermissionResultEvent extends OptimizationEvent {
  final OptimizationOutcomeStatus status;
  _BatteryPermissionResultEvent(this.status);
}

// ── Result Screen Event ──────────────────────────────────────────────────────
/// OptimizationResultScreen khulte hi yeh fire karo
class LoadResultDataEvent extends OptimizationEvent {}