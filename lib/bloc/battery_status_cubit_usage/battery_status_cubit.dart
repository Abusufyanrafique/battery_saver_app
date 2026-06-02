import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ─────────────────────────────────────────────
/// DATA MODEL (UPDATED FOR TYPE SAFETY & FORMATTING)
/// ─────────────────────────────────────────────

class BatteryStatusData extends Equatable {
  final int level;
  final String status;
  final int remainingMinutes; // Added from native battery payload

  /// Total Screen On Time in Seconds
  final int screenOnTime;

  /// Formatted time string (e.g., "5h 12m")
  final String screenTimeFormatted;

  const BatteryStatusData({
    required this.level,
    required this.status,
    required this.remainingMinutes,
    required this.screenOnTime,
    required this.screenTimeFormatted,
  });

  factory BatteryStatusData.fromMap(Map<String, dynamic> map) {
    // Native se seconds milenge, agar battery channel se call ho raha hai aur wahan SOT nahi hai toh fallback 0 chalega
    final totalSeconds = map['totalScreenOnTimeSec'] as int? ?? 0;

    // Seconds ko Human Readable format mein convert karne ka logic
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
  List<Object?> get props => [level, status, remainingMinutes, screenOnTime, screenTimeFormatted];
}

/// ─────────────────────────────────────────────
/// STATES (UNCHANGED)
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
/// CUBIT (DONO CHANNELS KA DATA COMBINE KAR DIYA)
/// ─────────────────────────────────────────────

class BatteryStatusCubit extends Cubit<BatteryStatusState> {
  static const _batteryChannel = MethodChannel('com.example.battery_saver_app/battery_status');
  static const _appStatsChannel = MethodChannel('com.example.battery_saver_app/app_stats');

  BatteryStatusCubit() : super(const BatteryStatusInitial());

  Future<void> loadBatteryStatus() async {
    emit(const BatteryStatusLoading());

    try {
      print("🚀 Fetching Battery and Screen On Time Data...");

      // 1. Battery Status Call Karein
      final rawBattery = await _batteryChannel.invokeMethod('getBatteryStatus');
      final batteryMap = Map<String, dynamic>.from(rawBattery);

      // 2. Screen On Time / App Stats Call Karein (Past 24 Hours ke liye)
      final int endTime = DateTime.now().millisecondsSinceEpoch;
      final int startTime = endTime - (24 * 60 * 60 * 1000); // 24 hours ago

      final rawStats = await _appStatsChannel.invokeMethod('getAppUsageStats', {
        'startTime': startTime,
        'endTime': endTime,
      });
      final statsMap = Map<String, dynamic>.from(rawStats);

      // 3. Dono responses ko ek single map mein merge kar dein
      final combinedMap = <String, dynamic>{}
        ..addAll(batteryMap)
        ..addAll(statsMap);

      print("📊 Combined Parsed Map Data:");
      combinedMap.forEach((key, value) {
        if (key != 'apps') print("➡ $key = $value"); // UI clutter se bachne ke liye apps list print nahi ki
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
}