part of 'phone_boost_bloc.dart';

abstract class PhoneBoostEvent extends Equatable {
  const PhoneBoostEvent();

  @override
  List<Object?> get props => [];
}

class PhoneBoostStarted extends PhoneBoostEvent {
  const PhoneBoostStarted();
}

class PhoneBoostRefresh extends PhoneBoostEvent {
  const PhoneBoostRefresh();
}

class PhoneBoostRequested extends PhoneBoostEvent {
  const PhoneBoostRequested();
}

/// Toggle a single app's selection by its index in topApps
class PhoneBoostSelectAppEvent extends PhoneBoostEvent {
  final int index;

  const PhoneBoostSelectAppEvent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Select all / deselect all apps
class PhoneBoostToggleAllEvent extends PhoneBoostEvent {
  const PhoneBoostToggleAllEvent();
}

/// ✅ NEW: Stop (force-close) every selected app, clear their cache,
/// and remove them from the running-apps list so the UI shows
/// "No Background Apps Found" once done.
class PhoneBoostCleanSelectedEvent extends PhoneBoostEvent {
  const PhoneBoostCleanSelectedEvent();
}