// battery_status_cubit.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ─────────────────────────────────────────────
/// DATA MODEL
/// ─────────────────────────────────────────────

class BatteryStatusData extends Equatable {
  final int level;
  final String status;
  final int remainingMinutes;
  final int screenOnTime;
  final String screenTimeFormatted;
  final String healthStatus;
  final int healthCode;
  final int capacityPercent;
  final int chargeCounterUah;
  final int currentNowUa;
  final double temperatureCelsius;
  final int voltageMv;
  final String technology;

  const BatteryStatusData({
    required this.level,
    required this.status,
    required this.remainingMinutes,
    required this.screenOnTime,
    required this.screenTimeFormatted,
    required this.healthStatus,
    required this.healthCode,
    required this.capacityPercent,
    required this.chargeCounterUah,
    required this.currentNowUa,
    required this.temperatureCelsius,
    required this.voltageMv,
    required this.technology,
  });

  factory BatteryStatusData.fromMap(Map<String, dynamic> map) {
    final totalSeconds = map['totalScreenOnTimeSec'] as int? ?? 0;

    String formattedTime = '0m';
    if (totalSeconds > 0) {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    }

    return BatteryStatusData(
      level: map['level'] as int? ?? 0,
      status: map['status'] as String? ?? 'unknown',
      remainingMinutes: map['remainingMinutes'] as int? ?? -1,
      screenOnTime: totalSeconds,
      screenTimeFormatted: formattedTime,
      healthStatus: map['healthStatus'] as String? ?? 'Unknown',
      healthCode: map['healthCode'] as int? ?? -1,
      capacityPercent: map['capacityPercent'] as int? ?? -1,
      chargeCounterUah: map['chargeCounterUah'] as int? ?? -1,
      currentNowUa: map['currentNowUa'] as int? ?? -1,
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble() ?? -1.0,
      voltageMv: map['voltageMv'] as int? ?? -1,
      technology: map['technology'] as String? ?? 'Unknown',
    );
  }

  @override
  List<Object?> get props => [
        level,
        status,
        remainingMinutes,
        screenOnTime,
        screenTimeFormatted,
        healthStatus,
        healthCode,
        capacityPercent,
        chargeCounterUah,
        currentNowUa,
        temperatureCelsius,
        voltageMv,
        technology,
      ];
}

/// ─────────────────────────────────────────────
/// STATES
/// ─────────────────────────────────────────────

abstract class BatteryStatusState extends Equatable {
  const BatteryStatusState();

  @override
  List<Object?> get props => [];
}

class BatteryStatusInitial extends BatteryStatusState {
  const BatteryStatusInitial();
}

class BatteryStatusLoading extends BatteryStatusState {
  const BatteryStatusLoading();
}

class BatteryStatusLoaded extends BatteryStatusState {
  final BatteryStatusData data;

  const BatteryStatusLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class BatteryStatusError extends BatteryStatusState {
  final String message;

  const BatteryStatusError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// ─────────────────────────────────────────────
/// CUBIT
/// ─────────────────────────────────────────────

class BatteryStatusCubit extends Cubit<BatteryStatusState> {
  static const _batteryChannel =
      MethodChannel('com.example.battery_saver_app/battery_status');
  static const _appStatsChannel =
      MethodChannel('com.example.battery_saver_app/app_stats');
  static const _batteryHealthChannel =
      MethodChannel('com.example.battery_saver_app/battery_health');

  Timer? _refreshTimer;

  BatteryStatusCubit() : super(const BatteryStatusInitial());

  void startAutoRefresh({Duration interval = const Duration(seconds: 10)}) {
    _refreshTimer?.cancel();
    loadBatteryStatus();
    _refreshTimer = Timer.periodic(interval, (_) => loadBatteryStatus());
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> loadBatteryStatus() async {
    if (state is! BatteryStatusLoaded) {
      emit(const BatteryStatusLoading());
    }

    try {
      final rawBattery = await _batteryChannel.invokeMethod('getBatteryStatus');
      final batteryMap = Map<String, dynamic>.from(rawBattery);

      final int endTime = DateTime.now().millisecondsSinceEpoch;
      final int startTime = endTime - (24 * 60 * 60 * 1000);

      final rawStats = await _appStatsChannel.invokeMethod('getAppUsageStats', {
        'startTime': startTime,
        'endTime': endTime,
      });
      final statsMap = Map<String, dynamic>.from(rawStats);

      Map<String, dynamic> healthMap = {};
      try {
        final rawHealth = await _batteryHealthChannel.invokeMethod('getBatteryHealth');
        healthMap = Map<String, dynamic>.from(rawHealth);
      } on PlatformException catch (e) {
        print("⚠️ Battery health fetch failed (non-fatal): ${e.message}");
      }

      final combinedMap = <String, dynamic>{}
        ..addAll(batteryMap)
        ..addAll(statsMap)
        ..addAll(healthMap);

      final data = BatteryStatusData.fromMap(combinedMap);
      emit(BatteryStatusLoaded(data: data));
    } on PlatformException catch (e) {
      emit(BatteryStatusError(message: e.message ?? 'Platform error'));
    } catch (e) {
      emit(BatteryStatusError(message: e.toString()));
    }
  }

  /// Background mein chal rahe (cached/idle) apps close karta hai
  /// aur real closed-count return karta hai.
  Future<int> closeBackgroundAppsAndGetCount() async {
    try {
      final result = await _appStatsChannel.invokeMethod('closeBackgroundApps');
      final map = Map<String, dynamic>.from(result);
      return map['closedCount'] as int? ?? 0;
    } on PlatformException catch (e) {
      print("❌ Close apps failed: ${e.message}");
      return 0;
    } catch (e) {
      print("❌ Unknown error while closing apps: $e");
      return 0;
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}