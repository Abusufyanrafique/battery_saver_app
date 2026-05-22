import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4A017), // golden border
            width: 1.5,
          ),
        ),
        child:  Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image(image: AssetImage(AppImages.premium)),
//             SvgPicture.asset(
//             AppIcons.premiumicon,
//             width: 16,
//             height: 14,
//             colorFilter: const ColorFilter.mode(
//           Colors.white,
//             BlendMode.srcIn,
//   ),
// ),
            SizedBox(width: 5),
            Text(
              'Premium',
              style: TextStyle(
                color:AppColors.premiumbannercolor, // golden text
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


