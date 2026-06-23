import 'dart:io';
import 'dart:typed_data';
import 'package:android_intent_plus/flag.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';

part 'app_manager_event.dart';
part 'app_manager_state.dart';

class AppManagerBloc extends Bloc<AppManagerEvent, AppManagerState> {
  static const _appSizeChannel =
      MethodChannel('com.example.battery_saver_app/app_size');

  AppManagerBloc() : super(const AppManagerState()) {
    on<AppManagerLoadApps>(_onLoad);
    on<AppManagerTabChanged>(_onTabChanged);
    on<AppManagerToggleApp>(_onToggle);
    on<AppManagerUninstallSelected>(_onUninstall);
    on<AppManagerInstallApk>(_onInstallApk); // ✅ NEW
  }

  Future<int> _getAndroidSdk() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (_) {
      return 30;
    }
  }

  Future<void> _onLoad(
    AppManagerLoadApps event,
    Emitter<AppManagerState> emit,
  ) async {
    emit(state.copyWith(status: AppManagerStatus.loading));

    try {
      if (Platform.isAndroid) {
        final sdkInt = await _getAndroidSdk();
        if (sdkInt >= 30) {
          if (!await Permission.manageExternalStorage.isGranted) {
            await Permission.manageExternalStorage.request();
          }
        } else {
          if (!await Permission.storage.isGranted) {
            await Permission.storage.request();
          }
        }
      }

      final List<AppInfo> apps = await InstalledApps.getInstalledApps(
        true,
        true,
      );

      debugPrint('=== Total apps found: ${apps.length}');

      final rawApps = <RealAppModel>[];
      for (final app in apps) {
        Uint8List? iconBytes;
        try {
          iconBytes = app.icon;
        } catch (_) {}

        rawApps.add(RealAppModel(
          name: app.name ?? 'Unknown',
          packageName: app.packageName ?? '',
          sizeMB: 0,
          icon: iconBytes,
          versionName: app.versionName,
        ));
      }

      final packageNames =
          rawApps.map((a) => a.packageName).where((p) => p.isNotEmpty).toList();

      Map<String, double> sizeMap = {};
      try {
        final result = await _appSizeChannel.invokeMethod<Map>(
          'getInstalledAppSizes',
          {'packageNames': packageNames},
        );
        if (result != null) {
          sizeMap = result.map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          );
        }
      } catch (e) {
        debugPrint('=== Size fetch error: $e');
      }

      final realApps = rawApps.map((app) {
        return app.copyWith(sizeMB: sizeMap[app.packageName] ?? 0);
      }).toList();

      realApps.sort((a, b) => b.sizeMB.compareTo(a.sizeMB));

      final apkFiles = await _scanApkFiles();

      emit(state.copyWith(
        status: AppManagerStatus.success,
        installedApps: realApps,
        apkFiles: apkFiles,
      ));
    } catch (e) {
      debugPrint('=== AppManager Error: $e');
      emit(state.copyWith(
        status: AppManagerStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<List<ApkFileModel>> _scanApkFiles() async {
    final List<ApkFileModel> result = [];

    final safeDirs = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Downloads',
      '/storage/emulated/0/Documents',
      '/storage/emulated/0/WhatsApp/Media',
    ];

    for (final path in safeDirs) {
      final dir = Directory(path);
      if (!dir.existsSync()) continue;
      try {
        final entities = dir.listSync(recursive: false, followLinks: false);
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.apk')) {
            try {
              final sizeMB = entity.lengthSync() / (1024 * 1024);
              final name = entity.uri.pathSegments.last
                  .replaceAll('.apk', '')
                  .replaceAll('_', ' ');
              result.add(ApkFileModel(
                name: name,
                path: entity.path,
                sizeMB: sizeMB,
              ));
            } catch (_) {}
          }
        }
      } catch (_) {
        continue;
      }
    }
    return result;
  }

  void _onTabChanged(
    AppManagerTabChanged event,
    Emitter<AppManagerState> emit,
  ) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  void _onToggle(
    AppManagerToggleApp event,
    Emitter<AppManagerState> emit,
  ) {
    if (state.isApkMode) {
      final updated = List<ApkFileModel>.from(state.apkFiles);
      final item = updated[event.index];
      updated[event.index] = ApkFileModel(
        name: item.name,
        path: item.path,
        sizeMB: item.sizeMB,
        version: item.version,
        isSelected: !item.isSelected,
      );
      emit(state.copyWith(apkFiles: updated));
    } else {
      final updated = List<RealAppModel>.from(state.installedApps);
      updated[event.index] = updated[event.index]
          .copyWith(isSelected: !updated[event.index].isSelected);
      emit(state.copyWith(installedApps: updated));
    }
  }

  Future<void> _onUninstall(
    AppManagerUninstallSelected event,
    Emitter<AppManagerState> emit,
  ) async {
    for (final app in state.selectedApps) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.DELETE',
          data: 'package:${app.packageName}',
        );
        await intent.launch();
      } catch (_) {}
    }
    add(const AppManagerLoadApps());
  }

  // NEW: Install APK handler
  Future<void> _onInstallApk(
    AppManagerInstallApk event,
    Emitter<AppManagerState> emit,
  ) async {
    try {
      // Android 8+ ke liye install permission check
      if (Platform.isAndroid) {
        final sdkInt = await _getAndroidSdk();
        if (sdkInt >= 26) {
          if (!await Permission.requestInstallPackages.isGranted) {
            final status = await Permission.requestInstallPackages.request();
            if (!status.isGranted) {
              debugPrint('=== Install permission denied');
              return;
            }
          }
        }
      }

      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: Uri.file(event.apkPath).toString(),
        type: 'application/vnd.android.package-archive',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      debugPrint('=== Install APK error: $e');
    }
  }
}