import 'package:battery_saver_app/bloc/power_boost/power_boost_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart'; 
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResultPowerBoostWidget extends StatelessWidget {
  const ResultPowerBoostWidget({super.key});

  String _badgeText(BoostStep step, PowerBoostState state) {
    final status = state.stepStatuses[step]!;
    switch (step) {
      case BoostStep.clearRam:
        return status == StepStatus.done ? state.ramUsedGB : '—';
      case BoostStep.optimizeCpu:
        return status == StepStatus.done ? 'Done' : '—';
      case BoostStep.closeApps:
        return status == StepStatus.done
            ? '${state.runningAppsCount} Apps'
            : '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerBoostBloc, PowerBoostState>(
      builder: (context, state) {
        final steps = [
          (
            BoostStep.clearRam,
             AppIcons.clearram, AppText.clearRAM,
             ),
          (BoostStep.optimizeCpu,
           AppIcons.optimizecup, AppText.optimizeCPUtext),
          (
            BoostStep.closeApps, 
            AppIcons.closebackgroundapps,
             AppText.closeBackgroundAppstext),
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 8
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
              width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(steps.length, (index) {
              final (step, icon, title) = steps[index];
              final status = state.stepStatuses[step]!;
              return _StatusRow(
                svgPath: icon,
                title: title,
                badge: _badgeText(step, state),
                status: status,
                isLast: index == steps.length - 1,
              );
            }),
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String svgPath;
  final String title;
  final String badge;
  final StepStatus status;
  final bool isLast;

  const _StatusRow({
    required this.svgPath,
    required this.title,
    required this.badge,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: getWidth(40),
                height: getHeight(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF232C6D),
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
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(14),
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    badge,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w700,
                      color: AppColors.checkiconcolor,
                    ),
                  ),
                   SizedBox(width: getWidth(10)),
                  _StatusIcon(status: status),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(color: Color(0xFF838283), thickness: 1, height: 1),
      ],
    );
  }
}

class _StatusIcon extends StatefulWidget {
  final StepStatus status;
  const _StatusIcon({required this.status});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.status) {
      case StepStatus.done:
        return Container(
          width: getWidth(16),
          height: getHeight(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.checkboxcolor, 
              width: 2),
          ),
          child: const Icon(
            Icons.check,
             size: 10,
             color: Color(0xFFFFCC00)),
        );
      case StepStatus.inProgress:
        return SizedBox(
          width: getWidth(16),
          height: getHeight(16),
          child: RotationTransition(
            turns: _controller,
            child: CustomPaint(
              painter: _ArcPainter(color: const Color(0xFF7B7FFF)),
            ),
          ),
        );
      case StepStatus.pending:
        return SizedBox(
          width: getWidth(16),
          height: getHeight(16),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF838283), width: 1.5),
            ),
          ),
        );
    }
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  const _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawArc(rect, 0, 4.5, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}