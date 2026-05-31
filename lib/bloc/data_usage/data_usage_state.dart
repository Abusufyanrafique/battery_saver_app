import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:equatable/equatable.dart';


abstract class DataUsageState extends Equatable {
  const DataUsageState();
  @override
  List<Object?> get props => [];
}

class DataUsageInitial extends DataUsageState {}

class DataUsageLoading extends DataUsageState {
  final UsagePeriod period;
  const DataUsageLoading({this.period = UsagePeriod.today});
}

class DataUsageLoaded extends DataUsageState {
  final DataUsageModel data;
  const DataUsageLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class DataUsageError extends DataUsageState {
  final String message;
  const DataUsageError(this.message);
  @override
  List<Object?> get props => [message];
}