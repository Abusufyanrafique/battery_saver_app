import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usage_stats/usage_stats.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class AppUsageItem extends Equatable {
  final String appName;
  final String usageTime;
  final int percentage;
  final Color percentageColor;
  final String svgIcon;
  final VoidCallback? onTap;

  const AppUsageItem({
    required this.appName,
    required this.usageTime,
    required this.percentage,
    required this.percentageColor,
    required this.svgIcon,
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
  'com.instagram.android': AppIcons.instagramicon,
  'com.google.android.youtube': AppIcons.youtubeicon,
  'com.whatsapp': AppIcons.whatsappicon,
  'com.facebook.katana': AppIcons.facebookicon,
};

const Map<String, String> _packageNameMap = {
  'com.instagram.android': 'Instagram',
  'com.google.android.youtube': 'YouTube',
  'com.whatsapp': 'WhatsApp',
  'com.facebook.katana': 'Facebook',
};

Color _colorForPercentage(int percent) {
  if (percent >= 15) return const Color(0xFFFE39C6);
  if (percent >= 10) return const Color(0xFF9A3CFF);
  return const Color(0xFF39DDFE);
}

String _formatDuration(Duration duration) {
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

// ─────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────

class BatteryUsageHomeBloc
    extends Bloc<BatteryUsageHomeEvent, BatteryUsageHomeState> {
  BatteryUsageHomeBloc() : super(const BatteryUsageHomeInitial()) {
    on<LoadBatteryUsageHome>(_onLoad);
  }

  Future<void> _onLoad(
    LoadBatteryUsageHome event,
    Emitter<BatteryUsageHomeState> emit,
  ) async {
    emit(const BatteryUsageHomeLoading());

    try {
      // 1. Permission check
      final bool granted = await UsageStats.checkUsagePermission() ?? false;
      if (!granted) {
        await UsageStats.grantUsagePermission();
      }

      // 2. Aaj ke stats
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);

      final List<UsageInfo> usageInfoList = await UsageStats.queryUsageStats(
        startOfDay,
        now,
      );

      // 3. Sirf hamare apps filter karo
      final Map<String, int> packageUsageMs = {};
      for (final UsageInfo info in usageInfoList) {
        final String pkg = info.packageName ?? '';
        if (_packageIconMap.containsKey(pkg)) {
          final int ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
          packageUsageMs[pkg] = ms;
        }
      }

      // 4. Total aur percentage
      final int totalMs = packageUsageMs.values.fold(0, (a, b) => a + b);

      final sortedEntries = packageUsageMs.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final List<AppUsageItem> items = sortedEntries.map((entry) {
        final int ms = entry.value;
        final int percentage =
            totalMs > 0 ? ((ms / totalMs) * 100).round() : 0;

        return AppUsageItem(
          appName: _packageNameMap[entry.key] ?? entry.key,
          usageTime: _formatDuration(Duration(milliseconds: ms)),
          percentage: percentage,
          percentageColor: _colorForPercentage(percentage),
          svgIcon: _packageIconMap[entry.key]!,
        );
      }).toList();

      emit(BatteryUsageHomeLoaded(items: items));
    } catch (e) {
      emit(BatteryUsageHomeError(message: e.toString()));
    }
  }
}