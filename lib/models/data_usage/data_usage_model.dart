import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum UsagePeriod { today, thisMonth }

class AppUsageModel extends Equatable {
  final String name;
  final String svgAssetPath;
  final double usageMB;
  final double maxMB;
  final Color barColor;

  const AppUsageModel({
    required this.name,
    required this.svgAssetPath,
    required this.usageMB,
    required this.maxMB,
    required this.barColor,
  });

  double get fraction => (usageMB / maxMB).clamp(0.0, 1.0);

  String get usageLabel {
    if (usageMB >= 1024) {
      return '${(usageMB / 1024).toStringAsFixed(2)} GB';
    }
    return '${usageMB.toStringAsFixed(0)} MB';
  }

  @override
  List<Object?> get props => [name, usageMB];
}

class DataUsageModel extends Equatable {
  final double totalUsedGB;
  final double wifiUsageGB;
  final List<double> dailyDataMB;      // 30 values for chart
  final List<AppUsageModel> appUsages;
  final UsagePeriod period;

  const DataUsageModel({
    required this.totalUsedGB,
    required this.wifiUsageGB,
    required this.dailyDataMB,
    required this.appUsages,
    required this.period,
  });

  String get totalUsedFormatted =>
      '${totalUsedGB.toStringAsFixed(2)} GB';

  String get wifiUsageFormatted =>
      '${wifiUsageGB.toStringAsFixed(2)} GB';

  @override
  List<Object?> get props => [totalUsedGB, wifiUsageGB, period];

  static Future<void> init() async {}
}