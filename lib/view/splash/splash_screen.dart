import 'dart:ui';

import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C20),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: getHeight(100), // 
          ),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BATTERY",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(48),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9A3CFF),
                        Color(0xFF5C0EE3),
                      ],
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    );
                  },
                  child: Text(
                    "OPTIMIZER",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(48),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(20)),

                Text(
                  "Optimize-Clean-Boost\nSave Battery Life",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(20),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}