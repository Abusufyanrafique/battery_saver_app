import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatsCard extends StatelessWidget {
  final int totalApps;
  final double totalSizeGB;
  final bool isApkMode; //   parameter

  const StatsCard({
    super.key,
    required this.totalApps,
    required this.totalSizeGB,
    this.isApkMode = false, //  default false
  });

  @override
  Widget build(BuildContext context) {
    // APK mode colors
    final Color labelColor = isApkMode
        ?  Colors.white  // orange label
        : Colors.white;
    final Color valueColor = isApkMode
        ? const Color(0xFF55D0FF)   // orange value
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        border: Border.all(
          color: Color(0xFF4103AC),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          //  Left side SVG icon (sirf APK mode mein)
          if (isApkMode) ...[
            SvgPicture.asset(
              AppIcons.apkfile, //  apna SVG path yahan lagao
              width: getWidth(36),
              height: getHeight(36),
              colorFilter: const ColorFilter.mode(
                Color(0xFF55D0FF),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: getWidth(14)),
          ],

          _StatItem(
            label: 'Total APKs',  // APK mode mein label change
            value: '$totalApps',
            labelColor: labelColor,
            valueColor: valueColor,
          ),
          SizedBox(width: getWidth(60)),
          Center(
            child: Container(
              height: 50,
              width: 1,
              color: const Color(0xFF373C62),
            ),
          ),
          SizedBox(width: getWidth(15)),
          _StatItem(
            label: 'Total Size',
            value: '${totalSizeGB.toStringAsFixed(2)} GB',
            labelColor: labelColor,
            valueColor: valueColor,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(12),
            color: labelColor, //  dynamic color
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(24),
            color: valueColor, //  dynamic color
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}