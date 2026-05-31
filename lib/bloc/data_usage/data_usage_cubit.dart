import 'package:battery_saver_app/data/repositories/data_usage_repository.dart';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      // Permission check — async
      final permitted = await _repository.hasPermission();
      if (!permitted!) {
        _repository.requestPermission();
        // User ko permission dene ka waqt do
        await Future.delayed(const Duration(seconds: 3));
      }

      final data = await _repository.getUsage(period);
      emit(DataUsageLoaded(data));
    } catch (e) {
      emit(DataUsageError('Something went wrong: $e'));
    }
  }

  Future<void> togglePeriod(UsagePeriod newPeriod) async {
    if (newPeriod == _currentPeriod && state is DataUsageLoaded) return;
    await loadUsage(period: newPeriod);
  }

  void retry() => loadUsage(period: _currentPeriod);
}