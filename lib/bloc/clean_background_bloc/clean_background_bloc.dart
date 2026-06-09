import 'dart:async';
import 'package:battery_saver_app/services/device_data_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'clean_background_event.dart';
part 'cleanbackground_state.dart';

class CleanBackgroundBloc
    extends Bloc<CleanBackgroundEvent, CleanBackgroundState> {
  Timer? _scanTimer;
  final DeviceDataService _deviceDataService;

  static const _scanDurationMs = 4000;
  static const _tickMs = 80;

  CleanBackgroundBloc({DeviceDataService? deviceDataService})
      : _deviceDataService = deviceDataService ?? DeviceDataService(),
        super(CleanBackgroundState.initial()) {
    on<StartScanningEvent>(_onStartScanning);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<ToggleAppSelectionEvent>(_onToggleAppSelection);
    on<ToggleSelectAllAppsEvent>(_onToggleSelectAll);
    on<StartCleaningEvent>(_onStartCleaning);
    on<CleaningCompletedEvent>(_onCleaningCompleted);
    on<CleaningFailedEvent>(_onCleaningFailed);
    on<CleanAgainEvent>(_onCleanAgain);
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onStartScanning(
      StartScanningEvent event, Emitter<CleanBackgroundState> emit) async {
    _cancelTimer();
    emit(state.copyWith(
      phase: CleanPhase.scanning,
      scanProgress: 0.0,
      clearResult: true,
      errorMessage: null,
    ));

    // Timer aur fetchRealData parallel chalao
    CleanResultData? fetchedData;
    await Future.wait([
      // Data fetch
      () async {
        try {
          fetchedData = await _deviceDataService.fetchRealData();
        } catch (_) {
          // fetch fail ho toh null rehega, placeholder show hoga
        }
      }(),
      // Progress animation
      () async {
        double elapsed = 0;
        const tickDuration = Duration(milliseconds: _tickMs);
        while (elapsed < _scanDurationMs) {
          await Future.delayed(tickDuration);
          elapsed += _tickMs;
          final progress = (elapsed / _scanDurationMs).clamp(0.0, 1.0);
          emit(state.copyWith(scanProgress: progress));
        }
      }(),
    ]);

    // Dono complete — real data ke saath cleanReady emit karo
    emit(state.copyWith(
      scanProgress: 1.0,
      phase: CleanPhase.cleanReady,
      cleanResult: fetchedData, // ab null nahi hoga
    ));
  }

  void _onUpdateProgress(
      UpdateProgressEvent event, Emitter<CleanBackgroundState> emit) {
    if (event.progress >= 1.0) {
      _cancelTimer();
      emit(state.copyWith(
        scanProgress: 1.0,
        phase: CleanPhase.cleanReady,
      ));
    } else {
      emit(state.copyWith(scanProgress: event.progress));
    }
  }

  void _onToggleAppSelection(
      ToggleAppSelectionEvent event, Emitter<CleanBackgroundState> emit) {
    final updated = List<bool>.from(state.appsSelected);
    updated[event.index] = !updated[event.index];
    emit(state.copyWith(appsSelected: updated));
  }

  void _onToggleSelectAll(
      ToggleSelectAllAppsEvent event, Emitter<CleanBackgroundState> emit) {
    final newValue = !state.allSelected;
    emit(state.copyWith(
        appsSelected: List.filled(state.appsSelected.length, newValue)));
  }

  Future<void> _onStartCleaning(
      StartCleaningEvent event, Emitter<CleanBackgroundState> emit) async {
    emit(state.copyWith(phase: CleanPhase.cleaning));
    try {
      final result = await _deviceDataService.fetchRealData();
      emit(state.copyWith(
        phase: CleanPhase.completed,
        cleanResult: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        phase: CleanPhase.cleanReady,
        errorMessage: 'Cleaning failed: ${e.toString()}',
      ));
    }
  }

  void _onCleaningCompleted(
      CleaningCompletedEvent event, Emitter<CleanBackgroundState> emit) {
    emit(state.copyWith(
      phase: CleanPhase.completed,
      cleanResult: event.result,
    ));
  }

  void _onCleaningFailed(
      CleaningFailedEvent event, Emitter<CleanBackgroundState> emit) {
    emit(state.copyWith(
      phase: CleanPhase.cleanReady,
      errorMessage: event.message,
    ));
  }

  void _onCleanAgain(
      CleanAgainEvent event, Emitter<CleanBackgroundState> emit) {
    _cancelTimer();
    emit(CleanBackgroundState.initial());
    add(StartScanningEvent());
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _cancelTimer() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}