// battery_status_widget.dart

import 'dart:math';
import 'package:battery_saver_app/bloc/battery_status_cubit_usage/battery_status_cubit.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

class BatteryStatusWidget extends StatefulWidget {
  final int batteryLevel;

  const BatteryStatusWidget({
    super.key,
    this.batteryLevel = 0,
  });

  @override
  State<BatteryStatusWidget> createState() => _BatteryStatusWidgetState();
}

class _BatteryStatusWidgetState extends State<BatteryStatusWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Pehli load + periodic auto refresh start
    context.read<BatteryStatusCubit>().startAutoRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<BatteryStatusCubit>();
    if (state == AppLifecycleState.resumed) {
      // App foreground mein wapas aaye -> turant refresh + timer restart
      cubit.startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App background mein gayi -> timer band, battery bachao
      cubit.stopAutoRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<BatteryStatusCubit>().stopAutoRefresh();
    super.dispose();
  }

  String _formatTime(int ms) {
    if (ms <= 0) return '0h 0m';
    int totalSeconds = ms ~/ 1000;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  String _getPerformanceLabel(int level) {
    if (level > 80) return 'Excellent';
    if (level > 50) return 'Good';
    if (level > 20) return 'Fair';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatteryStatusCubit, BatteryStatusState>(
      builder: (context, state) {
        int level = widget.batteryLevel;
        String remainingTime = '—';
        String screenOnTime = '—';
        String health = '—';
        String capacity = '—';
        String score = '—';
        String label = '—';

        if (state is BatteryStatusLoaded) {
          level = state.data.level;

          screenOnTime = state.data.screenTimeFormatted != '0s'
              ? state.data.screenTimeFormatted
              : _formatTime(state.data.screenOnTime);

          remainingTime = '${level * 15 ~/ 60}h ${(level * 15) % 60}m';
          label = _getPerformanceLabel(level);
          score = '$level/100';

          if (state.data.status.toLowerCase() == 'charging') {
            health = 'Charging';
            capacity = 'Optimizing';
          } else {
            health = level > 20 ? 'Good' : 'Low';
            capacity = '${(80 + (level * 0.15)).toStringAsFixed(0)}% Capacity';
          }
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(getWidth(10)),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.appWidgetBorderColor,
              width: 1.2,
            ),
            gradient: const RadialGradient(
              radius: 1.2,
              colors:AppColors.batteryusagecontainer
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: state is BatteryStatusLoading ? 0.3 : 1.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CircularBattery(level: level),
                    SizedBox(width: getWidth(16)),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatItem(
                                  imagepath: AppImages.time,
                                  iconColor: const Color(0xFF9A3CFF),
                                  title: AppText.remainingTime,
                                  value: remainingTime,
                                  subtitle: AppText.usageTime,
                                  showRightBorder: true,
                                ),
                              ),
                              Expanded(
                                child: _StatItem(
                                  imagepath: AppImages.phone,
                                  iconColor: const Color(0xFFCE93D8),
                                  title: AppText.screenOnTime,
                                  value: screenOnTime,
                                  subtitle: AppText.todaytext,
                                  showRightBorder: false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: getHeight(8)),
                          Container(
                            height: 1,
                            color: AppColors.linecolors,
                          ),
                          SizedBox(height: getHeight(8)),
                          SizedBox(width: getWidth(3)),
                          Row(
                            children: [
                              Expanded(
                                child: _StatItem(
                                  imagepath: AppImages.heart,
                                  iconColor: AppColors.heartcolor,
                                  title: AppText.batteryHealthtext1,
                                  value: health,
                                  subtitle: capacity,
                                  showRightBorder: true,
                                ),
                              ),
                              Expanded(
                                child: _StatItem(
                                  imagepath: AppImages.performance,
                                  iconColor: AppColors.performancecolor,
                                  title: AppText.performanceScoretext,
                                  value: score,
                                  subtitle: label,
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
              ),
              if (state is BatteryStatusLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9A3CFF),
                    ),
                  ),
                ),
              if (state is BatteryStatusError)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppText.failedtofetchrealdata,
                          style: TextStyle(color: AppColors.white, fontSize: 12),
                        ),
                        IconButton(
                          onPressed: () =>
                              context.read<BatteryStatusCubit>().loadBatteryStatus(),
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppColors.errorRed, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// CIRCULAR BATTERY (unchanged)
// ─────────────────────────────────────────────
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
              Icon(Icons.bolt_rounded,
                  color: AppColors.boltcolor, size: getWidth(20)),
              Text(
                '$level%',
                style: TextStyle(
                    fontSize: getFont(30),
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                AppText.batteryLeveltext,
                style: TextStyle(fontSize: getFont(9), color: Colors.white),
              ),
               SizedBox(height: getHeight(6)),
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

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        bgPaint);

    final fgPaint = Paint()
      ..shader =  SweepGradient(
        colors: AppColors.gradientlevelColors
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

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

// ─────────────────────────────────────────────
// STAT ITEM (unchanged)
// ─────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String imagepath;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool showRightBorder;

  const _StatItem({
    required this.imagepath,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.showRightBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: showRightBorder ? getWidth(12) : 0,
        left: showRightBorder ? 0 : getWidth(12),
      ),
      decoration: showRightBorder
          ? const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.appWidgetBorderColor,
                  width: 1,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(imagepath, width: getWidth(12), height: getWidth(16)),
              SizedBox(width: getWidth(4)),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      color: AppColors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: getHeight(5)),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(10),
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                  ),
            ),
          ),
          SizedBox(height: getHeight(2)),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(10),
                  color: AppColors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}