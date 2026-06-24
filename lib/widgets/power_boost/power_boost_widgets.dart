import 'package:battery_saver_app/bloc/power_boost/power_boost_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SystemOptimizeWidget extends StatelessWidget {
  const SystemOptimizeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerBoostBloc, PowerBoostState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 8,
            ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.drawerGradient
             
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.appWidgetBorderColor, 
              width: 1
              ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OptimizeRow(
                svgPath: AppIcons.clearram,
                title: AppText.clearram,
                subtitle: AppText.freeupmemorforbatteryperformance,
                badge: state.isLoading ? '...' : state.ramUsedGB,
                isLast: false,
              ),
              _OptimizeRow(
                svgPath: AppIcons.optimizecup,
                title: AppText.optimizeCPU,
                subtitle:AppText.improveprocessorperformance,
                badge: null,
                isLast: false,
              ),
              _OptimizeRow(
                svgPath: AppIcons.closebackgroundapps,
                title: AppText.closeBackgroundApps,
                subtitle: AppText.stoprunningappstospeedupdevice,
                badge: state.isLoading
                    ? '...'
                    : '${state.runningAppsCount} Apps',
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── ROW (same as before, no change needed) ────────────────────────────────
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
              Container(
                width: getWidth(40),
                height: getHeight(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.powerboostcontainercolor,
                  border: Border.all(
                    color: AppColors.appWidgetBorderColor,
                     width: 1.5),
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
              SizedBox(width: getWidth(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w500,
                        color: AppColors.allsmalltextcolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badge != null) ...[
                    Text(
                      badge!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w700,
                        color: AppColors.allsmalltextcolor,
                      ),
                    ),
                     SizedBox(width: getWidth(8)),
                  ],
                  const _GreenCheckIcon(),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: AppColors.powerboostdividercolor,
             thickness: 1,
            height: 1),
      ],
    );
  }
}

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
          color: AppColors.powerboostcolorcheckbox,
           width: 1),
      ),
      child: const Center(
        child: Icon(Icons.check, size: 10, color:AppColors.powerboostcolorcheckbox),
      ),
    );
  }
}