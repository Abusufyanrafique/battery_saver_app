import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class JunkScannerService {

  // ─── SIZE HELPERS ────────────────────────────────────────────────────────────

  static Future<double> _dirSizeInMB(Directory dir) async {
    if (!dir.existsSync()) return 0.0;
    double totalBytes = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    } catch (_) {}
    return totalBytes / (1024 * 1024);
  }

  // ─── SCAN METHODS ────────────────────────────────────────────────────────────

  /// App cache — getTemporaryDirectory() (safe to delete)
  static Future<double> getCacheJunkMB() async {
    final dir = await getTemporaryDirectory();
    debugPrint('[JUNK] Cache dir: ${dir.path}');
    final size = await _dirSizeInMB(dir);
    debugPrint('[JUNK] Cache Junk: ${size.toStringAsFixed(2)} MB');
    return size;
  }

  /// Residual — .log / .tmp / .bak / .old / .temp files inside app support dir
  static Future<double> getResidualJunkMB() async {
    final appDir = await getApplicationSupportDirectory();
    double total = 0;
    const junkyExtensions = ['.log', '.tmp', '.bak', '.old', '.temp'];
    if (appDir.existsSync()) {
      await for (final entity in appDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = entity.path.toLowerCase();
          if (junkyExtensions.any((e) => ext.endsWith(e))) {
            total += await entity.length();
          }
        }
      }
    }
    debugPrint('[JUNK] Residual Junk: ${(total / (1024 * 1024)).toStringAsFixed(2)} MB');
    return total / (1024 * 1024);
  }

  /// Ad Junk — known ad/analytics folder names inside documents directory
  static Future<double> getAdJunkMB() async {
    final docDir = await getApplicationDocumentsDirectory();
    double total = 0;
    const adFolders = ['ads', 'ad_cache', 'analytics', 'tracking', 'mraid'];
    if (docDir.existsSync()) {
      await for (final entity in docDir.list(followLinks: false)) {
        if (entity is Directory) {
          final name = entity.path.split('/').last.toLowerCase();
          if (adFolders.any((f) => name.contains(f))) {
            total += await _dirSizeInMB(entity) * 1024 * 1024;
          }
        }
      }
    }
    debugPrint('[JUNK] Ad Junk: ${(total / (1024 * 1024)).toStringAsFixed(2)} MB');
    return total / (1024 * 1024);
  }

  /// APK Junk — external cache directories (Android only)
  static Future<double> getAPKJunkMB() async {
    if (!Platform.isAndroid) return 0.0;
    double total = 0;
    try {
      final dirs = await getExternalCacheDirectories();
      if (dirs != null) {
        for (final dir in dirs) {
          total += await _dirSizeInMB(dir);
        }
      }
    } catch (_) {}
    debugPrint('[JUNK] APK Junk: ${total.toStringAsFixed(2)} MB');
    return total;
  }

  /// Memory Junk — cached + buffer memory from /proc/meminfo (Android only)
  static Future<double> getMemoryJunkMB() async {
    if (Platform.isAndroid) {
      try {
        final file = File('/proc/meminfo');
        if (file.existsSync()) {
          final lines = await file.readAsLines();
          double cachedMB = 0;
          double buffersMB = 0;
          for (final line in lines) {
            if (line.startsWith('Cached:')) {
              final kb = double.tryParse(line.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              cachedMB = kb / 1024;
            }
            if (line.startsWith('Buffers:')) {
              final kb = double.tryParse(line.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              buffersMB = kb / 1024;
            }
          }
          final total = cachedMB + buffersMB;
          debugPrint('[JUNK] Memory Junk (Cached+Buffers): ${total.toStringAsFixed(2)} MB');
          return total;
        }
      } catch (_) {}
    }
    return 0.0;
  }

  // ─── CLEAN METHODS ───────────────────────────────────────────────────────────

  /// Delete all files inside temp directory and recreate it
  static Future<void> cleanCacheJunk() async {
    try {
      final dir = await getTemporaryDirectory();
      if (dir.existsSync()) {
        await for (final entity in dir.list(followLinks: false)) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      }
      debugPrint('[CLEAN] Cache Junk cleaned');
    } catch (_) {}
  }

  /// Delete .log/.tmp/.bak/.old/.temp files from app support directory
  static Future<void> cleanResidualJunk() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      const junkyExtensions = ['.log', '.tmp', '.bak', '.old', '.temp'];
      if (appDir.existsSync()) {
        await for (final entity in appDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final ext = entity.path.toLowerCase();
            if (junkyExtensions.any((e) => ext.endsWith(e))) {
              try { await entity.delete(); } catch (_) {}
            }
          }
        }
      }
      debugPrint('[CLEAN] Residual Junk cleaned');
    } catch (_) {}
  }

  /// Delete known ad/analytics folders from documents directory
  static Future<void> cleanAdJunk() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      const adFolders = ['ads', 'ad_cache', 'analytics', 'tracking', 'mraid'];
      if (docDir.existsSync()) {
        await for (final entity in docDir.list(followLinks: false)) {
          if (entity is Directory) {
            final name = entity.path.split('/').last.toLowerCase();
            if (adFolders.any((f) => name.contains(f))) {
              try { await entity.delete(recursive: true); } catch (_) {}
            }
          }
        }
      }
      debugPrint('[CLEAN] Ad Junk cleaned');
    } catch (_) {}
  }

  /// Delete all external cache directories (Android only)
  static Future<void> cleanAPKJunk() async {
    if (!Platform.isAndroid) return;
    try {
      final dirs = await getExternalCacheDirectories();
      if (dirs != null) {
        for (final dir in dirs) {
          if (dir.existsSync()) {
            await for (final entity in dir.list(followLinks: false)) {
              try { await entity.delete(recursive: true); } catch (_) {}
            }
          }
        }
      }
      debugPrint('[CLEAN] APK Junk cleaned');
    } catch (_) {}
  }

  /// Memory junk — OS level, no direct file delete possible.
  /// Dart GC trigger is best effort.
  static Future<void> cleanMemoryJunk() async {
    // No direct OS memory release possible from Flutter sandbox.
    // GC will handle it — nothing to delete on disk.
    debugPrint('[CLEAN] Memory Junk: OS managed, no direct action');
  }

  // ─── SCAN ALL ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> scanAll() async {
    debugPrint('[JUNK] ===== SCAN STARTED =====');
    final results = await Future.wait([
      getCacheJunkMB(),
      getResidualJunkMB(),
      getAdJunkMB(),
      getAPKJunkMB(),
      getMemoryJunkMB(),
    ]);
    debugPrint('[JUNK] ===== SCAN COMPLETED =====');
    return [
      {'label': 'Cache Junk',    'mb': results[0]},
      {'label': 'Residual Junk', 'mb': results[1]},
      {'label': 'Ad Junk',       'mb': results[2]},
      {'label': 'APK Junk',      'mb': results[3]},
      {'label': 'Memory Junk',   'mb': results[4]},
    ];
  }

  // ─── FORMAT ──────────────────────────────────────────────────────────────────

  static String formatSize(double mb) {
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} GB';
    return '${mb.toStringAsFixed(0)} MB';
  }
}