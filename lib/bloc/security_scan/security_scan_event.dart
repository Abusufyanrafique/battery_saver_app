part of 'security_scan_bloc.dart';

abstract class SecurityScanEvent extends Equatable {
  const SecurityScanEvent();
  @override
  List<Object?> get props => [];
}

/// Screen load hone par ya "Scan Again" press par
class SecurityScanStarted extends SecurityScanEvent {
  const SecurityScanStarted();
}

/// Har scan item complete hone par (timer se trigger)
class SecurityScanItemCompleted extends SecurityScanEvent {
  final int index;
  const SecurityScanItemCompleted(this.index);
  @override
  List<Object?> get props => [index];
}