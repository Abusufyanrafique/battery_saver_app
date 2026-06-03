// sign_out_button_widget.dart

import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

class SignOutButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const SignOutButtonWidget({
    super.key,
    this.onTap, required bool isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 0.0,right: 0),
        child: Container(
          height: getHeight(40),
          width: double.infinity,
          // padding: EdgeInsets.symmetric(vertical: getHeight(10)),
          decoration: BoxDecoration(
             gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4103AC),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFAD2020),
                size: getWidth(20),
              ),
              SizedBox(width: getWidth(8)),
              Text(
                'Sign Out',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFAD2020),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}