import 'dart:collection';

/// A single real observation: battery % at a point in time.
class DrainSample {
  final int level;
  final DateTime time;
  const DrainSample(this.level, this.time);
}


///
/// Trade-off: estimates are unavailable until enough real samples exist
/// (see [minSamples] / [minElapsedMinutes]). The UI must show a
/// "Calculating..." state during this window rather than a guessed number.
class BatteryDrainTracker {
  BatteryDrainTracker({
    this.maxSamples = 40,
    this.minSamples = 3,
    this.minElapsedMinutes = 3,
  });

  final int maxSamples;
  final int minSamples;
  final int minElapsedMinutes;

  final Queue<DrainSample> _samples = Queue<DrainSample>();

  /// Record a real battery level reading. Call this whenever the level
  /// changes (e.g. from Battery.onBatteryStateChanged) or periodically.
  ///
  /// If the level goes UP (charging) or stays flat across a sudden jump,
  /// the tracker resets — old discharge data is no longer valid for
  /// estimating discharge time.
  void recordSample(int level, {DateTime? at}) {
    final time = at ?? DateTime.now();

    if (_samples.isNotEmpty && level > _samples.last.level) {
      // Charging happened — old discharge-rate data is stale, start over.
      _samples.clear();
    }

    _samples.add(DrainSample(level, time));
    while (_samples.length > maxSamples) {
      _samples.removeFirst();
    }
  }

  /// Clears all collected samples (e.g. call this when charging starts/stops
  /// so stale data doesn't pollute a fresh discharge-rate calculation).
  void reset() => _samples.clear();

  bool get hasEnoughData {
    if (_samples.length < minSamples) return false;
    final elapsed = _samples.last.time.difference(_samples.first.time);
    return elapsed.inMinutes >= minElapsedMinutes;
  }

  /// Real measured minutes-per-1%-drop, derived only from actual samples.
  /// Returns null if there isn't enough real data yet.
  double? get realMinutesPerPercent {
    if (!hasEnoughData) return null;

    final first = _samples.first;
    final last = _samples.last;
    final levelDrop = first.level - last.level;
    if (levelDrop <= 0) return null; // no real discharge observed yet

    final minutesElapsed = last.time.difference(first.time).inMinutes;
    if (minutesElapsed <= 0) return null;

    return minutesElapsed / levelDrop;
  }

  /// Real estimated remaining time at [currentLevel], formatted as "Xh Ym".
  /// Returns null if not enough real data exists — caller must show a
  /// "Calculating..." state in that case, never fabricate a number.
  String? estimateRemainingTime(int currentLevel) {
    final rate = realMinutesPerPercent;
    if (rate == null) return null;

    final totalMinutes = (rate * currentLevel).round();
    if (totalMinutes <= 0) return null;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}