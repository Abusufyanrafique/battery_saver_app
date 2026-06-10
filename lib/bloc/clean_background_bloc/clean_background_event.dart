part of 'clean_background_bloc.dart';

abstract class CleanBackgroundEvent {
  const CleanBackgroundEvent();
}

class StartScanningEvent extends CleanBackgroundEvent {
  const StartScanningEvent();
}

class _ScanTickEvent extends CleanBackgroundEvent {
  const _ScanTickEvent();
}

class ToggleAppSelectionEvent extends CleanBackgroundEvent {
  final int index;
  const ToggleAppSelectionEvent(this.index);
}

class ToggleSelectAllAppsEvent extends CleanBackgroundEvent {
  const ToggleSelectAllAppsEvent();
}

class StartCleaningEvent extends CleanBackgroundEvent {
  const StartCleaningEvent();
}

class CleanAgainEvent extends CleanBackgroundEvent {
  const CleanAgainEvent();
}