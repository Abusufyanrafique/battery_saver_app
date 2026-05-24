import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/apps_runningIn_background_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/clean_result_grid_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/scanning_progress_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CleanBackGroundScreen extends StatelessWidget {
  const CleanBackGroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar:AppBar(
            leading: IconButton(
    onPressed: () => Navigator.maybePop(context),
    icon: const Image(
      image: AssetImage(AppImages.chevron),
    ),
  ),

          title: Text(
            AppText.cleanBackgroundApp,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(24),
              fontWeight: FontWeight.w700,
            ),
            
            ),
        ),
        body: SingleChildScrollView(  
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: getHeight(150),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.resulttempimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      
               SizedBox(height: getHeight(14)),
      
              // Title
              Center(
                child: Text(
                 AppText.scanning,
                 textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: getFont(20),
                    color: Color(0xFF55D0FF),
                  ),
                ),
              ),
      
              SizedBox(height: getHeight(4)), 
      
              Center(
                child: Text(
                 AppText.detectingandcleaningunnecessary,
                 textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: getFont(14),
                    color: Color(0xFFD9D9D9),
                  ),
                ),
              ),
              SizedBox(height: getHeight(32),),
             
             ScanningProgressWidget(progress: 0.68),
               SizedBox(height: getHeight(24)),
                 CleanResultGridWidget.defaultValues(),
                  SizedBox(height: getHeight(24)),
             AppsRunningInBackgroundWidget(),
               SizedBox(height: getHeight(24)),
      
              // Button
              CleanButtonWidget(
                text:'Clean Now (375 MB)' 
,
                onPressed: () {
                  context.push('/CleaningCompleteScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}