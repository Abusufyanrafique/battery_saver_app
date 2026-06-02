part of 'temperature_bloc.dart';

abstract class TemperatureEvent {}

class TemperatureStarted extends TemperatureEvent {}

class TemperatureAutoCoolToggled extends TemperatureEvent {
  final bool value;
  TemperatureAutoCoolToggled(this.value);
}

class TemperatureCpuCoolerToggled extends TemperatureEvent {
  final bool value;
  TemperatureCpuCoolerToggled(this.value);
}

class TemperatureCoolDownStarted extends TemperatureEvent {}

class TemperatureScanStepCompleted extends TemperatureEvent {}

class TemperatureCoolDownCancelled extends TemperatureEvent {}