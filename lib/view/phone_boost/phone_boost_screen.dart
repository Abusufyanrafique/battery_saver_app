import 'package:battery_saver_app/bloc/phone_boost/phone_boost_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/phone_boost/phone_boost_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneBoostScreen extends StatelessWidget {
  const PhoneBoostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneBoostBloc()..add(const PhoneBoostStarted()),
      child: const _PhoneBoostView(),
    );
  }
}

class _PhoneBoostView extends StatelessWidget {
  const _PhoneBoostView();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),
      appBar: CustomAppBar(title: AppText.phoneBoost),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1633),
              Color(0xFF0B122B),
              Color(0xFF070C1F),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<PhoneBoostBloc, PhoneBoostState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ───── GAUGE IMAGE ─────
                    _BoostGauge(percent: state.memoryUsedPercent),

                    SizedBox(height: getHeight(16)),

                    // ───── MEMORY USED LABEL ─────
                    Center(
                      child: Text(
                        AppText.memoryUsed,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(14),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // ───── RAM detail (used / total) ─────
                    if (!state.isLoading)
                      Center(
                        child: Text(
                          '${state.usedRamMb} MB / ${state.totalRamMb} MB',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: getFont(12),
                            color: const Color(0xFF55D0FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    SizedBox(height: getHeight(80)),

                    // ───── HEADER ROW ─────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppText.runningProcesses,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: getFont(20),
                            color: const Color(0xFFD9D9D9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(
                            begin: 0,
                            end: state.topApps.length,
                          ),
                          duration: const Duration(milliseconds: 600),
                          builder: (_, val, __) => Text(
                            '$val',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: getFont(16),
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(12)),

                    // ───── LIST ─────
                    state.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF55D0FF),
                              ),
                            ),
                          )
                        : state.status == PhoneBoostStatus.boosted
                            ? Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF55D0FF),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Memory Optimized!',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontSize: getFont(16),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : PhoneBoostListWidget(apps: state.topApps),

                    SizedBox(height: getHeight(20)),

                    // ───── BOOST BUTTON ─────
                    CleanButtonWidget(
                      text: state.isBoosting
                          ? 'Boosting...'
                          : state.status == PhoneBoostStatus.boosted
                              ? 'Boosted!'
                              : AppText.boostNow1,
                      onPressed: state.isBoosting
                          ? null
                          : () => context
                              .read<PhoneBoostBloc>()
                              .add(const PhoneBoostRequested()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gauge widget — rocket image + live % overlay
// ─────────────────────────────────────────────────────────────────────────────
class _BoostGauge extends StatelessWidget {
  final int percent;
  const _BoostGauge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(200),
      width: double.infinity,
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: percent),
        duration: const Duration(milliseconds: 800),
        builder: (_, animatedVal, __) {
          final arcValue = (animatedVal / 100).clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(getHeight(180), getHeight(180)),
              ),
              Image.asset(
                "assets/images/phone_boost/rooket.png",
                height: getHeight(200),
                fit: BoxFit.contain,
              ),
              Positioned(
                bottom: getHeight(10),
                child: Text(
                  '$animatedVal%',
                  style: TextStyle(
                    fontSize: getFont(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double value;
  final Color color;
  const _ArcPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect, -3.14159, 3.14159, false,
      Paint()
        ..color = Colors.white12
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    canvas.drawArc(
      rect, -3.14159, 3.14159 * value, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect, -3.14159, 3.14159 * value, false,
      Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.value != value || old.color != color;
}