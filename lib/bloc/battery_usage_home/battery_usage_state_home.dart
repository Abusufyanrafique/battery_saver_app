// part of 'battery_usage_bloc.dart';

// abstract class BatteryUsageState extends Equatable {
//   const BatteryUsageState();

//   @override
//   List<Object?> get props => [];
// }

// /// Initial / loading state
// class BatteryUsageInitial extends BatteryUsageState {
//   const BatteryUsageInitial();
// }

// class BatteryUsageLoading extends BatteryUsageState {
//   const BatteryUsageLoading();
// }

// /// Data successfully fetch ho gaya
// class BatteryUsageLoaded extends BatteryUsageState {
//   final List<AppUsageItem> items;

//   const BatteryUsageLoaded({required this.items});

//   @override
//   List<Object?> get props => [items];
// }

// /// Koi error aya
// class BatteryUsageError extends BatteryUsageState {
//   final String message;

//   const BatteryUsageError({required this.message});

//   @override
//   List<Object?> get props => [message];
// }