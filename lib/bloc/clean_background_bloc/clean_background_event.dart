part of 'clean_background_bloc.dart';

abstract class CleanBackgroundEvent {}

class StartScanningEvent extends CleanBackgroundEvent {}

class UpdateProgressEvent extends CleanBackgroundEvent {
  final double progress;
  UpdateProgressEvent(this.progress);
}

class ToggleAppSelectionEvent extends CleanBackgroundEvent {
  final int index;
  ToggleAppSelectionEvent(this.index);
}

class ToggleSelectAllAppsEvent extends CleanBackgroundEvent {}

class StartCleaningEvent extends CleanBackgroundEvent {}

// Result DeviceDataService se aata hai
class CleaningCompletedEvent extends CleanBackgroundEvent {
  final CleanResultData result;
  CleaningCompletedEvent(this.result);
}

// Error case
class CleaningFailedEvent extends CleanBackgroundEvent {
  final String message;
  CleaningFailedEvent(this.message);
}

class CleanAgainEvent extends CleanBackgroundEvent {}