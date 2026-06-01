import 'dart:math';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart'
    as myModel;
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';

class DataUsageRepository {
  static const _channel = MethodChannel('com.battery_saver/network_stats');

  static const Map<String, _AppInfo> _knownApps = {
    'com.whatsapp':
        _AppInfo('WhatsApp', AppIcons.whatsappicon, Color(0xFF26D626)),
    'com.facebook.katana':
        _AppInfo('Facebook', AppIcons.facebookicon, Color(0xFF0392EB)),
    'com.instagram.android':
        _AppInfo('Instagram', AppIcons.instagramicon, Color(0xFFEA3918)),
    'com.google.android.youtube':
        _AppInfo('YouTube', AppIcons.youtubeicon, Color(0xFFEA0202)),
  };

  /// -------------------------
  /// Permission check
  /// -------------------------
  Future<bool> hasPermission() async {
    try {
      debugPrint('📡 [DATA_USAGE] Checking permission...');

      final result =
          await _channel.invokeMethod<bool>('hasPermission');

      debugPrint(' [DATA_USAGE] Permission result: $result');

      return result ?? false;
    } catch (e) {
      debugPrint('❌ [DATA_USAGE] Permission error: $e');
      return false;
    }
  }

  /// -------------------------
  /// Request permission
  /// -------------------------
  void requestPermission() {
    debugPrint('📡 [DATA_USAGE] Opening usage permission settings');
    UsageStats.grantUsagePermission();
  }

  /// -------------------------
  /// MAIN FUNCTION
  /// -------------------------
  Future<myModel.DataUsageModel> getUsage(
      myModel.UsagePeriod period) async {
    try {
      debugPrint('====================================');
      debugPrint('📊 [DATA_USAGE] START SCAN');
      debugPrint('📊 Period: $period');

      final now = DateTime.now();

      final startDate = period == myModel.UsagePeriod.today
          ? DateTime(now.year, now.month, now.day)
          : DateTime(now.year, now.month, 1);

      final startMs = startDate.millisecondsSinceEpoch;
      final endMs = now.millisecondsSinceEpoch;

      debugPrint('📊 Start: $startDate');
      debugPrint('📊 End: $now');

      /// -------------------------
      /// MOBILE DATA
      /// -------------------------
      final mobileRaw = await _channel.invokeMethod<Map>(
        'getTotalMobileData',
        {'startTime': startMs, 'endTime': endMs},
      );

      final mobileRx = (mobileRaw?['rx'] as num?)?.toInt() ?? 0;
      final mobileTx = (mobileRaw?['tx'] as num?)?.toInt() ?? 0;

      final totalMobileMB = (mobileRx + mobileTx) / (1024 * 1024);

      debugPrint(
          '📶 Mobile RX: $mobileRx | TX: $mobileTx | MB: $totalMobileMB');

      /// -------------------------
      /// WIFI DATA
      /// -------------------------
      final wifiRaw = await _channel.invokeMethod<Map>(
        'getTotalWifiData',
        {'startTime': startMs, 'endTime': endMs},
      );

      final wifiRx = (wifiRaw?['rx'] as num?)?.toInt() ?? 0;
      final wifiTx = (wifiRaw?['tx'] as num?)?.toInt() ?? 0;

      final totalWifiMB = (wifiRx + wifiTx) / (1024 * 1024);

      debugPrint(
          '📶 WiFi RX: $wifiRx | TX: $wifiTx | MB: $totalWifiMB');

      final totalMB = totalMobileMB + totalWifiMB;

      debugPrint('📊 TOTAL USAGE MB: $totalMB');

      /// -------------------------
      /// APP USAGE
      /// -------------------------
      final appModels = await _getAppUsage(startMs, endMs);

      debugPrint('📱 Apps loaded: ${appModels.length}');

      for (final a in appModels) {
        debugPrint('📱 ${a.name} => ${a.usageMB} MB');
      }

      /// -------------------------
      /// CHART DATA
      /// -------------------------
      final dailyData = await _getDailyChartData(
        startMs,
        endMs,
        period,
      );

      debugPrint('📊 Chart points: ${dailyData.length}');

      debugPrint('====================================');

      return myModel.DataUsageModel(
        totalUsedGB: totalMB / 1024,
        wifiUsageGB: totalWifiMB / 1024,
        dailyDataMB: dailyData,
        appUsages: appModels,
        period: period,
      );
    } catch (e) {
      debugPrint('❌ [DATA_USAGE] ERROR: $e');
      return _getMockData(period);
    }
  }

  /// -------------------------
  /// APP USAGE
  /// -------------------------
  Future<List<myModel.AppUsageModel>> _getAppUsage(
      int startMs, int endMs) async {
    try {
      debugPrint('📱 Fetching app usage...');

      final rawList = await _channel.invokeMethod<List>(
        'getAppNetworkData',
        {
          'startTime': startMs,
          'endTime': endMs,
          'packageNames': _knownApps.keys.toList(),
        },
      );

      debugPrint('📱 Raw app response: $rawList');

      if (rawList == null) {
        debugPrint('⚠️ No app data received');
        return _fallbackAppUsage();
      }

      final List<myModel.AppUsageModel> result = [];
      double maxMB = 1;

      for (final raw in rawList) {
        final map = Map<String, dynamic>.from(raw as Map);

        final pkg = map['packageName'] as String?;
        final info = pkg != null ? _knownApps[pkg] : null;

        if (info == null) continue;

        final total = (map['total'] as num?)?.toInt() ?? 0;
        final usageMB = total / (1024 * 1024);

        if (usageMB > maxMB) maxMB = usageMB;

        result.add(myModel.AppUsageModel(
          name: info.name,
          svgAssetPath: info.icon,
          usageMB: usageMB,
          maxMB: 0,
          barColor: info.color,
        ));
      }

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

      debugPrint('📱 Final mapped apps: ${mapped.length}');

      return mapped;
    } catch (e) {
      debugPrint('❌ App usage error: $e');
      return _fallbackAppUsage();
    }
  }

  /// -------------------------
  /// CHART DATA
  /// -------------------------
  Future<List<double>> _getDailyChartData(
      int startMs, int endMs, myModel.UsagePeriod period) async {
    try {
      final interval =
          period == myModel.UsagePeriod.today ? 1 : 24;

      final rawList = await _channel.invokeMethod<List>(
        'getDailyData',
        {
          'startTime': startMs,
          'endTime': endMs,
          'intervalHours': interval,
        },
      );

      debugPrint('📊 Raw chart: $rawList');

      if (rawList == null || rawList.isEmpty) {
        return _fallbackChart(period);
      }

      return rawList.map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        final total = (map['total'] as num?)?.toInt() ?? 0;
        return total / (1024 * 1024);
      }).toList();
    } catch (e) {
      debugPrint('❌ Chart error: $e');
      return _fallbackChart(period);
    }
  }

  /// -------------------------
  /// FALLBACKS
  /// -------------------------
  List<double> _fallbackChart(myModel.UsagePeriod period) {
    final rng = Random();
    final count = period == myModel.UsagePeriod.today ? 24 : 30;
    return List.generate(count, (_) => 50 + rng.nextDouble() * 200);
  }

  List<myModel.AppUsageModel> _fallbackAppUsage() {
    return _knownApps.entries
        .map((e) => myModel.AppUsageModel(
              name: e.value.name,
              svgAssetPath: e.value.icon,
              usageMB: 0,
              maxMB: 1,
              barColor: e.value.color,
            ))
        .toList();
  }

  myModel.DataUsageModel _getMockData(
      myModel.UsagePeriod period) {
    return myModel.DataUsageModel(
      totalUsedGB: 2.0,
      wifiUsageGB: 1.0,
      dailyDataMB: List.generate(24, (i) => i * 10.0),
      appUsages: _fallbackAppUsage(),
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