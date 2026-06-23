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

  // ─────────────────────────────────────────────────────────────────
  // LOAD — Summary fetch karo, listener active check karo, items load
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    // 1. Pehle summary se check karo listener active hai ya nahi
    final NotificationSummary summary =
        await NotificationScannerService.getNotificationSummary();

    if (!summary.isListenerActive) {
      // Listener connected nahi — permission denied treat karo
      emit(state.copyWith(
        status: NotificationStatus.permissionDenied,
        hasPermission: false,
        items: [],
      ));
      return;
    }

    // 2. Items fetch karo (async)
    final List<SocialStatItem> items =
        await NotificationScannerService.getCurrentItems();

    emit(state.copyWith(
      status: NotificationStatus.loaded,
      hasPermission: true,
      items: items,
      summary: summary,
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // TOGGLE — checkbox toggle
  // ─────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────
  // CLEAN — checked labels ki notifications cancel karo
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onClean(
    CleanNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.cleaning));

    final List<String> checkedLabels = state.items
        .where((e) => e.isChecked)
        .map((e) => e.label)
        .toList();

    // Real cancel — MethodChannel via Kotlin NotifListenerBridge
    await NotificationScannerService.clearCounts(checkedLabels);

    // UI update — checked items ka count 0 karo
    final List<SocialStatItem> updated = state.items.map((item) {
      if (item.isChecked) {
        return item.copyWith(count: 0, isChecked: false);
      }
      return item;
    }).toList();

    // Sirf woh items dikhao jinka count > 0 hai
    final List<SocialStatItem> filtered =
        updated.where((e) => e.count > 0).toList();

    emit(state.copyWith(
      status: NotificationStatus.cleaned,
      items: filtered,
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // REQUEST PERMISSION — system settings open karo
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // System notification listener settings kholo
    await NotificationScannerService.openPermissionSettings();

    // Wapas load karo — user ne permission de di hogi
    add(LoadNotifications());
  }
}