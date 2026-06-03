import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionBarWidget extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onClean;

  const ActionBarWidget({
    super.key,
    this.onShare,
    this.onDelete,
    this.onClean,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(80),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1B4D),
            Color(0xFF0A1240),
            Color(0xFF080E35),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1.2,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // SHARE
          GestureDetector(
            onTap: onShare,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.shareicon,
                  width: getWidth(22),
                  height: getHeight(22),
                ),

                SizedBox(height: getHeight(4)),

                Text(
                 AppText.share,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // CENTER ICON
          GestureDetector(
            onTap: onClean,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.roboticon,
                  color: Colors.white,
                  width: getWidth(24),
                  height: getHeight(24),
                ),

                SizedBox(height: getHeight(4)),

                Text(
                  AppText.clean,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // DELETE
          GestureDetector(
            onTap: onDelete,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.appmanagerdeleteicon,
                  width: getWidth(22),
                  height: getHeight(22),
                ),

                SizedBox(height: getHeight(4)),

                Text(
                  AppText.delete,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}