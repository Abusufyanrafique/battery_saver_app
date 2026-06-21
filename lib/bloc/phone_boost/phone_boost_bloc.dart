import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'phone_boost_event.dart';
part 'phone_boost_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Method Channel — MainActivity.kt se RAM + process data leta hai
// ─────────────────────────────────────────────────────────────────────────────
const _channel = MethodChannel('com.example.battery_saver_app/phone_boost');

class PhoneBoostBloc extends Bloc<PhoneBoostEvent, PhoneBoostState> {
  Timer? _timer;

  PhoneBoostBloc() : super(const PhoneBoostState()) {
    on<PhoneBoostStarted>(_onStarted);
    on<PhoneBoostRefresh>(_onRefresh);
    on<PhoneBoostRequested>(_onBoostRequested);
    on<PhoneBoostSelectAppEvent>(_onSelectApp);
    on<PhoneBoostToggleAllEvent>(_onToggleAll);
    on<PhoneBoostCleanSelectedEvent>(_onCleanSelected);
  }

  Future<void> _onStarted(
    PhoneBoostStarted event,
    Emitter<PhoneBoostState> emit,
  ) async {
    emit(state.copyWith(status: PhoneBoostStatus.loading));
    await _fetchAndEmit(emit, status: PhoneBoostStatus.monitoring);

    // Refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      add(const PhoneBoostRefresh());
    });
  }

  Future<void> _onRefresh(
    PhoneBoostRefresh event,
    Emitter<PhoneBoostState> emit,
  ) async {
    if (state.isBoosting) return;
    await _fetchAndEmit(emit, status: PhoneBoostStatus.monitoring);
  }

  Future<void> _onBoostRequested(
    PhoneBoostRequested event,
    Emitter<PhoneBoostState> emit,
  ) async {
    _timer?.cancel();
    emit(state.copyWith(status: PhoneBoostStatus.boosting));

    try {
      await _channel.invokeMethod('boostMemory');
    } catch (_) {}

    // Wait for system to reclaim memory
    await Future.delayed(const Duration(seconds: 2));

    await _fetchAndEmit(emit, status: PhoneBoostStatus.boosted);

    // Resume polling
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      add(const PhoneBoostRefresh());
    });
  }

  /// Toggle selection for a single app at [index]
  void _onSelectApp(
    PhoneBoostSelectAppEvent event,
    Emitter<PhoneBoostState> emit,
  ) {
    final updated = List<bool>.from(state.selectedApps);

    // Defensive: grow the list if topApps changed size since last build
    while (updated.length < state.topApps.length) {
      updated.add(false);
    }

    if (event.index < 0 || event.index >= updated.length) return;

    updated[event.index] = !updated[event.index];

    final allNowSelected =
        updated.isNotEmpty && updated.every((selected) => selected);

    emit(state.copyWith(
      selectedApps: updated,
      allSelected: allNowSelected,
    ));
  }

  /// Select all if not all selected yet, otherwise deselect all
  void _onToggleAll(
    PhoneBoostToggleAllEvent event,
    Emitter<PhoneBoostState> emit,
  ) {
    final newAllSelected = !state.allSelected;
    final updated = List<bool>.filled(state.topApps.length, newAllSelected);

    emit(state.copyWith(
      selectedApps: updated,
      allSelected: newAllSelected,
    ));
  }

  /// ✅ NEW: Stop every selected app (force-stop + clear its cache on the
  /// native side), then remove those apps from topApps/selectedApps so the
  /// UI naturally falls back to "No Background Apps Found" once the list
  /// is empty.
  Future<void> _onCleanSelected(
    PhoneBoostCleanSelectedEvent event,
    Emitter<PhoneBoostState> emit,
  ) async {
    // Collect package names of selected apps only.
    final selectedPackageNames = <String>[];
    for (var i = 0; i < state.topApps.length; i++) {
      final isSelected = i < state.selectedApps.length && state.selectedApps[i];
      if (isSelected) {
        selectedPackageNames.add(state.topApps[i].packageName);
      }
    }

    // If nothing is selected, there's nothing to stop — just no-op.
    if (selectedPackageNames.isEmpty) return;

    emit(state.copyWith(status: PhoneBoostStatus.boosting));

    try {
      // Native side: force-stop each package + clear its cache.
      // MainActivity.kt should expose this method (see notes).
      await _channel.invokeMethod('stopApps', {
        'packageNames': selectedPackageNames,
      });
    } catch (_) {
      // Even if the native call fails/partially fails, we still update the
      // UI optimistically below so the user sees progress. Adjust if you'd
      // rather surface a hard error instead.
    }

    // Remove the cleaned apps from the local list immediately so the UI
    // reflects "No Background Apps Found" without waiting for the next
    // 5-second poll.
    final remainingApps = <RunningAppInfo>[];
    for (var i = 0; i < state.topApps.length; i++) {
      final wasSelected =
          i < state.selectedApps.length && state.selectedApps[i];
      if (!wasSelected) {
        remainingApps.add(state.topApps[i]);
      }
    }

    emit(state.copyWith(
      status: PhoneBoostStatus.boosted,
      topApps: remainingApps,
      selectedApps: List<bool>.filled(remainingApps.length, false),
      allSelected: false,
    ));

    // Re-sync with the real system state shortly after, in case some apps
    // could not actually be stopped (e.g. OS restrictions) — this keeps the
    // list honest rather than just trusting the optimistic removal forever.
    await Future.delayed(const Duration(seconds: 2));
    await _fetchAndEmit(emit, status: PhoneBoostStatus.monitoring);
  }

  Future<void> _fetchAndEmit(
    Emitter<PhoneBoostState> emit, {
    required PhoneBoostStatus status,
  }) async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getMemoryInfo');

      if (result == null) return;

      final totalMb = (result['totalRamMb'] as num?)?.toInt() ?? 0;
      final usedMb = (result['usedRamMb'] as num?)?.toInt() ?? 0;
      final processCount = (result['runningProcessCount'] as num?)?.toInt() ?? 0;
      final percent = totalMb > 0 ? ((usedMb / totalMb) * 100).round() : 0;

      // Top apps list
      final rawApps = result['topApps'] as List<dynamic>? ?? [];
      final topApps = rawApps.map((a) {
        final map = a as Map<dynamic, dynamic>;
        return RunningAppInfo(
          name: map['name'] as String? ?? 'Unknown',
          packageName: map['packageName'] as String? ?? '',
          memoryMb: (map['memoryMb'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      // Keep selection list in sync with the new topApps length.
      // Preserve existing selections where possible (by index), default
      // new/extra slots to false.
      final preservedSelections = List<bool>.generate(
        topApps.length,
        (i) => i < state.selectedApps.length ? state.selectedApps[i] : false,
      );
      final allNowSelected = preservedSelections.isNotEmpty &&
          preservedSelections.every((selected) => selected);

      emit(state.copyWith(
        status: status,
        totalRamMb: totalMb,
        usedRamMb: usedMb,
        memoryUsedPercent: percent,
        runningProcessCount: processCount,
        topApps: topApps,
        selectedApps: preservedSelections,
        allSelected: allNowSelected,
      ));
    } on PlatformException catch (e) {
      emit(state.copyWith(
        status: PhoneBoostStatus.error,
        errorMessage: e.message,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}