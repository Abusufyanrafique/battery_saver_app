part of 'phone_boost_bloc.dart';

enum PhoneBoostStatus { initial, loading, monitoring, boosting, boosted, error }

class RunningAppInfo {
  final String name;
  final String packageName;
  final int memoryMb;

  const RunningAppInfo({
    required this.name,
    required this.packageName,
    required this.memoryMb,
  });
}

class PhoneBoostState extends Equatable {
  final PhoneBoostStatus status;

  /// Total RAM in MB
  final int totalRamMb;

  /// Used RAM in MB
  final int usedRamMb;

  /// 0–100 percent used
  final int memoryUsedPercent;

  /// Running process count
  final int runningProcessCount;

  /// Top apps with memory usage
  final List<RunningAppInfo> topApps;

  /// Selection state — one bool per app in topApps (same index order)
  final List<bool> selectedApps;

  /// true if every app in topApps is currently selected
  final bool allSelected;

  final String? errorMessage;

  const PhoneBoostState({
    this.status = PhoneBoostStatus.initial,
    this.totalRamMb = 0,
    this.usedRamMb = 0,
    this.memoryUsedPercent = 0,
    this.runningProcessCount = 0,
    this.topApps = const [],
    this.selectedApps = const [],
    this.allSelected = false,
    this.errorMessage,
  });

  bool get isBoosting => status == PhoneBoostStatus.boosting;
  bool get isLoading =>
      status == PhoneBoostStatus.initial || status == PhoneBoostStatus.loading;

  PhoneBoostState copyWith({
    PhoneBoostStatus? status,
    int? totalRamMb,
    int? usedRamMb,
    int? memoryUsedPercent,
    int? runningProcessCount,
    List<RunningAppInfo>? topApps,
    List<bool>? selectedApps,
    bool? allSelected,
    String? errorMessage,
  }) {
    return PhoneBoostState(
      status: status ?? this.status,
      totalRamMb: totalRamMb ?? this.totalRamMb,
      usedRamMb: usedRamMb ?? this.usedRamMb,
      memoryUsedPercent: memoryUsedPercent ?? this.memoryUsedPercent,
      runningProcessCount: runningProcessCount ?? this.runningProcessCount,
      topApps: topApps ?? this.topApps,
      selectedApps: selectedApps ?? this.selectedApps,
      allSelected: allSelected ?? this.allSelected,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalRamMb,
        usedRamMb,
        memoryUsedPercent,
        runningProcessCount,
        topApps,
        selectedApps,
        allSelected,
        errorMessage,
      ];
}