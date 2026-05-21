import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int totalApps;
  final double totalSizeGB;

  const StatsCard({
    super.key,
    required this.totalApps,
    required this.totalSizeGB,
  });

  @override
  Widget build(BuildContext context) {
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
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Total Apps', value: '$totalApps'),
          SizedBox(width: getWidth(60),),
          Center(
            child: Container(
              height: 50,
              width: 1,
              decoration: BoxDecoration(
                color: Color(0xFF373C62),
            
              ),
            ),
          ),
           SizedBox(width: getWidth(15)),
          _StatItem(
            label: 'Total Size',
            value: '${totalSizeGB.toStringAsFixed(2)} GB',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(12),
            color: Colors.white,
            fontWeight: FontWeight.w500
          )
        ),
        const SizedBox(height: 4),
        Text(
          value,
         style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(24),
            color: Colors.white,
            fontWeight: FontWeight.w500
          )
        ),
      ],
    );
  }
}