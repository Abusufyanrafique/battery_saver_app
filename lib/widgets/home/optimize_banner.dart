import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OptimizeBanner extends StatelessWidget {
  const OptimizeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/OptimizeScreen'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: AppColors.optimizeBannerGradient,
            stops: const [0.0, 0.25, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.optimizeBannerBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [

            // ─── ICON ─────────────────────────
            Container(
              width: getWidth(40),
              height: getHeight(40),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.optimizeCircleGradient,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Image.asset(
                  AppImages.homerocket,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(width: getWidth(14)),

            // ─── TEXT ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    AppText.optimizeNow,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.optimizeTextColor,
                    ),
                  ),

                  SizedBox(height: getHeight(3)),

                  Text(
                    AppText.improvebatteryperformance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w400,
                      color: AppColors.optimizeTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // ─── BUTTON ───────────────────────
            Container(
              height: getHeight(24),
              width: getWidth(84),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.optimizeButtonBorder,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.optimizeButtonShadow.withOpacity(0.25),
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    AppText.optimize,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w500,
                      color: AppColors.optimizeTextColor,
                    ),
                  ),

                  SizedBox(width: getWidth(4)),

                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.optimizeTextColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}