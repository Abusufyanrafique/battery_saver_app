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
class TemperatureCoolDownCancelled extends TemperatureEvent {}

// ── Auto Cool Service Events ──────────────────────────────────
class TemperatureAutoCoolServiceStarted extends TemperatureEvent {}
class TemperatureAutoCoolServiceStopped extends TemperatureEvent {}
class TemperatureCpuCoolerKillTriggered extends TemperatureEvent {}

// ── Internal step events (private) ───────────────────────────
class _TemperatureStepOneCompleted extends TemperatureEvent {}
class _TemperatureStepTwoCompleted extends TemperatureEvent {}
class _TemperatureStepThreeCompleted extends TemperatureEvent {}