import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class JunkScannerService {
  
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

  //  App cache — /cache directory (safe to delete)
  static Future<double> getCacheJunkMB() async {
    final dir = await getTemporaryDirectory();
    debugPrint('[JUNK] Cache dir: ${dir.path}');
    final size = await _dirSizeInMB(dir);
    debugPrint('[JUNK] Cache Junk: ${size.toStringAsFixed(2)} MB');
    return size;
  }

  //  Residual — /files ke andar sirf temp/log files
  static Future<double> getResidualJunkMB() async {
    final appDir = await getApplicationSupportDirectory();
    double total = 0;

    // Sirf specific extensions count karo — sab nahi
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

  //  Ad Junk — Documents directory mein sirf ad/analytics folders
  static Future<double> getAdJunkMB() async {
    final docDir = await getApplicationDocumentsDirectory();
    double total = 0;

    // Ad networks ke common folder names
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

  //  APK Junk — external cache only
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

  //  Memory Junk — device free memory (jo available nahi but recoverable hai)
  static Future<double> getMemoryJunkMB() async {
    // Android pe /proc/meminfo se real values
    if (Platform.isAndroid) {
      try {
        final file = File('/proc/meminfo');
        if (file.existsSync()) {
          final lines = await file.readAsLines();
          
          double cachedMB = 0;
          double buffersMB = 0;

          for (final line in lines) {
            // Cached memory — OS ne store kiya hai, app request pe free ho sakta hai
            if (line.startsWith('Cached:')) {
              final kb = double.tryParse(
                line.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ?? 0;
              cachedMB = kb / 1024;
            }
            // Buffers — disk I/O buffer
            if (line.startsWith('Buffers:')) {
              final kb = double.tryParse(
                line.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ?? 0;
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

  static String formatSize(double mb) {
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }

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
}