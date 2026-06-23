import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────
///  Battery Health Levels
/// ─────────────────────────────────────────────
enum BatteryHealthStatus { critical, low, moderate, good, full }

BatteryHealthStatus healthFromLevel(int level) {
  if (level >= 90) return BatteryHealthStatus.full;
  if (level >= 60) return BatteryHealthStatus.good;
  if (level >= 30) return BatteryHealthStatus.moderate;
  if (level >= 10) return BatteryHealthStatus.low;
  return BatteryHealthStatus.critical;
}

/// ─────────────────────────────────────────────
///  UI Labels
/// ─────────────────────────────────────────────
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

/// ─────────────────────────────────────────────
///  UI Colors
/// ─────────────────────────────────────────────
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

/// ─────────────────────────────────────────────
///  Battery Modes (IMPORTANT FIX)
/// ─────────────────────────────────────────────
/// 0 = Normal
/// 1 = Power Saving
/// 2 = Super Saving
/// 3 = Custom
enum BatteryMode { normal, powerSaving, superSaving, custom }

/// ─────────────────────────────────────────────
///  Remaining Time Estimator (FIXED LOGIC)
/// ─────────────────────────────────────────────
String remainingTimeFromLevel(
  int level, {
  BatteryMode mode = BatteryMode.normal,
}) {
  if (level <= 0) return '--';

  const double normalHours = 10.0;
  const double powerSavingHours = 18.0;
  const double superSavingHours = 30.0;
  const double customHours = 14.0; 

  double totalHours;

  switch (mode) {
    case BatteryMode.powerSaving:
      totalHours = powerSavingHours;
      break;

    case BatteryMode.superSaving:
      totalHours = superSavingHours;
      break;

    case BatteryMode.custom:
      totalHours = customHours;
      break;

    case BatteryMode.normal:
    default:
      totalHours = normalHours;
  }

  final totalMinutes = (level / 100 * totalHours * 60).round();
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours > 0) return '${hours}h ${minutes}m left';
  return '${minutes}m left';
}

/// ─────────────────────────────────────────────
///  Extra Health Color (optional alternative)
/// ─────────────────────────────────────────────
Color healthColor(BatteryHealthStatus status) {
  switch (status) {
    case BatteryHealthStatus.full:
      return Colors.green;
    case BatteryHealthStatus.good:
      return Colors.lightGreen;
    case BatteryHealthStatus.moderate:
      return Colors.orange;
    case BatteryHealthStatus.low:
      return Colors.deepOrange;
    case BatteryHealthStatus.critical:
    default:
      return Colors.red;
  }
}