import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class CleanButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const CleanButtonWidget({
    super.key,
    this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: getHeight(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient:  LinearGradient(
            colors: AppColors.buttonGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: getFont(16),
              color:Colors.white ,
            )
          ),
        ),
      ),
    );
  }
}