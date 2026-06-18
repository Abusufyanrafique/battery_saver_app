import 'package:battery_saver_app/bloc/cpu_cooler/cpu_cooler_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/cpu_cooler/cpu_cooler_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CpuCoolerScreen extends StatelessWidget {
  const CpuCoolerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CpuCoolerBloc()..add(const CpuCoolerStartMonitoring()),
      child: const _CpuCoolerView(),
    );
  }
}

class _CpuCoolerView extends StatefulWidget {
  const _CpuCoolerView();

  @override
  State<_CpuCoolerView> createState() => _CpuCoolerViewState();
}

class _CpuCoolerViewState extends State<_CpuCoolerView> {
  @override
  void dispose() {
    context.read<CpuCoolerBloc>().add(const CpuCoolerStopMonitoring());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: CustomAppBar(title: AppText.cooler),
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
          child: BlocBuilder<CpuCoolerBloc, CpuCoolerState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getHeight(30)),

                    // ───── CIRCULAR GAUGE ─────
                    _CpuGauge(temperature: state.temperature),

                    SizedBox(height: getHeight(40)),

                    // ───── STATUS TEXT ─────
                    Center(
                      child: state.isCoolingDown
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 SizedBox(
                                  width: getWidth(14),
                                  height: getHeight(14),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF55D0FF),
                                  ),
                                ),
                                 SizedBox(width: getWidth(8)),
                                Text(
                                  state.statusMessage,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: getFont(14),
                                    color: const Color(0xFF55D0FF),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              state.statusMessage,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: getFont(14),
                                color: state.status == CpuCoolerStatus.cooled
                                    ? Colors.greenAccent
                                    : const Color(0xFF55D0FF),
                              ),
                            ),
                    ),

                    SizedBox(height: getHeight(140)),

                    // ───── CPU INFO WIDGET ─────
                    CpuCoolerWidget(
                      items: [
                        CpuInfoItem(
                        imagePath: AppImages.cpuusage,
                        title: "CPU Usage",
                        value: state.cpuUsage == 0.0
                        ? '--'
                       : '${state.cpuUsage.toStringAsFixed(1)}%',
),
                        CpuInfoItem(
                          imagePath: AppImages.cpumangerimage,
                          title: "Running Apps",
                         
                          value: state.runningApps == 0
                              ? '--'
                              : '${state.runningApps}',
                        ),
                        CpuInfoItem(
                          imagePath: AppImages.temperature,
                          title: "Temperature",
                          value: state.temperature == 0.0
                              ? '--'
                              : '${state.temperature.toStringAsFixed(1)}°C',
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(80)),

                    // ───── BUTTON ─────
                    CleanButtonWidget(
                      text: state.isCoolingDown
                          ? 'Cooling...'
                          : AppText.coolDown,
                      onPressed: state.isCoolingDown
                          ? null
                          : () => context
                              .read<CpuCoolerBloc>()
                              .add(const CpuCoolerCoolDownRequested()),
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
// Animated CPU gauge
// ─────────────────────────────────────────────────────────────────────────────
class _CpuGauge extends StatelessWidget {
  final double temperature;

  const _CpuGauge({required this.temperature});

  Color get _tempColor {
    if (temperature == 0) return const Color(0xFF55D0FF);
    if (temperature < 50) return const Color(0xFF00E5FF);
    if (temperature < 70) return const Color(0xFFFFAA00);
    return const Color(0xFFFF4444);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            // size: Size(getHeight(180), getHeight(180)),
            // painter: _GaugePainter(
            //   value: temperature == 0
            //       ? 0.38
            //       : (temperature / 100).clamp(0.0, 1.0),
            //   color: _tempColor,
            // ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/phone_boost/whiteimage.png",
                width: getHeight(200),
                height: getHeight(200),
                errorBuilder: (_, __, ___) => Icon(
                  Icons.memory,
                  size: getHeight(48),
                  color: const Color(0xFF55D0FF),
                ),
              ),
              //  SizedBox(height:getHeight(6) ),
              Text(
                temperature == 0
                    ? '--°C'
                    : '${temperature.toStringAsFixed(0)}°C',
                style: TextStyle(
                  fontSize: getFont(28),
                  fontWeight: FontWeight.bold,
                  color: _tempColor,
                ),
              ),
              Text(
                'CPU Temperature',
                style: TextStyle(
                  fontSize: getFont(11),
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class _GaugePainter extends CustomPainter {
//   final double value;
//   final Color color;

//   _GaugePainter({required this.value, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2 - 8;

//     // Track
//     canvas.drawCircle(
//       center,
//       radius,
//       Paint()
//         ..color = Colors.white12
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 8,
//     );

//     // Arc
//     final rect = Rect.fromCircle(center: center, radius: radius);
//     canvas.drawArc(
//       rect,
//       -3.14 / 2,
//       2 * 3.14159 * value,
//       false,
//       Paint()
//         ..color = color
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 8
//         ..strokeCap = StrokeCap.round,
//     );

//     // Outer glow ring
//     canvas.drawCircle(
//       center,
//       radius + 12,
//       Paint()
//         ..color = color.withOpacity(0.15)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 20,
//     );
//   }

//   @override
//   bool shouldRepaint(_GaugePainter old) =>
//       old.value != value || old.color != color;
// }