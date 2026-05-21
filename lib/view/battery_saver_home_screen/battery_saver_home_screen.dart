import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver_home_screen/battery_saver_home_screen_widgets.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatterySaverHomeScreen extends StatefulWidget {
  const BatterySaverHomeScreen({super.key});

  @override
  State<BatterySaverHomeScreen> createState() => _BatterySaverHomeScreenState();
}

class _BatterySaverHomeScreenState extends State<BatterySaverHomeScreen> {
  SaverMode _selectedMode = SaverMode.smart;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor:AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title: AppText.batterySaver),
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
                    image: AssetImage(AppImages.homebatterysaver),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          
               SizedBox(height: getHeight(35)),
          
              // Gradient Title
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFE39C6), Color(0xFF9A3CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    AppText.batterySaverDescription,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: getHeight(12),),
              Center(
                child: Text(
                  AppText.optimizeSystemSettings,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          
              SizedBox(height: getHeight(24)),
          
              // Battery Saver Mode Card Widget
              BatterySaverModeCard(
                selected: _selectedMode,
                onChanged: (mode) => setState(() => _selectedMode = mode),
              ),
          
              SizedBox(height: getHeight(24)),
          
              // Button
              CleanButtonWidget(
                text: AppText.activateBatterySaver,
                onPressed: () {
                  context.push('/ResultBatterySaverScreen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}