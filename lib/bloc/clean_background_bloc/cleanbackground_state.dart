part of 'clean_background_bloc.dart';

enum CleanPhase { idle, scanning, cleanReady, cleaning, completed }

// ─────────────────────────────────────────────────────────────────
// FILE MODEL
// ─────────────────────────────────────────────────────────────────
class DeviceFile {
  final String name;
  final String path;
  final int sizeBytes;
  final DateTime lastModified;

  const DeviceFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.lastModified,
  });

  factory DeviceFile.fromMap(Map map) => DeviceFile(
        name:         map['name']         as String? ?? '',
        path:         map['path']         as String? ?? '',
        sizeBytes:    map['size']         as int?    ?? 0,
        lastModified: DateTime.fromMillisecondsSinceEpoch(
                        map['lastModified'] as int? ?? 0),
      );

  String get sizeFormatted {
    if (sizeBytes < 1024)        return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────
// ✅ NEW: RUNNING APP MODEL
// ─────────────────────────────────────────────────────────────────
class RunningAppInfo {
  final String packageName;
  final String appName;
  final double sizeMb;

  const RunningAppInfo({
    required this.packageName,
    required this.appName,
    required this.sizeMb,
  });

  factory RunningAppInfo.fromMap(Map map) => RunningAppInfo(
        packageName: map['packageName'] as String? ?? '',
        appName:     map['appName']     as String? ?? '',
        sizeMb:      (map['sizeMb'] as num?)?.toDouble() ?? 0.0,
      );

  String get sizeFormatted {
    if (sizeMb < 1.0) return '${(sizeMb * 1024).toStringAsFixed(0)} KB';
    return '${sizeMb.toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────
// RESULT DATA
// ─────────────────────────────────────────────────────────────────
class CleanResultData {
  final String junkRemoved;
  final String appsClosed;
  final String cacheCleared;
  final String residualFiles;
  final double beforeGB;
  final double afterGB;
  final double totalGB;
  final List<DeviceFile>     cacheFileList;
  final List<DeviceFile>     residualFileList;
  // ✅ Real running apps
  final List<RunningAppInfo> runningApps;

  const CleanResultData({
    required this.junkRemoved,
    required this.appsClosed,
    required this.cacheCleared,
    required this.residualFiles,
    required this.beforeGB,
    required this.afterGB,
    required this.totalGB,
    this.cacheFileList    = const [],
    this.residualFileList = const [],
    this.runningApps      = const [],   // ✅
  });

  int get cacheCount    => cacheFileList.length;
  int get residualCount => residualFileList.length;
}

// ─────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────
class CleanBackgroundState {
  final CleanPhase phase;
  final double scanProgress;
  final List<bool> appsSelected;
  final CleanResultData? cleanResult;
  final String? errorMessage;

  const CleanBackgroundState({
    required this.phase,
    required this.scanProgress,
    required this.appsSelected,
    this.cleanResult,
    this.errorMessage,
  });

  factory CleanBackgroundState.initial() => const CleanBackgroundState(
        phase:        CleanPhase.idle,
        scanProgress: 0.0,
        appsSelected: [],   //empty — real data aane pe dynamically resize hoga
        cleanResult:  null,
        errorMessage: null,
      );

  bool get allSelected =>
      appsSelected.isNotEmpty && appsSelected.every((s) => s);

  // Convenient getters
  List<DeviceFile>     get cacheFiles    => cleanResult?.cacheFileList    ?? [];
  List<DeviceFile>     get residualFiles => cleanResult?.residualFileList ?? [];
  List<RunningAppInfo> get runningApps   => cleanResult?.runningApps      ?? []; 

  CleanBackgroundState copyWith({
    CleanPhase?      phase,
    double?          scanProgress,
    List<bool>?      appsSelected,
    CleanResultData? cleanResult,
    bool             clearResult  = false,
    String?          errorMessage,
  }) =>
      CleanBackgroundState(
        phase:        phase        ?? this.phase,
        scanProgress: scanProgress ?? this.scanProgress,
        appsSelected: appsSelected ?? this.appsSelected,
        cleanResult:  clearResult ? null : (cleanResult ?? this.cleanResult),
        errorMessage: errorMessage ?? this.errorMessage,
      );
}