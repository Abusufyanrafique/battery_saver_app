part of 'cpu_cooler_bloc.dart';

abstract class CpuCoolerEvent extends Equatable {
  const CpuCoolerEvent();

  @override
  List<Object?> get props => [];
}

class CpuCoolerStartMonitoring extends CpuCoolerEvent {
  const CpuCoolerStartMonitoring();
}

class CpuCoolerCoolDownRequested extends CpuCoolerEvent {
  const CpuCoolerCoolDownRequested();
}

class CpuCoolerRefreshStats extends CpuCoolerEvent {
  const CpuCoolerRefreshStats();
}

class CpuCoolerStopMonitoring extends CpuCoolerEvent {
  const CpuCoolerStopMonitoring();
}