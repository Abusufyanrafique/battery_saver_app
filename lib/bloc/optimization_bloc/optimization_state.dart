part of 'optimization_bloc.dart';

enum TaskStatus { completed, inProgress, pending, done }

enum OptimizationPhase {
  idle,
  requestingPermission,
  running,
  stopped,
  complete,
  permissionDenied,
  settingsOpened,
}

enum ResultLoadStatus { initial, loading, loaded, error }

// ─── Combined State ───────────────────────────────────────────────────────────
class OptimizationState {
  // ── Optimize Screen ──────────────────────────────────────────────────────
  final List<TaskStatus> taskStatuses;
  final double progress;        // 0.0 → 1.0
  final bool isRunning;
  final bool isComplete;
  final OptimizationPhase phase;
  final String? errorMessage;

  // ── Result Screen (real device data) ────────────────────────────────────
  final ResultLoadStatus resultStatus;
  final String batterySavedText;    // e.g. "+42m"
  final String ramFreedText;        // e.g. "+312 MB"
  final String junkClearedText;     // e.g. "48 MB"
  final double junkClearedMB;       // raw MB — score calculation ke liye
  final String temperatureText;     // "Normal" / "Warm"
  final double temperatureChange;   // e.g. -3.0
  final int scoreBefore;            // 0-100
  final int scoreAfter;             // 0-100
  final bool isBatteryHealthGood;   // true = "Improved"
  final int batteryLevelBefore;     // % before optimization
  final int batteryLevelAfter;      // % current

  const OptimizationState({
    // Optimize Screen
    required this.taskStatuses,
    required this.progress,
    required this.isRunning,
    required this.isComplete,
    required this.phase,
    this.errorMessage,
    // Result Screen
    required this.resultStatus,
    required this.batterySavedText,
    required this.ramFreedText,
    required this.junkClearedText,
    required this.junkClearedMB,
    required this.temperatureText,
    required this.temperatureChange,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.isBatteryHealthGood,
    required this.batteryLevelBefore,
    required this.batteryLevelAfter,
  });

  factory OptimizationState.initial(int taskCount) => OptimizationState(
        taskStatuses: List.filled(taskCount, TaskStatus.pending),
        progress: 0.0,
        isRunning: false,
        isComplete: false,
        phase: OptimizationPhase.idle,
        // Result defaults
        resultStatus: ResultLoadStatus.initial,
        batterySavedText: '--',
        ramFreedText: '--',
        junkClearedText: '--',
        junkClearedMB: 0,
        temperatureText: '--',
        temperatureChange: 0,
        scoreBefore: 0,
        scoreAfter: 0,
        isBatteryHealthGood: true,
        batteryLevelBefore: 0,
        batteryLevelAfter: 0,
      );

  OptimizationState copyWith({
    List<TaskStatus>? taskStatuses,
    double? progress,
    bool? isRunning,
    bool? isComplete,
    OptimizationPhase? phase,
    String? errorMessage,
    ResultLoadStatus? resultStatus,
    String? batterySavedText,
    String? ramFreedText,
    String? junkClearedText,
    double? junkClearedMB,
    String? temperatureText,
    double? temperatureChange,
    int? scoreBefore,
    int? scoreAfter,
    bool? isBatteryHealthGood,
    int? batteryLevelBefore,
    int? batteryLevelAfter,
  }) {
    return OptimizationState(
      taskStatuses: taskStatuses ?? this.taskStatuses,
      progress: progress ?? this.progress,
      isRunning: isRunning ?? this.isRunning,
      isComplete: isComplete ?? this.isComplete,
      phase: phase ?? this.phase,
      errorMessage: errorMessage,
      resultStatus: resultStatus ?? this.resultStatus,
      batterySavedText: batterySavedText ?? this.batterySavedText,
      ramFreedText: ramFreedText ?? this.ramFreedText,
      junkClearedText: junkClearedText ?? this.junkClearedText,
      junkClearedMB: junkClearedMB ?? this.junkClearedMB,
      temperatureText: temperatureText ?? this.temperatureText,
      temperatureChange: temperatureChange ?? this.temperatureChange,
      scoreBefore: scoreBefore ?? this.scoreBefore,
      scoreAfter: scoreAfter ?? this.scoreAfter,
      isBatteryHealthGood: isBatteryHealthGood ?? this.isBatteryHealthGood,
      batteryLevelBefore: batteryLevelBefore ?? this.batteryLevelBefore,
      batteryLevelAfter: batteryLevelAfter ?? this.batteryLevelAfter,
    );
  }
}