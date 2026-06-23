import 'package:battery_saver_app/services/notification_scanner_service.dart';
import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';
import 'package:equatable/equatable.dart';

enum NotificationStatus { initial, loading, permissionDenied, loaded, cleaning, cleaned }

class NotificationState extends Equatable {
  final List<SocialStatItem> items;
  final NotificationStatus status;
  final bool hasPermission;
  final NotificationSummary? summary;

  const NotificationState({
    this.items = const [],
    this.status = NotificationStatus.initial,
    this.hasPermission = false,
    this.summary,
  });

  int get totalCount => items.fold(0, (sum, e) => sum + e.count);

  int get selectedCount => items
      .where((e) => e.isChecked)
      .fold(0, (sum, e) => sum + e.count);

  NotificationState copyWith({
    List<SocialStatItem>? items,
    NotificationStatus? status,
    bool? hasPermission,
    NotificationSummary? summary,
  }) {
    return NotificationState(
      items: items ?? this.items,
      status: status ?? this.status,
      hasPermission: hasPermission ?? this.hasPermission,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [items, status, hasPermission, summary];
}