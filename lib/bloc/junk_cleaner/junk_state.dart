import 'package:battery_saver_app/models/junk/junk_item.dart';

enum ScanPhase { idle, scanning, done, cleaning, cleaned }

class JunkState {
  final List<JunkItem> items;
  final ScanPhase phase;
  final String currentPackage;
  final String totalJunkDisplay;

  const JunkState({
    required this.items,
    required this.phase,
    required this.currentPackage,
    required this.totalJunkDisplay,
  });

  factory JunkState.initial() => const JunkState(
        items: [],
        phase: ScanPhase.idle,
        currentPackage: '',
        totalJunkDisplay: '0 MB',
      );

  JunkState copyWith({
    List<JunkItem>? items,
    ScanPhase? phase,
    String? currentPackage,
    String? totalJunkDisplay,
  }) {
    return JunkState(
      items: items ?? this.items,
      phase: phase ?? this.phase,
      currentPackage: currentPackage ?? this.currentPackage,
      totalJunkDisplay: totalJunkDisplay ?? this.totalJunkDisplay,
    );
  }
}