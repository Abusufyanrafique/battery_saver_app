part of 'cpu_cooler_bloc.dart';

enum CpuCoolerStatus { initial, monitoring, coolingDown, cooled, error }

class CpuCoolerState extends Equatable {
  final CpuCoolerStatus status;
  final double cpuUsage;       // 0–100 percent
  final int runningApps;
  final double temperature;    // Celsius
  final String statusMessage;
  final String? errorMessage;

  const CpuCoolerState({
    this.status = CpuCoolerStatus.initial,
    this.cpuUsage = 0.0,
    this.runningApps = 0,
    this.temperature = 0.0,
    this.statusMessage = '',
    this.errorMessage,
  });

  bool get isCoolingDown => status == CpuCoolerStatus.coolingDown;
  bool get isLoading =>
      status == CpuCoolerStatus.initial || status == CpuCoolerStatus.coolingDown;

  CpuCoolerState copyWith({
    CpuCoolerStatus? status,
    double? cpuUsage,
    int? runningApps,
    double? temperature,
    String? statusMessage,
    String? errorMessage,
  }) {
    return CpuCoolerState(
      status: status ?? this.status,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      runningApps: runningApps ?? this.runningApps,
      temperature: temperature ?? this.temperature,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cpuUsage,
        runningApps,
        temperature,
        statusMessage,
        errorMessage,
      ];
}