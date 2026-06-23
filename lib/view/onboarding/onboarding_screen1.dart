import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: getHeight(80),),
         Container(
          height: getHeight(296),
          width: getWidth(284),
          child: Image.asset(AppImages.onboardingimageone)),
         SizedBox(height: getHeight(100),),
          Text(
            AppText.welcometoPhoneOptimizer,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(30),
              fontWeight: FontWeight.w700,
            ),
          ),


          Text(
           AppText.cleanerandmoresecuredevice,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}