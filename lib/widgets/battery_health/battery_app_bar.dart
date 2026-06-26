import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

class BatteryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BatteryAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0D1B3E),
      elevation: 0,
      centerTitle: true,
      leading: const Icon(
        Icons.chevron_left,
        color: AppColors.white,
        size: 30,
      ),
      title:  Text(
       AppText.batteryHealth,
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: getFont(24),
          fontWeight: FontWeight.w700,
        )
      ),
    );
  }
}