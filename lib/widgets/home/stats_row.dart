import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/bloc/battery_status_cubit_usage/battery_status_cubit.dart';
import 'package:battery_saver_app/bloc/cpu_cooler/cpu_cooler_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/utils/helper/battery_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  BatteryHealthStatus _parseAndroidHealth(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'good':
        return BatteryHealthStatus.good;
      case 'overheat':
      case 'over voltage':
      case 'cold':
        return BatteryHealthStatus.moderate;
      case 'dead':
      case 'unspecified failure':
        return BatteryHealthStatus.critical;
      default:
        return BatteryHealthStatus.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpuCoolerBloc, CpuCoolerState>(
      builder: (context, cpuState) {
        return BlocBuilder<BatterySaverBloc, BatterySaverState>(
          builder: (context, batteryState) {
            return BlocBuilder<BatteryStatusCubit, BatteryStatusState>(
              builder: (context, statusState) {
                final String rawHealth = statusState is BatteryStatusLoaded
                    ? statusState.data.healthStatus
                    : 'Unknown';

                final BatteryHealthStatus healthEnum =
                    _parseAndroidHealth(rawHealth);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181C3B),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFF414669), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatItem(
                        iconPath: AppImages.remaining,
                        iconColor: const Color(0xFFFF6B9D),
                        value: batteryState.remainingTime.isEmpty
                            ? AppText.calculating
                            : batteryState.remainingTime,
                        label: AppText.remaining,
                      ),
                      const StatDivider(),
                      StatItem(
                        iconPath: AppImages.temp,
                        iconColor: const Color(0xFFFF9800),
                        value: cpuState.temperature == 0
                            ? 'N/A'
                            : '${cpuState.temperature.toStringAsFixed(1)}°C',
                        label: AppText.hometemperaturetext,
                      ),
                      const StatDivider(),
                      StatItem(
                        iconPath: AppImages.goodhe,
                        iconColor: batteryHealthColor(healthEnum),
                        value: rawHealth == 'Unknown' ? '...' : rawHealth,
                        label: AppText.health,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// STAT ITEM
// ─────────────────────────────────────────────
class StatItem extends StatelessWidget {
  final String iconPath;
  final Color iconColor;
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.iconPath,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(iconPath, width: getWidth(32), height: getHeight(32)),
        SizedBox(width: getWidth(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: getHeight(2)),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STAT DIVIDER
// ─────────────────────────────────────────────
class StatDivider extends StatelessWidget {
  const StatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(1),
      height: getHeight(40),
      color: const Color(0xFF414669),
    );
  }
}