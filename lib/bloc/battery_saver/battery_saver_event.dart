part of 'battery_saver_bloc.dart';

abstract class BatterySaverEvent extends Equatable {
  const BatterySaverEvent();

  @override
  List<Object?> get props => [];
}

class BatterySaverInitialized extends BatterySaverEvent {
  const BatterySaverInitialized();
}

class BatterySaverModeSelected extends BatterySaverEvent {
  final int index;
  const BatterySaverModeSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class BatterySaverApplyPressed extends BatterySaverEvent {
  const BatterySaverApplyPressed();
}

class _BatteryLevelChanged extends BatterySaverEvent {
  final int level;
  const _BatteryLevelChanged(this.level);

  @override
  List<Object?> get props => [level];
}

class _BatteryStateChanged extends BatterySaverEvent {
  final BatteryState state;
  const _BatteryStateChanged(this.state);

  @override
  List<Object?> get props => [state];
}