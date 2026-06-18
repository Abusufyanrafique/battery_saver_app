import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'security_scan_event.dart';
part 'security_scan_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. VIRUS SCAN
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
    defaultValue: 'com.example.app',
  );
  final dirsToScan = [
    Directory('/data/data/$appId/cache'),
    Directory('/data/data/$appId/files'),
    Directory('/data/data/$appId/app_flutter'),
  ];

  for (final dir in dirsToScan) {
    if (!await dir.exists()) continue;
    try {
      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
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
// ─────────────────────────────────────────────────────────────────────────────
const _expectedPermissions = <String>{
  'android.permission.INTERNET',
  'android.permission.ACCESS_NETWORK_STATE',
  'android.permission.CAMERA',
};

const _privacyChannel = MethodChannel('com.example.battery_saver_app/security');

Future<int> _runPrivacyScan() async {
  try {
    final List<dynamic>? granted = await _privacyChannel
        .invokeMethod<List<dynamic>>('getDangerousGrantedPermissions')
        .timeout(const Duration(milliseconds: 500));

    if (granted == null) return 0;

    return granted
        .cast<String>()
        .where((p) => !_expectedPermissions.contains(p))
        .length;
  } on PlatformException {
    return 0;
  } on TimeoutException {
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. VULNERABILITY SCAN
// ─────────────────────────────────────────────────────────────────────────────
const _minSafeKernelMajor = 4;
const _minSafeKernelMinor = 14;
const _minSafeApiLevel = 29;

Future<int> _runVulnerabilityScan() async {
  int threats = 0;

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

  try {
    final sdkLevel = await _privacyChannel
        .invokeMethod<int>('getSdkVersion')
        .timeout(const Duration(seconds: 2))
        .catchError((_) async => null);

    if (sdkLevel != null && sdkLevel < _minSafeApiLevel) threats++;
  } catch (_) {}

  try {
    final selinux = File('/sys/fs/selinux/enforce');
    if (await selinux.exists()) {
      final mode = (await selinux.readAsString()).trim();
      if (mode == '0') threats++;
    }
  } catch (_) {}

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SYSTEM PROTECTION SCAN (Root Detection)
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

const _dangerousBuildTags = ['test-keys', 'dev-keys', 'userdebug'];

Future<int> _runSystemProtectionScan() async {
  int threats = 0;

  for (final path in _rootBinaries) {
    try {
      if (await File(path).exists() || await Directory(path).exists()) {
        threats++;
        break;
      }
    } catch (_) {}
  }

  try {
    final testFile =
        File('/system/.rw_test_${DateTime.now().millisecondsSinceEpoch}');
    await testFile.writeAsString('test');
    await testFile.delete();
    threats++;
  } catch (_) {}

  try {
    final buildTags = await _privacyChannel
        .invokeMethod<String>('getBuildTags')
        .timeout(const Duration(seconds: 2))
        .catchError((_) async => null);

    if (buildTags != null) {
      final lower = buildTags.toLowerCase();
      if (_dangerousBuildTags.any((tag) => lower.contains(tag))) threats++;
    }
  } catch (_) {}

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

  //  FIX: SecurityScanState.initial() hata ke const SecurityScanState() use kiya
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
    // Active scan label show karo
    emit(SecurityScanState(
      status: SecurityScanStatus.scanning,
      completedItems: List<bool>.from(completed),
      progress: ((i / totalSteps) * 100).round(),
      threatsFound: totalThreats,
      currentScanLabel: _scanSteps[i],
    ));

    //  Scan + minimum 1 second delay dono saath
    final results = await Future.wait([
      _scanFunctions[i](),
      Future.delayed(const Duration(milliseconds: 1000)),
    ]);

    final threats = results[0] as int;
    totalThreats += threats;
    completed[i] = true;

    final progress = (((i + 1) / totalSteps) * 100).round();

    emit(SecurityScanState(
      status: SecurityScanStatus.scanning,
      completedItems: List<bool>.from(completed),
      progress: progress,
      threatsFound: totalThreats,
      currentScanLabel:
          i < totalSteps - 1 ? _scanSteps[i + 1] : _scanSteps[i],
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