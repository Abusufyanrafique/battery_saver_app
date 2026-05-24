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
          // TITLE
          Text(
            'Storage Comparison',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(10)),

          // ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // BEFORE
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

              // PIPE + ARROW + PIPE
              Container(
                width: getWidth(70),
                padding: EdgeInsets.symmetric(horizontal: getWidth(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LEFT PIPE
                   Container(
  width: 2,
  height: 58,
  decoration: BoxDecoration(
    color: const Color(0xFF838283),
    borderRadius: BorderRadius.circular(2),
  ),
),

                    SizedBox(width: getWidth(16)),

                    // ARROW
                    Container(
                      width: getWidth(30),
                      height: getWidth(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4103AC),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF00E676),
                        size: 18,
                      ),
                    ),

                    SizedBox(width: getWidth(6)),

                    // RIGHT PIPE
                    Container(
  width: 2,
  height: 58,
  decoration: BoxDecoration(
    color: const Color(0xFF838283),
    borderRadius: BorderRadius.circular(2),
  ),
),
                  ],
                ),
              ),

              // AFTER
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color: AppColors.allsmalltextcolor,
            ),
          ),

          SizedBox(height: getHeight(6)),

          Text(
            '${valueGB.toStringAsFixed(1)} GB',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(12),
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),

          SizedBox(height: getHeight(2)),

          Text(
            'used',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color: usedColor,
            ),
          ),

          SizedBox(height: getHeight(4)),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                Container(
                  height: getHeight(4),
                  width: getWidth(80),
                  color: Colors.white.withOpacity(0.12),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: getHeight(4),
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: getHeight(8)),

          Text(
            'Total ${totalGB.toInt()} GB',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color: AppColors.allsmalltextcolor,
            ),
          ),
        ],
      ),
    );
  }
}