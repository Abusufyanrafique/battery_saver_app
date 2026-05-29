import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/phone_boost/phone_boost_list_widget.dart';
import 'package:flutter/material.dart';

class PhoneBoostScreen extends StatelessWidget {
  const PhoneBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),
      appBar: CustomAppBar(title: AppText.phoneBoost),

      body: Container(
        width: double.infinity,
        height: double.infinity,

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
                      image: AssetImage(AppImages.phoneboostOptimizeimage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ───── TITLE ─────
                Center(
                  child: Text(
                    AppText.memoryUsed,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(14),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(80)),

                // ───── HEADER ROW ─────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppText.runningProcesses,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(20),
                        color: const Color(0xFFD9D9D9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "23",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(16),
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ───── LIST ─────
                const PhoneBoostListWidget(),

                const SizedBox(height: 20),

                // ───── BUTTON ─────
                CleanButtonWidget(
                  text: AppText.boostNow1,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}