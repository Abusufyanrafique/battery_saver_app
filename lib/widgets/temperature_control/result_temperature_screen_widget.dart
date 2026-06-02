// result_temperature_screen_widget.dart

import 'package:battery_saver_app/bloc/temperature/temperature_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────────────────────
// SCAN TASK MODEL
// ─────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────

class ScanResultWidget extends StatelessWidget {
  const ScanResultWidget({super.key});

  static const List<Map<String, String>> _taskData = [
    {'svgPath': AppIcons.scanningTemperature, 'title': 'Scanning Temperature'},
    {'svgPath': AppIcons.closingHeavyApps,    'title': 'Closing Heavy Apps'},
    {'svgPath': AppIcons.cpuicon,             'title': 'Cooling CPU'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemperatureBloc, TemperatureState>(
      builder: (context, state) {
        final statuses = state.taskStatuses;
        final isDone   = state.coolingStatus == CoolingStatus.done;

        return Column(
          children: [
            // ── Task List Container ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [
                    Color(0xFF232C6D),
                    Color(0xFF1B2153),
                    Color(0xFF13173A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4103AC), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_taskData.length, (i) {
                  return _ScanRow(
                    task: ScanTask(
                      svgPath: _taskData[i]['svgPath']!,
                      title:   _taskData[i]['title']!,
                      status:  statuses[i],
                    ),
                    isLast: i == _taskData.length - 1,
                  );
                }),
              ),
            ),

            // ── Temperature Update Card (done hone pe animate) ──
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: isDone
                  ? _TemperatureResultCard(tempCelsius: state.tempCelsius)
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEMPERATURE RESULT CARD — done hone pe slide in
// ─────────────────────────────────────────────────────────────

class _TemperatureResultCard extends StatefulWidget {
  final double tempCelsius;
  const _TemperatureResultCard({required this.tempCelsius});

  @override
  State<_TemperatureResultCard> createState() => _TemperatureResultCardState();
}

class _TemperatureResultCardState extends State<_TemperatureResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>    _fadeAnim;
  late Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim  = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B2153), Color(0xFF13173A)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3DDC84), width: 1.2),
          ),
          child: Row(
            children: [
              // Green check circle
              Container(
                width: getWidth(40),
                height: getHeight(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF232C6D),
                  border: Border.all(color: const Color(0xFF3DDC84), width: 1.5),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF3DDC84),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Cooled Successfully',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize:   getFont(12),
                        fontWeight: FontWeight.w600,
                        color:      const Color(0xFF3DDC84),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Current Temperature: ${widget.tempCelsius.toStringAsFixed(1)}°C',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(10),
                        color:    Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SCAN ROW
// ─────────────────────────────────────────────────────────────

class _ScanRow extends StatelessWidget {
  final ScanTask task;
  final bool isLast;

  const _ScanRow({required this.task, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              _IconCircle(svgPath: task.svgPath, status: task.status),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize:   getFont(14),
                        fontWeight: FontWeight.w500,
                        color:      Colors.white,
                      ),
                    ),
                    // Progress bar — sirf inProgress pe dikhao
                    if (task.status == TaskStatus.inProgress) ...[
                      const SizedBox(height: 6),
                      _AnimatedProgressBar(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusWidget(status: task.status),
            ],
          ),
        ),
        if (!isLast)
          const Divider(color: Color(0xFF838283), height: 1),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ANIMATED PROGRESS BAR
// ─────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatefulWidget {
  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 2),
    )..repeat(); // loop karta raho jab tak inProgress hai
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:            _anim.value,
            minHeight:        3,
            backgroundColor:  const Color(0xFF343964),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9A3CFF)),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ICON CIRCLE — spinning loader when inProgress
// ─────────────────────────────────────────────────────────────

class _IconCircle extends StatefulWidget {
  final String svgPath;
  final TaskStatus status;

  const _IconCircle({required this.svgPath, required this.status});

  @override
  State<_IconCircle> createState() => _IconCircleState();
}

class _IconCircleState extends State<_IconCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 1),
    );
    if (widget.status == TaskStatus.inProgress) {
      _spinController.repeat();
    }
  }

  @override
  void didUpdateWidget(_IconCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == TaskStatus.inProgress) {
      _spinController.repeat();
    } else {
      _spinController.stop();
      _spinController.reset();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInProgress = widget.status == TaskStatus.inProgress;
    final isDone       = widget.status == TaskStatus.done;

    return Container(
      width:  getWidth(40),
      height: getHeight(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF232C6D),
        border: Border.all(
          color: isDone
              ? const Color(0xFF3DDC84)
              : isInProgress
                  ? const Color(0xFF9A3CFF)
                  : const Color(0xFF4103AC),
          width: 1.5,
        ),
      ),
      child: Center(
        child: isInProgress
            // Spinning loader
            ? RotationTransition(
                turns: _spinController,
                child: SvgPicture.asset(
                  widget.svgPath,
                  width:  18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9A3CFF),
                    BlendMode.srcIn,
                  ),
                ),
              )
            // Done ya Pending — static icon
            : SvgPicture.asset(
                widget.svgPath,
                width:  20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDone
                      ? const Color(0xFF3DDC84)
                      : const Color(0xFF6A6FCC),
                  BlendMode.srcIn,
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STATUS WIDGET
// ─────────────────────────────────────────────────────────────

class _StatusWidget extends StatelessWidget {
  final TaskStatus status;
  const _StatusWidget({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TaskStatus.done:
        return const Icon(Icons.check, color: Color(0xFF3DDC84));

      case TaskStatus.inProgress:
        return const SizedBox(
          width:  16,
          height: 16,
          child:  CircularProgressIndicator(
            strokeWidth: 2,
            color:       Color(0xFF9A3CFF),
          ),
        );

      case TaskStatus.pending:
        return Text(
          'Pending',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(11),
            color:    const Color(0xFF898EE4),
          ),
        );
    }
  }
}