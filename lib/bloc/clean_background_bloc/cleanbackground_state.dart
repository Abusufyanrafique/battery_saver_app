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

  // ✅ File lists
  final List<DeviceFile> cacheFileList;
  final List<DeviceFile> residualFileList;

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
  });

  // Shortcut getters
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
        phase:       CleanPhase.idle,
        scanProgress: 0.0,
        appsSelected: [true, true, true, true, true],
        cleanResult:  null,
        errorMessage: null,
      );

  bool get allSelected => appsSelected.every((s) => s);

  // Convenient getters — null-safe
  List<DeviceFile> get cacheFiles    => cleanResult?.cacheFileList    ?? [];
  List<DeviceFile> get residualFiles => cleanResult?.residualFileList ?? [];

  CleanBackgroundState copyWith({
    CleanPhase?     phase,
    double?         scanProgress,
    List<bool>?     appsSelected,
    CleanResultData? cleanResult,
    bool            clearResult  = false,
    String?         errorMessage,
  }) =>
      CleanBackgroundState(
        phase:        phase        ?? this.phase,
        scanProgress: scanProgress ?? this.scanProgress,
        appsSelected: appsSelected ?? this.appsSelected,
        cleanResult:  clearResult ? null : (cleanResult ?? this.cleanResult),
        errorMessage: errorMessage ?? this.errorMessage,
      );
}