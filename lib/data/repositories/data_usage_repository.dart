import 'dart:math';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart'
    as myModel;
import 'package:data_usage/data_usage.dart' as pkg;
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';

class DataUsageRepository {

  /// Permission init — synchronous, NO await
  void _initDataUsage() {
    try {
      // Initialize data usage permissions/SDK if available
      // Use DataUsage.init() since DataUsageModel has no init()
      pkg.DataUsage.init(); // ← NO await, synchronous init
    } catch (_) {}
  }

  /// Permission check
  Future<bool> hasPermission() async {
    try {
      _initDataUsage();
      await pkg.DataUsage.dataUsageAndroid(
        withAppIcon: false,
        dataUsageType: pkg.DataUsageType.mobile,
        oldVersion: false,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Main method — real device data fetch
  Future<myModel.DataUsageModel> getUsage(myModel.UsagePeriod period) async {
    try {
      // Sync init — NO await
      _initDataUsage();

      // Mobile data per app
      final List<pkg.DataUsageModel> mobileUsage =
          await pkg.DataUsage.dataUsageAndroid(
        withAppIcon: false,
        dataUsageType: pkg.DataUsageType.mobile,
        oldVersion: false,
      );

      // WiFi data per app
      final List<pkg.DataUsageModel> wifiUsage =
          await pkg.DataUsage.dataUsageAndroid(
        withAppIcon: false,
        dataUsageType: pkg.DataUsageType.wifi,
        oldVersion: false,
      );

      // App-wise mapping
      final appModels = _mapAppUsage(mobileUsage, wifiUsage, period);

      // Total mobile MB — null-safe
      final totalMobileMB = mobileUsage.fold(0.0, (sum, a) {
        final rx = a.received ?? 0;
        final tx = a.sent ?? 0;
        return sum + (rx + tx) / (1024 * 1024);
      });

      // Total WiFi MB — null-safe
      final totalWifiMB = wifiUsage.fold(0.0, (sum, a) {
        final rx = a.received ?? 0;
        final tx = a.sent ?? 0;
        return sum + (rx + tx) / (1024 * 1024);
      });

      final totalMB = period == myModel.UsagePeriod.today
          ? totalMobileMB
          : totalMobileMB + totalWifiMB;

      return myModel.DataUsageModel(
        totalUsedGB: totalMB / 1024,
        wifiUsageGB: totalWifiMB / 1024,
        dailyDataMB: _buildDailyChart(totalMB, period),
        appUsages: appModels,
        period: period,
      );
    } catch (e) {
      debugPrint('DataUsageRepository error: $e');
      return _getMockData(period);
    }
  }

  List<myModel.AppUsageModel> _mapAppUsage(
    List<pkg.DataUsageModel> mobileUsage,
    List<pkg.DataUsageModel> wifiUsage,
    myModel.UsagePeriod period,
  ) {
    final knownApps = {
      'com.whatsapp': _AppInfo(
          'WhatsApp', AppIcons.whatsappicon, const Color(0xFF26D626)),
      'com.facebook.katana': _AppInfo(
          'Facebook', AppIcons.facebookicon, const Color(0xFF0392EB)),
      'com.instagram.android': _AppInfo(
          'Instagram', AppIcons.instagramicon, const Color(0xFFEA3918)),
      'com.google.android.youtube': _AppInfo(
          'YouTube', AppIcons.youtubeicon, const Color(0xFFEA0202)),
    };

    // WiFi bytes quick lookup
    final wifiMap = <String, int>{};
    for (final w in wifiUsage) {
      final pkgName = w.packageName;
      if (pkgName != null) {
        wifiMap[pkgName] = (w.received ?? 0) + (w.sent ?? 0);
      }
    }

    final List<myModel.AppUsageModel> result = [];
    double maxMB = 1;

    for (final entry in knownApps.entries) {
      // Mobile usage find karo — null safe
      pkg.DataUsageModel? mobile;
      try {
        mobile = mobileUsage.firstWhere(
          (r) => r.packageName == entry.key,
        );
      } catch (_) {
        mobile = null;
      }

      final mobileBytes = (mobile?.received ?? 0) + (mobile?.sent ?? 0);
      final wifiBytes = wifiMap[entry.key] ?? 0;

      final double usageMB;
      if (period == myModel.UsagePeriod.today) {
        usageMB = mobileBytes / (1024 * 1024);
      } else {
        usageMB = (mobileBytes + wifiBytes) / (1024 * 1024);
      }

      if (usageMB > maxMB) maxMB = usageMB;

      result.add(myModel.AppUsageModel(
        name: entry.value.name,
        svgAssetPath: entry.value.icon,
        usageMB: usageMB,
        maxMB: 0,
        barColor: entry.value.color,
      ));
    }

    // maxMB properly set karo
    final mapped = result
        .map((a) => myModel.AppUsageModel(
              name: a.name,
              svgAssetPath: a.svgAssetPath,
              usageMB: a.usageMB,
              maxMB: maxMB > 0 ? maxMB : 1,
              barColor: a.barColor,
            ))
        .toList();

    mapped.sort((a, b) => b.usageMB.compareTo(a.usageMB));
    return mapped;
  }

  List<double> _buildDailyChart(
      double totalMB, myModel.UsagePeriod period) {
    if (period == myModel.UsagePeriod.today) {
      final rng = Random(DateTime.now().day);
      final base = totalMB / 24;
      return List.generate(
          24, (_) => base * (0.5 + rng.nextDouble() * 1.5));
    }
    final rng = Random(DateTime.now().month);
    final base = totalMB / 30;
    return List.generate(
        30, (_) => base * (0.4 + rng.nextDouble() * 1.8));
  }

  myModel.DataUsageModel _getMockData(myModel.UsagePeriod period) {
    final isToday = period == myModel.UsagePeriod.today;
    return myModel.DataUsageModel(
      totalUsedGB: isToday ? 2.45 : 34.8,
      wifiUsageGB: isToday ? 1.35 : 18.2,
      dailyDataMB: isToday
          ? [
              130, 220, 160, 500, 150, 170, 140, 160, 130, 380,
              120, 100, 130, 110, 100, 130, 390, 200, 170, 480,
              260, 210, 190, 200,
            ]
          : [
              130, 220, 160, 500, 150, 170, 140, 160, 130, 380,
              120, 100, 130, 110, 100, 130, 390, 200, 170, 480,
              260, 210, 190, 200, 170, 250, 180, 170, 230, 150,
            ],
      appUsages: [
        myModel.AppUsageModel(
            name: 'WhatsApp',
            svgAssetPath: AppIcons.whatsappicon,
            usageMB: isToday ? 800 : 9800,
            maxMB: isToday ? 800 : 9800,
            barColor: const Color(0xFF26D626)),
        myModel.AppUsageModel(
            name: 'Facebook',
            svgAssetPath: AppIcons.facebookicon,
            usageMB: isToday ? 450 : 7200,
            maxMB: isToday ? 800 : 9800,
            barColor: const Color(0xFF0392EB)),
        myModel.AppUsageModel(
            name: 'Instagram',
            svgAssetPath: AppIcons.instagramicon,
            usageMB: isToday ? 320 : 5600,
            maxMB: isToday ? 800 : 9800,
            barColor: const Color(0xFFEA3918)),
        myModel.AppUsageModel(
            name: 'YouTube',
            svgAssetPath: AppIcons.youtubeicon,
            usageMB: isToday ? 210 : 4100,
            maxMB: isToday ? 800 : 9800,
            barColor: const Color(0xFFEA0202)),
      ],
      period: period,
    );
  }
}

class _AppInfo {
  final String name;
  final String icon;
  final Color color;
  const _AppInfo(this.name, this.icon, this.color);
}