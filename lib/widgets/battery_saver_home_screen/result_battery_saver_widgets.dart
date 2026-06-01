import 'package:battery_saver_app/bloc/battery_saver_bloc_home/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BatteryLifeWidget extends StatelessWidget {
  /// BLoC se aaya real data
  final BatteryLifeInfo? batteryLifeInfo;
  final int? batteryLevel;
  final bool isCharging;

  const BatteryLifeWidget({
    super.key,
    required this.batteryLifeInfo,
    required this.batteryLevel,
    required this.isCharging,
  });

  @override
  Widget build(BuildContext context) {
    // Agar data abhi available nahi to loading show karo
    if (batteryLifeInfo == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFE39C6)),
      );
    }

    final info = batteryLifeInfo!;

    return Container(
      padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4103AC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row — title + real battery level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expected Battery Life',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(15),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              // Real battery level badge
              if (batteryLevel != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x22FFFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCharging
                            ? Icons.battery_charging_full_rounded
                            : Icons.battery_std_rounded,
                        size: 14,
                        color: info.lifeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$batteryLevel%',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(11),
                          color: info.lifeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: getHeight(14)),

          // Estimated time — real calculated value
          Center(
            child: Text(
              info.estimatedTime,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(26),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: getHeight(6)),

          // Life label — "Extended" / "Normal" / "Low" / "Charging"
          Center(
            child: Text(
              info.lifeLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w600,
                color: info.lifeColor, // dynamic color
              ),
            ),
          ),

          SizedBox(height: getHeight(14)),

          const Divider(
            color: Color(0xFF838283),
            thickness: 0.5,
            height: 1,
          ),

          const SizedBox(height: 6),

          // Rows — real statuses from BLoC
          _BatteryRow(
            svgPath: AppIcons.brightness,
            label: 'Brightness',
            value: info.brightnessStatus,
            valueColor: _statusColor(info.brightnessStatus),
          ),
          _BatteryRow(
            svgPath: AppIcons.backgroundApps,
            label: 'Background Apps',
            value: info.backgroundAppsStatus,
            valueColor: _statusColor(info.backgroundAppsStatus),
          ),
          _BatteryRow(
            svgPath: AppIcons.autoSync,
            label: 'Auto Sync',
            value: info.autoSyncStatus,
            valueColor: _statusColor(info.autoSyncStatus),
          ),
          _BatteryRow(
            svgPath: AppIcons.notificationsicon,
            label: 'Notifications',
            value: info.notificationsStatus,
            valueColor: _statusColor(info.notificationsStatus),
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Status text ke basis par color decide karo
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disabled':
        return const Color(0xFFFF6B6B); // red — completely off
      case 'minimum':
        return const Color(0xFFFFD700); // yellow — very limited
      case 'limited':
      case 'reduced':
        return const Color(0xFFFFA500); // orange — partially limited
      case 'optimized':
        return const Color(0xFF00FF09); // green — smart optimization
      default:
        return const Color(0xFF00FF09);
    }
  }
}

// ─── ROW ─────────────────────────────────────────────────────────────────────

class _BatteryRow extends StatelessWidget {
  final String svgPath;
  final String label;
  final String value;
  final Color valueColor;
  final bool isLast;

  const _BatteryRow({
    required this.svgPath,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: getWidth(30),
                height: getHeight(30),
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgPath,
                    width: getWidth(20),
                    height: getHeight(20),
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF989CDF),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              SizedBox(width: getWidth(10)),

              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: getFont(11),
                  color: valueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (!isLast)
          const Divider(
            color: Color(0xFF838283),
            thickness: 0.5,
            height: 1,
          ),
      ],
    );
  }
}