import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class ToggleItemEvent extends NotificationEvent {
  final int index;
  const ToggleItemEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CleanNotificationsEvent extends NotificationEvent {}

class RequestPermissionEvent extends NotificationEvent {}