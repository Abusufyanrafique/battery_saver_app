// lib/blocs/battery_health/battery_health_state.dart
import 'package:battery_saver_app/view/battery_health/result_battery_health_screen.dart';
import 'package:equatable/equatable.dart';

abstract class BatteryHealthState extends Equatable {
  const BatteryHealthState();

  @override
  List<Object?> get props => [];
}

class BatteryHealthInitial extends BatteryHealthState {}

class BatteryHealthLoading extends BatteryHealthState {}

class BatteryHealthLoaded extends BatteryHealthState {
  final BatteryHealthModel data;

  const BatteryHealthLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class BatteryHealthError extends BatteryHealthState {
  final String message;

  const BatteryHealthError(this.message);

  @override
  List<Object?> get props => [message];
}