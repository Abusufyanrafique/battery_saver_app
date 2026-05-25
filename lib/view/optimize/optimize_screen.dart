import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver_home_screen/battery_saver_home_screen_widgets.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/optimize/optimization_widget.dart';
import 'package:battery_saver_app/widgets/optimize/stop_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OptimizeScreen extends StatefulWidget {
  const OptimizeScreen({super.key});

  @override
  State<OptimizeScreen> createState() => _OptimizeScreenState();
}

class _OptimizeScreenState extends State<OptimizeScreen> {
  SaverMode _selectedMode = SaverMode.smart;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor:AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title: AppText.optimize1),
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20),
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
                    image: AssetImage(AppImages.optimizeimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          
               SizedBox(height: getHeight(20)),
          
              // Gradient Title
              Center(
                child: Text(
                  AppText.optimizing,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(20),
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluetextcolor
                  ),
                ),
              ),
              // SizedBox(height: getHeight(6),),
              Center(
                child: Text(
                  AppText.scanningdeviceandoptimizingperformance,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.allsmalltextcolor
                  ),
                ),
              ),
          SizedBox(height: getHeight(6),),
             
          OptimizationWidget(),
                SizedBox(height: getHeight(20),),
              // Button
             StopButton(
    onPressed: () {
    context.push('/OptimizationResultScreen');
  },
),
            ],
          ),
        ),
      ),
    );
  }
}