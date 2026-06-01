part of 'battery_saver_bloc.dart';

abstract class BatterySaverHomeEvent extends Equatable {
  const BatterySaverHomeEvent();

  @override
  List<Object?> get props => [];
}

/// App start hone par ya screen open hone par battery info load karo
class LoadBatteryInfo extends BatterySaverHomeEvent {
  const LoadBatteryInfo();
}

/// User ne mode change kiya
class SelectSaverMode extends BatterySaverHomeEvent {
  final SaverMode mode;
  const SelectSaverMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// User ne "Activate Battery Saver" button dabaya
class ActivateBatterySaver extends BatterySaverHomeEvent {
  const ActivateBatterySaver();
}

/// Battery level ya status real-time update aaya
class BatteryLevelUpdated extends BatterySaverHomeEvent {
  final int level;
  final BatteryState batteryState;

  const BatteryLevelUpdated({required this.level, required this.batteryState});

  @override
  List<Object?> get props => [level, batteryState];
}

/// Saver deactivate karo (Done button)
class DeactivateBatterySaver extends BatterySaverHomeEvent {
  const DeactivateBatterySaver();
}