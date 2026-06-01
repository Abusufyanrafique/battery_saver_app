part of 'battery_saver_bloc.dart';

// ─── Battery Saver Status ────────────────────────────────────────────────────

enum BatterySaverStatus { initial, loading, loaded, activating, active, error }

// ─── Computed Battery Life Model ─────────────────────────────────────────────

class BatteryLifeInfo {
  final String estimatedTime;   // e.g. "15h 30m"
  final String lifeLabel;       // e.g. "Extended" / "Normal" / "Low"
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
}

// ─── Main State ───────────────────────────────────────────────────────────────

class BatterySaverHomeState extends Equatable {
  final BatterySaverStatus status;

  /// Real battery level (0-100), null agar abhi load nahi hua
  final int? batteryLevel;

  /// Real battery charging/discharging/full state
  final BatteryState? batteryChargeState;

  /// User ka selected mode
  final SaverMode selectedMode;

  /// Saver active hai ya nahi
  final bool isActive;

  /// Computed battery life info (active hone ke baad)
  final BatteryLifeInfo? batteryLifeInfo;

  /// Error message agar kuch galat ho
  final String? errorMessage;

  const BatterySaverHomeState({
    this.status = BatterySaverStatus.initial,
    this.batteryLevel,
    this.batteryChargeState,
    this.selectedMode = SaverMode.smart,
    this.isActive = false,
    this.batteryLifeInfo,
    this.errorMessage,
  });

  // ── Convenience getters ──────────────────────────────────────────────────

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

  // ── CopyWith ─────────────────────────────────────────────────────────────

  BatterySaverHomeState copyWith({
    BatterySaverStatus? status,
    int? batteryLevel,
    BatteryState? batteryChargeState,
    SaverMode? selectedMode,
    bool? isActive,
    BatteryLifeInfo? batteryLifeInfo,
    String? errorMessage,
  }) {
    return BatterySaverHomeState(
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryChargeState: batteryChargeState ?? this.batteryChargeState,
      selectedMode: selectedMode ?? this.selectedMode,
      isActive: isActive ?? this.isActive,
      batteryLifeInfo: batteryLifeInfo ?? this.batteryLifeInfo,
      errorMessage: errorMessage ?? this.errorMessage,
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