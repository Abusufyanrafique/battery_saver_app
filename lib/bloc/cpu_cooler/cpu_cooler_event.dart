part of 'cpu_cooler_bloc.dart';

abstract class CpuCoolerEvent extends Equatable {
  const CpuCoolerEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when screen loads — starts monitoring
class CpuCoolerStartMonitoring extends CpuCoolerEvent {
  const CpuCoolerStartMonitoring();
}

/// Triggered when "Cool Down" button is pressed
class CpuCoolerCoolDownRequested extends CpuCoolerEvent {
  const CpuCoolerCoolDownRequested();
}

/// Triggered by the periodic timer to refresh stats
class CpuCoolerRefreshStats extends CpuCoolerEvent {
  const CpuCoolerRefreshStats();
}

/// Triggered when screen is disposed
class CpuCoolerStopMonitoring extends CpuCoolerEvent {
  const CpuCoolerStopMonitoring();
}