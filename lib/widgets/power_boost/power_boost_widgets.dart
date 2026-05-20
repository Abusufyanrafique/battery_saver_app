import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SystemOptimizeWidget extends StatelessWidget {
  const SystemOptimizeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:  [
          _OptimizeRow(
            svgPath: AppIcons.clearram,
            title: 'Clear RAM',
            subtitle: 'Free up memory for\nbattery performance',
            badge: '1.2 GB',
            isLast: false,
          ),
          _OptimizeRow(
            svgPath: AppIcons.optimizecup,
            title: 'Optimize CPU',
            subtitle: 'Improve processor\nperformance',
            badge: null,
            isLast: false,
          ),
          _OptimizeRow(
            svgPath:AppIcons.closebackgroundapps,
            title: 'Close Background Apps',
            subtitle: 'Stop running apps to\nspeed up device',
            badge: '12 Apps',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─── ROW ─────────────────────────────────────────────

class _OptimizeRow extends StatelessWidget {
  final String svgPath;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isLast;

  const _OptimizeRow({
    required this.svgPath,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SVG ICON
              Container(
                width: getWidth(40),
                height: getHeight(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF232C6D),
                  border: Border.all(
                    color: const Color(0xFF4103AC),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgPath,
                    width: getWidth(15),
                    height: getHeight(15),
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF8A8FCC),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

               SizedBox(width:getWidth(16)),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(12),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD9D9D9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // BADGE + CHECK
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badge != null) ...[
                    Text(
                      badge!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF55D0FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const _GreenCheckIcon(),
                ],
              ),
            ],
          ),
        ),

        if (!isLast)
          const Divider(
            color: Color(0xFF838283),
            thickness: 1,
            height: 1,
          ),
      ],
    );
  }
}

// ─── CHECK ICON ─────────────────────────────────────

class _GreenCheckIcon extends StatelessWidget {
  const _GreenCheckIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(16),
      height: getHeight(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF3DDC84),
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.check,
          size: 10,
          color: Color(0xFF3DDC84),
        ),
      ),
    );
  }
}