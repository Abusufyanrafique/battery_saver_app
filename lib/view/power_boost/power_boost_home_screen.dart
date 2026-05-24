import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/power_boost/power_boost_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PowerBoostHomeScreen extends StatelessWidget {
  const PowerBoostHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),

      appBar: CustomAppBar(
        title: AppText.powerBoost,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              SizedBox(height: getHeight(10)),

              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.powerboostimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title 1 (Blue Gradient)
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF55D0FF),
                      Color(0xFF4103AC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    AppText.boostPerformance,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Title 2 (Pink Gradient)
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFE39C6),
                      Color(0xFF9A3CFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    AppText.whenYouNeedIt,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Center(
                child: Text(
                  AppText.clearMemoryOptimizeSystem,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
              ),

              SizedBox(height: getHeight(40)),

              // System Widget
              SystemOptimizeWidget(),

              SizedBox(height: getHeight(24)),

              // Button
              CleanButtonWidget(
                text: AppText.boostNow,
                onPressed: () {
                  context.push('/ResultPowerBoostScreen');
                },
              ),

              SizedBox(height: getHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}