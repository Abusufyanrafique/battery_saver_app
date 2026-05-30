import 'dart:async';
import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<LoadNotifications>(_onLoad);
    on<ToggleItemEvent>(_onToggle);
    on<CleanNotificationsEvent>(_onClean);
  }

  static const List<SocialStatItem> _items = [
    SocialStatItem(label: 'WhatsApp', count: 45, svgAssetPath: 'assets/icons/whatsapp.svg'),
    SocialStatItem(label: 'Facebook', count: 32, svgAssetPath: 'assets/icons/facebook.svg'),
    SocialStatItem(label: 'Instagram', count: 21, svgAssetPath: 'assets/icons/instagram.svg'),
    SocialStatItem(label: 'YouTube', count: 16, svgAssetPath: 'assets/icons/youtube.svg'),
    SocialStatItem(label: 'Others', count: 12, svgAssetPath: 'assets/icons/others.svg'),
  ];

  Future<void> _onLoad(
      LoadNotifications event,
      Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loaded, items: _items));
  }

  void _onToggle(
      ToggleItemEvent event,
      Emitter<NotificationState> emit,
  ) {
    final updated = List<SocialStatItem>.from(state.items);

    final item = updated[event.index];
    updated[event.index] = item.copyWith(isChecked: !item.isChecked);

    emit(state.copyWith(items: updated));
  }

  Future<void> _onClean(
      CleanNotificationsEvent event,
      Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.cleaning));

    await Future.delayed(const Duration(seconds: 2));

    final cleaned =
        state.items.where((e) => !e.isChecked).toList();

    emit(state.copyWith(
      status: NotificationStatus.cleaned,
      items: cleaned,
    ));
  }
}