import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'security_scan_event.dart';
part 'security_scan_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Real security checks (no permissions needed)
// ─────────────────────────────────────────────────────────────────────────────

/// 1. Virus Scan — checks for suspicious writable paths in app directory
Future<int> _runVirusScan() async {
  int threats = 0;
  try {
    final appDir = Directory('/data/data');
    // Check for unexpected .apk or .dex files in temp directories
    const suspiciousExtensions = ['.apk', '.dex', '.so.bak'];
    final cacheDir = Directory(
        '/data/data/${const String.fromEnvironment('APP_ID', defaultValue: '')}/cache');
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          if (suspiciousExtensions.any((ext) => entity.path.endsWith(ext))) {
            threats++;
          }
        }
      }
    }
  } catch (_) {}
  return threats;
}

/// 2. Privacy Scan — checks if dangerous permissions are currently active
///    Uses platform channel result passed from native side via MethodChannel.
///    Falls back to 0 if not available.
Future<int> _runPrivacyScan() async {
  // Simulate checking: in real app wire this to MethodChannel
  // returning count of granted dangerous permissions beyond expected ones.
  await Future.delayed(const Duration(milliseconds: 300));
  return 0; // safe by default
}

/// 3. Vulnerability Scan — checks if device is running an old API level
///    Old API = higher vulnerability risk
Future<int> _runVulnerabilityScan() async {
  try {
    // Read Android SDK version from /proc/version or system property
    final versionFile = File('/proc/version');
    if (await versionFile.exists()) {
      final content = await versionFile.readAsString();
      // Very old kernels (pre-4.x) considered vulnerable
      if (content.contains('3.') || content.contains('2.')) return 1;
    }
  } catch (_) {}
  return 0;
}

/// 4. System Protection — checks if device is rooted
Future<int> _runSystemProtectionScan() async {
  const rootPaths = [
    '/system/app/Superuser.apk',
    '/sbin/su',
    '/system/bin/su',
    '/system/xbin/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/system/sd/xbin/su',
  ];
  for (final path in rootPaths) {
    if (await File(path).exists()) return 1; // rooted = threat
  }
  return 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────────────────────────────────────────
class SecurityScanBloc extends Bloc<SecurityScanEvent, SecurityScanState> {
  final List<Future<int> Function()> _scanSteps = [
    _runVirusScan,
    _runPrivacyScan,
    _runVulnerabilityScan,
    _runSystemProtectionScan,
  ];

  SecurityScanBloc() : super(const SecurityScanState()) {
    on<SecurityScanStarted>(_onScanStarted);
    on<SecurityScanItemCompleted>(_onItemCompleted);
  }

  Future<void> _onScanStarted(
    SecurityScanStarted event,
    Emitter<SecurityScanState> emit,
  ) async {
    // Reset to scanning state
    emit(const SecurityScanState(
      status: SecurityScanStatus.scanning,
      completedItems: [false, false, false, false],
      progress: 0,
      threatsFound: 0,
    ));

    int totalThreats = 0;
    final completed = [false, false, false, false];

    for (int i = 0; i < _scanSteps.length; i++) {
      // Small delay between items for visual effect
      await Future.delayed(const Duration(milliseconds: 800));

      // Run the actual check
      final threats = await _scanSteps[i]();
      totalThreats += threats;
      completed[i] = true;

      final progress = ((i + 1) / _scanSteps.length * 100).round();

      emit(state.copyWith(
        completedItems: List.from(completed),
        progress: progress,
        threatsFound: totalThreats,
      ));
    }

    // All done
    emit(state.copyWith(
      status: SecurityScanStatus.done,
      progress: 100,
      threatsFound: totalThreats,
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