import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

import 'base_card.dart';

class BatteryTipsCard extends StatelessWidget {
  final String tip;
  final String subTip;

  const BatteryTipsCard({
    super.key,
    required this.tip,
    required this.subTip,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            AppText.improvebatteryHealth,
             style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      color: AppColors.textwhitecolor,
                      fontWeight: FontWeight.w600,
                    ),
          ),

           SizedBox(height: getHeight(14)),

          Row(
            children: [
             Container(
  width: getWidth(40),
  height: getHeight(40),
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Color(0xFF232C6D), // center dark
        Color(0xFF1F8EFF), // edges blue
      ],
      stops: [0.3, 1.0],
    ),
  ),
  child: Center(
    child: Icon(
      Icons.battery_unknown, // ya jo bhi icon chaho
      color: AppColors.unknownbatterycolor,
      size: 22,
    ),
  ),
),

               SizedBox(width: getWidth(12)),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip,
                      style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(14),
                      color: AppColors.textwhitecolor,
                      fontWeight: FontWeight.w600,
                    ),
                    ),

                     SizedBox(height:getHeight(10)),

                    Text(
                      subTip,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(12),
                      color: AppColors.allsmalltextcolor,
                    ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFF55D0FF),
                size: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}