import 'package:battery_saver_app/view/battery_health/result_battery_health_screen.dart';
import 'package:flutter/services.dart';

class BatteryRepository {
  static const MethodChannel _channel =
      MethodChannel('com.example.battery_saver_app/battery_health');

  Future<BatteryHealthModel> getBatteryHealth() async {
    try {
      final result = await _channel.invokeMethod('getBatteryHealth');

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(result);

      return BatteryHealthModel(
        batteryLevel: data['batteryLevel'] ?? 0,
        batteryState: "Unknown",
        voltage: data['voltage'] ?? 0.0,
        temperature: data['temperature'] ?? 0.0,
        chargingCycles: data['chargingCycles'] ?? 0,
        manufactureDate: data['manufactureDate'] ?? 'N/A',
        designCapacity: (data['designCapacity'] ?? 0).toInt(),
        currentCapacity: (data['currentCapacity'] ?? 0).toInt(),
        healthStatus: data['healthStatus'] ?? 'Unknown',
        healthPercent: _calcHealth(
          data['designCapacity'] ?? 0,
          data['currentCapacity'] ?? 0,
        ),
        deviceModel: "Android Device",
        osVersion: "Unknown",
      );
    } catch (e) {
      throw Exception("Battery native fetch failed: $e");
    }
  }

  int _calcHealth(dynamic design, dynamic current) {
    if (design == 0) return 0;
    return ((current / design) * 100).round().clamp(0, 100);
  }
}