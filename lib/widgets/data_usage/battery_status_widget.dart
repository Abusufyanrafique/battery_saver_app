// battery_status_widget.dart

import 'dart:math';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

class BatteryStatusWidget extends StatelessWidget {
  final int batteryLevel;
  final String remainingTime;
  final String screenOnTime;
  final String batteryHealth;
  final String capacity;
  final String performanceScore;
  final String performanceLabel;

  const BatteryStatusWidget({
    super.key,
    this.batteryLevel = 72,
    this.remainingTime = '18h 45m',
    this.screenOnTime = '6h 28m',
    this.batteryHealth = 'Good',
    this.capacity = '85% Capacity',
    this.performanceScore = '92/100',
    this.performanceLabel = 'Excellent',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(getWidth(12)),
      decoration: BoxDecoration(
        
        border: Border.all(
      color: const Color(0xFF4103AC),
      width: 1.2,
    ),
    gradient: const RadialGradient(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        Color(0xFF070D34), // center dark
        Color(0xFF1A1A3C), // middle dark
        Color(0xCC5C0EE3), // outer glow (80% opacity)
      ],
      stops: [0.0, 0.55, 1.0],
    ),
        borderRadius: BorderRadius.circular(16),
      
      ),
      child: Row(
        children: [
          // ───────── CIRCULAR BATTERY ─────────
          _CircularBattery(level: batteryLevel),

          SizedBox(width: getWidth(12)),

          // ───────── STATS GRID ─────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                      imagepath: AppImages.time,
                        iconColor: const Color(0xFF9A3CFF),
                        title: 'Remaning Time',
                        value: remainingTime,
                        subtitle: 'Usage Time',
                        showRightBorder: true,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        imagepath: AppImages.phone,
                        iconColor: const Color(0xFFCE93D8),
                        title: 'Screen On Time',
                        value: screenOnTime,
                        subtitle: 'Today',
                        showRightBorder: false,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: getHeight(6),),
                Row(
  children: [
    Expanded(
      child: Container(
        height: 1.5,
        color: const Color(0xFF4103AC),
      ),
    ),

    SizedBox(width: getWidth(20)), 

    Expanded(
      child: Container(
        height: 1.5,
        color: const Color(0xFF4103AC),
      ),
    ),
  ],
),

              SizedBox(height: getHeight(6),),
                // Bottom row
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                       imagepath: AppImages.heart,
                        iconColor: const Color(0xFFE53935),
                        title: 'Battery Health',
                        value: batteryHealth,
                        subtitle: capacity,
                        showRightBorder: true,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        imagepath: AppImages.performance,
                        iconColor: const Color(0xFF00BCD4),
                        title: 'Performance Score',
                        value: performanceScore,
                        subtitle: performanceLabel,
                        showRightBorder: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CIRCULAR BATTERY
// ─────────────────────────────────────────────────────────────

class _CircularBattery extends StatelessWidget {
  final int level;

  const _CircularBattery({required this.level});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidth(114),
      height: getWidth(110),
      child: CustomPaint(
        painter: _CircularBatteryPainter(level: level),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt_rounded,
                color: const Color(0xFFFF2D9B),
                size: getWidth(20),
              ),
              Text(
                '$level%',
                style: TextStyle(
                  fontSize: getFont(30),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'Battery Level',
                style: TextStyle(
                  fontSize: getFont(9),
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularBatteryPainter extends CustomPainter {
  final int level;

  _CircularBatteryPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const startAngle = -pi * 0.75;
    const sweepAngle = pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: pi * 2,
        colors: [
          Color(0xFF9A3CFF),
          Color(0xFFFF2D9B),
          Color(0xFF00BFFF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * (level / 100),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────
// STAT ITEM
// ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String imagepath;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool showRightBorder;

  const _StatItem({
    
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.showRightBorder, 
    required this.imagepath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: showRightBorder ? getWidth(10) : 0,
        left: showRightBorder ? 0 : getWidth(10),
      ),
      decoration: showRightBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Color(0xFF4103AC),
                  width: 1.5,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + Title
          Row(
            children: [
          Image.asset(
          imagepath,
          width: getWidth(12),
          height: getWidth(16),
),
              SizedBox(width: getWidth(4)),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(9),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(3)),

          // Value
          Padding(
            padding: const EdgeInsets.only(left: 9.0),
            child: Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: getHeight(1)),

          // Subtitle
          Padding(
            padding: const EdgeInsets.only(left: 9.0),
            child: Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(10),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}