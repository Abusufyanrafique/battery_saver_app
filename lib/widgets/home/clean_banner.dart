import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CleanBanner extends StatelessWidget {
  const CleanBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/CleanBackGroundScreen'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 14),
        decoration: BoxDecoration(
          color: AppColors.cleanBannerBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cleanBannerBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [

            // ─── TEXT SECTION ─────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    AppText.cleanBackgroundApps,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(14),
                      color: AppColors.cleanBannerTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: getHeight(4)),

                  Text(
                    AppText.stopunusedappsrunninginthebackground,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(12),
                      color: AppColors.cleanBannerDescription,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: getWidth(10)),

            // ─── ICON BOX ─────────────────────────
            Container(
              width: getWidth(52),
              height: getHeight(52),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image(
                image: AssetImage(AppImages.checkbox1),
              ),
            ),

            SizedBox(width: getWidth(10)),

            // ─── BUTTON ───────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: getHeight(32),
                width: getWidth(94),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.cleanBannerGradientStart,
                      AppColors.cleanBannerGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [

                      Text(
                        AppText.cleanNow,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(10),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: getWidth(10)),

                      Image(
                        image: AssetImage(AppImages.cleaneNow),
                        height: getHeight(40),
                        width: getWidth(10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}