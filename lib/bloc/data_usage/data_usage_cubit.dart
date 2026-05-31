import 'package:battery_saver_app/data/repositories/data_usage_repository.dart';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'data_usage_event.dart';
import 'data_usage_state.dart';

class DataUsageCubit extends Cubit<DataUsageState> {
  final DataUsageRepository _repository;
  UsagePeriod _currentPeriod = UsagePeriod.today;

  DataUsageCubit(this._repository) : super(DataUsageInitial());

  UsagePeriod get currentPeriod => _currentPeriod;

  Future<void> loadUsage({UsagePeriod period = UsagePeriod.today}) async {
    _currentPeriod = period;
    emit(DataUsageLoading(period: period));

    try {
      // Request usage stats permission (Android)
      final status = await Permission.manageExternalStorage.request();
      // Note: usage_stats needs special permission — guide user if denied
      
      final data = await _repository.getUsage(period);
      emit(DataUsageLoaded(data));
    } catch (e) {
      emit(DataUsageError('Failed to load data: $e'));
    }
  }

  Future<void> togglePeriod(UsagePeriod newPeriod) async {
    if (newPeriod == _currentPeriod) return;
    await loadUsage(period: newPeriod);
  }

  void retry() => loadUsage(period: _currentPeriod);
}