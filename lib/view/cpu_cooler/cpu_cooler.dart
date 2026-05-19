import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver/battery_mode_list_widget.dart';
import 'package:battery_saver_app/widgets/cpu_cooler/cpu_cooler_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/phone_boost/phone_boost_list_widget.dart';
import 'package:flutter/material.dart';

class CpuCoolerScreen extends StatelessWidget {
  const CpuCoolerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: 'CPU Cooler'),
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
                    image: AssetImage(AppImages.cpucoolerimage),
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
          text: "Cooling down...",
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: getFont(14),
            color: Color(0xFF55D0FF),
          ),
        ),
      ],
    ),
  ),
),
      
              SizedBox(height: getHeight(150)), 
      
             
             CpuCoolerWidget(
  items:  [
    CpuInfoItem(
      imagePath: AppImages.cpuusage,
      title: "CPU Usage",
      value: "38%",
    ),
    CpuInfoItem(
      imagePath: AppImages.cpumangerimage,
      title: "Running Apps",
      value: "24",
    ),
    CpuInfoItem(
      imagePath: AppImages.temperature,
      title: "Temperature",
      value: "38°C",
    ),
  ],
),
      
               SizedBox(height:getHeight(60)),
      
              // Button
              CleanButtonWidget(
                text: "Cool Down",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}