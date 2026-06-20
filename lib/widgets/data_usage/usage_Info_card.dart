import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

class UsageInfoCard extends StatelessWidget {
  final String label;
  final String value;

  const UsageInfoCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF232C6D),
             Color(0xFF1B2153),
             Color(0xFF13173A),
             ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B3FA0).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
             style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getHeight(16),
               fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            )
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getHeight(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Demo ──────────────────────────────────────────────────────────────────────

class UsageCardDemoPage extends StatelessWidget {
  const UsageCardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D24),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              UsageInfoCard(
                label: AppText.wifiUsagetext,
                value: '1.35 GB',
              ),
              SizedBox(height: 12),
              // Add more cards easily:
              UsageInfoCard(
                label: AppText.mobileData,
                value: '0.82 GB',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

