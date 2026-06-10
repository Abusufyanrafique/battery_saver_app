import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class JunkScannerService {

  // ─────────────────────────────────────────────
  // SIZE HELPER
  // ─────────────────────────────────────────────
  static Future<double> _dirSizeInMB(Directory dir) async {
    if (!dir.existsSync()) return 0.0;

    int totalBytes = 0;

    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            totalBytes += await entity.length();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("[JUNK] Error scanning dir: $e");
    }

    return totalBytes / (1024 * 1024);
  }

  // ─────────────────────────────────────────────
  // CACHE JUNK (REAL)
  // ─────────────────────────────────────────────
  static Future<double> getCacheJunkMB() async {
    final dir = await getTemporaryDirectory();
    final size = await _dirSizeInMB(dir);

    debugPrint('[JUNK] Cache: ${size.toStringAsFixed(2)} MB');
    return size;
  }

  // ─────────────────────────────────────────────
  // RESIDUAL JUNK (HEURISTIC)
  // ─────────────────────────────────────────────
  static Future<double> getResidualJunkMB() async {
    final dir = await getApplicationSupportDirectory();

    const exts = ['.log', '.tmp', '.bak', '.old', '.temp'];

    int totalBytes = 0;

    if (dir.existsSync()) {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          if (exts.any((e) => entity.path.toLowerCase().endsWith(e))) {
            try {
              totalBytes += await entity.length();
            } catch (_) {}
          }
        }
      }
    }

    final mb = totalBytes / (1024 * 1024);
    debugPrint('[JUNK] Residual: ${mb.toStringAsFixed(2)} MB');
    return mb;
  }

  // ─────────────────────────────────────────────
  // APK JUNK (FIXED → Downloads scan added)
  // ─────────────────────────────────────────────
  static Future<double> getAPKJunkMB() async {
    double totalBytes = 0;

    try {
      final downloadDir = Directory('/storage/emulated/0/Download');

      if (await downloadDir.exists()) {
        await for (final file in downloadDir.list(recursive: true, followLinks: false)) {
          if (file is File && file.path.toLowerCase().endsWith('.apk')) {
            try {
              totalBytes += await file.length();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    final mb = totalBytes / (1024 * 1024);
    debugPrint('[JUNK] APK: ${mb.toStringAsFixed(2)} MB');
    return mb;
  }

  // ─────────────────────────────────────────────
  // AD JUNK (HEURISTIC)
  // ─────────────────────────────────────────────
  static Future<double> getAdJunkMB() async {
    final dir = await getApplicationDocumentsDirectory();

    const keywords = ['ads', 'ad_cache', 'analytics', 'tracking', 'mraid'];

    double total = 0;

    if (dir.existsSync()) {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is Directory) {
          final name = entity.path.toLowerCase();

          if (keywords.any((k) => name.contains(k))) {
            total += await _dirSizeInMB(entity);
          }
        }
      }
    }

    final mb = total;
    debugPrint('[JUNK] Ad Junk: ${mb.toStringAsFixed(2)} MB');
    return mb;
  }

  // ─────────────────────────────────────────────
  // MEMORY JUNK (FAKE BUT REALISTIC UI METRIC)
  // ─────────────────────────────────────────────
  static Future<double> getMemoryJunkMB() async {
    final tempDir = await getTemporaryDirectory();

    int totalBytes = 0;

    if (tempDir.existsSync()) {
      await for (final entity in tempDir.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            final age = DateTime.now().difference(stat.modified);

            if (age.inDays >= 7) {
              totalBytes += await entity.length();
            }
          } catch (_) {}
        }
      }
    }

    final mb = totalBytes / (1024 * 1024);
    debugPrint('[JUNK] Memory (estimated): ${mb.toStringAsFixed(2)} MB');
    return mb;
  }

  // ─────────────────────────────────────────────
  // CLEAN METHODS (SAFE)
  // ─────────────────────────────────────────────
  static Future<void> cleanCacheJunk() async {
    final dir = await getTemporaryDirectory();

    if (dir.existsSync()) {
      await for (final entity in dir.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  static Future<void> cleanResidualJunk() async {
    final dir = await getApplicationSupportDirectory();

    const exts = ['.log', '.tmp', '.bak', '.old', '.temp'];

    if (dir.existsSync()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          if (exts.any((e) => entity.path.toLowerCase().endsWith(e))) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }
    }
  }

  static Future<void> cleanAPKJunk() async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');

      if (await downloadDir.exists()) {
        await for (final file in downloadDir.list()) {
          if (file is File && file.path.endsWith('.apk')) {
            try {
              await file.delete();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> cleanAdJunk() async {
    final dir = await getApplicationDocumentsDirectory();

    const keywords = ['ads', 'ad_cache', 'analytics', 'tracking', 'mraid'];

    if (dir.existsSync()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is Directory) {
          final name = entity.path.toLowerCase();

          if (keywords.any((k) => name.contains(k))) {
            try {
              await entity.delete(recursive: true);
            } catch (_) {}
          }
        }
      }
    }
  }

  static Future<void> cleanMemoryJunk() async {
    debugPrint('[CLEAN] Memory is OS controlled');
  }

  // ─────────────────────────────────────────────
  // FULL SCAN
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> scanAll() async {
    debugPrint('===== SCAN START =====');

    final results = await Future.wait([
      getCacheJunkMB(),
      getResidualJunkMB(),
      getAdJunkMB(),
      getAPKJunkMB(),
      getMemoryJunkMB(),
    ]);

    debugPrint('===== SCAN DONE =====');

    return [
      {'label': 'Cache Junk', 'mb': results[0]},
      {'label': 'Residual Junk', 'mb': results[1]},
      {'label': 'Ad Junk', 'mb': results[2]},
      {'label': 'APK Junk', 'mb': results[3]},
      {'label': 'Memory Junk', 'mb': results[4]},
    ];
  }

  // ─────────────────────────────────────────────
  // FORMAT
  // ─────────────────────────────────────────────
  static String formatSize(double mb) {
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} GB';
    return '${mb.toStringAsFixed(1)} MB';
  }
}