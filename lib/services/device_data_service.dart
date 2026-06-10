import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:flutter/services.dart';

class DeviceDataService {
  static const _channel      = MethodChannel('com.example.battery_saver_app/device_storage');
  static const _cacheChannel = MethodChannel('com.example.battery_saver_app/device');

  Future<CleanResultData> fetchRealData() async {
    try {
      print("🚀 DEVICE SCAN STARTED");

      final results = await Future.wait([
        _channel.invokeMethod('getStorageStats'),
        _cacheChannel.invokeMethod<int>('getRunningAppsCount'),
        _cacheChannel.invokeMethod('getCacheFiles'),
        _cacheChannel.invokeMethod('getResidualFiles'),
      ]);

      print("📦 RAW RESULTS RECEIVED");

      final stats     = Map<String, dynamic>.from(results[0] as Map);
      final appsCount = (results[1] as int?) ?? 0;

      final rawCache    = (results[2] as List?) ?? [];
      final rawResidual = (results[3] as List?) ?? [];

      // Size calculate karo file lists se
      int calcSizeBytes(List raw) {
        return raw.fold<int>(0, (sum, e) {
          final map = e as Map;
          return sum + ((map['size'] as int?) ?? 0);
        });
      }

      final junkBytes         = (stats['junkFiles'] as int?) ?? 0;
      final cacheSizeBytes    = calcSizeBytes(rawCache);
      final residualSizeBytes = calcSizeBytes(rawResidual);

      print("📱 APPS COUNT:       $appsCount");
      print("🧮 JUNK BYTES:       $junkBytes");
      print("🧮 CACHE BYTES:      $cacheSizeBytes");
      print("🧮 RESIDUAL BYTES:   $residualSizeBytes");

      String toMB(int bytes) =>
          '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';

      final totalBytes = junkBytes + cacheSizeBytes + residualSizeBytes;
      final beforeGB   = totalBytes / (1024 * 1024 * 1024);
      final afterGB    = beforeGB * 0.3;
      const totalGB    = 64.0;

      print("💾 TOTAL BYTES: $totalBytes");

      // ✅ Naye CleanResultData ke saath — extra fields nahi
      return CleanResultData(
        junkRemoved:   toMB(junkBytes),
        appsClosed:    '$appsCount Apps',
        cacheCleared:  toMB(cacheSizeBytes),
        residualFiles: toMB(residualSizeBytes),
        beforeGB:      beforeGB,
        afterGB:       afterGB,
        totalGB:       totalGB,
      );
    } on PlatformException catch (e) {
      throw Exception('Storage scan failed: ${e.message}');
    }
  }

  Future<int> cleanFiles() async {
    try {
      final result = await _channel.invokeMethod<int>('cleanResidualFiles');
      return result ?? 0;
    } on PlatformException catch (e) {
      throw Exception('Clean failed: ${e.message}');
    }
  }
}