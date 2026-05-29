import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/security_scan/security_scan_widget.dart';
import 'package:flutter/material.dart';

class SecurityScanScreen extends StatelessWidget {
  const SecurityScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),

      //  inside Scaffold (removes white flash)
      appBar: CustomAppBar(title: AppText.securityScan),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // stable gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1633),
              Color(0xFF0B122B),
              Color(0xFF070C1F),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ───── IMAGE ─────
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

                const SizedBox(height: 20),

                // ───── STATUS TEXT ─────
                Center(
                  child: Text(
                    "100%",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(30),
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Center(
                  child: Text(
                   AppText.safe,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(14),
                      color: const Color(0xFFD9D9D9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    AppText.nothreatsfound,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      color: const Color(0xFF2FE55D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(99)),

                // ───── SCAN LIST ─────
                const SecurityScanWidget(
                  items: [
                    SecurityScanItem(title: "Virus Scan"),
                    SecurityScanItem(title: "Privacy Scan"),
                    SecurityScanItem(title: "Vulnerability Scan"),
                    SecurityScanItem(title: "System Protection"),
                  ],
                ),

                SizedBox(height: getHeight(64)),

                // ───── BUTTON ─────
                CleanButtonWidget(
                  text: AppText.scanAgain,
                  onPressed: () {},
                ),

                // SizedBox(height: getHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}