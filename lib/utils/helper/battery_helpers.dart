import 'package:flutter/material.dart';

enum BatteryHealthStatus { critical, low, moderate, good, full }

BatteryHealthStatus healthFromLevel(int level) {
  if (level >= 90) return BatteryHealthStatus.full;
  if (level >= 60) return BatteryHealthStatus.good;
  if (level >= 30) return BatteryHealthStatus.moderate;
  if (level >= 10) return BatteryHealthStatus.low;
  return BatteryHealthStatus.critical;
}

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