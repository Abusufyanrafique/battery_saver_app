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
//    REAL CRITERIA: known malicious extensions only + checksum/size combo
//    REMOVED: ">8MB = threat" — bilkul wrong heuristic tha, normal cache files
//             (videos, images, downloaded media) routinely exceed 8MB.
// ─────────────────────────────────────────────────────────────────────────────
Future<int> _runVirusScan() async {
  int threats = 0;

  // Only genuinely suspicious for an APP'S OWN sandbox:
  // executable/installer payloads that have NO reason to exist in a
  // battery-saver app's private cache/files directory.
  const suspiciousExtensions = [
    '.apk',   // installer package — never legitimately cached by this app
    '.dex',   // raw Android bytecode
    '.so.bak', // backup of native lib — sign of tampering, not normal use
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
        }
        // NOTE: file-size check removed entirely. Size alone says nothing
        // about maliciousness. If you want real malware detection, you need
        // either (a) a signature/hash database compared against known
        // malware hashes, or (b) server-side scanning (e.g. VirusTotal API),
        // not a local heuristic. Be upfront with users that this app only
        // checks its OWN sandbox, not the whole device — Android's
        // permission model doesn't allow a normal app to scan other apps'
        // files or the shared storage for "viruses" on modern OS versions.
      }
    } catch (_) {}
  }

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PRIVACY SCAN
//    REAL CRITERIA:
//    - Dangerous permission count threshold raised — 3+ is normal for many
//      legitimate apps (camera, maps, messaging). Flag only apps combining
//      *high-risk* permission categories that together suggest spyware/
//      stalkerware behavior (e.g. SMS + location + camera/mic + contacts
//      simultaneously), not just "3 permissions of any kind."
//    - Sideloading is reported as INFORMATION, not automatically a threat —
//      most sideloaded apps are F-Droid, work-internal APKs, etc.
//    - Hidden apps (no launcher icon) ARE a meaningful signal — legitimate
//      apps rarely hide their icon; this is a known stalkerware pattern.
// ─────────────────────────────────────────────────────────────────────────────

// Permission categories that, in COMBINATION, indicate real surveillance risk
const _highRiskPermGroups = {
  'location': ['ACCESS_FINE_LOCATION', 'ACCESS_BACKGROUND_LOCATION'],
  'messaging': ['READ_SMS', 'RECEIVE_SMS', 'READ_CALL_LOG'],
  'media': ['CAMERA', 'RECORD_AUDIO'],
  'contacts': ['READ_CONTACTS'],
};

int _countHighRiskGroups(List<dynamic> perms) {
  final permSet = perms.map((p) => p.toString().toUpperCase()).toSet();
  int groupsHit = 0;
  for (final group in _highRiskPermGroups.values) {
    if (group.any((p) => permSet.any((up) => up.contains(p)))) {
      groupsHit++;
    }
  }
  return groupsHit;
}

Future<int> _runPrivacyScan() async {
  int threats = 0;

  // Apps combining 3+ distinct high-risk permission CATEGORIES
  // (not just "any 3 permissions") = genuine stalkerware/spyware pattern.
  try {
    final List<dynamic>? riskyApps = await _channel
        .invokeMethod<List<dynamic>>('getDangerousPermissionApps')
        .timeout(const Duration(seconds: 5));

    if (riskyApps != null) {
      for (final app in riskyApps) {
        final perms = (app as Map)['permissions'] as List? ?? [];
        if (_countHighRiskGroups(perms) >= 3) {
          threats++;
        }
      }
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  // Sideloaded apps are no longer auto-counted as threats.
  // They're surfaced to the UI as informational, but only contribute to
  // the threat count if ALSO hidden (no launcher icon) — that combination
  // (installed outside Play Store AND hiding itself) is the real red flag.
  Set<String> sideloadedPackages = {};
  try {
    final List<dynamic>? sideloaded = await _channel
        .invokeMethod<List<dynamic>>('getSideloadedApps')
        .timeout(const Duration(seconds: 5));
    if (sideloaded != null) {
      sideloadedPackages = sideloaded.map((e) => e.toString()).toSet();
    }
  } on PlatformException {
    // ignore
  } on TimeoutException {
    // ignore
  }

  try {
    final List<dynamic>? hidden = await _channel
        .invokeMethod<List<dynamic>>('getHiddenApps')
        .timeout(const Duration(seconds: 5));

    if (hidden != null) {
      for (final pkg in hidden) {
        // Hidden + sideloaded together = real threat signal.
        // Hidden alone (e.g. a system component) is much weaker signal,
        // still counted but at lower weight conceptually — here we keep
        // it simple and count any hidden app once, since icon-hiding is
        // unusual even for system apps and worth surfacing.
        threats++;
        if (sideloadedPackages.contains(pkg.toString())) {
          threats++; // extra weight for hidden + sideloaded combo
        }
      }
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
//    REAL CRITERIA: kept mostly as-is, these are legitimate checks.
//    Kernel/SDK age and SELinux permissive mode are genuine, well-established
//    security posture indicators used by real device-security tooling.
//    FIX: debuggable apps threshold — having ONE debuggable app (e.g. an app
//    still in dev/testing) isn't itself a device-wide vulnerability; only
//    flag if a debuggable app is also a SYSTEM app (debuggable system apps
//    are a real attack surface) — without that data, we report count as
//    informational severity rather than 1-per-app inflation.
// ─────────────────────────────────────────────────────────────────────────────
const _minSafeKernelMajor = 4;
const _minSafeKernelMinor = 14;
const _minSafeApiLevel = 29; // Android 10

Future<int> _runVulnerabilityScan() async {
  int threats = 0;

  // Kernel version check — legitimate: EOL kernels miss security patches.
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

  // SDK level check — legitimate: old API levels lack security mitigations.
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

  // SELinux check — legitimate: permissive mode is a real, well-known
  // security regression (normally enforced on production Android).
  try {
    final selinux = File('/sys/fs/selinux/enforce');
    if (await selinux.exists()) {
      final mode = (await selinux.readAsString()).trim();
      if (mode == '0') threats++;
    }
  } catch (_) {}

  // Debuggable apps — only count once as a single informational threat,
  // not one threat per debuggable app. A handful of debug-build apps is
  // common (dev tools, test builds) and isn't proportional risk.
  try {
    final List<dynamic>? debugApps = await _channel
        .invokeMethod<List<dynamic>>('getDebuggableApps')
        .timeout(const Duration(seconds: 5));

    if (debugApps != null && debugApps.isNotEmpty) {
      threats += 1; // capped, not debugApps.length
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
//    REAL CRITERIA: root binaries + build type are legitimate, standard
//    root-detection techniques used by real banking/security apps.
//    FIX: removed the "write to /system" probe as a threat source — on
//    Android 10+ this will ALWAYS fail due to system partition being
//    read-only + SELinux, regardless of root status, so it tested nothing
//    meaningful and risked false negatives/positives depending on OS quirks.
//    Modern root detection should rely on binary presence + build tags +
//    Play Integrity API (server-verified) for real confidence — a local
//    write-test is not reliable evidence either way.
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

  // Root binaries check — real, standard technique.
  for (final path in _rootBinaries) {
    try {
      if (await File(path).exists() || await Directory(path).exists()) {
        threats++;
        break; // one hit is enough signal, avoid double counting
      }
    } catch (_) {}
  }

  // Build type check — real, standard technique. userdebug/eng builds
  // ship with elevated privileges not meant for production devices.
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

  // /proc/cmdline check — real, standard technique for bootloader state.
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

  // NOTE: the old "/system writable" write-probe was removed here.
  // It is not a reliable signal on modern Android and was likely
  // contributing to either inflated or meaningless counts.

  return threats;
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoC — unchanged structure, only the scan functions above changed.
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
      emit(SecurityScanState(
        status: SecurityScanStatus.scanning,
        completedItems: List<bool>.from(completed),
        progress: ((i / totalSteps) * 100).round(),
        threatsFound: totalThreats,
        currentScanLabel: _scanSteps[i],
      ));

      final results = await Future.wait([
        _scanFunctions[i](),
        Future.delayed(const Duration(milliseconds: 1000)),
      ]);

      final threats = results[0] as int;
      // TEMP DEBUG: terminal/logcat mein dikhega ke har scan individually
      // kitne threats de raha hai. Confirm karne ke baad hata dena.
      // ignore: avoid_print
      print('[SECURITY SCAN DEBUG] ${_scanSteps[i]} => $threats threats');
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

    emit(SecurityScanState(
      status: SecurityScanStatus.done,
      completedItems: List.filled(totalSteps, true),
      progress: 100,
      threatsFound: totalThreats,
      currentScanLabel: '',
    ));
  }
}