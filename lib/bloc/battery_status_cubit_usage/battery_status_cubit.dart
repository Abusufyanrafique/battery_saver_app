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

  const BatteryStatusData({
    required this.level,
    required this.status,
    required this.remainingMinutes,
    required this.screenOnTime,
    required this.screenTimeFormatted,
  });

  factory BatteryStatusData.fromMap(Map<String, dynamic> map) {
    final totalSeconds = map['totalScreenOnTimeSec'] as int? ?? 0;

    String formattedTime = '0m';
    if (totalSeconds > 0) {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;

      if (hours > 0) {
        formattedTime = '${hours}h ${minutes}m';
      } else {
        formattedTime = '${minutes}m';
      }
    }

    return BatteryStatusData(
      level: map['level'] as int? ?? 0,
      status: map['status'] as String? ?? 'unknown',
      remainingMinutes: map['remainingMinutes'] as int? ?? -1,
      screenOnTime: totalSeconds,
      screenTimeFormatted: formattedTime,
    );
  }

  @override
  List<Object?> get props =>
      [level, status, remainingMinutes, screenOnTime, screenTimeFormatted];
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
/// CUBIT (AUTO REFRESH ADDED)
/// ─────────────────────────────────────────────

class BatteryStatusCubit extends Cubit<BatteryStatusState> {
  static const _batteryChannel =
      MethodChannel('com.example.battery_saver_app/battery_status');
  static const _appStatsChannel =
      MethodChannel('com.example.battery_saver_app/app_stats');

  Timer? _refreshTimer;

  BatteryStatusCubit() : super(const BatteryStatusInitial());

  /// Periodic auto-refresh start karta hai (default har 10 seconds).
  /// Screen open rehte hue bhi data fresh rakhne ke liye.
  void startAutoRefresh({Duration interval = const Duration(seconds: 10)}) {
    _refreshTimer?.cancel();
    loadBatteryStatus(); // pehli call immediately
    _refreshTimer = Timer.periodic(interval, (_) => loadBatteryStatus());
  }

  /// Jab app background mein jaye to timer band kar dein (battery saving).
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> loadBatteryStatus() async {
    // Agar pehle se data loaded hai to loading state mat dikhao —
    // isse UI flicker/blink nahi karegi har refresh par.
    if (state is! BatteryStatusLoaded) {
      emit(const BatteryStatusLoading());
    }

    try {
      print("🚀 Fetching Battery and Screen On Time Data...");

      final rawBattery = await _batteryChannel.invokeMethod('getBatteryStatus');
      final batteryMap = Map<String, dynamic>.from(rawBattery);

      final int endTime = DateTime.now().millisecondsSinceEpoch;
      final int startTime = endTime - (24 * 60 * 60 * 1000);

      final rawStats = await _appStatsChannel.invokeMethod('getAppUsageStats', {
        'startTime': startTime,
        'endTime': endTime,
      });
      final statsMap = Map<String, dynamic>.from(rawStats);

      final combinedMap = <String, dynamic>{}
        ..addAll(batteryMap)
        ..addAll(statsMap);

      print("📊 Combined Parsed Map Data:");
      combinedMap.forEach((key, value) {
        if (key != 'apps') print("➡ $key = $value");
      });

      final data = BatteryStatusData.fromMap(combinedMap);

      print("✅ Battery + Screen Time Data Ready. Formatted SOT: ${data.screenTimeFormatted}");

      emit(BatteryStatusLoaded(data: data));
    } on PlatformException catch (e) {
      print("❌ Platform Exception: ${e.message}");
      emit(BatteryStatusError(message: e.message ?? 'Platform error'));
    } catch (e) {
      print("❌ Unknown Error: $e");
      emit(BatteryStatusError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}