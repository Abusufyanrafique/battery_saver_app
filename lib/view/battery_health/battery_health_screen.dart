import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_health_widget%20.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatteryHealthScreen extends StatelessWidget {
  const BatteryHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),

      appBar: CustomAppBar(
        title: AppText.batteryHealth,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.batteryhealthimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title 1 (Gradient)
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFB8CBEF),
                      Color(0xFF0E65B0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    AppText.monitorProtect,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Title 2
              Text(
                AppText.yourBattery,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: getFont(20),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7634C0),
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                AppText.checkbatteryhealthandgettipstoextendbattery,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: getFont(14),
                  color: const Color(0xFFD9D9D9),
                ),
              ),

              SizedBox(height: getHeight(40)),

              // Widget
              BatteryHealthWidget(
                healthStatus: 'Good',
                healthPercent: 85,
                designCapacity: '5000 mah',
                currentCapacity: '4250 mah',
                batteryVoltage: '3.9 V',
                batteryTemperature: '32°C',
              ),

              SizedBox(height: getHeight(24)),

              // Button
              CleanButtonWidget(
                text: AppText.viewDetails,
                onPressed: () {
                  context.push('/ResultBatteryHealthScreen');
                },
              ),

              SizedBox(height: getHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}