import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class JunkScannerService {
  static const _channel = MethodChannel(
    'com.example.battery_saver_app/junk_scanner',
  );

  // ─────────────────────────────────────────────
  // SCAN METHODS
  // ─────────────────────────────────────────────

  static Future<double> getCacheJunkMB() async {
    try {
      final bytes = await _channel.invokeMethod<int>('getCacheSize') ?? 0;
      final mb = bytes / (1024 * 1024);
      debugPrint('[JUNK] Cache: ${mb.toStringAsFixed(2)} MB');
      return mb;
    } catch (e) {
      debugPrint('[JUNK] getCacheSize error: $e');
      return 0.0;
    }
  }

  static Future<double> getResidualJunkMB() async {
    try {
      final bytes = await _channel.invokeMethod<int>('getResidualSize') ?? 0;
      final mb = bytes / (1024 * 1024);
      debugPrint('[JUNK] Residual: ${mb.toStringAsFixed(2)} MB');
      return mb;
    } catch (e) {
      debugPrint('[JUNK] getResidualSize error: $e');
      return 0.0;
    }
  }

  static Future<double> getAPKJunkMB() async {
    try {
      final bytes = await _channel.invokeMethod<int>('getApkSize') ?? 0;
      final mb = bytes / (1024 * 1024);
      debugPrint('[JUNK] APK: ${mb.toStringAsFixed(2)} MB');
      return mb;
    } catch (e) {
      debugPrint('[JUNK] getApkSize error: $e');
      return 0.0;
    }
  }

  static Future<double> getTrackedFilesMB() async {
    try {
      final bytes = await _channel.invokeMethod<int>('getTrackedSize') ?? 0;
      final mb = bytes / (1024 * 1024);
      debugPrint('[JUNK] Tracked: ${mb.toStringAsFixed(2)} MB');
      return mb;
    } catch (e) {
      debugPrint('[JUNK] getTrackedSize error: $e');
      return 0.0;
    }
  }

  static Future<MemoryInfo> getMemoryInfo() async {
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>('getMemoryInfo');
      return MemoryInfo.fromMap(data ?? {});
    } catch (e) {
      debugPrint('[JUNK] getMemoryInfo error: $e');
      return MemoryInfo.zero();
    }
  }

  // ─────────────────────────────────────────────
  // SCAN ALL — single Kotlin call, faster
  // ─────────────────────────────────────────────
  static Future<JunkScanResult> scanAll() async {
    debugPrint('===== SCAN START =====');
    try {
      final data = await _channel.invokeMapMethod<String, dynamic>('scanAll');
      final result = JunkScanResult.fromMap(data ?? {});
      debugPrint('===== SCAN DONE =====');
      debugPrint(result.toString());
      return result;
    } catch (e) {
      debugPrint('[JUNK] scanAll error: $e');
      return JunkScanResult.zero();
    }
  }

  // ─────────────────────────────────────────────
  // CLEAN METHODS
  // ─────────────────────────────────────────────
  static Future<void> cleanCacheJunk() async {
    try {
      await _channel.invokeMethod('cleanCache');
    } catch (e) {
      debugPrint('[CLEAN] cleanCache error: $e');
    }
  }

  static Future<void> cleanResidualJunk() async {
    try {
      await _channel.invokeMethod('cleanResidual');
    } catch (e) {
      debugPrint('[CLEAN] cleanResidual error: $e');
    }
  }

  static Future<void> cleanAPKJunk() async {
    try {
      await _channel.invokeMethod('cleanApk');
    } catch (e) {
      debugPrint('[CLEAN] cleanApk error: $e');
    }
  }

  static Future<void> cleanTrackedFiles() async {
    try {
      await _channel.invokeMethod('cleanTracked');
    } catch (e) {
      debugPrint('[CLEAN] cleanTracked error: $e');
    }
  }

  // Memory OS-controlled hai, clean nahi hoti Flutter se
  static Future<void> cleanMemoryJunk() async {
    debugPrint('[CLEAN] Memory is OS-controlled');
  }

  // ─────────────────────────────────────────────
  // FORMAT HELPER
  // ─────────────────────────────────────────────
  static String formatSize(double mb) {
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} GB';
    if (mb < 0.1) return '0.0 MB';
    return '${mb.toStringAsFixed(1)} MB';
  }

  static String formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return formatSize(mb);
  }
}

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class MemoryInfo {
  final int totalRam;
  final int availableRam;
  final int usedRam;
  final int threshold;
  final bool isLowMemory;

  const MemoryInfo({
    required this.totalRam,
    required this.availableRam,
    required this.usedRam,
    required this.threshold,
    required this.isLowMemory,
  });

  factory MemoryInfo.fromMap(Map<String, dynamic> map) {
    return MemoryInfo(
      totalRam:     (map['totalRam']     as int?) ?? 0,
      availableRam: (map['availableRam'] as int?) ?? 0,
      usedRam:      (map['usedRam']      as int?) ?? 0,
      threshold:    (map['threshold']    as int?) ?? 0,
      isLowMemory:  ((map['isLowMemory'] as int?) ?? 0) == 1,
    );
  }

  factory MemoryInfo.zero() => const MemoryInfo(
    totalRam: 0, availableRam: 0, usedRam: 0,
    threshold: 0, isLowMemory: false,
  );

  double get totalRamMB     => totalRam     / (1024 * 1024);
  double get availableRamMB => availableRam / (1024 * 1024);
  double get usedRamMB      => usedRam      / (1024 * 1024);

  double get usedPercent =>
      totalRam > 0 ? (usedRam / totalRam * 100) : 0.0;
}

class JunkScanResult {
  final int cacheBytes;
  final int residualBytes;
  final int apkBytes;
  final int trackedBytes;
  final int usedRam;
  final int totalRam;
  final int availableRam;

  const JunkScanResult({
    required this.cacheBytes,
    required this.residualBytes,
    required this.apkBytes,
    required this.trackedBytes,
    required this.usedRam,
    required this.totalRam,
    required this.availableRam,
  });

  factory JunkScanResult.fromMap(Map<String, dynamic> map) {
    return JunkScanResult(
      cacheBytes:    (map['cacheBytes']    as int?) ?? 0,
      residualBytes: (map['residualBytes'] as int?) ?? 0,
      apkBytes:      (map['apkBytes']      as int?) ?? 0,
      trackedBytes:  (map['trackedBytes']  as int?) ?? 0,
      usedRam:       (map['usedRam']       as int?) ?? 0,
      totalRam:      (map['totalRam']      as int?) ?? 0,
      availableRam:  (map['availableRam']  as int?) ?? 0,
    );
  }

  factory JunkScanResult.zero() => const JunkScanResult(
    cacheBytes: 0, residualBytes: 0, apkBytes: 0,
    trackedBytes: 0, usedRam: 0, totalRam: 0, availableRam: 0,
  );

  double get cacheMB    => cacheBytes    / (1024 * 1024);
  double get residualMB => residualBytes / (1024 * 1024);
  double get apkMB      => apkBytes      / (1024 * 1024);
  double get trackedMB  => trackedBytes  / (1024 * 1024);
  double get usedRamMB  => usedRam       / (1024 * 1024);
  double get totalRamMB => totalRam      / (1024 * 1024);

  double get totalJunkMB => cacheMB + residualMB + apkMB + trackedMB;

  /// UI ke liye list — Memory alag dikhao (RAM info hai, junk nahi)
  List<Map<String, dynamic>> toUIList() => [
    {'label': 'Cache Junk',      'mb': cacheMB},
    {'label': 'Residual Junk',   'mb': residualMB},
    {'label': 'Tracked Files',   'mb': trackedMB},
    {'label': 'APK Files',       'mb': apkMB},
    {'label': 'Memory Used',     'mb': usedRamMB},  // info only
  ];

  @override
  String toString() =>
      '[JunkScan] Cache:${cacheMB.toStringAsFixed(1)} '
      'Residual:${residualMB.toStringAsFixed(1)} '
      'APK:${apkMB.toStringAsFixed(1)} '
      'Tracked:${trackedMB.toStringAsFixed(1)} '
      'RAM:${usedRamMB.toStringAsFixed(0)}/${totalRamMB.toStringAsFixed(0)} MB';
}