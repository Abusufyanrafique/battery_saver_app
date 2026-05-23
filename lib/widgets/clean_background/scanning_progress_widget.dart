import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class ScanningProgressWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ScanningProgressWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(16),
        vertical: getHeight(4),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF4103AC),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Scanning Progress',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(12)),

          // Progress Bar + Percentage
          Row(
            children: [
              // Progress Bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        height: getHeight(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232C6D),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      // Foreground
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: getHeight(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2FE55D),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: getWidth(12)),

              // Percentage Text
              Text(
                '$percentage%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2FE55D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}