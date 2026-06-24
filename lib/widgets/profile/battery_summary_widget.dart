// battery_summary_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class BatterySummaryItem {
  final String svgicon;
  final Color iconColor;
  final String value;
  final String label;

  const BatterySummaryItem({
   
    required this.iconColor,
    required this.value,
    required this.label, 
    required this.svgicon,
  });
}

// ─────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────

class BatterySummaryWidget extends StatelessWidget {
  final String batteryLife;
  final int chargingCycles;
  final int efficiency;
  final int batteryDrain;

  const BatterySummaryWidget({
    super.key,
    this.batteryLife = '12h 45m',
    this.chargingCycles = 3,
    this.efficiency = 85,
    this.batteryDrain = -18,
  });

  @override
  Widget build(BuildContext context) {
    final List<BatterySummaryItem> items = [
      BatterySummaryItem(
       svgicon: AppIcons.profilebatteryicon,
        iconColor: AppColors.summarybatterycolor,
        value: batteryLife,
        label: AppText.abatteryLife,
      ),
      BatterySummaryItem(
        svgicon:AppIcons.profilechargeicon ,
        iconColor: AppColors.summarychagercolor,
        value: '$chargingCycles',
        label: AppText.chargingCyclesprofiletext,
      ),
      BatterySummaryItem(
       svgicon:AppIcons.profileffici ,
        iconColor: AppColors.summaryleavecolor,
        value: '$efficiency%',
        label:AppText.efficiency,
      ),
      BatterySummaryItem(
        svgicon: AppIcons.profiledrainicon,
        iconColor: AppColors.summarydraincolor,
        value: '${batteryDrain > 0 ? '+' : ''}$batteryDrain%',
        label: AppText.batteryDrain,
      ),
    ];

    return SizedBox(
      height: getHeight(120),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(12),
          vertical: getHeight(8),
        ),
        decoration: BoxDecoration(
           gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.drawerGradient
        ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.appWidgetBorderColor,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── HEADING ─────────
            Text(
             AppText.yourBatterySummary,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),

            const Spacer(),

            // ───────── ITEMS ROW ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isLast = index == items.length - 1;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SummaryItem(item: item),
                    if (!isLast)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: getWidth(8)),
                        width: 2,
                        height: getHeight(50),
                        color: AppColors.appWidgetBorderColor,
                      ),
                  ],
                );
              }),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUMMARY ITEM
// ─────────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final BatterySummaryItem item;

  const _SummaryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Icon Circle ──
        Container(
          width: getWidth(36),
          height: getWidth(36),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: item.iconColor,
              width: 1.8,
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              item.svgicon,
            )
          ),
        ),

        SizedBox(height: getHeight(4)),

        // ── Value ──
        Text(
          item.value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: getFont(16),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),

        SizedBox(height: getHeight(1)),

        // ── Label ──
        Text(
          item.label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(9),
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}