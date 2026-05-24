import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/cpu_cooler/cpu_cooler_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';

class CpuCoolerScreen extends StatelessWidget {
  const CpuCoolerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E112F),

      // AppBar inside Scaffold (avoid white flash)
      appBar: CustomAppBar(title: 'CPU Cooler'),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        //  stable gradient background
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(height: getHeight(30)),

                // ───── IMAGE ─────
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

                SizedBox(height: getHeight(40)),

                // ───── STATUS TEXT ─────
                Center(
                  child: Text(
                    "Cooling down...",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: getFont(14),
                      color: const Color(0xFF55D0FF),
                    ),
                  ),
                ),

                SizedBox(height: getHeight(120)),

                // ───── CPU INFO WIDGET ─────
                CpuCoolerWidget(
                  items: [
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

                SizedBox(height: getHeight(50)),

                // ───── BUTTON ─────
                CleanButtonWidget(
                  text: "Cool Down",
                  onPressed: () {},
                ),

                SizedBox(height: getHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}