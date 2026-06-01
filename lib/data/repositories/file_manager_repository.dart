import 'dart:io';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── DATA MODELS ────────────────────────────────────────────────────────────

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
  final bool   isSdCard;

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

// ─── REPOSITORY ─────────────────────────────────────────────────────────────

class FileManagerRepository {
  static const String _root = '/storage/emulated/0';

  static const Set<String> _blockedFolders = {
    '/storage/emulated/0/Android/data',
    '/storage/emulated/0/Android/obb',
    '/storage/emulated/0/Android/media',
  };

  static const Map<String, List<String>> _exts = {
    'Images':    ['jpg','jpeg','png','gif','webp','bmp','heic','heif','tiff'],
    'Videos':    ['mp4','mkv','avi','mov','wmv','flv','3gp','webm','ts','m4v'],
    'Audio':     ['mp3','wav','aac','flac','m4a','ogg','wma','opus','amr'],
    'Documents': ['pdf','doc','docx','xls','xlsx','ppt','pptx','txt','csv','rtf'],
    'APKs':      ['apk'],
  };

  static const Map<String, String> _images = {
    'Images':    'assets/images/tools/filemanagerimages.png',
    'Videos':    'assets/images/tools/filemanagervideos.png',
    'Audio':     'assets/images/tools/filemanageraudio.png',
    'Documents': 'assets/images/tools/filemanagernotes.png',
    'Downloads': 'assets/images/tools/filemanagerdownload.png',
    'APKs':      'assets/images/tools/filemanagerapk.png',
  };

  // ─── PERMISSION ───────────────────────────────────────────────────────────

  Future<bool> requestStoragePermission() async {
    print("Requesting storage permission...");
    if (!Platform.isAndroid) return true;

    if (await Permission.manageExternalStorage.isGranted) {
      print("✅ Manage external storage already granted");
      return true;
    }

    final storage = await Permission.storage.request();
    if (storage.isGranted) return true;

    final manage = await Permission.manageExternalStorage.request();
    return manage.isGranted;
  }

  // ─── INTERNAL STORAGE ─────────────────────────────────────────────────────

  Future<StorageDeviceModel> fetchInternalStorage() async {
    print("📊 Fetching internal storage...");
    try {
      final diskSpace = DiskSpacePlus();
      final totalMB = await diskSpace.getTotalDiskSpace ?? 0.0;
      final freeMB  = await diskSpace.getFreeDiskSpace  ?? 0.0;
      final usedMB  = totalMB - freeMB;
      print("💾 Total: $totalMB MB, Free: $freeMB MB, Used: $usedMB MB");
      return StorageDeviceModel(
        name:    'Internal Storage',
        usedGB:  usedMB  / 1024,
        totalGB: totalMB / 1024,
        isSdCard: false,
      );
    } catch (e) {
      print("❌ Internal storage error: $e");
      return const StorageDeviceModel(
        name: 'Internal Storage',
        usedGB: 0,
        totalGB: 0,
        isSdCard: false,
      );
    }
  }

  // ─── SD CARD STORAGE ──────────────────────────────────────────────────────

  Future<StorageDeviceModel?> fetchSdCardStorage() async {
    print("📊 Fetching SD card storage...");
    if (!Platform.isAndroid) return null;

    try {
      // getExternalStorageDirectories — most reliable method
      final dirs = await getExternalStorageDirectories();
      print("📂 External dirs: ${dirs?.map((d) => d.path).toList()}");

      if (dirs != null && dirs.length > 1) {
        final sdDir = dirs[1];
        print("✅ SD card dir: ${sdDir.path}");

        // Root path: /storage/XXXX-XXXX
        final segments = sdDir.path.split('/');
        final sdRoot = segments.length >= 3
            ? '/${segments[1]}/${segments[2]}'
            : sdDir.path;
        print("📂 SD root: $sdRoot");

        final result = await Process.run('df', ['-k', sdRoot]);
        print("df exit: ${result.exitCode}, stdout: ${result.stdout}");

        if (result.exitCode == 0) {
          final lines = (result.stdout as String).trim().split('\n');
          if (lines.length >= 2) {
            final parts = lines[1].trim().split(RegExp(r'\s+'));
            print("df parts: $parts");
            if (parts.length >= 3) {
              final totalKB = double.tryParse(parts[1]) ?? 0;
              final usedKB  = double.tryParse(parts[2]) ?? 0;
              print("💾 SD total KB: $totalKB, used KB: $usedKB");

              if (totalKB > 0) {
                return StorageDeviceModel(
                  name:     'SD Card',
                  usedGB:   usedKB  / (1024 * 1024),
                  totalGB:  totalKB / (1024 * 1024),
                  isSdCard: true,
                );
              }
            }
          }
        }

        // df kaam na kare to StatFs alternative
        print("⚠️ df failed, trying stat...");
        try {
          final stat = await FileStat.stat(sdRoot);
          print("stat: $stat");
        } catch (_) {}

        // SD card exist karta hai lekin size nahi mila — phir bhi show karein
        return const StorageDeviceModel(
          name:     'SD Card',
          usedGB:   0,
          totalGB:  0,
          isSdCard: true,
        );
      }

      // Fallback: common paths check karein
      final possiblePaths = [
        '/storage/sdcard1',
        '/storage/extSdCard',
        '/storage/external_SD',
        '/storage/ext_sd',
        '/mnt/extSdCard',
        '/mnt/sdcard1',
      ];

      for (final path in possiblePaths) {
        if (await Directory(path).exists()) {
          print("✅ SD card found at fallback path: $path");
          final result = await Process.run('df', ['-k', path]);
          if (result.exitCode == 0) {
            final lines = (result.stdout as String).trim().split('\n');
            if (lines.length >= 2) {
              final parts = lines[1].trim().split(RegExp(r'\s+'));
              if (parts.length >= 3) {
                final totalKB = double.tryParse(parts[1]) ?? 0;
                final usedKB  = double.tryParse(parts[2]) ?? 0;
                if (totalKB > 0) {
                  return StorageDeviceModel(
                    name:     'SD Card',
                    usedGB:   usedKB  / (1024 * 1024),
                    totalGB:  totalKB / (1024 * 1024),
                    isSdCard: true,
                  );
                }
              }
            }
          }
          return const StorageDeviceModel(
            name: 'SD Card', usedGB: 0, totalGB: 0, isSdCard: true,
          );
        }
      }

      print("ℹ️ No SD card found");
      return null;
    } catch (e) {
      print("❌ SD card error: $e");
      return null;
    }
  }

  // ─── FILE CATEGORIES ──────────────────────────────────────────────────────

  Future<List<FileCategoryModel>> fetchFileCategories() async {
    print("📂 Starting file category scan...");
    final allFiles = await _safeScan(Directory(_root));
    print("📁 Total scanned files: ${allFiles.length}");

    final dlFiles = <File>[];
    for (final name in ['Download', 'Downloads']) {
      final dir = Directory('$_root/$name');
      if (await dir.exists()) dlFiles.addAll(await _safeScan(dir));
    }

    final categories = <FileCategoryModel>[];
    for (final cat in ['Images','Videos','Audio','Documents','Downloads','APKs']) {
      if (cat == 'Downloads') {
        final bytes = await _totalBytes(dlFiles);
        categories.add(FileCategoryModel(
          name: 'Downloads',
          size: _fmtBytes(bytes),
          imagePath: _images['Downloads']!,
          fileCount: dlFiles.length,
        ));
        continue;
      }
      final exts = _exts[cat]!;
      final matched = allFiles.where((f) {
        if (!f.path.contains('.')) return false;
        return exts.contains(f.path.split('.').last.toLowerCase());
      }).toList();
      final bytes = await _totalBytes(matched);
      categories.add(FileCategoryModel(
        name: cat,
        size: _fmtBytes(bytes),
        imagePath: _images[cat]!,
        fileCount: matched.length,
      ));
    }
    return categories;
  }

  // ─── SAFE SCAN ────────────────────────────────────────────────────────────

  Future<List<File>> _safeScan(Directory dir) async {
    final files = <File>[];
    if (_isBlocked(dir.path)) return files;
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) {
          files.add(entity);
        } else if (entity is Directory && !_isBlocked(entity.path)) {
          files.addAll(await _safeScan(entity));
        }
      }
    } catch (e) {
      print("⚠️ Scan error: ${dir.path} → $e");
    }
    return files;
  }

  bool _isBlocked(String path) {
    for (final b in _blockedFolders) {
      if (path == b || path.startsWith('$b/')) return true;
    }
    return false;
  }

  Future<int> _totalBytes(List<File> files) async {
    int total = 0;
    for (final f in files) {
      try { total += await f.length(); } catch (_) {}
    }
    return total;
  }

  String _fmtBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}