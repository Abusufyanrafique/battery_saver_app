import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/utils/helper/battery_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteryCard extends StatelessWidget {
  const BatteryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatterySaverBloc, BatterySaverState>(
      builder: (context, state) {
        final int battery = state.batteryLevel;
        final BatteryHealthStatus status = healthFromLevel(battery);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(19, 10, 16, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.batteryCardGradient,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      AppText.batteryLevel,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: getHeight(8)),

                    Row(
                      children: [
                        Text(
                          battery == 0 ? '--' : '$battery%',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: getFont(32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: getWidth(6)),
                        Icon(
                          Icons.bolt,
                          color: state.isCharging
                              ? AppColors.chargingIconActive
                              : AppColors.chargingIconInactive,
                          size: 28,
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(10)),

                    Row(
                      children: [
                        Container(
                          width: getWidth(12),
                          height: getHeight(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isCharging
                                ? AppColors.charging
                                : AppColors.notCharging,
                          ),
                        ),
                        SizedBox(width: getWidth(6)),
                        Text(
                          state.isCharging ? AppText.charginghometext : AppText.notCharging,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: getFont(16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(10)),

                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: AppColors.heartIcon,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          batteryHealthLabel(status),
                          style: TextStyle(
                            color: batteryHealthColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: getWidth(110),
                height: getHeight(140),
                child: Image.asset(
                  AppImages.bigbattery,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}