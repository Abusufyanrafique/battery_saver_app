import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver/battery_mode_list_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';

class BatterySaverScreen extends StatelessWidget {
  const BatterySaverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: 'Apply'),
        body: SingleChildScrollView(  
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(63),),
              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.batterysaverimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      
               SizedBox(height: getHeight(64)),
      
              // Title
             Center(
  child: RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: "Battery Status: ",
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: getFont(14),
            color: Colors.white,
          ),
        ),
        TextSpan(
          text: "Good",
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(14),
            color: const Color(0xFF2FE55D), 
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
),
      
              SizedBox(height: getHeight(150)), 
      
             
             BatteryModeListWidget(
    items: const [
    BatteryModeItem(
      title: "Power Saving Mode",
      subtitle: "12h 30m",
      icon: Icons.bolt,
      iconBgColor: Color(0xFF2FE55D), // Green
    ),
    BatteryModeItem(
      title: "Super Saving Mode",
      subtitle: "24h 15m",
      icon: Icons.battery_charging_full,
      iconBgColor: Color(0xFF55D0FF), // Blue
    ),
    BatteryModeItem(
      title: "Custom Mode",
      subtitle: "Custom settings",
      icon: Icons.settings_outlined,
      iconBgColor: Color(0xFF989CDF), // Purple
    ),
  ],
),
      
               SizedBox(height:getHeight(60)),
      
              // Button
              CleanButtonWidget(
                text: "Boost Now",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}