import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/temperature_control/result_temperature_screen_widget.dart';
import 'package:flutter/material.dart';

class ResultTemperatureControlScreen extends StatelessWidget {
  const ResultTemperatureControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),

      appBar: CustomAppBar(
        title: AppText.temperatureControl,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.resulttempimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: getHeight(70)),

              // Title
              Center(
                child: Text(
                  AppText.optimizingdevicetemperature,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: getFont(20),
                    color: const Color(0xFF55D0FF),
                  ),
                ),
              ),

              SizedBox(height: getHeight(4)),

              Center(
                child: Text(
                  AppText.pleasewait,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: getFont(14),
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
              ),

              SizedBox(height: getHeight(44)),

              ScanResultWidget(),

              SizedBox(height: getHeight(38)),

              // Button
              CleanButtonWidget(
                text: AppText.cancletemp,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}