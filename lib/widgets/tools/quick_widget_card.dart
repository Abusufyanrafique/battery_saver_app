import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:battery_saver_app/models/tools/quick_widget_item.dart';

class QuickWidgetCard extends StatelessWidget {
  final QuickWidgetItem item;
  final VoidCallback? onTap;

  const QuickWidgetCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getHeight(110),
        width: getWidth(80),
        decoration: BoxDecoration(
          color: const Color(0xFF151A30),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: item.borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ── Icon + optional percentage badge ──
            _IconWithBadge(item: item),

            const SizedBox(height: 8),

            Text(
              item.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textwhitecolor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ICON + PERCENTAGE BADGE (Stack)
// ─────────────────────────────────────────────────────────────
class _IconWithBadge extends StatelessWidget {
  final QuickWidgetItem item;

  const _IconWithBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // ── SVG Icon ──
        SvgPicture.asset(
          item.svgIcon,
          width: getWidth(46),
          height: getHeight(46),
        ),

        // ── Percentage badge — sirf tab show ho jab value ho ──
        if (item.percentage != null)
          Positioned(
            top: getHeight(15),
            right: getWidth(10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(4),
                vertical: getHeight(2),
              ),
              
              child: Text(
                '${item.percentage}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(9),
                  fontWeight: FontWeight.w700,
                  color: item.borderColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}