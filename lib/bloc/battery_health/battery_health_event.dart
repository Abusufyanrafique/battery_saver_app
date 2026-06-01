// lib/blocs/battery_health/battery_health_event.dart

import 'package:equatable/equatable.dart';

abstract class BatteryHealthEvent extends Equatable {
  const BatteryHealthEvent();

  @override
  List<Object?> get props => [];
}

class LoadBatteryHealth extends BatteryHealthEvent {
  const LoadBatteryHealth();
}

class RefreshBatteryHealth extends BatteryHealthEvent {
  const RefreshBatteryHealth();
}