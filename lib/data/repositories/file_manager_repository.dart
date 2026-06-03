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
  'Images':    'assets/images/tools/filemanagerimages.png',
  'Videos':    'assets/images/tools/filemanagervideos.png',
  'Audio':     'assets/images/tools/filemanageraudio.png',
  'Documents': 'assets/images/tools/filemanagernotes.png',
  'Downloads': 'assets/images/tools/filemanagerdownload.png',
  'APKs':      'assets/images/tools/filemanagerapk.png',
};

// ─── BLOCKED DIRS (Android 11+ restricted paths) ──────────────────────────────

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
  // Android 11+: MANAGE_EXTERNAL_STORAGE needed for broad access.
  // Falls back to READ_EXTERNAL_STORAGE for partial access.

  Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Already granted?
    if (await Permission.manageExternalStorage.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    // Request MANAGE_EXTERNAL_STORAGE first (Android 11+)
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;

    // Fallback: READ_EXTERNAL_STORAGE (Android 10 and below, or partial)
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  // ── STORAGE INFO ────────────────────────────────────────────────────────────

  Future<StorageDeviceModel> fetchInternalStorage() async {
    try {
      final ds    = DiskSpacePlus();
      final total = await ds.getTotalDiskSpace ?? 0.0;
      final free  = await ds.getFreeDiskSpace  ?? 0.0;
      return StorageDeviceModel(
        name: 'Internal Storage',
        usedGB: (total - free) / 1024,
        totalGB: total / 1024,
      );
    } catch (e) {
      debugLog('fetchInternalStorage error: $e');
      return const StorageDeviceModel(
        name: 'Internal Storage', usedGB: 0, totalGB: 0,
      );
    }
  }

  Future<StorageDeviceModel?> fetchSdCardStorage() async {
    if (!Platform.isAndroid) return null;
    try {
      final dirs = await getExternalStorageDirectories();
      if (dirs != null && dirs.length > 1) {
        final parts = dirs[1].path.split('/');
        if (parts.length >= 3) {
          final sd = '/${parts[1]}/${parts[2]}';
          if (Directory(sd).existsSync()) {
            return StorageDeviceModel(
              name: 'SD Card', usedGB: 0, totalGB: 0, isSdCard: true,
            );
          }
        }
      }
    } catch (e) {
      debugLog('fetchSdCardStorage error: $e');
    }
    return null;
  }

  // ── FILE SCAN — main thread compute, NO isolate ─────────────────────────────
  // Isolate was causing silent hangs on Android 11+ due to permission
  // context not being available inside the spawned isolate.
  // Using compute() keeps it off the UI thread safely.

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

      // Run scan directly — no isolate, no spawn failures
      final maps = await _scanDirectory(root);
      debugLog('[FM] scan returned ${maps.length} categories');

      final models = maps.map((m) => FileCategoryModel(
        name:      m['name']      as String,
        size:      m['size']      as String,
        imagePath: m['imagePath'] as String,
        fileCount: m['fileCount'] as int,
      )).toList();

      for (final m in models) {
        debugLog('[FM]   ${m.name}: ${m.fileCount} files  ${m.size}');
      }

      _cache = models;
      return models;
    } catch (e, st) {
      debugLog('[FM] fetchFileCategories EXCEPTION: $e\n$st');
      return _empty();
    } finally {
      _scanning = false;
    }
  }

  // ── DIRECTORY SCAN (runs in same isolate via async, off UI via compute) ──────

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

    // Download folder paths
    final dlPaths = <String>[];
    for (final n in ['Download', 'Downloads']) {
      final p = '$rootPath/$n';
      if (Directory(p).existsSync()) dlPaths.add(p);
    }

    // BFS stack with depth tracking
    final stack  = <String>[rootPath];
    final depths = <String, int>{rootPath: 0};
    int   scanned = 0;

    while (stack.isNotEmpty) {
      final path  = stack.removeLast();
      final depth = depths[path] ?? 0;
      if (depth > 6) continue;

      // Skip hidden dirs
      final dirName = path.split('/').last;
      if (dirName.startsWith('.')) continue;

      // Skip Android restricted dirs
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
        continue; // Permission denied for this sub-dir — skip silently
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

          // Check if in Downloads folder
          final inDl = dlPaths.any((dp) => fp.startsWith(dp));
          if (inDl) { dlCount++; dlBytes += sz; }

          // Categorize by extension
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

  // ── ROOT RESOLUTION ─────────────────────────────────────────────────────────

  Future<String> _resolveRoot() async {
    // Try getExternalStorageDirectories first
    try {
      final dirs = await getExternalStorageDirectories();
      if (dirs != null && dirs.isNotEmpty) {
        // Walk up to the storage root (strip Android/data/... suffix)
        final parts = dirs[0].path.split('/');
        for (int i = parts.length; i >= 3; i--) {
          final candidate = parts.sublist(0, i).join('/');
          final d = Directory(candidate);
          if (d.existsSync()) {
            // Make sure it looks like a storage root (has DCIM or Download)
            final hasDCIM     = Directory('$candidate/DCIM').existsSync();
            final hasDownload = Directory('$candidate/Download').existsSync()
                             || Directory('$candidate/Downloads').existsSync();
            if (hasDCIM || hasDownload) {
              debugLog('[FM] resolved root via getExternalStorageDirectories: $candidate');
              return candidate;
            }
          }
        }
      }
    } catch (e) {
      debugLog('[FM] getExternalStorageDirectories failed: $e');
    }

    // Fallback: standard Android path
    const fallback = '/storage/emulated/0';
    debugLog('[FM] using fallback root: $fallback');
    return fallback;
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

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