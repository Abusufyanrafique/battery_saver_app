import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// ── Model ─────────────────────────────────────────────────────────────────

class BatteryModeItem {
  final String title;
  final String subtitle;
  final String svgicon;
  final Color iconBgColor;

  const BatteryModeItem({
    required this.title,
    required this.subtitle,
    required this.svgicon,
    required this.iconBgColor,
  });
}

// ── List Widget ───────────────────────────────────────────────────────────

class BatteryModeListWidget extends StatelessWidget {
  final List<BatteryModeItem> items;
  final int selectedIndex;          // ← from BLoC state
  final int? appliedIndex;          // ← from BLoC state  (shows "Active" badge)
  final ValueChanged<int> onSelect; // ← fires BatterySaverModeSelected

  const BatteryModeListWidget({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.appliedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.appWidgetBorderColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BatteryModeTile(
                  item:        items[index],
                  isSelected:  index == selectedIndex,
                  isApplied:   index == appliedIndex,
                  onTap:       () => onSelect(index),
                ),
                if (index != items.length - 1)
                  const Divider(
                    color:     AppColors.dividerColor,
                    height:    1,
                    thickness: 1,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Tile Widget ───────────────────────────────────────────────────────────

class BatteryModeTile extends StatelessWidget {
  final BatteryModeItem item;
  final bool isSelected;
  final bool isApplied;
  final VoidCallback onTap;

  const BatteryModeTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isApplied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isSelected
            ? Colors.white.withOpacity(0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // ── Icon circle ──────────────────────────────────────────────
            Container(
              width:  getWidth(40),
              height: getHeight(40),
              decoration: BoxDecoration(
                color:  item.iconBgColor,
                shape:  BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width:  getWidth(20),
                  height: getHeight(20),
                  child: SvgPicture.asset(
                    item.svgicon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            SizedBox(width: getWidth(16)),

            // ── Title + Active badge ─────────────────────────────────────
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize:   getFont(14),
                      color:      AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isApplied) ...[
                    SizedBox(width: getWidth(6)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:        item.iconBgColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                       AppText.active,
                        style: TextStyle(
                          color:      item.iconBgColor,
                          fontSize:   getFont(10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Subtitle ─────────────────────────────────────────────────
            Text(
              item.subtitle,
              style:AppTextStyles.bodyMedium.copyWith(
                color:    AppColors.allsmalltextcolor,
                fontSize: getFont(14),
              ),
             
            ),

            SizedBox(width: getWidth(8)),

            // ── Chevron ──────────────────────────────────────────────────
            Icon(
              Icons.chevron_right,
              color: isSelected
                  ? item.iconBgColor
                  : AppColors.allsmalltextcolor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}