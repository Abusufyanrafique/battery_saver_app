import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/phone_boost/phone_boost_list_widget.dart';
import 'package:flutter/material.dart';

class PhoneBoostScreen extends StatelessWidget {
  const PhoneBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: 'Phone Boost'),
        body: SingleChildScrollView(  
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
                    image: AssetImage(AppImages.phoneboostOptimizeimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      
              const SizedBox(height: 16),
      
              // Title
              Center(
                child: Text(
                  "Memory Used",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    color: Colors.white,
                  ),
                ),
              ),
      
              SizedBox(height: getHeight(80)), 
      
              // Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Running Processes",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                  Text(
                    "23",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(14),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      
              const SizedBox(height: 8),
      
             
              const PhoneBoostListWidget(),
      
              const SizedBox(height: 12),
      
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