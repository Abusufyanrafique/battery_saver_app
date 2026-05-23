import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class StorageComparisonWidget extends StatelessWidget {
  final double beforeGB;
  final double afterGB;
  final double totalGB;

  const StorageComparisonWidget({
    super.key,
    this.beforeGB = 28.0,
    this.afterGB = 27.5,
    this.totalGB = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(getWidth(12)),
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
          color: const Color(0xFF4103AC),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Storage Comparison',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(10)),

          // Comparison Row
          IntrinsicHeight(
            child: Row(
              children: [
                // Before Cleaning
                Expanded(
                  child: _StorageColumn(
                    label: 'Before Cleaning',
                    valueGB: beforeGB,
                    totalGB: totalGB,
                    valueColor: AppColors.textwhitecolor,
                    usedColor: AppColors.textwhitecolor,
                    barColor: const Color(0xFFFF19BD),
                  ),
                ),

                // Divider + Arrow
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: getWidth(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Vertical Divider Left
                      Expanded(
                        child: Container(
                          width: 1,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),

                      SizedBox(height: getHeight(4)),

                      // Arrow Circle
                      Container(
                        width: getWidth(34),
                        height: getWidth(34),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF4103AC),
                            width: 1.5,
                          ),
                          color: Colors.transparent,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: const Color(0xFF00E676),
                          size: getWidth(18),
                        ),
                      ),

                      SizedBox(height: getHeight(4)),

                      Expanded(
                        child: Container(
                          width: 1,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),

                // After Cleaning
                Expanded(
                  child: _StorageColumn(
                    label: 'After Cleaning',
                    valueGB: afterGB,
                    totalGB: totalGB,
                    valueColor: const Color(0xFF00E676),
                    usedColor: const Color(0xFF00E676),
                    barColor: const Color(0xFF00E676),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageColumn extends StatelessWidget {
  final String label;
  final double valueGB;
  final double totalGB;
  final Color valueColor;
  final Color usedColor;
  final Color barColor;

  const _StorageColumn({
    required this.label,
    required this.valueGB,
    required this.totalGB,
    required this.valueColor,
    required this.usedColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (valueGB / totalGB).clamp(0.0, 1.0);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              fontWeight: FontWeight.w400,
              color: AppColors.allsmalltextcolor,
            ),
          ),
      
          SizedBox(height: getHeight(6)),
      
          // Value
          Text(
            '${valueGB.toStringAsFixed(1)} GB',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(22),
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
      
          SizedBox(height: getHeight(2)),
      
          // Used label
          Text(
            'used',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              fontWeight: FontWeight.w400,
              color: usedColor,
            ),
          ),
      
          SizedBox(height: getHeight(4)),
      
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                // Background
                Container(
                  height: getHeight(4),
                  width: getWidth(80),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                // Foreground
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: getHeight(4),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          SizedBox(height: getHeight(8)),
      
          // Total
          Text(
            'Total ${totalGB.toInt()} GB',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              fontWeight: FontWeight.w400,
              color: AppColors.allsmalltextcolor,
            ),
          ),
        ],
      ),
    );
  }
}