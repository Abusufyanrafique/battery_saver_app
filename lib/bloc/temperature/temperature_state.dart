part of 'temperature_bloc.dart';

enum CoolingStatus { idle, scanning, done, cancelled }
enum TaskStatus { pending, inProgress, done }

class TemperatureState {
  final double tempValue;
  final double tempCelsius;
  final double cpuUsage;
  final int runningApps;
  final bool autoCool;
  final bool cpuCooler;
  final CoolingStatus coolingStatus;
  final int completedSteps;
  final bool isLoading;
  final bool isCancelled;
  final bool autoCoolServiceRunning; // ← NEW
  final String? serviceError;        // ← NEW

  const TemperatureState({
    this.tempValue              = 0.5,
    this.tempCelsius            = 32.0,
    this.cpuUsage               = 0.0,
    this.runningApps            = 0,
    this.autoCool               = true,
    this.cpuCooler              = false,
    this.coolingStatus          = CoolingStatus.idle,
    this.completedSteps         = 0,
    this.isLoading              = true,
    this.isCancelled            = false,
    this.autoCoolServiceRunning = false, // ← NEW
    this.serviceError           = null,  // ← NEW
  });

  String get tempLabel {
    if (tempValue < 0.35) return 'Cool';
    if (tempValue < 0.65) return 'Normal';
    return 'Hot';
  }

  Color get tempLabelColor {
    if (tempValue < 0.35) return const Color(0xFF3DDC84);
    if (tempValue < 0.65) return const Color(0xFF55D0FF);
    return const Color(0xFFFF6B6B);
  }

  List<TaskStatus> get taskStatuses {
    return List.generate(3, (i) {
      if (i < completedSteps) return TaskStatus.done;
      if (i == completedSteps && coolingStatus == CoolingStatus.scanning) {
        return TaskStatus.inProgress;
      }
      return TaskStatus.pending;
    });
  }

  TemperatureState copyWith({
    double? tempValue,
    double? tempCelsius,
    double? cpuUsage,
    int? runningApps,
    bool? autoCool,
    bool? cpuCooler,
    CoolingStatus? coolingStatus,
    int? completedSteps,
    bool? isLoading,
    bool? isCancelled,
    bool? autoCoolServiceRunning, // ← NEW
    String? serviceError,         // ← NEW
  }) {
    return TemperatureState(
      tempValue:              tempValue              ?? this.tempValue,
      tempCelsius:            tempCelsius            ?? this.tempCelsius,
      cpuUsage:               cpuUsage               ?? this.cpuUsage,
      runningApps:            runningApps            ?? this.runningApps,
      autoCool:               autoCool               ?? this.autoCool,
      cpuCooler:              cpuCooler              ?? this.cpuCooler,
      coolingStatus:          coolingStatus          ?? this.coolingStatus,
      completedSteps:         completedSteps         ?? this.completedSteps,
      isLoading:              isLoading              ?? this.isLoading,
      isCancelled:            isCancelled            ?? this.isCancelled,
      autoCoolServiceRunning: autoCoolServiceRunning ?? this.autoCoolServiceRunning,
      serviceError:           serviceError           ?? this.serviceError,
    );
  }
}