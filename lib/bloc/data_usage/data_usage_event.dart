import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:equatable/equatable.dart';


abstract class DataUsageEvent extends Equatable {
  const DataUsageEvent();
  @override
  List<Object?> get props => [];
}

class LoadDataUsage extends DataUsageEvent {
  final UsagePeriod period;
  const LoadDataUsage({this.period = UsagePeriod.today});
  @override
  List<Object?> get props => [period];
}

class TogglePeriod extends DataUsageEvent {
  final UsagePeriod period;
  const TogglePeriod(this.period);
  @override
  List<Object?> get props => [period];
}