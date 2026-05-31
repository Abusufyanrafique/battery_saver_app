import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/services/notification_scanner_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<LoadNotifications>(_onLoad);
    on<ToggleItemEvent>(_onToggle);
    on<CleanNotificationsEvent>(_onClean);
    on<RequestPermissionEvent>(_onRequestPermission);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    final bool permitted = await NotificationScannerService.hasPermission();

    if (!permitted) {
      emit(state.copyWith(
        status: NotificationStatus.permissionDenied,
        hasPermission: false,
        items: [],
      ));
      return;
    }

    // Listener start karo
    await NotificationScannerService.startListening();

    // 2 second wait karo stream events ke liye
    await Future.delayed(const Duration(seconds: 2));

    // Chahe counts hon ya na hon — loaded emit karo
    final List<SocialStatItem> items =
        NotificationScannerService.getCurrentItems();

    emit(state.copyWith(
      status: NotificationStatus.loaded,
      hasPermission: true,
      items: items,
    ));
  }

  void _onToggle(
    ToggleItemEvent event,
    Emitter<NotificationState> emit,
  ) {
    final List<SocialStatItem> updated =
        List<SocialStatItem>.from(state.items);
    final SocialStatItem item = updated[event.index];
    updated[event.index] = item.copyWith(isChecked: !item.isChecked);
    emit(state.copyWith(items: updated));
  }

  Future<void> _onClean(
    CleanNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.cleaning));
    await Future.delayed(const Duration(seconds: 2));

    final List<String> checkedLabels = state.items
        .where((e) => e.isChecked)
        .map((e) => e.label)
        .toList();

    NotificationScannerService.clearCounts(checkedLabels);

    final List<SocialStatItem> updated = [];
    for (final SocialStatItem item in state.items) {
      if (item.isChecked) {
        updated.add(item.copyWith(count: 0, isChecked: false));
      } else {
        updated.add(item);
      }
    }

    final List<SocialStatItem> filtered =
        updated.where((e) => e.count > 0).toList();

    emit(state.copyWith(
      status: NotificationStatus.cleaned,
      items: filtered,
    ));
  }

  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await NotificationScannerService.requestPermission();
    add(LoadNotifications());
  }
}