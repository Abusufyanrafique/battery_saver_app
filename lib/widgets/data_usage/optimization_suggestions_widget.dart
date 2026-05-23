// optimization_suggestions_widget.dart

import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

class OptimizationSuggestionsWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onViewAll;
  final VoidCallback? onOptimize;

  const OptimizationSuggestionsWidget({
    super.key,
    this.title = 'Close background apps',
    this.subtitle = '6 apps are running in background',
    this.onViewAll,
    this.onOptimize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(14),
        vertical: getHeight(5),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
           begin: Alignment.topCenter,
           end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3440A0),
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A)
          ]
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ───────── HEADER ROW ─────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Optimization Suggestions',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9A3CFF),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(7)),

          // ───────── SUGGESTION CARD ─────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(12),
              vertical: getHeight(12),
            ),
            decoration: BoxDecoration(
             gradient: LinearGradient(colors: [
              Color(0xFF1B235C),
              Color(0xFF1B235C),
              Color(0xFF13173A)
             ]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4103AC),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // ── Icon ──
                Container(
                  width: getWidth(30),
                  height: getWidth(30),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                   gradient: const RadialGradient(
  center: Alignment.center,
  radius: 1.2,
  colors: [
    Color(0xFF181C3B), // center dark
    Color(0xFF9A3CFF), // outer purple glow
  ],
),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      size: getWidth(22),
                      color: Color(0xFFFF1DBF),
                    ),
                  ),
                ),

                SizedBox(width: getWidth(12)),

                // ── Text ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: getFont(13),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: getHeight(3)),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: getFont(9),
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: getWidth(8)),

                // ── Optimize Button ──
                GestureDetector(
                  onTap: onOptimize,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(10),
                      vertical: getHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF9A3CFF),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Optimize',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
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