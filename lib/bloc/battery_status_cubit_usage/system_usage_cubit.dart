// system_usage_cubit.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────

class SystemUsageData extends Equatable {
  final double cpuUsage;       // e.g. 32.5
  final double temperature;    // e.g. 36.0
  final int totalRamMb;        // e.g. 6144
  final int usedRamMb;         // e.g. 4096
  final int chargeCycles;      // estimated from battery level history

  // Formatted strings for UI
  String get cpuUsageFormatted   => '${cpuUsage.toStringAsFixed(0)}%';
  String get temperatureFormatted => '${temperature.toStringAsFixed(1)}°C';
  String get ramUsageFormatted {
    if (totalRamMb <= 0) return '—';
    final percent = (usedRamMb / totalRamMb * 100).round();
    return '$percent%';
  }
  int get ramUsagePercent {
    if (totalRamMb <= 0) return 0;
    return (usedRamMb / totalRamMb * 100).round();
  }

  const SystemUsageData({
    required this.cpuUsage,
    required this.temperature,
    required this.totalRamMb,
    required this.usedRamMb,
    required this.chargeCycles,
  });

  @override
  List<Object?> get props => [cpuUsage, temperature, totalRamMb, usedRamMb, chargeCycles];
}

// ─────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────

abstract class SystemUsageState extends Equatable {
  const SystemUsageState();
  @override
  List<Object?> get props => [];
}

class SystemUsageInitial extends SystemUsageState {
  const SystemUsageInitial();
}

class SystemUsageLoading extends SystemUsageState {
  const SystemUsageLoading();
}

class SystemUsageLoaded extends SystemUsageState {
  final SystemUsageData data;
  const SystemUsageLoaded({required this.data});
  @override
  List<Object?> get props => [data];
}

class SystemUsageError extends SystemUsageState {
  final String message;
  const SystemUsageError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────
// CUBIT
// ─────────────────────────────────────────────────────────────

class SystemUsageCubit extends Cubit<SystemUsageState> {
  // Native channels — same as MainActivity.kt
  static const _cpuChannel   = MethodChannel('com.example.battery_saver_app/cpu_info');
  static const _boostChannel = MethodChannel('com.example.battery_saver_app/phone_boost');
  static const _batteryChannel = MethodChannel('com.example.battery_saver_app/battery_status');

  SystemUsageCubit() : super(const SystemUsageInitial());

  Future<void> loadSystemUsage() async {
    emit(const SystemUsageLoading());

    try {
      print('🚀 SystemUsageCubit: Fetching real system data...');

      // ── 1. CPU Info (getCpuInfo) ──────────────────────────────
      // Returns: { cpuUsage: double, temperature: double, runningApps: int }
      final dynamic cpuRaw = await _cpuChannel.invokeMethod('getCpuInfo');
      final Map<String, dynamic> cpuMap = Map<String, dynamic>.from(cpuRaw as Map);

      print('📊 CPU Map: $cpuMap');

      final double cpuUsage    = (cpuMap['cpuUsage']    as num?)?.toDouble() ?? 0.0;
      final double temperature = (cpuMap['temperature'] as num?)?.toDouble() ?? 0.0;

      // ── 2. Memory Info (getMemoryInfo) ────────────────────────
      // Returns: { totalRamMb, usedRamMb, runningProcessCount, performanceScore }
      final dynamic memRaw = await _boostChannel.invokeMethod('getMemoryInfo');
      final Map<String, dynamic> memMap = Map<String, dynamic>.from(memRaw as Map);

      print('📊 Memory Map: $memMap');

      final int totalRamMb = (memMap['totalRamMb'] as num?)?.toInt() ?? 0;
      final int usedRamMb  = (memMap['usedRamMb']  as num?)?.toInt() ?? 0;

      // ── 3. Charge Cycles — Battery level se estimate ──────────
      // Android BatteryManager mein charge cycles directly available nahi hain
      // Isliye battery level se ek rough estimate karte hain
      final dynamic batteryRaw = await _batteryChannel.invokeMethod('getBatteryStatus');
      final Map<String, dynamic> batteryMap = Map<String, dynamic>.from(batteryRaw as Map);
      final int batteryLevel = (batteryMap['level'] as num?)?.toInt() ?? 50;

      // Simple heuristic: level 80%+ phones are usually well-maintained
      // Real charge cycles Android APIs mein publicly exposed nahi hain
      final int estimatedCycles = _estimateChargeCycles(batteryLevel);

      print('✅ SystemUsage ready — CPU: $cpuUsage%, Temp: $temperature°C, RAM: $usedRamMb/$totalRamMb MB, Cycles: ~$estimatedCycles');

      emit(SystemUsageLoaded(
        data: SystemUsageData(
          cpuUsage:    cpuUsage,
          temperature: temperature,
          totalRamMb:  totalRamMb,
          usedRamMb:   usedRamMb,
          chargeCycles: estimatedCycles,
        ),
      ));
    } on PlatformException catch (e) {
      print('❌ PlatformException: ${e.message}');
      emit(SystemUsageError(message: e.message ?? 'Platform error'));
    } catch (e) {
      print('❌ Unknown Error: $e');
      emit(SystemUsageError(message: e.toString()));
    }
  }

  // Battery level se rough charge cycle estimate
  // Note: Android mein actual charge cycles kisi bhi public API se nahi milte
  int _estimateChargeCycles(int batteryLevel) {
    // Typical phone: ~500 full cycles lifetime
    // Yeh sirf ek placeholder estimate hai — real data available nahi
    if (batteryLevel > 80) return 120;
    if (batteryLevel > 60) return 200;
    if (batteryLevel > 40) return 320;
    return 450;
  }
}