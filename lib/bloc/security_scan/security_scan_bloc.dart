import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'security_scan_event.dart';
part 'security_scan_state.dart';

const _channel = MethodChannel('com.example.battery_saver_app/security_scan');

// ─────────────────────────────────────────────────────────────────────────────
// 1. VIRUS SCAN
//    Own app ki cache/files directory mein suspicious files dhundo
// ─────────────────────────────────────────────────────────────────────────────
Future<int> _runVirusScan() async {
  int threats = 0;

  const suspiciousExtensions = [
    '.apk',
    '.dex',
    '.odex',
    '.so.bak',
    '.jar',
  ];

  final appId = const String.fromEnvironment(
    'APP_ID',
    defaultValue: 'com.example.battery_saver_app',
  );

  final dirsToScan = [
    Directory('/data/data/$appId/cache'),
    Directory('/data/data/$appId/files'),
    Directory('/data/data/$appId/app_flutter'),
  ];

  for (final dir in dirsToScan) {
    if (!await dir.exists()) continue;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final path = entity.path.toLowerCase();

        if (suspiciousExtensions.any((ext) => path.endsWith(ext))) {
          threats++;
          continue;
        }

        try {
          final stat = await entity.stat();
          if (stat.size > 8 * 1024 * 1024) threats++;
        } catch (_) {}
      }
    } catch (_) {}
  }

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PRIVACY SCAN
//    Dangerous permissions wali apps + sideloaded apps count karo
//    Uses: getDangerousPermissionApps, getSideloadedApps
// ─────────────────────────────────────────────────────────────────────────────
Future<int> _runPrivacyScan() async {
  int threats = 0;

  // Dangerous permissions wali apps
  try {
    final List<dynamic>? riskyApps = await _channel
        .invokeMethod<List<dynamic>>('getDangerousPermissionApps')
        .timeout(const Duration(seconds: 5));

    if (riskyApps != null) {
      // Har app jo 3+ dangerous perms use karti hai = 1 threat
      for (final app in riskyApps) {
        final perms = (app as Map)['permissions'] as List? ?? [];
        if (perms.length >= 3) threats++;
      }
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  // Sideloaded apps (unknown source se install hue)
  try {
    final List<dynamic>? sideloaded = await _channel
        .invokeMethod<List<dynamic>>('getSideloadedApps')
        .timeout(const Duration(seconds: 5));

    if (sideloaded != null && sideloaded.isNotEmpty) {
      threats += sideloaded.length;
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  // Hidden apps (no launcher icon wali user apps)
  try {
    final List<dynamic>? hidden = await _channel
        .invokeMethod<List<dynamic>>('getHiddenApps')
        .timeout(const Duration(seconds: 5));

    if (hidden != null && hidden.isNotEmpty) {
      threats += hidden.length;
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. VULNERABILITY SCAN
//    Kernel version, SDK level, SELinux check
//    SDK level ab getSystemInfo se lenge
// ─────────────────────────────────────────────────────────────────────────────
const _minSafeKernelMajor = 4;
const _minSafeKernelMinor = 14;
const _minSafeApiLevel    = 29; // Android 10

Future<int> _runVulnerabilityScan() async {
  int threats = 0;

  // Kernel version check
  try {
    final versionFile = File('/proc/version');
    if (await versionFile.exists()) {
      final content = await versionFile.readAsString();
      final match = RegExp(r'Linux version (\d+)\.(\d+)').firstMatch(content);
      if (match != null) {
        final major = int.tryParse(match.group(1) ?? '') ?? 0;
        final minor = int.tryParse(match.group(2) ?? '') ?? 0;
        final tooOld = major < _minSafeKernelMajor ||
            (major == _minSafeKernelMajor && minor < _minSafeKernelMinor);
        if (tooOld) threats++;
      }
    }
  } catch (_) {}

  // SDK level — getSystemInfo se
  try {
    final Map<dynamic, dynamic>? sysInfo = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('getSystemInfo')
        .timeout(const Duration(seconds: 3));

    if (sysInfo != null) {
      final sdkLevel = sysInfo['sdk'] as int? ?? 0;
      if (sdkLevel < _minSafeApiLevel) threats++;
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  // SELinux enforcing check
  try {
    final selinux = File('/sys/fs/selinux/enforce');
    if (await selinux.exists()) {
      final mode = (await selinux.readAsString()).trim();
      if (mode == '0') threats++;
    }
  } catch (_) {}

  // Debuggable apps check
  try {
    final List<dynamic>? debugApps = await _channel
        .invokeMethod<List<dynamic>>('getDebuggableApps')
        .timeout(const Duration(seconds: 5));

    if (debugApps != null && debugApps.isNotEmpty) {
      threats += debugApps.length;
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SYSTEM PROTECTION SCAN (Root Detection)
//    Root binaries, writable /system, build type
//    buildType ab getSystemInfo se lenge
// ─────────────────────────────────────────────────────────────────────────────
const _rootBinaries = [
  '/sbin/su',
  '/system/bin/su',
  '/system/xbin/su',
  '/system/xbin/mu',
  '/data/local/xbin/su',
  '/data/local/bin/su',
  '/data/local/su',
  '/system/sd/xbin/su',
  '/system/bin/failsafe/su',
  '/dev/com.koushikdutta.superuser.daemon/',
  '/system/app/Superuser.apk',
  '/system/app/SuperSU.apk',
  '/system/app/Magisk.apk',
  '/data/adb/magisk',
  '/data/adb/modules',
];

const _dangerousBuildTypes = ['userdebug', 'eng'];

Future<int> _runSystemProtectionScan() async {
  int threats = 0;

  // Root binaries check
  for (final path in _rootBinaries) {
    try {
      if (await File(path).exists() || await Directory(path).exists()) {
        threats++;
        break; // ek bhi mila toh enough hai
      }
    } catch (_) {}
  }

  // /system writable hai?
  try {
    final testFile = File(
      '/system/.rw_test_${DateTime.now().millisecondsSinceEpoch}',
    );
    await testFile.writeAsString('test');
    await testFile.delete();
    threats++;
  } catch (_) {}

  // Build type — getSystemInfo se (userdebug / eng = risky)
  try {
    final Map<dynamic, dynamic>? sysInfo = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('getSystemInfo')
        .timeout(const Duration(seconds: 3));

    if (sysInfo != null) {
      final buildType = (sysInfo['buildType'] as String? ?? '').toLowerCase();
      if (_dangerousBuildTypes.any((t) => buildType.contains(t))) threats++;
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  // /proc/cmdline check (bootloader unlock / debug mode)
  try {
    final cmdline = File('/proc/cmdline');
    if (await cmdline.exists()) {
      final content = await cmdline.readAsString();
      if (content.contains('androidboot.verifiedbootstate=orange') ||
          content.contains('ro.debuggable=1')) {
        threats++;
      }
    }
  } catch (_) {}

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────────────────────────────────────────
class SecurityScanBloc extends Bloc<SecurityScanEvent, SecurityScanState> {
  static const _scanSteps = [
    'Virus Scan',
    'Privacy Scan',
    'Vulnerability Scan',
    'System Protection',
  ];

  static final List<Future<int> Function()> _scanFunctions = [
    _runVirusScan,
    _runPrivacyScan,
    _runVulnerabilityScan,
    _runSystemProtectionScan,
  ];

  SecurityScanBloc() : super(const SecurityScanState()) {
    on<SecurityScanStarted>(_onScanStarted);
  }

  Future<void> _onScanStarted(
    SecurityScanStarted event,
    Emitter<SecurityScanState> emit,
  ) async {
    final totalSteps = _scanSteps.length;

    // Reset
    emit(SecurityScanState(
      status: SecurityScanStatus.scanning,
      completedItems: List.filled(totalSteps, false),
      progress: 0,
      threatsFound: 0,
      currentScanLabel: _scanSteps[0],
    ));

    int totalThreats = 0;
    final completed = List<bool>.filled(totalSteps, false);

    for (int i = 0; i < totalSteps; i++) {
      // Active label emit
      emit(SecurityScanState(
        status: SecurityScanStatus.scanning,
        completedItems: List<bool>.from(completed),
        progress: ((i / totalSteps) * 100).round(),
        threatsFound: totalThreats,
        currentScanLabel: _scanSteps[i],
      ));

      // Scan + minimum 1 second delay
      final results = await Future.wait([
        _scanFunctions[i](),
        Future.delayed(const Duration(milliseconds: 1000)),
      ]);

      final threats = results[0] as int;
      totalThreats += threats;
      completed[i] = true;

      emit(SecurityScanState(
        status: SecurityScanStatus.scanning,
        completedItems: List<bool>.from(completed),
        progress: (((i + 1) / totalSteps) * 100).round(),
        threatsFound: totalThreats,
        currentScanLabel: i < totalSteps - 1 ? _scanSteps[i + 1] : _scanSteps[i],
      ));
    }

    // Done
    emit(SecurityScanState(
      status: SecurityScanStatus.done,
      completedItems: List.filled(totalSteps, true),
      progress: 100,
      threatsFound: totalThreats,
      currentScanLabel: '',
    ));
  }
}