// battery_usage_by_apps_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:flutter_svg/svg.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class AppUsageItem {
  final String appName;
  final String usageTime;
  final int percentage;
  final Color percentageColor;
  final String svgIcon; // 
  final VoidCallback? onTap;

  const AppUsageItem({
    required this.appName,
    required this.usageTime,
    required this.percentage,
    required this.percentageColor,
    required this.svgIcon,
   
    this.onTap,
  });
}
// ─────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────

class BatteryUsageByAppsWidget extends StatelessWidget {
  final List<AppUsageItem>? items;
  final VoidCallback? onViewAll;

  const BatteryUsageByAppsWidget({
    super.key,
    this.items,
    this.onViewAll,
  });

  List<AppUsageItem> get _defaultItems => [
        AppUsageItem(
          appName: 'Instagram',
          usageTime: '1h 28m',
          percentage: 18,
          percentageColor: const Color(0xFFFE39C6), 
          svgIcon: AppIcons.instagramicon,
        ),
        AppUsageItem(
          appName: 'YouTube',
          usageTime: '1h 15m',
          percentage: 14,
          percentageColor: const Color(0xFFFE39C6),
         svgIcon: AppIcons.youtubeicon,
        
        ),
        AppUsageItem(
          appName: 'WhatsApp',
          usageTime: '55m',
          percentage: 11,
          percentageColor: const Color(0xFF9A3CFF),
         svgIcon: AppIcons.whatsappicon,
        
        ),
        AppUsageItem(
          appName: 'Facebook',
          usageTime: '45m',
          percentage: 7,
          percentageColor: const Color(0xFF39DDFE),
          svgIcon: AppIcons.facebookicon,
          
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final appList = items ?? _defaultItems;

    return SizedBox(
      height: getHeight(150),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(14),
          vertical: getHeight(6),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4, 0.75, 1.0],
            colors: [
              Color(0xFF3440A0),
              Color(0xFF232C6D),
              Color(0xFF1B2153),
              Color(0xFF13173A),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4103AC),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── HEADER ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Battery Usage by Apps',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(11),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9A3CFF),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: getHeight(6)),

            // ───────── APP LIST ─────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(appList.length, (index) {
                  return _AppUsageRow(item: appList[index]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// APP USAGE ROW
// ─────────────────────────────────────────────────────────────

class _AppUsageRow extends StatelessWidget {
  final AppUsageItem item;

  const _AppUsageRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Row(
        children: [
          // ── App Icon ──
          Container(
            width: getWidth(20),
            height: getWidth(20),
            decoration: BoxDecoration(
              
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child:SvgPicture.asset(
              item.svgIcon,
  width: getWidth(15),
  height: getWidth(15),
 
),
            ),
          ),

          SizedBox(width: getWidth(8)),

          // ── Name + Progress Bar ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name + Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.appName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(11),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      item.usageTime,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w400,
                        color: AppColors.allsmalltextcolor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: getHeight(3)),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: item.percentage / 100,
                    minHeight: getHeight(4),
                    backgroundColor: Color(0xFF343964),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF9A3CFF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: getWidth(8)),

          // ── Percentage + Arrow ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.percentage}%',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(13),
                  fontWeight: FontWeight.w700,
                  color: item.percentageColor,
                ),
              ),
              SizedBox(width: getWidth(2)),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: getWidth(10),
                color: item.percentageColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}