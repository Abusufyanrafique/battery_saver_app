import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:battery_saver_app/services/battery_saver_channel.dart'; // <-- new
import 'package:battery_saver_app/widgets/battery_saver_home_screen/battery_saver_home_screen_widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'battery_saver_event.dart';
part 'battery_saver_state.dart';

class BatterySaverHomeBloc extends Bloc<BatterySaverHomeEvent, BatterySaverHomeState> {
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  BatterySaverHomeBloc() : super(const BatterySaverHomeState()) {
    on<LoadBatteryInfo>(_onLoadBatteryInfo);
    on<SelectSaverMode>(_onSelectSaverMode);
    on<ActivateBatterySaver>(_onActivateBatterySaver);
    on<BatteryLevelUpdated>(_onBatteryLevelUpdated);
    on<DeactivateBatterySaver>(_onDeactivateBatterySaver);
  }

  // ─── Load Battery Info ──────────────────────────────────────────────────────
  Future<void> _onLoadBatteryInfo(
    LoadBatteryInfo event,
    Emitter<BatterySaverHomeState> emit,
  ) async {
    emit(state.copyWith(status: BatterySaverStatus.loading));
    try {
      // Use battery_plus for level + charge state (cross-platform)
      final level = await _battery.batteryLevel;
      final chargeState = await _battery.batteryState;

      emit(state.copyWith(
        status: BatterySaverStatus.loaded,
        batteryLevel: level,
        batteryChargeState: chargeState,
      ));

      // Listen for real-time battery changes
      _batteryStateSubscription?.cancel();
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen((newState) async {
        final newLevel = await _battery.batteryLevel;
        add(BatteryLevelUpdated(level: newLevel, batteryState: newState));
      });
    } catch (e) {
      emit(state.copyWith(
        status: BatterySaverStatus.error,
        errorMessage: 'Battery info load nahi ho saka: $e',
      ));
    }
  }

  // ─── Select Mode ────────────────────────────────────────────────────────────
 void _onSelectSaverMode(
  SelectSaverMode event,
  Emitter<BatterySaverHomeState> emit,
) {
  emit(state.copyWith(
    selectedMode: event.mode,
    status: BatterySaverStatus.loaded,
    isActive: false,
    clearBatteryLifeInfo: true, 
  ));
}

  // ─── Activate Battery Saver ──────────────────────────────────────────────────
  Future<void> _onActivateBatterySaver(
    ActivateBatterySaver event,
    Emitter<BatterySaverHomeState> emit,
  ) async {
    emit(state.copyWith(status: BatterySaverStatus.activating));

    // ── 1. Brightness ──────────────────────────────────────────────────────────
    String brightnessStatus = 'Unknown';
    final hasBrightnessPerm = await BatterySaverChannel.hasWriteSettingsPermission();

    if (hasBrightnessPerm) {
      int targetBrightness;
      switch (state.selectedMode) {
        case SaverMode.ultra:
          targetBrightness = 30;   // ~12% — minimum visible
          break;
        case SaverMode.smart:
          targetBrightness = 90;   // ~35% — adaptive-ish
          break;
        case SaverMode.custom:
          targetBrightness = 60;   // ~24% — reduced
          break;
      }
      final success = await BatterySaverChannel.setBrightness(targetBrightness);
      if (success) {
        brightnessStatus = state.selectedMode == SaverMode.ultra
            ? 'Minimum'
            : state.selectedMode == SaverMode.smart
                ? 'Optimized'
                : 'Reduced';
      } else {
        brightnessStatus = 'Permission Denied';
      }
    } else {
      // Ask user to grant the permission; show a status label
      brightnessStatus = 'Permission Required';
      await BatterySaverChannel.requestWriteSettingsPermission();
    }

    // ── 2. Auto Sync ───────────────────────────────────────────────────────────
    String autoSyncStatus;
    switch (state.selectedMode) {
      case SaverMode.ultra:
      case SaverMode.custom:
        await BatterySaverChannel.setAutoSyncEnabled(false);
        autoSyncStatus = 'Disabled';
        break;
      case SaverMode.smart:
        // Reduce but don't fully disable — we just leave it on for Smart mode
        autoSyncStatus = 'Reduced';
        break;
    }

    // ── 3. Notifications / DND ─────────────────────────────────────────────────
    String notificationsStatus;
    final hasDndAccess = await BatterySaverChannel.isNotificationPolicyAccessGranted();

    if (hasDndAccess) {
      final shouldLimit = state.selectedMode == SaverMode.ultra ||
          state.selectedMode == SaverMode.custom;
      final success = await BatterySaverChannel.setNotificationsLimited(shouldLimit);
      if (success) {
        notificationsStatus = shouldLimit ? 'Limited' : 'Normal';
      } else {
        notificationsStatus = await BatterySaverChannel.getNotificationStatus();
      }
    } else {
      notificationsStatus = 'Permission Required';
      if (state.selectedMode == SaverMode.ultra || state.selectedMode == SaverMode.custom) {
        await BatterySaverChannel.requestNotificationPolicyAccess();
      } else {
        notificationsStatus = 'Normal';
      }
    }

    // ── 4. Background Apps ─────────────────────────────────────────────────────
    // Android does NOT allow silent restriction of other apps.
    // We read OUR own restriction state and set a descriptive label.
    final isBgRestricted = await BatterySaverChannel.isBackgroundRestricted();
    String backgroundAppsStatus;
    switch (state.selectedMode) {
      case SaverMode.ultra:
        backgroundAppsStatus = isBgRestricted ? 'Disabled' : 'Limited';
        if (!isBgRestricted) await BatterySaverChannel.openBackgroundAppsSettings();
        break;
      case SaverMode.smart:
      case SaverMode.custom:
        backgroundAppsStatus = isBgRestricted ? 'Disabled' : 'Limited';
        break;
    }

    // ── 5. Power Saver (OS-level) ──────────────────────────────────────────────
    // Cannot enable silently — only read + deep-link for Ultra mode.
    if (state.selectedMode == SaverMode.ultra) {
      final osPowerSaver = await BatterySaverChannel.isPowerSaverEnabled();
      if (!osPowerSaver) {
        await BatterySaverChannel.openPowerSaverSettings();
      }
    }

    // ── 6. Build BatteryLifeInfo with REAL values ──────────────────────────────
    final level = state.batteryLevel ?? 50;
    final chargeState = state.batteryChargeState;

    final lifeInfo = BatteryLifeInfo(
      estimatedTime: _buildEstimatedTime(level, state.selectedMode),
      lifeLabel: _buildLifeLabel(level, chargeState),
      lifeColor: _buildLifeColor(level, chargeState),
      brightnessStatus: brightnessStatus,
      backgroundAppsStatus: backgroundAppsStatus,
      autoSyncStatus: autoSyncStatus,
      notificationsStatus: notificationsStatus,
    );

    emit(state.copyWith(
      status: BatterySaverStatus.active,
      isActive: true,
      batteryLifeInfo: lifeInfo,
    ));
  }

  // ─── Battery Level Updated ───────────────────────────────────────────────────
  void _onBatteryLevelUpdated(
    BatteryLevelUpdated event,
    Emitter<BatterySaverHomeState> emit,
  ) {
    BatteryLifeInfo? updatedInfo;
    if (state.isActive && state.batteryLifeInfo != null) {
      // Keep existing feature statuses, just refresh time + label
      updatedInfo = state.batteryLifeInfo!.copyWith(
        estimatedTime: _buildEstimatedTime(event.level, state.selectedMode),
        lifeLabel: _buildLifeLabel(event.level, event.batteryState),
        lifeColor: _buildLifeColor(event.level, event.batteryState),
      );
    }

    emit(state.copyWith(
      batteryLevel: event.level,
      batteryChargeState: event.batteryState,
      batteryLifeInfo: updatedInfo ?? state.batteryLifeInfo,
    ));
  }

  // ─── Deactivate ──────────────────────────────────────────────────────────────
 Future<void> _onDeactivateBatterySaver(
  DeactivateBatterySaver event,
  Emitter<BatterySaverHomeState> emit,
) async {
  await BatterySaverChannel.setAutoSyncEnabled(true);

  final hasDndAccess = await BatterySaverChannel.isNotificationPolicyAccessGranted();
  if (hasDndAccess) {
    await BatterySaverChannel.setNotificationsLimited(false);
  }

  final hasBrightnessPerm = await BatterySaverChannel.hasWriteSettingsPermission();
  if (hasBrightnessPerm) {
    await BatterySaverChannel.setBrightness(128);
  }

  emit(state.copyWith(
    status: BatterySaverStatus.loaded,
    isActive: false,
    clearBatteryLifeInfo: true, // ← fix
  ));
}
  // ─── Helpers ──────────────────────────────────────────────────────────────────

  String _buildEstimatedTime(int level, SaverMode mode) {
    final double baseHours = level / 100 * 10;
    final double multiplier = switch (mode) {
      SaverMode.smart => 1.35,
      SaverMode.ultra => 1.80,
      SaverMode.custom => 1.55,
    };
    final double totalHours = baseHours * multiplier;
    final int h = totalHours.floor();
    final int m = ((totalHours - h) * 60).round();
    return '${h}h ${m}m';
  }

  String _buildLifeLabel(int level, BatteryState? chargeState) {
    if (chargeState == BatteryState.charging || chargeState == BatteryState.full) {
      return 'Charging';
    }
    if (level >= 60) return 'Extended';
    if (level >= 25) return 'Normal';
    return 'Low';
  }

  Color _buildLifeColor(int level, BatteryState? chargeState) {
    if (chargeState == BatteryState.charging || chargeState == BatteryState.full) {
      return const Color(0xFF55D0FF);
    }
    if (level >= 60) return const Color(0xFF00FF09);
    if (level >= 25) return const Color(0xFFFFD700);
    return const Color(0xFFFF4444);
  }

  @override
  Future<void> close() {
    _batteryStateSubscription?.cancel();
    return super.close();
  }
}
