part of 'security_scan_bloc.dart';

enum SecurityScanStatus { idle, scanning, done }

class SecurityScanState extends Equatable {
  final SecurityScanStatus status;

  /// Konse items complete ho gaye (index list)
  final List<bool> completedItems;

  /// 0–100 scan progress
  final int progress;

  /// Kitne threats mile (real check se)
  final int threatsFound;

  const SecurityScanState({
    this.status = SecurityScanStatus.idle,
    this.completedItems = const [false, false, false, false],
    this.progress = 0,
    this.threatsFound = 0,
  });

  bool get isSafe => threatsFound == 0;
  bool get isScanning => status == SecurityScanStatus.scanning;
  bool get isDone => status == SecurityScanStatus.done;

  SecurityScanState copyWith({
    SecurityScanStatus? status,
    List<bool>? completedItems,
    int? progress,
    int? threatsFound,
  }) {
    return SecurityScanState(
      status: status ?? this.status,
      completedItems: completedItems ?? this.completedItems,
      progress: progress ?? this.progress,
      threatsFound: threatsFound ?? this.threatsFound,
    );
  }

  @override
  List<Object?> get props => [status, completedItems, progress, threatsFound];
}