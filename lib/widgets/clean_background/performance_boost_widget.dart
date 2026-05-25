import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PerformanceBoostWidget extends StatelessWidget {
  const PerformanceBoostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(getWidth(16)),
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
            'Performance Boost',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(6)),

          // Three Items Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Speed Improved
              _BoostItem(
                icon: Icons.rocket_launch_rounded,
                iconColor: const Color(0xFF00E676),
                arcColor: const Color(0xFF00E676),
                title: 'Speed Improved',
                value: '+35%',
                valueColor: const Color(0xFF00E676),
                subtitle: 'Performance Boost',
              ),

              // RAM Freed
              _BoostItem(
                icon: Icons.memory_rounded,
                iconColor: const Color(0xFF55D0FF),
                arcColor: const Color(0xFF55D0FF),
                title: 'RAM Freed',
                value: '+1.0 GB',
                valueColor: const Color(0xFF55D0FF),
                subtitle: 'Memory Boost',
              ),

              // Battery Saved
              _BoostItem(
                icon: Icons.battery_charging_full_rounded,
                iconColor: const Color(0xFF9A3CFF),
                arcColor: const Color(0xFF9A3CFF),
                title: 'Battery Saved',
                value: '+1h 20m',
                valueColor: const Color(0xFF9A3CFF),
                subtitle: 'Extra Battery Life',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoostItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color arcColor;
  final String title;
  final String value;
  final Color valueColor;
  final String subtitle;

  const _BoostItem({
    required this.icon,
    required this.iconColor,
    required this.arcColor,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle with Arc
        SizedBox(
          width: getWidth(40),
          height: getWidth(40),
          child: CustomPaint(
            painter: _ArcPainter(color: arcColor),
            child: Center(
              child: Container(
                width: getWidth(40),
                height: getWidth(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: getWidth(24),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: getHeight(10)),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(10),
            fontWeight: FontWeight.w600,
            color: AppColors.textwhitecolor,
          ),
        ),

        SizedBox(height: getHeight(4)),

        // Value
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(12),
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),

        SizedBox(height: getHeight(2)),

        // Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(8),
            fontWeight: FontWeight.w500,
            color: AppColors.allsmalltextcolor,
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;

  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.85,
      math.pi * 1.7,
      false,
      bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.85,
      math.pi * 1.1,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}