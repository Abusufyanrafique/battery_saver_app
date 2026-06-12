import 'package:battery_saver_app/bloc/power_boost/power_boost_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/power_boost/result_power_boost_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultPowerBoostScreen extends StatelessWidget {
  final PowerBoostBloc? bloc;
  const ResultPowerBoostScreen({
  super.key, 
  this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,

      appBar: CustomAppBar(
        title: AppText.powerBoost,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 10
            ),
          child: Column(
            children: [
              SizedBox(height: getHeight(20)),

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
                    color: const Color(0xFF55D0FF),
                  ),
                ),
              ),

              SizedBox(height: getHeight(24)),

              // Subtitle
              Center(
                child: Text(
                  AppText.pleasewaitwhileweoptimizeyourdevice,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
              ),

              SizedBox(height: getHeight(24)),

              // Result Widget
              ResultPowerBoostWidget(),

              SizedBox(height: getHeight(38)),

              // Button
              CleanButtonWidget(
                text: AppText.cancle,
                onPressed: () {
                  // back to previous screen
                  context.pop();
                },
              ),

              // SizedBox(height: getHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}