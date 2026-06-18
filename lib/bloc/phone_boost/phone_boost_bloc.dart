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

      emit(state.copyWith(
        status: status,
        totalRamMb: totalMb,
        usedRamMb: usedMb,
        memoryUsedPercent: percent,
        runningProcessCount: processCount,
        topApps: topApps,
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

