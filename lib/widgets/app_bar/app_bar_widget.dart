import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:AppColors.allscreenBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.allscreenBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Image(
              image: AssetImage(AppImages.chevron),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: getFont(24),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
           SizedBox(width: getWidth(48)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}