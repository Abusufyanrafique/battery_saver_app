part of 'battery_saver_bloc.dart';

// Battery reading with timestamp
class BatteryReading extends Equatable {
  final int level;
  final DateTime time;
  const BatteryReading({required this.level, required this.time});

  @override
  List<Object?> get props => [level, time];
}

class BatterySaverState extends Equatable {
  final int batteryLevel;
  final BatteryHealthStatus healthStatus;
  final bool isCharging;
  final String remainingTime;
  final int selectedIndex;
  final int appliedIndex;
  final bool isApplying;
  final bool applySuccess;
  final String? errorMessage;
  final List<BatteryReading> batteryHistory; // ← ADD THIS

  const BatterySaverState({
    this.batteryLevel = 0,
    this.healthStatus = BatteryHealthStatus.critical,
    this.isCharging = false,
    this.remainingTime = '--',
    this.selectedIndex = 0,
    this.appliedIndex = 0,
    this.isApplying = false,
    this.applySuccess = false,
    this.errorMessage,
    this.batteryHistory = const [], // ← ADD THIS
  });

  BatterySaverState copyWith({
    int? batteryLevel,
    BatteryHealthStatus? healthStatus,
    bool? isCharging,
    String? remainingTime,
    int? selectedIndex,
    int? appliedIndex,
    bool? isApplying,
    bool? applySuccess,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
    List<BatteryReading>? batteryHistory, // ← ADD THIS
  }) {
    return BatterySaverState(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      healthStatus: healthStatus ?? this.healthStatus,
      isCharging: isCharging ?? this.isCharging,
      remainingTime: remainingTime ?? this.remainingTime,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      appliedIndex: appliedIndex ?? this.appliedIndex,
      isApplying: isApplying ?? this.isApplying,
      applySuccess: clearSuccess ? false : (applySuccess ?? this.applySuccess),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      batteryHistory: batteryHistory ?? this.batteryHistory, // ← ADD THIS
    );
  }

  @override
  List<Object?> get props => [
        batteryLevel,
        healthStatus,
        isCharging,
        remainingTime,
        selectedIndex,
        appliedIndex,
        isApplying,
        applySuccess,
        errorMessage,
        batteryHistory, // ← ADD THIS
      ];
}