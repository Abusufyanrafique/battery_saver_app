import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';

class NotificationScannerService {
  static const _channel = MethodChannel('com.example.battery_saver_app/notification_cleaner');

  // ─────────────────────────────────────────────
  static void _log(String tag, String msg) =>
      debugPrint('🟢 [NOTIF][$tag] $msg');
  static void _error(String tag, String msg) =>
      debugPrint('🔴 [NOTIF][ERROR][$tag] $msg');
  static void _warn(String tag, String msg) =>
      debugPrint('🟡 [NOTIF][WARN][$tag] $msg');

  // ─────────────────────────────────────────────
  static const Map<String, Map<String, String>> _appMap = {
    'com.whatsapp':               {'label': 'WhatsApp',  'icon': 'whatsapp'},
    'com.facebook.katana':        {'label': 'Facebook',  'icon': 'facebook'},
    'com.facebook.orca':          {'label': 'Facebook',  'icon': 'facebook'},
    'com.instagram.android':      {'label': 'Instagram', 'icon': 'instagram'},
    'com.google.android.youtube': {'label': 'YouTube',   'icon': 'youtube'},
    'com.snapchat.android':       {'label': 'Snapchat',  'icon': 'others'},
    'com.twitter.android':        {'label': 'Twitter',   'icon': 'others'},
    'com.tiktok.android':         {'label': 'TikTok',    'icon': 'others'},
    'com.google.android.gm':      {'label': 'Gmail',     'icon': 'others'},
    'com.microsoft.teams':        {'label': 'Teams',     'icon': 'others'},
  };

  // ─────────────────────────────────────────────
  static String _iconPath(String iconKey) {
    switch (iconKey) {
      case 'whatsapp':  return AppIcons.whatsappicon;
      case 'facebook':  return AppIcons.facebookicon;
      case 'instagram': return AppIcons.instagramicon;
      case 'youtube':   return AppIcons.youtubeicon;
      default:          return 'assets/icons/others.svg';
    }
  }

  // ─────────────────────────────────────────────
  // PERMISSION — Notification Listener Settings open karo
  //    AndroidManifest mein NotifListenerBridge registered honi chahiye
  // ─────────────────────────────────────────────
  static Future<void> openPermissionSettings() async {
    try {
      _log('PERMISSION', 'Opening notification listener settings...');
      await _channel.invokeMethod('openNotificationListenerSettings');
    } catch (e) {
      _error('PERMISSION', 'openPermissionSettings failed: $e');
    }
  }

  // ─────────────────────────────────────────────
  // 1. TOTAL ACTIVE NOTIFICATIONS COUNT
  //    NotifListenerBridge → getActiveNotificationCount()
  // ─────────────────────────────────────────────
  static Future<int> getActiveNotificationCount() async {
    try {
      _log('COUNT', 'Fetching total active notification count...');
      final int result =
          await _channel.invokeMethod('getActiveNotificationCount');
      _log('COUNT', 'Total = $result');
      return result;
    } catch (e) {
      _error('COUNT', 'getActiveNotificationCount failed: $e');
      return 0;
    }
  }

  // ─────────────────────────────────────────────
  // 2. PER-APP NOTIFICATION COUNT
  //    NotifListenerBridge → getNotificationCountPerApp()
  //    Returns: List<Map> with {package, count}
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getNotificationCountPerApp() async {
    try {
      _log('PER_APP', 'Fetching per-app notification counts...');

      final List<dynamic> result =
          await _channel.invokeMethod('getNotificationCountPerApp');

      final mapped = result
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      _log('PER_APP', 'Apps found = ${mapped.length}');
      return mapped;
    } catch (e) {
      _error('PER_APP', 'getNotificationCountPerApp failed: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // 3. SUSPICIOUS / SPAM APPS
  //    NotifListenerBridge → getSuspiciousNotificationApps()
  //    Returns: List<Map> with {package, count, risk}
  // ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getSuspiciousNotificationApps() async {
    try {
      _log('SPAM', 'Fetching suspicious/spam apps...');

      final List<dynamic> result =
          await _channel.invokeMethod('getSuspiciousNotificationApps');

      final mapped = result
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      _log('SPAM', 'Suspicious apps = ${mapped.length}');
      for (final app in mapped) {
        _log('SPAM',
            '→ ${app['package']} | count=${app['count']} | risk=${app['risk']}');
      }
      return mapped;
    } catch (e) {
      _error('SPAM', 'getSuspiciousNotificationApps failed: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // 4. CANCEL — specific app ki saari notifications hatao
  //    NotifListenerBridge → cancelNotificationsForPackage(packageName)
  // ─────────────────────────────────────────────
  static Future<bool> cancelNotificationsForPackage(String packageName) async {
    try {
      _log('CANCEL', 'Cancelling notifications for: $packageName');

      final bool result = await _channel.invokeMethod(
        'cancelNotificationsForPackage',
        {'packageName': packageName},
      );

      _log('CANCEL', 'Result for $packageName = $result');
      return result;
    } catch (e) {
      _error('CANCEL', 'cancelNotificationsForPackage failed: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // 5. CANCEL ALL — saari notifications ek saath hatao
  //    NotifListenerBridge → cancelAllNotifications()
  // ─────────────────────────────────────────────
  static Future<bool> cancelAllNotifications() async {
    try {
      _log('CANCEL_ALL', 'Cancelling all notifications...');

      final bool result = await _channel.invokeMethod('cancelAllNotifications');

      _log('CANCEL_ALL', 'Result = $result');
      return result;
    } catch (e) {
      _error('CANCEL_ALL', 'cancelAllNotifications failed: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // 6. FULL SUMMARY — ek call mein sab kuch
  //    NotifListenerBridge → getNotificationSummary()
  //    Returns: {totalNotifications, totalApps, spamAppsCount, isListenerActive}
  // ─────────────────────────────────────────────
  static Future<NotificationSummary> getNotificationSummary() async {
    try {
      _log('SUMMARY', 'Fetching full notification summary...');

      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getNotificationSummary');

      final summary = NotificationSummary(
        totalNotifications: result['totalNotifications'] as int? ?? 0,
        totalApps:          result['totalApps']          as int? ?? 0,
        spamAppsCount:      result['spamAppsCount']      as int? ?? 0,
        isListenerActive:   result['isListenerActive']   as bool? ?? false,
      );

      _log('SUMMARY',
          'total=${summary.totalNotifications} | apps=${summary.totalApps} '
          '| spam=${summary.spamAppsCount} | active=${summary.isListenerActive}');

      return summary;
    } catch (e) {
      _error('SUMMARY', 'getNotificationSummary failed: $e');
      return NotificationSummary.empty();
    }
  }

  // ─────────────────────────────────────────────
  // GET CURRENT ITEMS — UI ke liye SocialStatItem list
  //    getNotificationCountPerApp() use karke build karta hai
  // ─────────────────────────────────────────────
  static Future<List<SocialStatItem>> getCurrentItems() async {
    _log('SCAN', 'getCurrentItems called');

    final perAppList = await getNotificationCountPerApp();

    if (perAppList.isEmpty) {
      _warn('SCAN', 'No notifications found → returning zero items');
      return zeroItems();
    }

    final resultMap = <String, Map<String, dynamic>>{};

    for (final entry in perAppList) {
      final pkg   = entry['package'] as String? ?? '';
      final count = entry['count']   as int?    ?? 0;

      if (pkg.isEmpty) continue;
      _log('PROCESS', '$pkg → $count');

      if (_appMap.containsKey(pkg)) {
        final info  = _appMap[pkg]!;
        final label = info['label']!;
        resultMap[label] = {
          'label': label,
          'count': (resultMap[label]?['count'] as int? ?? 0) + count,
          'icon':  info['icon']!,
        };
        _log('MAP', 'Known app → $label ($count)');
      } else {
        resultMap['Others'] = {
          'label': 'Others',
          'count': (resultMap['Others']?['count'] as int? ?? 0) + count,
          'icon':  'others',
        };
        _log('MAP', 'Unknown → Others ($count)');
      }
    }

    final items = resultMap.entries.map((e) {
      return SocialStatItem(
        label:        e.value['label'] as String,
        count:        e.value['count'] as int,
        svgAssetPath: _iconPath(e.value['icon'] as String),
        isChecked:    true,
      );
    }).toList();

    _log('RESULT', 'Final items = ${items.length}');
    return items;
  }

  // ─────────────────────────────────────────────
  // CLEAR COUNTS — label ke according packages cancel karo
  //    cancelNotificationsForPackage() use karta hai
  // ─────────────────────────────────────────────
  static Future<void> clearCounts(List<String> labels) async {
    _log('CLEAR', 'Requested labels = $labels');

    final perAppList = await getNotificationCountPerApp();

    for (final entry in perAppList) {
      final pkg = entry['package'] as String? ?? '';
      if (pkg.isEmpty) continue;

      final targetLabel = _appMap.containsKey(pkg)
          ? _appMap[pkg]!['label']!
          : 'Others';

      if (labels.contains(targetLabel)) {
        _log('CLEAR', 'Cancelling $pkg (label: $targetLabel)');
        await cancelNotificationsForPackage(pkg);
      }
    }

    _log('CLEAR', 'Done clearing for labels: $labels');
  }

  // ─────────────────────────────────────────────
  // ZERO ITEMS FALLBACK
  // ─────────────────────────────────────────────
  static List<SocialStatItem> zeroItems() => [
        SocialStatItem(label: 'WhatsApp',  count: 0, svgAssetPath: AppIcons.whatsappicon),
        SocialStatItem(label: 'Facebook',  count: 0, svgAssetPath: AppIcons.facebookicon),
        SocialStatItem(label: 'Instagram', count: 0, svgAssetPath: AppIcons.instagramicon),
        SocialStatItem(label: 'YouTube',   count: 0, svgAssetPath: AppIcons.youtubeicon),
        SocialStatItem(label: 'Others',    count: 0, svgAssetPath: 'assets/icons/others.svg'),
      ];

  static int totalCount(List<SocialStatItem> items) =>
      items.fold(0, (sum, e) => sum + e.count);
}

// ─────────────────────────────────────────────
// MODEL — getNotificationSummary() ka response
// ─────────────────────────────────────────────
class NotificationSummary {
  final int  totalNotifications;
  final int  totalApps;
  final int  spamAppsCount;
  final bool isListenerActive;

  const NotificationSummary({
    required this.totalNotifications,
    required this.totalApps,
    required this.spamAppsCount,
    required this.isListenerActive,
  });

  factory NotificationSummary.empty() => const NotificationSummary(
        totalNotifications: 0,
        totalApps:          0,
        spamAppsCount:      0,
        isListenerActive:   false,
      );

  @override
  String toString() =>
      'NotificationSummary(total=$totalNotifications, apps=$totalApps, '
      'spam=$spamAppsCount, active=$isListenerActive)';
}