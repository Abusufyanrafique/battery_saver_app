import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: getHeight(80)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                // ───── LOTTIE ANIMATION ─────
                Lottie.asset(
                  'assets/animations/battery progress.json',
                  width: getWidth(220),
                  height: getHeight(220),
                  fit: BoxFit.contain,
                ),
            
                SizedBox(height: getHeight(10)),
            
                // ───── TEXT UI (same as yours) ─────
                Text(
                AppText.batterysplashtext,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(48),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            
                //  SizedBox(height: getHeight(8)),
            
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
                  AppText.optimizersplashtext,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(48),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            
                SizedBox(height: getHeight(10)),
            
                Text(
                  AppText.saveBatteryLife,
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