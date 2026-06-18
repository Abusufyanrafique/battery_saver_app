import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class PerformanceBoostWidget extends StatelessWidget {
  /// Fallback values passed from [CleaningCompleteScreen].
  /// These are either real BLoC data or live estimates — never null/empty.
  final String speedValue;
  final String ramValue;
  final String batteryValue;

  const PerformanceBoostWidget({
    super.key,
    required this.speedValue,
    required this.ramValue,
    required this.batteryValue,
  });

  // ─── Ratio parsers ────────────────────────────────────────────────────────

  /// "+35%" → 0.35
  static double _parseSpeedRatio(String val) {
    final clean = val.replaceAll('+', '').replaceAll('%', '').trim();
    final pct = double.tryParse(clean) ?? 0.0;
    return (pct / 100).clamp(0.0, 1.0);
  }

  /// "+1.2 GB" or "+512 MB" → ratio out of max 8 GB
  static double _parseRamRatio(String val) {
    final clean = val
        .replaceAll('+', '')
        .replaceAll('GB', '')
        .replaceAll('MB', '')
        .trim();
    final num = double.tryParse(clean) ?? 0.0;
    final isGB = val.toUpperCase().contains('GB');
    final kb = isGB ? num * 1024 : num;
    return (kb / (8 * 1024)).clamp(0.0, 1.0);
  }

  /// "+1h 20m" or "+45m" → ratio out of max 120 min
  static double _parseBatteryRatio(String val) {
    int totalMin = 0;
    final hourMatch = RegExp(r'(\d+)h').firstMatch(val);
    final minMatch = RegExp(r'(\d+)m').firstMatch(val);
    if (hourMatch != null) totalMin += int.parse(hourMatch.group(1)!) * 60;
    if (minMatch != null) totalMin += int.parse(minMatch.group(1)!);
    return (totalMin / 120).clamp(0.0, 1.0);
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Compute arc ratios from the resolved values (real or estimated)
    final speedRatio = _parseSpeedRatio(speedValue);
    final ramRatio = _parseRamRatio(ramValue);
    final batteryRatio = _parseBatteryRatio(batteryValue);

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
          Text(
            'Performance Boost',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(6)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BoostItem(
                icon: Icons.rocket_launch_rounded,
                iconColor: const Color(0xFF00E676),
                arcColor: const Color(0xFF00E676),
                title: 'Speed Improved',
                value: speedValue,
                valueColor: const Color(0xFF00E676),
                subtitle: 'Performance Boost',
                arcRatio: speedRatio,
              ),
              _BoostItem(
                icon: Icons.memory_rounded,
                iconColor: const Color(0xFF55D0FF),
                arcColor: const Color(0xFF55D0FF),
                title: 'RAM Freed',
                value: ramValue,
                valueColor: const Color(0xFF55D0FF),
                subtitle: 'Memory Boost',
                arcRatio: ramRatio,
              ),
              _BoostItem(
                icon: Icons.battery_charging_full_rounded,
                iconColor: const Color(0xFF9A3CFF),
                arcColor: const Color(0xFF9A3CFF),
                title: 'Battery Saved',
                value: batteryValue,
                valueColor: const Color(0xFF9A3CFF),
                subtitle: 'Extra Battery Life',
                arcRatio: batteryRatio,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _BoostItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color arcColor;
  final String title;
  final String value;
  final Color valueColor;
  final String subtitle;
  final double arcRatio; // 0.0 – 1.0

  const _BoostItem({
    required this.icon,
    required this.iconColor,
    required this.arcColor,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.subtitle,
    required this.arcRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: getWidth(40),
          height: getWidth(40),
          child: CustomPaint(
            painter: _ArcPainter(color: arcColor, ratio: arcRatio),
            child: Center(
              child: Container(
                width: getWidth(40),
                height: getWidth(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
                child: Icon(icon, color: iconColor, size: getWidth(24)),
              ),
            ),
          ),
        ),
        SizedBox(height: getHeight(10)),
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
  final double ratio; // 0.0 – 1.0

  _ArcPainter({required this.color, required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    const startAngle = -math.pi * 0.85;
    const totalSweep = math.pi * 1.7;

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // Foreground arc — driven by real or estimated ratio
    final sweepAngle = totalSweep * ratio.clamp(0.0, 1.0);
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.ratio != ratio;
}