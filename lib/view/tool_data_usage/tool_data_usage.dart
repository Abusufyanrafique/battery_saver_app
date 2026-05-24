import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/app_usage_list_card.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_usage_by_apps_widget.dart' hide AppUsageItem;
import 'package:battery_saver_app/widgets/data_usage/custom_toggle_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/storage_bar_chart.dart';
import 'package:battery_saver_app/widgets/data_usage/usage_Info_card.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';

import 'package:battery_saver_app/utils/SizeConfig.dart';

class ToolDataUsageScreen extends StatelessWidget {
  const ToolDataUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<AppUsageItem> items = [
      AppUsageItem(
        name: "WhatsApp",
        svgAssetPath: AppIcons.whatsappicon,
        usageMB: 1200,
        maxMB: 5000,
        barColor: const Color(0xFF26D626),
      ),
       AppUsageItem(
        name: "Facebook",
        svgAssetPath: AppIcons.facebookicon,
        usageMB: 3000,
        maxMB: 5000,
        barColor: const Color(0xFF0392EB),
      ),
      AppUsageItem(
        name: "Instagram",
        svgAssetPath: AppIcons.instagramicon,
        usageMB: 3000,
        maxMB: 5000,
        barColor: const Color(0xFFEA3918),
      ),
      AppUsageItem(
        name: "Youtube",
        svgAssetPath: AppIcons.youtubeicon,
        usageMB: 1800,
        maxMB: 5000,
        barColor: const Color(0xFFEA0202),
      ),
    ];
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar:CustomAppBar(title: AppText.dataUsage),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOTAL USAGE CARD
            SizedBox(
            width: 340,
            child: CustomToggleWidget(),
            ),
            SizedBox(height: getHeight(24),),
            Center(
              child: Text.rich(
                TextSpan(
                  text: "2.45 ",
                  style:AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(32),
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: "GB",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(24),
                        color: AppColors.textwhitecolor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(child: Text("Used",
              style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(16),
                        color: AppColors.allsmalltextcolor,
                        fontWeight: FontWeight.w600,
                      ),
            )),
            const StorageBarChart(),
               SizedBox(height: getHeight(20)),
              AppUsageListCard(items: items),
                SizedBox(height: getHeight(20)),
               UsageInfoCard(
            label: 'Wi-Fi Usage',
            value: '1.35 GB',
             ),
          ],
        ),
      ),
    );
  }
}