import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Welcome to\n Phone Optimizer",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(30),
              fontWeight: FontWeight.w700,
            ),
          ),


          Text(
            "Your all-in -one solution for a faster,\ncleaner and more secure device.",
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