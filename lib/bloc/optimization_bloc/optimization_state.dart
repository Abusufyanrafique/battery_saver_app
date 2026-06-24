part of 'optimization_bloc.dart';

enum TaskStatus { pending, inProgress, completed, done }

enum OptimizationPhase {
  idle,
  requestingPermission,
  settingsOpened,
  running,
  stopped,
  complete,
}

enum ResultLoadStatus { initial, loading, loaded, error }

class OptimizationState {
  // ── Optimize screen ──────────────────────────────────────────────────────
  final List<TaskStatus> taskStatuses;
  final double progress;
  final bool isRunning;
  final bool isComplete;
  final OptimizationPhase phase;
  final String? errorMessage;

  // ── Result screen — ONLY real, measured values ──────────────────────────
  final ResultLoadStatus resultStatus;
  final int? batteryLevelAtSessionStart;
  final int? batteryLevelNow;
  final double junkClearedMB;
  final String junkClearedText;

  final double diskSpaceFreedMB;
  final String diskSpaceFreedText;
  final double? temperatureCelsius;

  /// Real performance score derived only from real inputs
  /// (current battery % and current free-disk %). No fabricated baseline.
  final int? performanceScore;

  final int? scoreBefore;

  /// Real "after" score — same calculation, using current readings.
  /// Identical to [performanceScore]; kept as a separate field so the
  /// UI can show a clean before/after pair without re-deriving it.
  final int? scoreAfter;

  final double? ramFreedMB;
  final String ramFreedText;

  final String? estimatedBatterySavedText;

  OptimizationState({
    required this.taskStatuses,
    required this.progress,
    required this.isRunning,
    required this.isComplete,
    required this.phase,
    this.errorMessage,
    this.resultStatus = ResultLoadStatus.initial,
    this.batteryLevelAtSessionStart,
    this.batteryLevelNow,
    this.junkClearedMB = 0,
    this.junkClearedText = '',
    this.diskSpaceFreedMB = 0,
    this.diskSpaceFreedText = '',
    this.temperatureCelsius,
    this.performanceScore,
    this.scoreBefore,
    this.scoreAfter,
    this.ramFreedMB,
    this.ramFreedText = '',
    this.estimatedBatterySavedText,
  });

  factory OptimizationState.initial(int totalTasks) {
    return OptimizationState(
      taskStatuses: List<TaskStatus>.filled(totalTasks, TaskStatus.pending),
      progress: 0.0,
      isRunning: false,
      isComplete: false,
      phase: OptimizationPhase.idle,
    );
  }

  OptimizationState copyWith({
    List<TaskStatus>? taskStatuses,
    double? progress,
    bool? isRunning,
    bool? isComplete,
    OptimizationPhase? phase,
    String? errorMessage,
    ResultLoadStatus? resultStatus,
    int? batteryLevelAtSessionStart,
    int? batteryLevelNow,
    double? junkClearedMB,
    String? junkClearedText,
    double? diskSpaceFreedMB,
    String? diskSpaceFreedText,
    double? temperatureCelsius,
    int? performanceScore,
    int? scoreBefore,
    int? scoreAfter,
    double? ramFreedMB,
    String? ramFreedText,
    String? estimatedBatterySavedText,
  }) {
    return OptimizationState(
      taskStatuses: taskStatuses ?? this.taskStatuses,
      progress: progress ?? this.progress,
      isRunning: isRunning ?? this.isRunning,
      isComplete: isComplete ?? this.isComplete,
      phase: phase ?? this.phase,
      errorMessage: errorMessage,
      resultStatus: resultStatus ?? this.resultStatus,
      batteryLevelAtSessionStart:
          batteryLevelAtSessionStart ?? this.batteryLevelAtSessionStart,
      batteryLevelNow: batteryLevelNow ?? this.batteryLevelNow,
      junkClearedMB: junkClearedMB ?? this.junkClearedMB,
      junkClearedText: junkClearedText ?? this.junkClearedText,
      diskSpaceFreedMB: diskSpaceFreedMB ?? this.diskSpaceFreedMB,
      diskSpaceFreedText: diskSpaceFreedText ?? this.diskSpaceFreedText,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      performanceScore: performanceScore ?? this.performanceScore,
      scoreBefore: scoreBefore ?? this.scoreBefore,
      scoreAfter: scoreAfter ?? this.scoreAfter,
      ramFreedMB: ramFreedMB ?? this.ramFreedMB,
      ramFreedText: ramFreedText ?? this.ramFreedText,

      estimatedBatterySavedText: estimatedBatterySavedText,
    );
  }

  /// Real battery percentage saved during this session.
  /// Returns null if no session baseline was recorded yet.
  int? get batteryPercentSavedDuringSession {
    if (batteryLevelAtSessionStart == null || batteryLevelNow == null) {
      return null;
    }
    return batteryLevelNow! - batteryLevelAtSessionStart!;
  }

  bool get isChargeLevelHealthy =>
      batteryLevelNow != null && batteryLevelNow! > 20;
}