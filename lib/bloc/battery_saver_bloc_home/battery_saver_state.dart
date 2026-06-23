part of 'battery_saver_bloc.dart';

enum BatterySaverStatus { initial, loading, loaded, activating, active, error }

class BatteryLifeInfo {
  final String estimatedTime;
  final String lifeLabel;
  final Color lifeColor;
  final String brightnessStatus;
  final String backgroundAppsStatus;
  final String autoSyncStatus;
  final String notificationsStatus;

  const BatteryLifeInfo({
    required this.estimatedTime,
    required this.lifeLabel,
    required this.lifeColor,
    required this.brightnessStatus,
    required this.backgroundAppsStatus,
    required this.autoSyncStatus,
    required this.notificationsStatus,
  });

  BatteryLifeInfo copyWith({
    String? estimatedTime,
    String? lifeLabel,
    Color? lifeColor,
    String? brightnessStatus,
    String? backgroundAppsStatus,
    String? autoSyncStatus,
    String? notificationsStatus,
  }) {
    return BatteryLifeInfo(
      estimatedTime: estimatedTime ?? this.estimatedTime,
      lifeLabel: lifeLabel ?? this.lifeLabel,
      lifeColor: lifeColor ?? this.lifeColor,
      brightnessStatus: brightnessStatus ?? this.brightnessStatus,
      backgroundAppsStatus: backgroundAppsStatus ?? this.backgroundAppsStatus,
      autoSyncStatus: autoSyncStatus ?? this.autoSyncStatus,
      notificationsStatus: notificationsStatus ?? this.notificationsStatus,
    );
  }
}

class BatterySaverHomeState extends Equatable {
  final BatterySaverStatus status;
  final int? batteryLevel;
  final BatteryState? batteryChargeState;
  final SaverMode selectedMode;
  final bool isActive;
  final BatteryLifeInfo? batteryLifeInfo;
  final String? errorMessage;
  // ← yeh flag add kiya — null reset track karne ke liye
  final bool clearBatteryLifeInfo;

  const BatterySaverHomeState({
    this.status = BatterySaverStatus.initial,
    this.batteryLevel,
    this.batteryChargeState,
    this.selectedMode = SaverMode.smart,
    this.isActive = false,
    this.batteryLifeInfo,
    this.errorMessage,
    this.clearBatteryLifeInfo = false,
  });

  bool get isCharging => batteryChargeState == BatteryState.charging;
  bool get isFull => batteryChargeState == BatteryState.full;
  bool get isLoading => status == BatterySaverStatus.loading;
  bool get isActivating => status == BatterySaverStatus.activating;

  String get batteryLevelText =>
      batteryLevel != null ? '$batteryLevel%' : '--';

  String get chargeStatusText {
    switch (batteryChargeState) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.connectedNotCharging:
        return 'Connected';
      default:
        return 'Unknown';
    }
  }

  BatterySaverHomeState copyWith({
    BatterySaverStatus? status,
    int? batteryLevel,
    BatteryState? batteryChargeState,
    SaverMode? selectedMode,
    bool? isActive,
    BatteryLifeInfo? batteryLifeInfo,
    String? errorMessage,
    bool clearBatteryLifeInfo = false, // ← explicit flag
  }) {
    return BatterySaverHomeState(
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryChargeState: batteryChargeState ?? this.batteryChargeState,
      selectedMode: selectedMode ?? this.selectedMode,
      isActive: isActive ?? this.isActive,
      // agar clearBatteryLifeInfo true hai to null karo, warna raho
      batteryLifeInfo: clearBatteryLifeInfo ? null : (batteryLifeInfo ?? this.batteryLifeInfo),
      errorMessage: errorMessage ?? this.errorMessage,
      clearBatteryLifeInfo: clearBatteryLifeInfo,
    );
  }

  @override
  List<Object?> get props => [
        status,
        batteryLevel,
        batteryChargeState,
        selectedMode,
        isActive,
        batteryLifeInfo,
        errorMessage,
      ];
}