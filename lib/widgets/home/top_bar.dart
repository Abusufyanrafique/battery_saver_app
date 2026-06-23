import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [

          // ─── MENU BUTTON ─────────────────────
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: getWidth(36),
              height: getHeight(36),
              decoration: BoxDecoration(
                color: AppColors.topBarIconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image(
                image: AssetImage(AppImages.meun),
              ),
            ),
          ),

          // ─── TITLE ───────────────────────────
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [

                    TextSpan(
                      text: AppText.battery,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: getFont(24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.topBarGradientText,
                        ).createShader(
                          Rect.fromLTWH(
                            0,
                            0,
                            bounds.width,
                            bounds.height,
                          ),
                        ),
                        child: Text(
                          AppText.optimizer,
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: getFont(24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── SETTINGS BUTTON ────────────────
          Container(
            width: getWidth(36),
            height: getHeight(36),
            decoration: BoxDecoration(
              color: AppColors.topBarIconRightBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.topBarIconBorder,
              ),
            ),
            child: Image(
              image: AssetImage(AppImages.setting),
            ),
          ),
        ],
      ),
    );
  }
}