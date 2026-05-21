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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title:AppText.powerBoost),
        body: SingleChildScrollView(  
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      
              // Title
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
        fontWeight: FontWeight.w600
        // color: Colors.white,
      ),
    ),
  ),
),
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
        fontWeight: FontWeight.w600
        // color: Colors.white,
      ),
    ),
  ),
),


            Center(
              child: Text(AppText.clearMemoryOptimizeSystem,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
              fontSize: getFont(14),
              color: Color(0xFFD9D9D9)
              ),
              ),
            ),
      
              SizedBox(height: getHeight(80)), 
             
              SystemOptimizeWidget(),
      
             SizedBox(height: getHeight(24),),
      
              // Button
              CleanButtonWidget(
                text: AppText.boostNow,
                onPressed: () {
                  context.push('/ResultPowerBoostScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}