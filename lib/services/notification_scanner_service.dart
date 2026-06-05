import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';

class NotificationScannerService {
  static final Map<String, int> _liveCounts = {};
  static bool _isListening = false;
  static const _channel = MethodChannel('notification_scanner');

  // ─────────────────────────────────────────────
  static void _log(String tag, String msg) =>
      debugPrint('🟢 [NOTIF][$tag] $msg');
  static void _error(String msg) =>
      debugPrint('🔴 [NOTIF][ERROR] $msg');
  static void _warn(String msg) =>
      debugPrint('🟡 [NOTIF][WARN] $msg');

  // ─────────────────────────────────────────────
  static const Map<String, Map<String, String>> _appMap = {
    'com.whatsapp':              {'label': 'WhatsApp',  'icon': 'whatsapp'},
    'com.facebook.katana':       {'label': 'Facebook',  'icon': 'facebook'},
    'com.facebook.orca':         {'label': 'Facebook',  'icon': 'facebook'},
    'com.instagram.android':     {'label': 'Instagram', 'icon': 'instagram'},
    'com.google.android.youtube':{'label': 'YouTube',   'icon': 'youtube'},
    'com.snapchat.android':      {'label': 'Snapchat',  'icon': 'others'},
    'com.twitter.android':       {'label': 'Twitter',   'icon': 'others'},
    'com.tiktok.android':        {'label': 'Others',    'icon': 'others'},
    'com.google.android.gm':     {'label': 'Others',    'icon': 'others'},
    'com.microsoft.teams':       {'label': 'Others',    'icon': 'others'},
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
  static Future<bool> hasPermission() async {
    final status = await NotificationsListener.hasPermission;
    _log('PERMISSION', 'Status = $status');
    return status ?? false;
  }

  static Future<void> requestPermission() async {
    _log('PERMISSION', 'Opening system settings...');
    await NotificationsListener.openPermissionSettings();
  }

  // ─────────────────────────────────────────────
  // EXISTING NOTIFICATIONS — MethodChannel se fetch karo
  // ─────────────────────────────────────────────
  static Future<void> fetchExistingNotifications() async {
    try {
      _log('FETCH', 'Fetching existing notifications via MethodChannel...');

      final List<dynamic>? result =
          await _channel.invokeListMethod('getActiveNotifications');

      if (result == null || result.isEmpty) {
        _warn('No existing notifications found');
        return;
      }

      _log('FETCH', 'Found ${result.length} existing notifications');

      // Pehle clear karo
      _liveCounts.clear();

      for (final item in result) {
        final pkg = (item as Map)['packageName'] as String?;
        if (pkg == null || pkg.isEmpty) continue;
        _liveCounts[pkg] = (_liveCounts[pkg] ?? 0) + 1;
        _log('FETCH_COUNT', '$pkg → ${_liveCounts[pkg]}');
      }

      _log('FETCH', 'Final map = $_liveCounts');
    } catch (e) {
      _error('fetchExistingNotifications failed: $e');
    }
  }

  // ─────────────────────────────────────────────
  // START LISTENING
  // ─────────────────────────────────────────────
  static Future<void> startListening() async {
    if (_isListening) {
      _warn('Listener already running');
      return;
    }

    _log('INIT', 'Starting notification listener...');

    await NotificationsListener.initialize();

    // ── PEHLE EXISTING NOTIFICATIONS FETCH KARO ──
    await fetchExistingNotifications();

    // ── PHIR LIVE EVENTS SUNO ──
    NotificationsListener.receivePort?.listen((dynamic event) {
      try {
        _log('EVENT_RAW', '$event');

        String? pkg;
        int? flag;

        if (event is NotificationEvent) {
          pkg  = event.packageName;
          flag = event.flags;
          _log('PARSE', 'NotificationEvent → pkg=$pkg flag=$flag');
        } else if (event is Map) {
          pkg  = event['packageName'] as String?;
          flag = event['flag'] as int?;
          _log('PARSE', 'Map Event → pkg=$pkg flag=$flag');
        }

        if (pkg == null || pkg.isEmpty) {
          _warn('Empty package received');
          return;
        }

        final isRemoved = flag == 8;
        _log('STATE', 'Package=$pkg | removed=$isRemoved');

        if (isRemoved) {
          if (_liveCounts.containsKey(pkg)) {
            _liveCounts[pkg] = _liveCounts[pkg]! - 1;
            _log('COUNT', 'Decreased $pkg → ${_liveCounts[pkg]}');
            if (_liveCounts[pkg]! <= 0) {
              _liveCounts.remove(pkg);
              _log('COUNT', 'Removed $pkg (zero count)');
            }
          } else {
            _warn('Remove event but pkg not found: $pkg');
          }
        } else {
          _liveCounts[pkg] = (_liveCounts[pkg] ?? 0) + 1;
          _log('COUNT', 'Increased $pkg → ${_liveCounts[pkg]}');
        }

        _log('MAP_STATE', _liveCounts.toString());
      } catch (e, st) {
        _error('Listener crash: $e');
        debugPrint('$st');
      }
    });

    _isListening = true;
    _log('INIT', 'Listener started successfully');
  }

  // ─────────────────────────────────────────────
  // GET CURRENT ITEMS
  // ─────────────────────────────────────────────
  static List<SocialStatItem> getCurrentItems() {
    _log('SCAN', 'getCurrentItems called');

    if (_liveCounts.isEmpty) {
      _warn('Live map empty → returning zero items');
      return zeroItems();
    }

    final resultMap = <String, Map<String, dynamic>>{};
    _log('SCAN', 'Processing ${_liveCounts.length} packages');

    for (final entry in _liveCounts.entries) {
      final pkg   = entry.key;
      final count = entry.value;
      _log('PROCESS', '$pkg → $count');

      if (_appMap.containsKey(pkg)) {
        final info  = _appMap[pkg]!;
        final label = info['label']!;
        resultMap[label] = {
          'label': label,
          'count': (resultMap[label]?['count'] ?? 0) + count,
          'icon':  info['icon']!,
        };
        _log('MAP', 'Mapped known app → $label');
      } else {
        resultMap['Others'] = {
          'label': 'Others',
          'count': (resultMap['Others']?['count'] ?? 0) + count,
          'icon':  'others',
        };
        _log('MAP', 'Mapped unknown → Others');
      }
    }

    final items = resultMap.entries.map((e) {
      return SocialStatItem(
        label:        e.value['label'],
        count:        e.value['count'],
        svgAssetPath: _iconPath(e.value['icon']),
        isChecked:    true,
      );
    }).toList();

    _log('RESULT', 'Final items = ${items.length}');
    return items;
  }

  // ─────────────────────────────────────────────
  // CLEAR COUNTS
  // ─────────────────────────────────────────────
  static void clearCounts(List<String> labels) {
    _log('CLEAR', 'Requested labels = $labels');

    final toRemove = <String>[];

    for (final entry in _liveCounts.entries) {
      final pkg = entry.key;
      if (_appMap.containsKey(pkg)) {
        final label = _appMap[pkg]!['label']!;
        if (labels.contains(label)) toRemove.add(pkg);
      } else if (labels.contains('Others')) {
        toRemove.add(pkg);
      }
    }

    for (final pkg in toRemove) {
      _liveCounts.remove(pkg);
      _log('CLEAR', 'Removed $pkg');
    }

    _log('CLEAR', 'Remaining map = $_liveCounts');
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