import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class AppUsageItem extends Equatable {
  final String appName;
  final String usageTime;      // "2h 30m" ya "45m" ya "30s"
  final int percentage;        // poore din ke total se
  final Color percentageColor;
  final String svgIcon;
  final double batteryPercent; // estimated battery %
  final VoidCallback? onTap;

  const AppUsageItem({
    required this.appName,
    required this.usageTime,
    required this.percentage,
    required this.percentageColor,
    required this.svgIcon,
    required this.batteryPercent,
    this.onTap,
  });

  @override
  List<Object?> get props => [appName, usageTime, percentage];
}

// ─────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────

abstract class BatteryUsageHomeEvent extends Equatable {
  const BatteryUsageHomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadBatteryUsageHome extends BatteryUsageHomeEvent {
  const LoadBatteryUsageHome();
}

// ─────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────

abstract class BatteryUsageHomeState extends Equatable {
  const BatteryUsageHomeState();
  @override
  List<Object?> get props => [];
}

class BatteryUsageHomeInitial extends BatteryUsageHomeState {
  const BatteryUsageHomeInitial();
}

class BatteryUsageHomeLoading extends BatteryUsageHomeState {
  const BatteryUsageHomeLoading();
}

class BatteryUsageHomeLoaded extends BatteryUsageHomeState {
  final List<AppUsageItem> items;
  const BatteryUsageHomeLoaded({required this.items});
  @override
  List<Object?> get props => [items];
}

class BatteryUsageHomeError extends BatteryUsageHomeState {
  final String message;
  const BatteryUsageHomeError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

const Map<String, String> _packageIconMap = {
  'com.instagram.android':        AppIcons.instagramicon,
  'com.google.android.youtube':   AppIcons.youtubeicon,
  'com.whatsapp':                 AppIcons.whatsappicon,
  'com.facebook.katana':          AppIcons.facebookicon,
};

const Map<String, String> _packageNameMap = {
  'com.instagram.android':        'Instagram',
  'com.google.android.youtube':   'YouTube',
  'com.whatsapp':                 'WhatsApp',
  'com.facebook.katana':          'Facebook',
};

Color _appColor(String packageName) {
  switch (packageName) {
    case 'com.instagram.android':      return const Color(0xFFFE39C6);
    case 'com.google.android.youtube': return const Color(0xFFFF4444);
    case 'com.whatsapp':               return const Color(0xFF25D366);
    case 'com.facebook.katana':        return const Color(0xFF1877F2);
    default:                           return const Color(0xFF39DDFE);
  }
}

String _formatDuration(Duration duration) {
  final int hours   = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  final int seconds = duration.inSeconds.remainder(60);

  if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
  if (hours > 0)                 return '${hours}h';
  if (minutes > 0)               return '${minutes}m';
  if (seconds > 0)               return '${seconds}s';
  return '0s';
}

// ─────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────

class BatteryUsageHomeBloc
    extends Bloc<BatteryUsageHomeEvent, BatteryUsageHomeState> {

  static const _channel =
      MethodChannel('com.example.battery_saver_app/app_stats');

  BatteryUsageHomeBloc() : super(const BatteryUsageHomeInitial()) {
    on<LoadBatteryUsageHome>(_onLoad);
  }

  Future<void> _onLoad(
    LoadBatteryUsageHome event,
    Emitter<BatteryUsageHomeState> emit,
  ) async {
    emit(const BatteryUsageHomeLoading());

    try {
      // 1. Aaj subah se ab tak
      final DateTime now        = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);

      // 2. Native channel se real data lo — dynamic type use karo
      //    kyunki Android kabhi Map<> return karta hai, kabhi List<>
      final dynamic rawResult = await _channel.invokeMethod(
        'getAppUsageStats',
        {
          'startTime': startOfDay.millisecondsSinceEpoch,
          'endTime':   now.millisecondsSinceEpoch,
        },
      );

      // ─── DEBUG: Native se kya aa raha hai dekho ───
      print('🔍 RAW TYPE: ${rawResult.runtimeType}');
      print('🔍 RAW DATA: $rawResult');
      // ──────────────────────────────────────────────

      // 3. Map ya List — dono cases handle karo
      List<dynamic> rawList = [];

      if (rawResult is List) {
        // Case A: Native ne seedha List return ki
        rawList = rawResult;
      } else if (rawResult is Map) {
        // Case B: Native ne Map return ki jisme 'apps' key hai
        rawList = (rawResult['apps'] as List<dynamic>?) ?? [];
      }

      if (rawList.isEmpty) {
        emit(const BatteryUsageHomeError(
          message: 'No usage data — permission required',
        ));
        return;
      }

      // 4. Safely Map<String, dynamic> mein convert karo
      final List<Map<String, dynamic>> allApps = rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // 🔍 DEBUG: Build APK mein konse package names actually aa rahe hain
      print('📦 All package names: ${allApps.map((a) => a['packageName']).toList()}');

      // 🔍 DEBUG: Har package name ka exact type + match-check + length
      //    (hidden whitespace / wrong type pakadne ke liye)
      for (final app in allApps) {
        final pkg = app['packageName'];
        print(
          '🔎 pkg="$pkg" | type=${pkg?.runtimeType} | '
          'len=${pkg?.toString().length} | '
          'directMatch=${_packageIconMap.containsKey(pkg)}',
        );
      }

      // 5. Sirf hamare tracked apps filter karo
      //    FIX: packageName ko safely String banaya + trim kiya,
      //    taake hidden whitespace ya wrong type se match fail na ho.
      final List<Map<String, dynamic>> trackedApps = allApps.where((app) {
        final String? pkg = app['packageName']?.toString().trim();
        return pkg != null && _packageIconMap.containsKey(pkg);
      }).toList();

      print('🎯 Tracked apps raw data: $trackedApps');

      if (trackedApps.isEmpty) {
        emit(const BatteryUsageHomeError(
          message: 'Tracked apps ka data nahi mila',
        ));
        return;
      }

      // 6. Poore din ka total screen time (sirf tracked apps se)
      final int totalScreenSec = trackedApps.fold<int>(
        0,
        (sum, app) => sum + ((app['screenTimeSec'] as num?)?.toInt() ?? 0),
      );

      // 7. AppUsageItem list banao
      final List<AppUsageItem> items = trackedApps.map((app) {
        // FIX: yahan bhi trim() use kiya taake map lookups
        // (_packageNameMap, _packageIconMap, _appColor) sab match karein.
        final String pkg     = app['packageName'].toString().trim();
        final int    secTime = (app['screenTimeSec'] as num?)?.toInt() ?? 0;
        final double battery = (app['batteryPercent'] as num?)?.toDouble() ?? 0.0;

        final int percentage = totalScreenSec > 0
            ? ((secTime / totalScreenSec) * 100).round()
            : 0;

        return AppUsageItem(
          appName:         _packageNameMap[pkg] ?? pkg,
          usageTime:       _formatDuration(Duration(seconds: secTime)),
          percentage:      percentage,
          percentageColor: _appColor(pkg),
          svgIcon:         _packageIconMap[pkg]!,
          batteryPercent:  battery,
        );
      }).toList();

      // 8. Screen time ke hisab se sort (highest first)
      items.sort((a, b) => b.percentage.compareTo(a.percentage));

      print('✅ Loaded ${items.length} app usage items');
      emit(BatteryUsageHomeLoaded(items: items));

    } on PlatformException catch (e) {
      print('❌ PlatformException: ${e.message}');
      emit(BatteryUsageHomeError(message: e.message ?? 'Platform error'));
    } catch (e) {
      print('❌ Unknown Error: $e');
      emit(BatteryUsageHomeError(message: e.toString()));
    }
  }
}