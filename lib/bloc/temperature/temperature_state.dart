part of 'temperature_bloc.dart';

enum CoolingStatus { idle, scanning, done, cancelled }

class TemperatureState {
  final double tempValue;       // 0.0 to 1.0 (slider position)
  final double tempCelsius;     // actual °C value
  final bool autoCool;
  final bool cpuCooler;
  final CoolingStatus coolingStatus;
  final int completedSteps;     // 0, 1, 2, 3

  const TemperatureState({
    this.tempValue = 0.5,
    this.tempCelsius = 32.0,
    this.autoCool = true,
    this.cpuCooler = false,
    this.coolingStatus = CoolingStatus.idle,
    this.completedSteps = 0,
  });

  // Temperature label
  String get tempLabel {
    if (tempValue < 0.35) return 'Cool';
    if (tempValue < 0.65) return 'Normal';
    return 'Hot';
  }

  // Temperature label color
  Color get tempLabelColor {
    if (tempValue < 0.65) return const Color(0xFF3DDC84);
    return const Color(0xFFFF6B6B);
  }

  // Scan tasks ka status dynamically
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
    bool? autoCool,
    bool? cpuCooler,
    CoolingStatus? coolingStatus,
    int? completedSteps,
  }) {
    return TemperatureState(
      tempValue: tempValue ?? this.tempValue,
      tempCelsius: tempCelsius ?? this.tempCelsius,
      autoCool: autoCool ?? this.autoCool,
      cpuCooler: cpuCooler ?? this.cpuCooler,
      coolingStatus: coolingStatus ?? this.coolingStatus,
      completedSteps: completedSteps ?? this.completedSteps,
    );
  }
}