import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/power_boost/result_power_boost_widget.dart';
import 'package:flutter/material.dart';

class ResultPowerBoostScreen extends StatelessWidget {
  const ResultPowerBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor:AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title:AppText.powerBoost),
        body: SingleChildScrollView(  
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(40),),
              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.resultpowerboost),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      
               SizedBox(height: getHeight(70)),
      
              // Title
            Center(
              child: Text(
                    AppText.boostPerformance,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF55D0FF),
                    ),
                  
              ),
            ),
            SizedBox(height: getHeight(4),),
          Center(
            child: Text(
                  AppText.pleasewaitwhileweoptimizeyourdevice,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD9D9D9),
                  ),
                
            ),
          ),
              SizedBox(height: getHeight(24)), 
             
              ResultPowerBoostWidget(),
      
               SizedBox(height: getHeight(38)),
      
              // Button
              CleanButtonWidget(
                text: AppText.cancle,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}