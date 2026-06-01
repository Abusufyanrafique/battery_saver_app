part of 'temperature_bloc.dart';

abstract class TemperatureEvent {}

// Screen load hone par real temperature fetch karo
class TemperatureStarted extends TemperatureEvent {}

// Auto Cool toggle
class TemperatureAutoCoolToggled extends TemperatureEvent {
  final bool value;
  TemperatureAutoCoolToggled(this.value);
}

// CPU Cooler toggle
class TemperatureCpuCoolerToggled extends TemperatureEvent {
  final bool value;
  TemperatureCpuCoolerToggled(this.value);
}

// Cool Down button press - scanning shuru karo
class TemperatureCoolDownStarted extends TemperatureEvent {}

// Scan step complete hua (timer se trigger hoga)
class TemperatureScanStepCompleted extends TemperatureEvent {}

// Cancel cooling
class TemperatureCoolDownCancelled extends TemperatureEvent {}