import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
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

  // ─── Load Battery Info ────────────────────────────────────────────────────

  Future<void> _onLoadBatteryInfo(
    LoadBatteryInfo event,
    Emitter<BatterySaverHomeState> emit,
  ) async {
    emit(state.copyWith(status: BatterySaverStatus.loading));

    try {
      // Real battery level fetch karo
      final level = await _battery.batteryLevel;
      final chargeState = await _battery.batteryState;

      emit(state.copyWith(
        status: BatterySaverStatus.loaded,
        batteryLevel: level,
        batteryChargeState: chargeState,
      ));

      // Real-time battery state changes listen karo
      _batteryStateSubscription?.cancel();
      _batteryStateSubscription =
          _battery.onBatteryStateChanged.listen((newState) async {
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

  // ─── Select Mode ──────────────────────────────────────────────────────────

  void _onSelectSaverMode(
    SelectSaverMode event,
    Emitter<BatterySaverHomeState> emit,
  ) {
    emit(state.copyWith(selectedMode: event.mode));
  }

  // ─── Activate Battery Saver ───────────────────────────────────────────────

  Future<void> _onActivateBatterySaver(
    ActivateBatterySaver event,
    Emitter<BatterySaverHomeState> emit,
  ) async {
    emit(state.copyWith(status: BatterySaverStatus.activating));

    // Simulate optimization delay (real app mein actual system calls hote hain)
    await Future.delayed(const Duration(milliseconds: 1200));

    final level = state.batteryLevel ?? 50;
    final chargeState = state.batteryChargeState;

    // Battery life calculate karo mode + level ke basis par
    final lifeInfo = _calculateBatteryLife(
      mode: state.selectedMode,
      batteryLevel: level,
      isCharging: chargeState == BatteryState.charging ||
          chargeState == BatteryState.full,
    );

    emit(state.copyWith(
      status: BatterySaverStatus.active,
      isActive: true,
      batteryLifeInfo: lifeInfo,
    ));
  }

  // ─── Battery Level Updated ────────────────────────────────────────────────

  void _onBatteryLevelUpdated(
    BatteryLevelUpdated event,
    Emitter<BatterySaverHomeState> emit,
  ) {
    // Agar saver active hai to recalculate karo
    BatteryLifeInfo? updatedInfo;
    if (state.isActive) {
      updatedInfo = _calculateBatteryLife(
        mode: state.selectedMode,
        batteryLevel: event.level,
        isCharging: event.batteryState == BatteryState.charging ||
            event.batteryState == BatteryState.full,
      );
    }

    emit(state.copyWith(
      batteryLevel: event.level,
      batteryChargeState: event.batteryState,
      batteryLifeInfo: updatedInfo ?? state.batteryLifeInfo,
    ));
  }

  // ─── Deactivate ───────────────────────────────────────────────────────────

  void _onDeactivateBatterySaver(
    DeactivateBatterySaver event,
    Emitter<BatterySaverHomeState> emit,
  ) {
    emit(state.copyWith(
      status: BatterySaverStatus.loaded,
      isActive: false,
      batteryLifeInfo: null,
    ));
  }

  // ─── Battery Life Calculator ──────────────────────────────────────────────

  BatteryLifeInfo _calculateBatteryLife({
    required SaverMode mode,
    required int batteryLevel,
    required bool isCharging,
  }) {
    // Base hours: battery level se estimate (100% = 10h normal usage)
    final double baseHours = batteryLevel / 100 * 10;

    double multiplier;
    String brightnessStatus;
    String backgroundAppsStatus;
    String autoSyncStatus;
    String notificationsStatus;

    switch (mode) {
      case SaverMode.smart:
        multiplier = 1.35; // 35% better
        brightnessStatus = 'Optimized';
        backgroundAppsStatus = 'Limited';
        autoSyncStatus = 'Reduced';
        notificationsStatus = 'Normal';
        break;
      case SaverMode.ultra:
        multiplier = 1.80; // 80% better
        brightnessStatus = 'Minimum';
        backgroundAppsStatus = 'Disabled';
        autoSyncStatus = 'Disabled';
        notificationsStatus = 'Limited';
        break;
      case SaverMode.custom:
        multiplier = 1.55; // 55% better
        brightnessStatus = 'Reduced';
        backgroundAppsStatus = 'Limited';
        autoSyncStatus = 'Disabled';
        notificationsStatus = 'Limited';
        break;
    }

    final double estimatedHours = baseHours * multiplier;
    final int hours = estimatedHours.floor();
    final int minutes = ((estimatedHours - hours) * 60).round();

    // Life label determine karo
    String lifeLabel;
    Color lifeColor;

    if (isCharging) {
      lifeLabel = 'Charging';
      lifeColor = const Color(0xFF55D0FF);
    } else if (estimatedHours >= 8) {
      lifeLabel = 'Extended';
      lifeColor = const Color(0xFF00FF09);
    } else if (estimatedHours >= 4) {
      lifeLabel = 'Normal';
      lifeColor = const Color(0xFFFFD700);
    } else {
      lifeLabel = 'Low';
      lifeColor = const Color(0xFFFF4444);
    }

    return BatteryLifeInfo(
      estimatedTime: '${hours}h ${minutes}m',
      lifeLabel: lifeLabel,
      lifeColor: lifeColor,
      brightnessStatus: brightnessStatus,
      backgroundAppsStatus: backgroundAppsStatus,
      autoSyncStatus: autoSyncStatus,
      notificationsStatus: notificationsStatus,
    );
  }

  @override
  Future<void> close() {
    _batteryStateSubscription?.cancel();
    return super.close();
  }
}