// file_manager_repository.dart

import 'dart:io';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── MODELS ──────────────────────────────────────────────────────────────────

class FileCategoryModel {
  final String name;
  final String size;
  final String imagePath;
  final int fileCount;

  const FileCategoryModel({
    required this.name,
    required this.size,
    required this.imagePath,
    required this.fileCount,
  });
}

class StorageDeviceModel {
  final String name;
  final double usedGB;
  final double totalGB;
  final bool isSdCard;

  const StorageDeviceModel({
    required this.name,
    required this.usedGB,
    required this.totalGB,
    this.isSdCard = false,
  });

  String get usedLabel  => _fmt(usedGB);
  String get totalLabel => _fmt(totalGB);
  double get percentage =>
      totalGB > 0 ? (usedGB / totalGB).clamp(0.0, 1.0) : 0.0;

  String _fmt(double gb) {
    if (gb <= 0) return '0 GB';
    if (gb < 1.0) return '${(gb * 1024).toStringAsFixed(0)} MB';
    return '${gb.toStringAsFixed(1)} GB';
  }
}

// ─── CONSTANTS ────────────────────────────────────────────────────────────────

const _kExts = {
  'Images':    ['jpg','jpeg','png','gif','webp','bmp','heic','heif','tiff','raw'],
  'Videos':    ['mp4','mkv','avi','mov','wmv','flv','3gp','webm','ts','m4v','mpg'],
  'Audio':     ['mp3','wav','aac','flac','m4a','ogg','wma','opus','amr'],
  'Documents': ['pdf','doc','docx','xls','xlsx','ppt','pptx','txt','csv','rtf','epub'],
  'APKs':      ['apk','xapk'],
};

const _kImages = {
  'Images':    'assets/images/file_manager/filemanagerimages.png',
  'Videos':    'assets/images/file_manager/filemanagervideos.png',
  'Audio':     'assets/images/file_manager/filemanageraudio.png',
  'Documents': 'assets/images/file_manager/filemanagernotes.png',
  'Downloads': 'assets/images/file_manager/filemanagerdownload.png',
  'APKs':      'assets/images/file_manager/filemanagerapk.png',
};

const _kBlockedSuffixes = [
  'Android/data',
  'Android/obb',
  'Android/media',
];

// ─── REPOSITORY ───────────────────────────────────────────────────────────────

class FileManagerRepository {
  List<FileCategoryModel>? _cache;
  bool _scanning = false;

  // ── PERMISSION ──────────────────────────────────────────────────────────────

  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.isGranted) return true;
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  // ── INTERNAL STORAGE ────────────────────────────────────────────────────────

  Future<StorageDeviceModel> fetchInternalStorage() async {
    try {
      final ds    = DiskSpacePlus();
      final total = await ds.getTotalDiskSpace ?? 0.0;
      final free  = await ds.getFreeDiskSpace  ?? 0.0;
      return StorageDeviceModel(
        name:    'Internal Storage',
        usedGB:  (total - free) / 1024,
        totalGB: total / 1024,
      );
    } catch (e) {
      debugLog('fetchInternalStorage error: $e');
      return const StorageDeviceModel(
        name: 'Internal Storage', usedGB: 0, totalGB: 0,
      );
    }
  }

  // ── SD CARD STORAGE (FIXED) ──────────────────────────────────────────────────
  // FIX 1: Root walk-up added (same as _resolveRoot)
  // FIX 2: Real size via `df` command instead of hardcoded 0

  Future<StorageDeviceModel?> fetchSdCardStorage() async {
    if (!Platform.isAndroid) return null;
    try {
      final dirs = await getExternalStorageDirectories();
      debugLog('[FM] external dirs count: ${dirs?.length}');
        // ── DEBUG ──
    print("🗂️ EXTERNAL DIRS COUNT: ${dirs?.length}");
    dirs?.forEach((d) => print("   📂 DIR: ${d.path}"));
      // SD card is second entry — if only 1 or none, no SD card
     if (dirs == null || dirs.length <= 1) {
  debugLog('[FM] No SD card — showing placeholder');
  return const StorageDeviceModel(
    name:    'SD Card',
    usedGB:  0,
    totalGB: 0,
    isSdCard: true,
  );
}

      // Walk up to find real SD card root (strip Android/data/... suffix)
      final parts = dirs[1].path.split('/');
      String? sdRoot;

      for (int i = parts.length; i >= 3; i--) {
        final candidate = parts.sublist(0, i).join('/');
        final d = Directory(candidate);
        if (!d.existsSync()) continue;

        final hasDCIM     = Directory('$candidate/DCIM').existsSync();
        final hasDownload = Directory('$candidate/Download').existsSync()
                         || Directory('$candidate/Downloads').existsSync();
        if (hasDCIM || hasDownload) {
          sdRoot = candidate;
          debugLog('[FM] SD root via walk-up: $sdRoot');
          break;
        }
      }

      // Fallback: use /storage/XXXX-XXXX directly
      if (sdRoot == null && parts.length >= 3) {
        final candidate = '/${parts[1]}/${parts[2]}';
        if (Directory(candidate).existsSync()) {
          sdRoot = candidate;
          debugLog('[FM] SD root via fallback: $sdRoot');
        }
      }

      if (sdRoot == null) {
        debugLog('[FM] SD root not resolved — returning null');
        return null;
      }

      // ── Get real SD card size via `df` ─────────────────────────────────────
      double totalGB = 0;
      double usedGB  = 0;

      try {
        final result = await Process.run('df', [sdRoot]);
        debugLog('[FM] df stdout: ${result.stdout}');

        if (result.exitCode == 0) {
          final lines = result.stdout
              .toString()
              .trim()
              .split('\n')
              .where((l) => l.isNotEmpty)
              .toList();

          // df output (Android):
          // Filesystem       1K-blocks    Used Available Use% Mounted on
          // /dev/block/...   xxxxxxxxx   xxxxx   xxxxxxx  xx% /storage/XXXX

          for (final line in lines) {
            // Skip header line
            if (line.startsWith('Filesystem') || line.startsWith('Sys')) continue;

            final cols = line.trim().split(RegExp(r'\s+'));
            if (cols.length >= 4) {
              final totalKB = double.tryParse(cols[1]) ?? 0;
              final usedKB  = double.tryParse(cols[2]) ?? 0;
              if (totalKB > 0) {
                totalGB = totalKB / (1024 * 1024);
                usedGB  = usedKB  / (1024 * 1024);
                debugLog('[FM] SD card size: used=${usedGB.toStringAsFixed(2)}GB total=${totalGB.toStringAsFixed(2)}GB');
                break;
              }
            }
          }
        }
      } catch (e) {
        debugLog('[FM] df error: $e');
      }

      return StorageDeviceModel(
        name:     'SD Card',
        usedGB:   usedGB,
        totalGB:  totalGB,
        isSdCard: true,
      );
    } catch (e) {
      debugLog('[FM] fetchSdCardStorage error: $e');
      return null;
    }
  }

  // ── FILE SCAN ────────────────────────────────────────────────────────────────

  Future<List<FileCategoryModel>> fetchFileCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) {
      debugLog('[FM] cache hit — returning ${_cache!.length} items');
      return _cache!;
    }

    if (_scanning) {
      debugLog('[FM] already scanning, skipping duplicate call');
      return _empty();
    }

    _scanning = true;
    _cache = null;

    try {
      final root = await _resolveRoot();
      debugLog('[FM] root=$root  exists=${Directory(root).existsSync()}');

      final maps = await _scanDirectory(root);
      debugLog('[FM] scan returned ${maps.length} categories');

      final models = maps.map((m) => FileCategoryModel(
        name:      m['name']      as String,
        size:      m['size']      as String,
        imagePath: m['imagePath'] as String,
        fileCount: m['fileCount'] as int,
      )).toList();

      _cache = models;
      return models;
    } catch (e, st) {
      debugLog('[FM] fetchFileCategories EXCEPTION: $e\n$st');
      return _empty();
    } finally {
      _scanning = false;
    }
  }

  // ── DIRECTORY SCAN ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _scanDirectory(String rootPath) async {
    final root = Directory(rootPath);
    if (!root.existsSync()) {
      debugLog('[FM] root does not exist: $rootPath');
      return _emptyMaps();
    }

    final counts = <String, int>{
      'Images': 0, 'Videos': 0, 'Audio': 0, 'Documents': 0, 'APKs': 0,
    };
    final bytes = <String, int>{
      'Images': 0, 'Videos': 0, 'Audio': 0, 'Documents': 0, 'APKs': 0,
    };
    int dlCount = 0, dlBytes = 0;

    final dlPaths = <String>[];
    for (final n in ['Download', 'Downloads']) {
      final p = '$rootPath/$n';
      if (Directory(p).existsSync()) dlPaths.add(p);
    }

    final stack  = <String>[rootPath];
    final depths = <String, int>{rootPath: 0};
    int   scanned = 0;

    while (stack.isNotEmpty) {
      final path  = stack.removeLast();
      final depth = depths[path] ?? 0;
      if (depth > 6) continue;

      final dirName = path.split('/').last;
      if (dirName.startsWith('.')) continue;

      bool blocked = false;
      for (final suffix in _kBlockedSuffixes) {
        if (path.endsWith(suffix) || path.contains('/$suffix/')) {
          blocked = true;
          break;
        }
      }
      if (blocked) continue;

      List<FileSystemEntity> entities;
      try {
        entities = await Directory(path).list(followLinks: false).toList();
      } catch (_) {
        continue;
      }

      for (final entity in entities) {
        if (entity is File) {
          scanned++;
          final fp  = entity.path;
          final dot = fp.lastIndexOf('.');
          if (dot == -1) continue;
          final ext = fp.substring(dot + 1).toLowerCase();

          int sz = 0;
          try { sz = entity.statSync().size; } catch (_) {}

          final inDl = dlPaths.any((dp) => fp.startsWith(dp));
          if (inDl) { dlCount++; dlBytes += sz; }

          for (final cat in _kExts.keys) {
            if (_kExts[cat]!.contains(ext)) {
              counts[cat] = counts[cat]! + 1;
              bytes[cat]  = bytes[cat]!  + sz;
              break;
            }
          }
        } else if (entity is Directory) {
          final name = entity.path.split('/').last;
          if (name.startsWith('.')) continue;

          bool subBlocked = false;
          for (final suffix in _kBlockedSuffixes) {
            if (entity.path.endsWith(suffix) ||
                entity.path.contains('/$suffix/')) {
              subBlocked = true;
              break;
            }
          }
          if (!subBlocked) {
            depths[entity.path] = depth + 1;
            stack.add(entity.path);
          }
        }
      }
    }

    debugLog('[FM] scanned $scanned files total');

    const order = ['Images', 'Videos', 'Audio', 'Documents', 'Downloads', 'APKs'];
    return order.map((cat) {
      if (cat == 'Downloads') {
        return {
          'name': 'Downloads',
          'size': _fmtBytes(dlBytes),
          'imagePath': _kImages['Downloads']!,
          'fileCount': dlCount,
        };
      }
      return {
        'name': cat,
        'size': _fmtBytes(bytes[cat] ?? 0),
        'imagePath': _kImages[cat]!,
        'fileCount': counts[cat] ?? 0,
      };
    }).toList();
  }

  // ── ROOT RESOLUTION ──────────────────────────────────────────────────────────

  Future<String> _resolveRoot() async {
    try {
      final dirs = await getExternalStorageDirectories();
      if (dirs != null && dirs.isNotEmpty) {
        final parts = dirs[0].path.split('/');
        for (int i = parts.length; i >= 3; i--) {
          final candidate = parts.sublist(0, i).join('/');
          final d = Directory(candidate);
          if (d.existsSync()) {
            final hasDCIM     = Directory('$candidate/DCIM').existsSync();
            final hasDownload = Directory('$candidate/Download').existsSync()
                             || Directory('$candidate/Downloads').existsSync();
            if (hasDCIM || hasDownload) {
              debugLog('[FM] resolved root: $candidate');
              return candidate;
            }
          }
        }
      }
    } catch (e) {
      debugLog('[FM] getExternalStorageDirectories failed: $e');
    }
    const fallback = '/storage/emulated/0';
    debugLog('[FM] using fallback root: $fallback');
    return fallback;
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────────

  void cancelScan() {
    _scanning = false;
    debugLog('[FM] cancelScan called');
  }

  List<FileCategoryModel> _empty() =>
      ['Images', 'Videos', 'Audio', 'Documents', 'Downloads', 'APKs']
          .map((n) => FileCategoryModel(
                name: n, size: '0 B',
                imagePath: _kImages[n]!, fileCount: 0,
              ))
          .toList();

  List<Map<String, dynamic>> _emptyMaps() =>
      ['Images', 'Videos', 'Audio', 'Documents', 'Downloads', 'APKs']
          .map((n) => {
                'name': n, 'size': '0 B',
                'imagePath': _kImages[n]!, 'fileCount': 0,
              })
          .toList();

  static String _fmtBytes(int b) {
    if (b <= 0)         return '0 B';
    if (b < 1048576)    return '${(b / 1024).toStringAsFixed(0)} KB';
    if (b < 1073741824) return '${(b / 1048576).toStringAsFixed(1)} MB';
    return '${(b / 1073741824).toStringAsFixed(2)} GB';
  }

  static void debugLog(String msg) {
    // ignore: avoid_print
    print(msg);
  }
}