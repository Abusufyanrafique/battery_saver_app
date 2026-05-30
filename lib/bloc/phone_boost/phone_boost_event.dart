part of 'phone_boost_bloc.dart';

abstract class PhoneBoostEvent extends Equatable {
  const PhoneBoostEvent();
  @override
  List<Object?> get props => [];
}

/// Screen load par — real data fetch karo
class PhoneBoostStarted extends PhoneBoostEvent {
  const PhoneBoostStarted();
}

/// "Boost Now" button press
class PhoneBoostRequested extends PhoneBoostEvent {
  const PhoneBoostRequested();
}

/// Periodic refresh (har 5 sec)
class PhoneBoostRefresh extends PhoneBoostEvent {
  const PhoneBoostRefresh();
}