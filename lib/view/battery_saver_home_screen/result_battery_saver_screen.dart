import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver_home_screen/result_battery_saver_widgets.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';

class ResultBatterySaverScreen extends StatelessWidget {
  const ResultBatterySaverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor:AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title:AppText.batterySaver),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(20),),
              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.resultbatterysaver),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
                
              const SizedBox(height: 16),
                
              // Title
              Center(
                child: Text(
                      AppText.batterySaverIsActive,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(20),
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF55D0FF),
                      ),
                    ),
              ),
            
           SizedBox(height: getHeight(12),),
            Center(
              child: Text(AppText.yourDeviceIsNowInSmartSaverModeToExtendBatteryLife,
               textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
               fontSize: getFont(14),
               color: Color(0xFFD9D9D9),
              ),
              ),
            ),
                
              SizedBox(height: getHeight(24)), 
             
              BatteryLifeWidget(),
                
               SizedBox(height: getHeight(16)),
                
              // Button
              CleanButtonWidget(
                text: AppText.done,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}