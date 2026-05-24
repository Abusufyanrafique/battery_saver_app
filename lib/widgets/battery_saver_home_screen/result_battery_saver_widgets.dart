import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BatteryLifeWidget extends StatelessWidget {
  const BatteryLifeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20,right: 20,left: 20,bottom: 10), //  reduced padding
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, //  important
        children: [
          Text(
            'Expected Battery Life',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(15), // slightly reduced
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          SizedBox(height: getHeight(14)), // reduced

          Center(
            child: Text(
              '15h 30m',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(26), // reduced
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: getHeight(6)),

          Center(
            child: Text(
              'Extended',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00FF09),
              ),
            ),
          ),

            SizedBox(height: getHeight(14)),

          const Divider(
            color: Color(0xFF838283),
            thickness: 0.5,
            height: 1,
          ),

          const SizedBox(height: 6),

          _BatteryRow(
            svgPath: AppIcons.brightness,
            label: 'Brightness',
            value: 'Optimized',
            valueColor: const Color(0xFF00FF09),
          ),

          _BatteryRow(
            svgPath: AppIcons.backgroundApps,
            label: 'Background Apps',
            value: 'Limited',
            valueColor: const Color(0xFF00FF09),
          ),

          _BatteryRow(
            svgPath: AppIcons.autoSync,
            label: 'Auto Sync',
            value: 'Disabled',
            valueColor: const Color(0xFF00FF09),
          ),

          _BatteryRow(
            svgPath: AppIcons.notificationsicon,
            label: 'Notifications',
            value: 'Limited',
            valueColor: const Color(0xFF00FF09),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─── ROW ───────────────────────────────────────────────

class _BatteryRow extends StatelessWidget {
  final String svgPath;
  final String label;
  final String value;
  final Color valueColor;
  final bool isLast;

  const _BatteryRow({
    required this.svgPath,
    required this.label,
    required this.value,
    required this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4), 
          child: Row(
            children: [
              Container(
                width: getWidth(30), 
                height: getHeight(30),
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgPath,
                    width: getWidth(20), 
                    height: getHeight(20),
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF989CDF),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

               SizedBox(width: getWidth(10)),

              Expanded(
                child: Text(
                  label,
                  style:AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  )
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(11),
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isLast)
          const Divider(
            color: Color(0xFF838283),
            thickness: 0.5,
            height: 1,
          ),
      ],
    );
  }
}