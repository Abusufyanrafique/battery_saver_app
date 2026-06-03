import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'security_scan_event.dart';
part 'security_scan_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. VIRUS SCAN
//    Scans app's own cache + files dir for injected/suspicious binaries.
//    No permissions required — app has full access to its sandbox.
// ─────────────────────────────────────────────────────────────────────────────
Future<int> _runVirusScan() async {
  int threats = 0;

  // Extensions that have no business being in an app's data directory
  const suspiciousExtensions = [
    '.apk',  // side-loaded package
    '.dex',  // raw Dalvik bytecode — classic code injection artifact
    '.odex', // optimised dex outside system dirs
    '.so.bak', // renamed native lib (often used to hide malware)
    '.jar',  // executable Java archive
  ];

  // Directories writable by the app that malware commonly targets
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
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final path = entity.path.toLowerCase();

        // Flag by extension
        if (suspiciousExtensions.any((ext) => path.endsWith(ext))) {
          threats++;
          continue;
        }

        // Flag suspiciously large files in cache (> 8 MB — unusual for Flutter assets)
        try {
          final stat = await entity.stat();
          if (stat.size > 8 * 1024 * 1024) threats++;
        } catch (_) {}
      }
    } catch (_) {
      // Permission denied on a sub-dir is fine — skip it
    }
  }

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PRIVACY SCAN
//    Uses a MethodChannel to ask the native side how many *dangerous*
//    permissions are granted beyond a known-safe allowlist.
//
//    Native side (Android, Kotlin) — add to MainActivity or a Plugin:
//
//    MethodChannel("com.yourapp/security").setMethodCallHandler { call, result ->
//      if (call.method == "getDangerousGrantedPermissions") {
//        val dangerous = listOf(
//          Manifest.permission.READ_CONTACTS,
//          Manifest.permission.READ_CALL_LOG,
//          Manifest.permission.RECORD_AUDIO,
//          Manifest.permission.ACCESS_FINE_LOCATION,
//          Manifest.permission.READ_SMS,
//          Manifest.permission.CAMERA,
//          Manifest.permission.READ_EXTERNAL_STORAGE,
//        )
//        val pm = packageManager
//        val granted = dangerous.filter {
//          pm.checkPermission(it, packageName) ==
//              PackageManager.PERMISSION_GRANTED
//        }
//        result.success(granted)
//      }
//    }
// ─────────────────────────────────────────────────────────────────────────────

/// Permissions your app legitimately needs — adjust per your manifest.
const _expectedPermissions = <String>{
  'android.permission.INTERNET',
  'android.permission.ACCESS_NETWORK_STATE',
  'android.permission.CAMERA', // only if your app uses camera
};

const _privacyChannel = MethodChannel('com.yourapp/security');

Future<int> _runPrivacyScan() async {
  try {
    final List<dynamic>? granted = await _privacyChannel
        .invokeMethod<List<dynamic>>('getDangerousGrantedPermissions')
        .timeout(const Duration(seconds: 3));

    if (granted == null) return 0;

    // Count permissions that are NOT in our expected set
    final unexpected = granted
        .cast<String>()
        .where((p) => !_expectedPermissions.contains(p))
        .length;

    return unexpected;
  } on PlatformException {
    // Channel not wired yet — safe default
    return 0;
  } on TimeoutException {
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. VULNERABILITY SCAN
//    Checks Android kernel version + API level via /proc/version and
//    system properties.  Old kernels / old API levels = known CVEs.
// ─────────────────────────────────────────────────────────────────────────────

/// Minimum kernel major.minor considered safe (4.14 LTS baseline).
const _minSafeKernelMajor = 4;
const _minSafeKernelMinor = 14;

/// Minimum Android API level considered safe (Android 10 = API 29).
const _minSafeApiLevel = 29;

Future<int> _runVulnerabilityScan() async {
  int threats = 0;

  // ── Kernel version check ──────────────────────────────────────────────────
  try {
    final versionFile = File('/proc/version');
    if (await versionFile.exists()) {
      final content = await versionFile.readAsString();
      // e.g. "Linux version 4.19.113-perf+ ..."
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

  // ── Android API level check ───────────────────────────────────────────────
  try {
    // system.prop is not directly readable on non-root, but we can try
    // the build.prop alternative via getprop via MethodChannel, or
    // read the SDK from a known proc file.
    // Reliable fallback: read from /proc/cmdline or via MethodChannel.
    final sdkLevel = await _privacyChannel
        .invokeMethod<int>('getSdkVersion')
        .timeout(const Duration(seconds: 2))
        .catchError((_) => null);

    if (sdkLevel != null && sdkLevel < _minSafeApiLevel) threats++;
  } catch (_) {}

  // ── SELinux check ─────────────────────────────────────────────────────────
  try {
    final selinux = File('/sys/fs/selinux/enforce');
    if (await selinux.exists()) {
      final mode = (await selinux.readAsString()).trim();
      // '0' = permissive (not enforcing) — security risk
      if (mode == '0') threats++;
    }
  } catch (_) {}

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. SYSTEM PROTECTION SCAN (Root Detection)
//    Multi-vector root detection: binary paths, build tags, dangerous props,
//    and test-keys signature.
// ─────────────────────────────────────────────────────────────────────────────

/// Known su / root binary locations across common root methods
/// (Magisk, SuperSU, KingRoot, etc.)
const _rootBinaries = [
  '/sbin/su',
  '/system/bin/su',
  '/system/xbin/su',
  '/system/xbin/mu',           // Magisk early variant
  '/data/local/xbin/su',
  '/data/local/bin/su',
  '/data/local/su',
  '/system/sd/xbin/su',
  '/system/bin/failsafe/su',
  '/dev/com.koushikdutta.superuser.daemon/', // SuperUser socket
  '/system/app/Superuser.apk',
  '/system/app/SuperSU.apk',
  '/system/app/Magisk.apk',
  '/data/adb/magisk',          // Magisk data dir
  '/data/adb/modules',         // Magisk modules
];

/// Build tags that indicate a rooted / custom ROM device
const _dangerousBuildTags = ['test-keys', 'dev-keys', 'userdebug'];

Future<int> _runSystemProtectionScan() async {
  int threats = 0;

  // ── Check root binaries ───────────────────────────────────────────────────
  for (final path in _rootBinaries) {
    try {
      if (await File(path).exists() ||
          await Directory(path).exists()) {
        threats++;
        break; // one confirmed root binary is enough
      }
    } catch (_) {}
  }

  // ── Check writable /system ────────────────────────────────────────────────
  // A writable /system partition = device has been rooted + remounted
  try {
    final testFile = File('/system/.rw_test_${DateTime.now().millisecondsSinceEpoch}');
    await testFile.writeAsString('test');
    await testFile.delete();
    threats++; // If we got here, /system is writable!
  } catch (_) {
    // Expected: permission denied on un-rooted device
  }

  // ── Check build tags via MethodChannel ───────────────────────────────────
  // Native side: result.success(android.os.Build.TAGS)
  try {
    final buildTags = await _privacyChannel
        .invokeMethod<String>('getBuildTags')
        .timeout(const Duration(seconds: 2))
        .catchError((_) => null);

    if (buildTags != null) {
      final lower = buildTags.toLowerCase();
      if (_dangerousBuildTags.any((tag) => lower.contains(tag))) threats++;
    }
  } catch (_) {}

  // ── Check dangerous system props via proc ────────────────────────────────
  try {
    // ro.debuggable=1 on a production build means modified ROM
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
  /// Each tuple: (label, scan function)
  /// The label is surfaced in state so the UI can show "Scanning: Virus Check…"
  final List<(String, Future<int> Function())> _scanSteps = [
    ('Virus Scan',         _runVirusScan),
    ('Privacy Scan',       _runPrivacyScan),
    ('Vulnerability Scan', _runVulnerabilityScan),
    ('System Protection',  _runSystemProtectionScan),
  ];

  SecurityScanBloc() : super(const SecurityScanState()) {
    on<SecurityScanStarted>(_onScanStarted);
    on<SecurityScanItemCompleted>(_onItemCompleted);
  }

  Future<void> _onScanStarted(
    SecurityScanStarted event,
    Emitter<SecurityScanState> emit,
  ) async {
    emit(SecurityScanState(
      status: SecurityScanStatus.scanning,
      completedItems: List.filled(_scanSteps.length, false),
      progress: 0,
      threatsFound: 0,
      currentScanLabel: _scanSteps.first.$1,
    ));

    int totalThreats = 0;
    final completed = List.filled(_scanSteps.length, false);

    for (int i = 0; i < _scanSteps.length; i++) {
      final (label, scan) = _scanSteps[i];

      // Update UI to show which scan is currently active
      emit(state.copyWith(currentScanLabel: label));

      final threats = await scan();
      totalThreats += threats;
      completed[i] = true;

      final progress = ((i + 1) / _scanSteps.length * 100).round();

      emit(state.copyWith(
        completedItems: List<bool>.from(completed),
        progress: progress,
        threatsFound: totalThreats,
        currentScanLabel: i < _scanSteps.length - 1
            ? _scanSteps[i + 1].$1
            : label,
      ));

      // Small breathing room between scans for visual feedback
      if (i < _scanSteps.length - 1) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }

    emit(state.copyWith(
      status: SecurityScanStatus.done,
      completedItems: List.filled(_scanSteps.length, true),
      progress: 100,
      threatsFound: totalThreats,
      currentScanLabel: '',
    ));
  }

  void _onItemCompleted(
    SecurityScanItemCompleted event,
    Emitter<SecurityScanState> emit,
  ) {
    final updated = List<bool>.from(state.completedItems);
    if (event.index < updated.length) updated[event.index] = true;
    emit(state.copyWith(completedItems: updated));
  }
}