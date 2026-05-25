// premium_banner_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';


class PremiumBannerWidget extends StatelessWidget {
  final VoidCallback? onManageTap;

  const PremiumBannerWidget({
    super.key,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0,right: 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(14),
          vertical: getHeight(10),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF232C6D), // dark left
      Color(0xFF1B2153), // mid blend
      Color(0xFF6913FD), // blue right
    ],
  ),
          border: Border.all(
            color: const Color(0xFF4103AC),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // ───────── GEM ICON ─────────
            Container(
              width: getWidth(40),
              height: getWidth(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF13173A),
                    Color(0xFF9A3CFF),
                  ],
                ),
              ),
              child: Center(
                child:
              Image.asset(
                AppImages.daimond,
                 width: getWidth(20),
                 height: getHeight(20),
                )
              ),
            ),
      
            SizedBox(width: getWidth(14)),
      
            // ───────── TEXT ─────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppText.youPremium,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7D40E6),
                    ),
                  ),
                  SizedBox(height: getHeight(3)),
                  Text(
                    AppText.enjoyallpremiumfeatures,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w400,
                      color: AppColors.allsmalltextcolor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
      
            SizedBox(width: getWidth(10)),
      
            // ───────── MANAGE PLAN BUTTON ─────────
            GestureDetector(
              onTap: onManageTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getWidth(8),
                  vertical: getHeight(6),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Color(0xFFD9D9D9).withOpacity(0.10),
                  border: Border.all(
                    color: const Color(0xFF9A3CFF),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppText.managePlan,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: getWidth(4)),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: getWidth(11),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}