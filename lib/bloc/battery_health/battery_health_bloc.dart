// lib/blocs/battery_health/battery_health_bloc.dart

import 'package:battery_saver_app/data/repositories/battery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'battery_health_event.dart';
import 'battery_health_state.dart';

class BatteryHealthBloc extends Bloc<BatteryHealthEvent, BatteryHealthState> {
  final BatteryRepository _repository;

  BatteryHealthBloc({required BatteryRepository repository})
      : _repository = repository,
        super(BatteryHealthInitial()) {
    on<LoadBatteryHealth>(_onLoad);
    on<RefreshBatteryHealth>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadBatteryHealth event,
    Emitter<BatteryHealthState> emit,
  ) async {
    emit(BatteryHealthLoading());
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    RefreshBatteryHealth event,
    Emitter<BatteryHealthState> emit,
  ) async {
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<BatteryHealthState> emit) async {
    try {
      final data = await _repository.getBatteryHealth();
      emit(BatteryHealthLoaded(data));
    } catch (e) {
      emit(BatteryHealthError('Failed to load battery data: $e'));
    }
  }
}