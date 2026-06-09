import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:flutter/services.dart';

class DeviceDataService {
  static const _channel      = MethodChannel('com.example.battery_saver_app/device_storage');
  static const _cacheChannel = MethodChannel('com.example.battery_saver_app/device');

  Future<CleanResultData> fetchRealData() async {
    try {
      print("🚀 DEVICE SCAN STARTED");

      // Char calls ek saath parallel — fastest approach
      final results = await Future.wait([
        _channel.invokeMethod('getStorageStats'),           // 0 — junk size
        _cacheChannel.invokeMethod<int>('getRunningAppsCount'), // 1 — apps count
        _cacheChannel.invokeMethod('getCacheFiles'),        // 2 — cache file list
        _cacheChannel.invokeMethod('getResidualFiles'),     // 3 — residual file list
      ]);

      print("📦 RAW RESULTS RECEIVED");

      // ── Parse results ──────────────────────────────────────────
      final stats     = Map<String, dynamic>.from(results[0] as Map);
      final appsCount = (results[1] as int?) ?? 0;

      final rawCache    = (results[2] as List?) ?? [];
      final rawResidual = (results[3] as List?) ?? [];

      final cacheFileList    = rawCache   .map((e) => DeviceFile.fromMap(e as Map)).toList();
      final residualFileList = rawResidual.map((e) => DeviceFile.fromMap(e as Map)).toList();

      print("📊 STATS MAP:        $stats");
      print("📱 APPS COUNT:       $appsCount");
      print("🗂 CACHE FILES:      ${cacheFileList.length} files");
      print("🧠 RESIDUAL FILES:   ${residualFileList.length} files");

      // ── Size calculate karo ────────────────────────────────────
      final junkBytes     = (stats['junkFiles'] as int?) ?? 0;

      // Actual file lists se size — native number pe depend nahi
      final cacheSizeBytes    = cacheFileList   .fold<int>(0, (s, f) => s + f.sizeBytes);
      final residualSizeBytes = residualFileList.fold<int>(0, (s, f) => s + f.sizeBytes);

      print("🧮 JUNK BYTES:     $junkBytes");
      print("🧮 CACHE BYTES:    $cacheSizeBytes");
      print("🧮 RESIDUAL BYTES: $residualSizeBytes");

      String toMB(int bytes) =>
          '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';

      final totalBytes = junkBytes + cacheSizeBytes + residualSizeBytes;
      final beforeGB   = totalBytes / (1024 * 1024 * 1024);
      final afterGB    = beforeGB * 0.3;
      const totalGB    = 64.0;

      print("💾 TOTAL BYTES: $totalBytes");

      return CleanResultData(
        junkRemoved:      toMB(junkBytes),
        appsClosed:       '$appsCount Apps',
        cacheCleared:     toMB(cacheSizeBytes),
        residualFiles:    toMB(residualSizeBytes),
        beforeGB:         beforeGB,
        afterGB:          afterGB,
        totalGB:          totalGB,
        cacheFileList:    cacheFileList,     // ✅
        residualFileList: residualFileList,  // ✅
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