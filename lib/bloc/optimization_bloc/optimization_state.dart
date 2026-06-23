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

  /// Real battery % at the moment the user pressed "Optimize".
  /// Null until a session has actually started.
  final int? batteryLevelAtSessionStart;

  /// Real battery % right now (when result is shown).
  final int? batteryLevelNow;

  /// Real measured cache size removed, in MB. Always >= 0.
  final double junkClearedMB;
  final String junkClearedText;

  /// Real measured free-disk-space delta caused by the cache clear, in MB.
  /// Can be 0 if nothing was cleared.
  final double diskSpaceFreedMB;
  final String diskSpaceFreedText;

  /// Real battery temperature in Celsius, read from the OS via a platform
  /// channel (BatteryManager.EXTRA_TEMPERATURE on Android). Null if the
  /// platform channel is unavailable (e.g. iOS, or call failed) — in that
  /// case the UI must hide the temperature row rather than invent a value.
  final double? temperatureCelsius;

  /// Real performance score derived only from real inputs
  /// (current battery % and current free-disk %). No fabricated baseline.
  final int? performanceScore;

  /// Real "before" score — captured at the moment the optimize session
  /// started, from real battery % and real free-disk % at that time.
  /// Null if the user reached the result screen without starting a
  /// session (no genuine "before" snapshot exists in that case).
  final int? scoreBefore;

  /// Real "after" score — same calculation, using current readings.
  /// Identical to [performanceScore]; kept as a separate field so the
  /// UI can show a clean before/after pair without re-deriving it.
  final int? scoreAfter;

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

  /// Honest status label based only on the real current charge level.
  /// This does NOT claim to measure battery "health" (wear/degradation) —
  /// no such API exists. It only reflects whether the current charge is
  /// in a comfortable range.
  bool get isChargeLevelHealthy =>
      batteryLevelNow != null && batteryLevelNow! > 20;
}