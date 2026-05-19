import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/security_scan/security_scan_widget.dart';
import 'package:flutter/material.dart';

class SecurityScanScreen extends StatelessWidget {
  const SecurityScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: 'Security Scan'),
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
                    image: AssetImage(AppImages.securityscanimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      
              const SizedBox(height: 16),
      
              // Title
              Center(
                child: Text(
                  "100%",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(30),
                    color: Colors.white,
                  ),
                ),
              ),
               Center(
                child: Text(
                  "safe",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    color: Color(0xFFD9D9D9),
                  ),
                ),
              ),
               Center(
                child: Text(
                  "No threats found",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: Color(0xFF2FE55D),
                  ),
                ),
              ),
      
              SizedBox(height: getHeight(80)), 
      
             
              SecurityScanWidget(
  items: const [
    SecurityScanItem(title: "Virus Scan"),
    SecurityScanItem(title: "Privacy Scan"),
    SecurityScanItem(title: "Vulnerability Scan"),
    SecurityScanItem(title: "System Protection"),
  ],
),
      
             SizedBox(height: getHeight(64),),
      
              // Button
              CleanButtonWidget(
                text: "Scan Again",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}