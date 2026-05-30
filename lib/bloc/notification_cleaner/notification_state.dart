import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';
import 'package:equatable/equatable.dart';


enum NotificationStatus { initial, loaded, cleaning, cleaned }

class NotificationState extends Equatable {
  final List<SocialStatItem> items;
  final NotificationStatus status;

  const NotificationState({
    this.items = const [],
    this.status = NotificationStatus.initial,
  });

  int get totalCount =>
      items.fold(0, (sum, e) => sum + e.count);

  NotificationState copyWith({
    List<SocialStatItem>? items,
    NotificationStatus? status,
  }) {
    return NotificationState(
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [items, status];
}