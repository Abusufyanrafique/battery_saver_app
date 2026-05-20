import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

// ─── Main Widget ──────────────────────────────────────────────────────────────
class TemperatureWidget extends StatefulWidget {
  const TemperatureWidget({super.key});

  @override
  State<TemperatureWidget> createState() => _TemperatureWidgetState();
}

class _TemperatureWidgetState extends State<TemperatureWidget> {
  bool _autoCool = true;
  bool _cpuCooler = false;

  final double _tempValue = 0.5;

  String get _tempLabel {
    if (_tempValue < 0.35) return 'Cool';
    if (_tempValue < 0.65) return 'Normal';
    return 'Hot';
  }

  Color get _tempLabelColor {
    if (_tempValue < 0.65) {
      return const Color(0xFF3DDC84);
    }
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 270,
      padding: EdgeInsets.only(left: 20,right: 20,top:0),
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
          color: const Color(0xFF3A3FCC),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ─── TOP SECTION ───────────────────────
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppText.currenttemperature,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '32°C',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(22),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                _tempLabel,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(10),
                  fontWeight: FontWeight.w500,
                  color: _tempLabelColor,
                ),
              ),

              const SizedBox(height: 10),

              _GradientSlider(value: _tempValue),

              const SizedBox(height: 4),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cool',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF00FF09),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Normal',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF55D0FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Hot',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFFFF23C1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(
            color: Color(0xFF838283),
            thickness: 1,
            height: 1,
          ),

          // ─── TOGGLE ROWS ───────────────────────
          Column(
            children: [
              _ToggleRow(
                icon: Icons.ac_unit,
                title: 'Auto Cool',
                subtitle: 'Automatically reduce\ntemperature',
                value: _autoCool,
                onChanged: (val) {
                  setState(() => _autoCool = val);
                },
              ),

              const Divider(
                color: Color(0xFF838283),
                thickness: 1,
                height: 1,
              ),

              const SizedBox(height: 8),

              _ToggleRow(
                icon: Icons.developer_board_outlined,
                title: 'CPU Cooler',
                subtitle: 'Reduce CPU usage\nto cool down',
                value: _cpuCooler,
                onChanged: (val) {
                  setState(() => _cpuCooler = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Gradient Slider ──────────────────────────────────────────────────────────
class _GradientSlider extends StatelessWidget {
  final double value;

  const _GradientSlider({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thumbX = value * width;

        return SizedBox(
          height: 14,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2979FF),
                      Color(0xFF3DDC84),
                      Color(0xFFFFEB3B),
                      Color(0xFFFF9800),
                      Color(0xFFFF1744),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: thumbX - 5,
                child: Container(
                  width: getWidth(10),
                  height: getHeight(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3DDC84),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF3DDC84).withOpacity(0.4),
                        blurRadius: 5,
                        spreadRadius: 1,
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

// ─── Toggle Row ───────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(50), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ICON
          Container(
            width: getWidth(40),
            height: getHeight(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF232C6D),
              border: Border.all(
                color: const Color(0xFF4103AC),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF989CDF),
            ),
          ),

          const SizedBox(width: 10),

          // TEXT
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(11),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 2),

                // 🔥 FIX HERE
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(9),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD9D9D9),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // SWITCH
          Transform.scale(
            scale: 0.70,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF286FEE),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF3A3F6A),
            ),
          ),
        ],
      ),
    );
  }
}