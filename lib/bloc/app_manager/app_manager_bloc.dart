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
    on<AppManagerInstallApk>(_onInstallApk);
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
      debugPrint("=========== APK COUNT ===========");
      debugPrint("APK Files: ${apkFiles.length}");
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

  /// Calls the native Android side, which uses MediaStore to find .apk
  /// files — the same mechanism file manager apps use. This is necessary
  /// because a plain Dart `Directory.listSync()` walk can miss files that
  /// Android's Scoped Storage (Android 10+) hides from direct filesystem
  /// access even when MANAGE_EXTERNAL_STORAGE is granted.
  Future<List<ApkFileModel>> _scanApkFiles() async {
    try {
      final result = await _appSizeChannel.invokeMethod<List<dynamic>>(
        'scanApkFiles',
      );

      if (result == null) {
        debugPrint('=== [APK scan] native returned null');
        
        return [];
      }

      final apkFiles = <ApkFileModel>[];
      for (final item in result) {
        try {
          final map = item as Map;
          final name = (map['name'] as String?) ?? 'Unknown.apk';
          final path = (map['path'] as String?) ?? '';
          final sizeMB = (map['sizeMB'] as num?)?.toDouble() ?? 0.0;

          apkFiles.add(ApkFileModel(
            name: name.replaceAll(RegExp(r'\.apk$', caseSensitive: false), ''),
            path: path,
            sizeMB: sizeMB,
          ));
        } catch (e) {
          debugPrint('=== [APK scan] error parsing entry: $e');
          continue;
        }
      }

      debugPrint('=== [APK scan] total found: ${apkFiles.length}');
      return apkFiles;
    } catch (e) {
      debugPrint('=== [APK scan] native call failed: $e');
      return [];
    }
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

  // Install APK handler
 Future<void> _onInstallApk(
  AppManagerInstallApk event,
  Emitter<AppManagerState> emit,
) async {
  try {
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

    // ← Sirf yeh hona chahiye, AndroidIntent bilkul nahi
    await _appSizeChannel.invokeMethod('installApk', {
      'path': event.apkPath,
    });

  } catch (e) {
    debugPrint('=== Install APK error: $e');
  }
}
}