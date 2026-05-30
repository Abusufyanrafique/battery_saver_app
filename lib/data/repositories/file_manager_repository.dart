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
  final String iconPath;

  const StorageDeviceModel({
    required this.name,
    required this.usedGB,
    required this.totalGB,
    required this.iconPath,
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

  static const String _storageIcon =
      'assets/icons/tools_screen/internalstorage.svg';

  // ─── PERMISSION ─────────────────────────────────────────────────────────

  Future<bool> requestStoragePermission() async {
    print(" Requesting storage permission...");

    if (!Platform.isAndroid) {
      print("Not Android → skipping permission");
      return true;
    }

    if (await Permission.manageExternalStorage.isGranted) {
      print("✅ Manage external storage already granted");
      return true;
    }

    final storage = await Permission.storage.request();
    print("📦 Storage permission result: ${storage.isGranted}");

    if (storage.isGranted) return true;

    final manage = await Permission.manageExternalStorage.request();
    print("🛠 Manage external storage result: ${manage.isGranted}");

    return manage.isGranted;
  }

  // ─── INTERNAL STORAGE ───────────────────────────────────────────────────

  Future<StorageDeviceModel> fetchInternalStorage() async {
    print("📊 Fetching internal storage info...");

    try {
      final diskSpace = DiskSpacePlus();
      final totalMB = await diskSpace.getTotalDiskSpace ?? 0.0;
      final freeMB  = await diskSpace.getFreeDiskSpace  ?? 0.0;
      final usedMB  = totalMB - freeMB;

      print("💾 Total MB: $totalMB");
      print("💾 Free MB: $freeMB");
      print("💾 Used MB: $usedMB");

      return StorageDeviceModel(
        name:     'Internal Storage',
        usedGB:   usedMB  / 1024,
        totalGB:  totalMB / 1024,
        iconPath: _storageIcon,
      );
    } catch (e) {
      print("❌ Storage fetch error: $e");

      return const StorageDeviceModel(
        name: 'Internal Storage',
        usedGB: 0,
        totalGB: 0,
        iconPath: _storageIcon,
      );
    }
  }

  // ─── FILE CATEGORIES ────────────────────────────────────────────────────

  Future<List<FileCategoryModel>> fetchFileCategories() async {
    print("📂 Starting file category scan...");

    final allFiles = await _safeScan(Directory(_root));
    print("📁 Total scanned files: ${allFiles.length}");

    final dlFiles = <File>[];

    for (final name in ['Download', 'Downloads']) {
      final dir = Directory('$_root/$name');
      if (await dir.exists()) {
        print("📥 Scanning downloads folder: $name");
        dlFiles.addAll(await _safeScan(dir));
      }
    }

    print("📥 Total download files: ${dlFiles.length}");

    final categories = <FileCategoryModel>[];

    for (final cat in ['Images','Videos','Audio','Documents','Downloads','APKs']) {
      print("🔍 Processing category: $cat");

      if (cat == 'Downloads') {
        final bytes = await _totalBytes(dlFiles);
        print("📦 Downloads bytes: $bytes");

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

      print("📌 $cat matched files: ${matched.length}");

      final bytes = await _totalBytes(matched);
      print("📦 $cat bytes: $bytes");

      categories.add(FileCategoryModel(
        name: cat,
        size: _fmtBytes(bytes),
        imagePath: _images[cat]!,
        fileCount: matched.length,
      ));
    }

    print("✅ File categories ready: ${categories.length}");
    return categories;
  }

  // ─── SAFE SCAN ──────────────────────────────────────────────────────────

  Future<List<File>> _safeScan(Directory dir) async {
    print("🔎 Scanning: ${dir.path}");

    final files = <File>[];

    if (_isBlocked(dir.path)) {
      print("⛔ Blocked folder skipped: ${dir.path}");
      return files;
    }

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File) {
          files.add(entity);
        } else if (entity is Directory) {
          if (!_isBlocked(entity.path)) {
            files.addAll(await _safeScan(entity));
          } else {
            print("⛔ Skipping blocked subfolder: ${entity.path}");
          }
        }
      }
    } catch (e) {
      print("⚠️ Permission denied or error in: ${dir.path} → $e");
    }

    return files;
  }

  bool _isBlocked(String path) {
    for (final blocked in _blockedFolders) {
      if (path == blocked || path.startsWith('$blocked/')) return true;
    }
    return false;
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────

  Future<int> _totalBytes(List<File> files) async {
    int total = 0;

    for (final f in files) {
      try {
        total += await f.length();
      } catch (e) {
        print("⚠️ File read error: ${f.path} → $e");
      }
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