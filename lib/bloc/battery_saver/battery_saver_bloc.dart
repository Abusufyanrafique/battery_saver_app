import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:battery_saver_app/utils/helper/battery_helpers.dart';
import 'package:battery_saver_app/utils/helper/battery_history_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'battery_saver_event.dart';
part 'battery_saver_state.dart';

class BatterySaverBloc extends Bloc<BatterySaverEvent, BatterySaverState> {
  final Battery _battery;
  StreamSubscription<BatteryState>? _stateSub;
  Timer? _timer;

  BatterySaverBloc({Battery? battery})
      : _battery = battery ?? Battery(),
        super(const BatterySaverState()) {
    on<BatterySaverInitialized>(_onInit);
    on<BatterySaverModeSelected>(_onModeSelected);
    on<BatterySaverApplyPressed>(_onApply);
    on<_BatteryLevelChanged>(_onLevelChanged);
    on<_BatteryStateChanged>(_onStateChanged);
  }

  Future<void> _onInit(
    BatterySaverInitialized event,
    Emitter<BatterySaverState> emit,
  ) async {
    final level = await _battery.batteryLevel;
    final batState = await _battery.batteryState;
    final isCharging =
        batState == BatteryState.charging || batState == BatteryState.full;

    // ── Step 1: Hive se purani history load karo
    final savedHistory = await BatteryHistoryStorage.load();

    // ── Step 2: Startup par purani readings purge karo (30 din se zyada)
    await BatteryHistoryStorage.purgeOld();

    // ── Step 3: Naya reading banao
    final now = DateTime.now();
    final initialReading = BatteryReading(level: level, time: now);

    // Duplicate avoid: last reading 1 minute se kam purani ho toh mat add karo
    final bool isDuplicate = savedHistory.isNotEmpty &&
        now.difference(savedHistory.last.time).inMinutes < 1;

    final List<BatteryReading> history = isDuplicate
        ? savedHistory
        : [...savedHistory, initialReading];

    // ── Step 4: Hive mein append karo (sirf naya reading)
    if (!isDuplicate) {
      await BatteryHistoryStorage.append(initialReading);
    }

    emit(state.copyWith(
      batteryLevel: level,
      healthStatus: healthFromLevel(level),
      isCharging: isCharging,
      remainingTime: isCharging
          ? 'Charging'
          : remainingTimeFromLevel(level, modeIndex: state.appliedIndex),
      batteryHistory: history,
    ));

    // ── Har 5 second mein level check karo
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final newLevel = await _battery.batteryLevel;
      add(_BatteryLevelChanged(newLevel));
    });

    // ── Charging state changes sunna
    _stateSub = _battery.onBatteryStateChanged.listen((s) {
      add(_BatteryStateChanged(s));
    });
  }

  void _onModeSelected(
    BatterySaverModeSelected event,
    Emitter<BatterySaverState> emit,
  ) {
    emit(state.copyWith(
      selectedIndex: event.index,
      clearSuccess: true,
    ));
  }

  Future<void> _onApply(
    BatterySaverApplyPressed event,
    Emitter<BatterySaverState> emit,
  ) async {
    emit(state.copyWith(
      isApplying: true,
      clearError: true,
      clearSuccess: true,
    ));

    await Future.delayed(const Duration(milliseconds: 800));

    emit(state.copyWith(
      isApplying: false,
      appliedIndex: state.selectedIndex,
      applySuccess: true,
      remainingTime: state.isCharging
          ? 'Charging'
          : remainingTimeFromLevel(
              state.batteryLevel,
              modeIndex: state.selectedIndex,
            ),
    ));
  }

  Future<void> _onLevelChanged(
    _BatteryLevelChanged event,
    Emitter<BatterySaverState> emit,
  ) async {
    final newReading = BatteryReading(
      level: event.level,
      time: DateTime.now(),
    );

    // ── Hive mein sirf naya reading append karo
    await BatteryHistoryStorage.append(newReading);

    // ── State ke liye 30 din ka filter lagao
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final updatedHistory = [
      ...state.batteryHistory.where((r) => r.time.isAfter(cutoff)),
      newReading,
    ];

    emit(state.copyWith(
      batteryLevel: event.level,
      healthStatus: healthFromLevel(event.level),
      remainingTime: state.isCharging
          ? 'Charging'
          : remainingTimeFromLevel(
              event.level,
              modeIndex: state.appliedIndex,
            ),
      batteryHistory: updatedHistory,
    ));
  }

  void _onStateChanged(
    _BatteryStateChanged event,
    Emitter<BatterySaverState> emit,
  ) {
    final isCharging =
        event.state == BatteryState.charging ||
        event.state == BatteryState.full;

    emit(state.copyWith(
      isCharging: isCharging,
      remainingTime: isCharging
          ? 'Charging'
          : remainingTimeFromLevel(
              state.batteryLevel,
              modeIndex: state.appliedIndex,
            ),
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _stateSub?.cancel();
    return super.close();
  }
}