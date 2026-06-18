import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

class BatteryHealthWidget extends StatefulWidget {
  final String healthStatus;
  final int healthPercent;
  final String designCapacity;
  final String currentCapacity;
  final String batteryVoltage;
  final String batteryTemperature;

  const BatteryHealthWidget({
    super.key,
    required this.healthStatus,
    required this.healthPercent,
    required this.designCapacity,
    required this.currentCapacity,
    required this.batteryVoltage,
    required this.batteryTemperature,
  });

  @override
  State<BatteryHealthWidget> createState() => _BatteryHealthWidgetState();
}

class _BatteryHealthWidgetState extends State<BatteryHealthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.healthPercent / 100,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.healthPercent >= 80) {
      return const Color(0xFF10E3D6);
    } else if (widget.healthPercent >= 50) {
      return const Color(0xFFFFC107);
    } else {
      return const Color(0xFFFF5252);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(275),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(18),
        vertical: getHeight(18),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            AppText.batteryHealth1,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          SizedBox(height: getHeight(2)),

          // STATUS
          Text(
            widget.healthStatus,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(11),
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
          ),

          SizedBox(height: getHeight(8)),

          // PERCENT
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              final displayPercent =
                  (_progressAnimation.value * widget.healthPercent).round();

              return Text(
                '$displayPercent%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(28),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            },
          ),

          SizedBox(height: getHeight(8)),

          // PROGRESS BAR
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: getHeight(6),
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        height: getHeight(6),
                        width:
                            constraints.maxWidth * _progressAnimation.value,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2979FF),
                              Color(0xFF00B0FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          SizedBox(height: getHeight(14)),

          // INFO ROWS (NO DIVIDER)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoRow(
                  label: AppText.designCapacity,
                  value: widget.designCapacity,
                ),
                _InfoRow(
                  label: AppText.currentCapacity,
                  value: widget.currentCapacity,
                ),
                _InfoRow(
                  label: AppText.batteryVoltage,
                  value: widget.batteryVoltage,
                ),
                _InfoRow(
                  label: AppText.batteryTemperature,
                  value: widget.batteryTemperature,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getHeight(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(11),
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD9D9D9),
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(11),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}