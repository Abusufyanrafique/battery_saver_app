import 'package:flutter/material.dart';

///  Battery Health Levels
enum BatteryHealthStatus { critical, low, moderate, good, full }

///  Convert battery level → status
BatteryHealthStatus healthFromLevel(int level) {
  if (level >= 90) return BatteryHealthStatus.full;
  if (level >= 60) return BatteryHealthStatus.good;
  if (level >= 30) return BatteryHealthStatus.moderate;
  if (level >= 10) return BatteryHealthStatus.low;
  return BatteryHealthStatus.critical;
}

///  Convert status → readable text (NEW)
String batteryHealthLabel(BatteryHealthStatus status) {
  switch (status) {
    case BatteryHealthStatus.full:
      return "Excellent";
    case BatteryHealthStatus.good:
      return "Good";
    case BatteryHealthStatus.moderate:
      return "Normal";
    case BatteryHealthStatus.low:
      return "Low";
    case BatteryHealthStatus.critical:
      return "Critical";
  }
}

///  Convert status → UI color (NEW)
Color batteryHealthColor(BatteryHealthStatus status) {
  switch (status) {
    case BatteryHealthStatus.full:
      return const Color(0xFF3DDC84);
    case BatteryHealthStatus.good:
      return const Color(0xFF8BC34A);
    case BatteryHealthStatus.moderate:
      return const Color(0xFFFFC107);
    case BatteryHealthStatus.low:
      return const Color(0xFFFF9800);
    case BatteryHealthStatus.critical:
      return const Color(0xFFFF5252);
  }
}

///  Remaining time estimator
String remainingTimeFromLevel(int level, {int modeIndex = 0}) {
  if (level <= 0) return '--';

  const double normalHours = 10.0;
  const double powerSavingHours = 18.0;
  const double superSavingHours = 30.0;

  double totalHours;

  switch (modeIndex) {
    case 1:
      totalHours = powerSavingHours;
      break;
    case 2:
      totalHours = superSavingHours;
      break;
    default:
      totalHours = normalHours;
  }

  final totalMinutes = (level / 100 * totalHours * 60).round();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours > 0) return '${hours}h ${minutes}m left';
  return '${minutes}m left';
}