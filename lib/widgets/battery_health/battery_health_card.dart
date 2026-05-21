import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

import 'base_card.dart';
import 'battery_progress_bar.dart';
import 'status_badge.dart';

class BatteryHealthCard extends StatelessWidget {
  final int percentage;
  final String status;
  final String description;

  const BatteryHealthCard({
    super.key,
    required this.percentage,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Battery Health',
                style: AppTextStyles.bodySmall.copyWith(
              fontSize:getFont(20),
              fontWeight: FontWeight.w600,
              color: Colors.white
            )
              ),
              StatusBadge(status: status),
            ],
          ),

          Text(
            '$percentage%',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize:getFont(36),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            )
          ),

               SizedBox(height: getHeight(10)),

          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize:getFont(14),
              fontWeight: FontWeight.w600,
              color: Color(0xFFD9D9D9)
            )
          ),

           SizedBox(height: getHeight(20)),

          BatteryProgressBar(percentage: percentage),
        ],
      ),
    );
  }
}