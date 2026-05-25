import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
class ToolsAppBar extends StatelessWidget implements PreferredSizeWidget {

  final VoidCallback? onBackPressed;
  final bool isPremium;
  final VoidCallback? onPremiumPressed;
  final String title;

  const ToolsAppBar({
    super.key,
    this.onBackPressed,
    this.isPremium = true,
    this.onPremiumPressed,
    this.title = 'Tools',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F1628), // dark navy
      elevation: 0,
      centerTitle: true,

      // ── Back Button ──────────────────────────────────────────
      leading: IconButton(
        icon: Image(image: AssetImage(AppImages.chevron)),
        onPressed: onBackPressed ?? () => Navigator.maybePop(context),
        tooltip: 'Back',
      ),

      // ── Centered Title ────────────────────────────────────────
      title: Text(
        "Tools",
        style: AppTextStyles.displayLarge.copyWith(
          fontSize: getFont(24)
        ),
      ),

      // ── Premium Badge ─────────────────────────────────────────
      actions: [
        if (isPremium)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _PremiumBadge(onTap: onPremiumPressed),
          ),
      ],
    );
  }
}

/// The golden " Premium" pill badge shown on the right side.
class _PremiumBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const _PremiumBadge({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: Color(0xFF0E112F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEDC009), // golden border
            width: 1.5,
          ),
        ),
        child:  Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(image: AssetImage(AppImages.premium)),
            SvgPicture.asset(
            AppIcons.premiumicon,
            width: getWidth(8),
            height: getHeight(10),
            colorFilter: const ColorFilter.mode(
          Colors.white,
            BlendMode.srcIn,
  ),
),
            
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Text(
                'Premium',
                style:AppTextStyles.bodySmall.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE7CC5A)
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}


