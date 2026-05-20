// ─── IMPORTS ──────────────────────────────────────────────────────────────────
import 'dart:math' as math;

import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── Status Enum ──────────────────────────────────────────────────────────────
enum TaskStatus { done, inProgress, pending }

// ─── Data Model ───────────────────────────────────────────────────────────────
class ScanTask {
  final String svgPath;
  final String title;
  final TaskStatus status;

  const ScanTask({
    required this.svgPath,
    required this.title,
    required this.status,
  });
}

// ─── Main Widget ──────────────────────────────────────────────────────────────
class ScanResultWidget extends StatelessWidget {
  const ScanResultWidget({super.key});

  static  List<ScanTask> tasks = [
    ScanTask(
      svgPath: AppIcons.scanningTemperature,
      title: 'Scanning Temperature',
      status: TaskStatus.done,
    ),
    ScanTask(
      svgPath: AppIcons.closingHeavyApps,
      title: 'Closing Heavy Apps',
      status: TaskStatus.inProgress,
    ),
    ScanTask(
      svgPath: AppIcons.cpuicon,
      title: 'Cooling CPU',
      status: TaskStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tasks.length, (i) {
          return _ScanRow(
            task: tasks[i],
            isLast: i == tasks.length - 1,
          );
        }),
      ),
    );
  }
}

// ─── Scan Row ─────────────────────────────────────────────────────────────────
class _ScanRow extends StatelessWidget {
  final ScanTask task;
  final bool isLast;

  const _ScanRow({
    required this.task,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SVG Icon Circle
              _IconCircle(
                svgPath: task.svgPath,
                status: task.status,
              ),

              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              // Status Widget
              _StatusWidget(status: task.status),
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

// ─── Icon Circle ──────────────────────────────────────────────────────────────
class _IconCircle extends StatelessWidget {
  final String svgPath;
  final TaskStatus status;

  const _IconCircle({
    required this.svgPath,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = status == TaskStatus.done;

    return Container(
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
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            isDone
                ? const Color(0xFF6A6FCC)
                : const Color(0xFF8A8FCC),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

// ─── Status Widget ────────────────────────────────────────────────────────────
class _StatusWidget extends StatelessWidget {
  final TaskStatus status;

  const _StatusWidget({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TaskStatus.done:
        return const _DoneIcon();

      case TaskStatus.inProgress:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'In Progress',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6E74E6),
              ),
            ),

            const SizedBox(width: 8),

            const _SpinnerIcon(),
          ],
        );

      case TaskStatus.pending:
        return Text(
          'Pending',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(12),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF898EE4),
          ),
        );
    }
  }
}

// ─── Done Icon ────────────────────────────────────────────────────────────────
class _DoneIcon extends StatelessWidget {
  const _DoneIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(16),
      height: getHeight(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF55D0FF),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.check,
        size: 10,
        color: Color(0xFF55D0FF),
      ),
    );
  }
}

// ─── Spinner Icon ─────────────────────────────────────────────────────────────
class _SpinnerIcon extends StatefulWidget {
  const _SpinnerIcon();

  @override
  State<_SpinnerIcon> createState() => _SpinnerIconState();
}

class _SpinnerIconState extends State<_SpinnerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return CustomPaint(
          size: const Size(16, 16),
          painter: _SpinnerPainter(
            progress: _ctrl.value,
            color: const Color(0xFF484CAB),
          ),
        );
      },
    );
  }
}

// ─── Spinner Painter ──────────────────────────────────────────────────────────
class _SpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Arc
    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = 2 * math.pi * progress - math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      math.pi * 1.2,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) {
    return old.progress != progress;
  }
}