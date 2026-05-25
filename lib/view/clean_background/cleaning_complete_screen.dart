import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/clean_result_grid_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/performance_boost_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/result_action_buttons_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/storage_comparison_widget.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CleaningCompleteScreen extends StatelessWidget {
  const CleaningCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title:AppText.cleaningComplete),
        body: SingleChildScrollView(  
          padding: const EdgeInsets.only(left: 16.0,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: getHeight(140),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.cleaningcomplete),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      
               SizedBox(height: getHeight(18)),
      
              // Title
              Center(
                child: Text(
                 AppText.greatYouDeviceisNowClean,
                 textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: getFont(20),
                    color: Color(0xFF2FE55D),
                  ),
                ),
              ),
      
              SizedBox(height: getHeight(4)), 
      
              Center(
                child: Text(
                 AppText.wehavesuccessfullycleanedunnecessarfiles,
                 textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: getFont(14),
                    color: Color(0xFFD9D9D9),
                  ),
                ),
              ),
                     SizedBox(height: getHeight(20),),
              Text("Clean Summary",
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(16),
                fontWeight: FontWeight.w600,
                color: AppColors.textwhitecolor
              ),
              ),
              SizedBox(height: getHeight(4),),
              CleanResultGridWidget.defaultValues(),
             SizedBox(height: getHeight(20),),
            
              PerformanceBoostWidget(),
               SizedBox(height: getHeight(20)),
                StorageComparisonWidget(
                beforeGB: 28.0,
                  afterGB: 27.5,
                 totalGB: 64.0,
            ),
            SizedBox(height: getHeight(20)),
           ResultActionButtonsWidget(
  onViewDetails: () {
    // View Details action
  },
  onDone: () {
    context.go('/home');
  },
  onCleanAgain: () {
    // Clean Again action
  },
),
              
            ],
          ),
        ),
      ),
    );
  }
}