import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';

import 'base_card.dart';
import 'info_row.dart';

class BatteryCapacityCard extends StatelessWidget {
  final String designCapacity;
  final String currentCapacity;

  const BatteryCapacityCard({
    super.key,
    required this.designCapacity,
    required this.currentCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      height: getHeight(100),
      // width: getWidth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Text(
                'Battery Capacity',
                style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      color: AppColors.textwhitecolor,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(width: 8),

             Image(image: AssetImage(AppImages.lowbattery))
            ],
          ),

           SizedBox(height: getHeight(12)),

          InfoRow(
            label: 'Design Capacity',
            value: designCapacity,
          ),

          
           SizedBox(height: getHeight(12)),

          InfoRow(
            label: 'Current Capacity',
            value: currentCapacity,
          ),
        ],
      ),
    );
  }
}