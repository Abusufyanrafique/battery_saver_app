part of 'security_scan_bloc.dart';

enum SecurityScanStatus { idle, scanning, done }

class SecurityScanState extends Equatable {
  final SecurityScanStatus status;
  final List<bool> completedItems;
  final int progress;
  final int threatsFound;

  /// Human-readable name of the scan currently running, e.g. "Virus Scan"
  final String currentScanLabel;

  const SecurityScanState({
    this.status = SecurityScanStatus.idle,
    this.completedItems = const [false, false, false, false],
    this.progress = 0,
    this.threatsFound = 0,
    this.currentScanLabel = '',
  });

  bool get isSafe => threatsFound == 0;
  bool get isScanning => status == SecurityScanStatus.scanning;
  bool get isDone => status == SecurityScanStatus.done;

  SecurityScanState copyWith({
    SecurityScanStatus? status,
    List<bool>? completedItems,
    int? progress,
    int? threatsFound,
    String? currentScanLabel,
  }) {
    return SecurityScanState(
      status: status ?? this.status,
      completedItems: completedItems ?? this.completedItems,
      progress: progress ?? this.progress,
      threatsFound: threatsFound ?? this.threatsFound,
      currentScanLabel: currentScanLabel ?? this.currentScanLabel,
    );
  }

  @override
  List<Object?> get props =>
      [status, completedItems, progress, threatsFound, currentScanLabel];
}