abstract class JunkEvent {}

class StartScanEvent extends JunkEvent {}

class ScanTickEvent extends JunkEvent {
  final String packageName;
  ScanTickEvent(this.packageName);
}

class ToggleJunkItemEvent extends JunkEvent {
  final int index;
  ToggleJunkItemEvent(this.index);
}

class CleanJunkEvent extends JunkEvent {}