import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:battery_saver_app/view/battery_health/result_battery_health_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class BatteryRepository {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<BatteryHealthModel> getBatteryHealth() async {
    debugPrint("🔋 BatteryHealth fetch started");

    // Battery level
    final int level = await _battery.batteryLevel;
    debugPrint("📊 Battery Level: $level%");

    // Battery state
    final BatteryState state = await _battery.batteryState;
    final String stateStr = _mapBatteryState(state);
    debugPrint("⚡ Battery State: $stateStr");

    // Device info
    String deviceModel = 'Unknown';
    String osVersion = 'Unknown';

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      deviceModel = '${androidInfo.brand} ${androidInfo.model}';
      osVersion = 'Android ${androidInfo.version.release}';

      debugPrint("📱 Device: $deviceModel");
      debugPrint("🤖 OS Version: $osVersion");
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';

      debugPrint("📱 Device: $deviceModel");
      debugPrint("🍎 OS Version: $osVersion");
    }

    // Fake / approximate values
    double voltage = 3.9;
    double temperature = 30.0 + (level * 0.05);

    debugPrint("🔌 Voltage (approx): $voltage V");
    debugPrint("🌡 Temperature (approx): $temperature °C");

    final int designCapacity = 5000;
    final int currentCapacity = (designCapacity * level / 100).round();

    final int healthPercent = _calculateHealthPercent(level);
    final String healthStatus = _getHealthStatus(healthPercent);

    debugPrint("🧠 Health %: $healthPercent");
    debugPrint("💚 Health Status: $healthStatus");

    final int cycles = _estimateCycles(level);
    debugPrint("🔄 Estimated Cycles: $cycles");

    final result = BatteryHealthModel(
      batteryLevel: level,
      batteryState: stateStr,
      voltage: voltage,
      temperature: temperature,
      chargingCycles: cycles,
      manufactureDate: 'N/A',
      designCapacity: designCapacity,
      currentCapacity: currentCapacity,
      healthStatus: healthStatus,
      healthPercent: healthPercent,
      deviceModel: deviceModel,
      osVersion: osVersion,
    );

    debugPrint("✅ BatteryHealthModel ready: ${result.toString()}");

    return result;
  }

  String _mapBatteryState(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      default:
        return 'Unknown';
    }
  }

  int _calculateHealthPercent(int level) {
    if (level >= 80) return 90;
    if (level >= 60) return 75;
    if (level >= 40) return 60;
    return 45;
  }

  String _getHealthStatus(int healthPercent) {
    if (healthPercent >= 80) return 'Good';
    if (healthPercent >= 60) return 'Fair';
    return 'Poor';
  }

  int _estimateCycles(int level) {
    return 200 + ((100 - level) * 2);
  }
}