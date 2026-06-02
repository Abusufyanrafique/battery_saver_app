// system_usage_widget.dart

import 'dart:math';
import 'package:battery_saver_app/bloc/battery_status_cubit_usage/system_usage_cubit.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class SystemUsageItem {
  final String imagepath;
  final Color iconColor;
  final String label;
  final String value;
  final List<Color> chartColors;

  const SystemUsageItem({
    required this.iconColor,
    required this.label,
    required this.value,
    required this.chartColors,
    required this.imagepath,
  });
}

// ─────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────

class SystemUsageWidget extends StatelessWidget {
  const SystemUsageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SystemUsageCubit()..loadSystemUsage(),
      child: const _SystemUsageBody(),
    );
  }
}

class _SystemUsageBody extends StatelessWidget {
  const _SystemUsageBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemUsageCubit, SystemUsageState>(
      builder: (context, state) {

        // ── Fallback / Loading values ──
        String cpuVal    = '—';
        String tempVal   = '—';
        String ramVal    = '—';
        String cyclesVal = '—';

        if (state is SystemUsageLoaded) {
          cpuVal    = state.data.cpuUsageFormatted;
          tempVal   = state.data.temperatureFormatted;
          ramVal    = state.data.ramUsageFormatted;
          cyclesVal = '${state.data.chargeCycles}';
        }

        final List<SystemUsageItem> items = [
          SystemUsageItem(
            imagepath:   AppImages.datausagecpu,
            iconColor:   const Color(0xFF9A3CFF),
            label:       'CPU Usage',
            value:       cpuVal,
            chartColors: [const Color(0xFF9A3CFF), const Color(0xFF4103AC)],
          ),
          SystemUsageItem(
            imagepath:   AppImages.datausagetemp,
            iconColor:   const Color(0xFFE53935),
            label:       'Temperature',
            value:       tempVal,
            chartColors: [const Color(0xFFE53935), const Color(0xFF7B1FA2)],
          ),
          SystemUsageItem(
            imagepath:   AppImages.datausageram,
            iconColor:   const Color(0xFF1E88E5),
            label:       'RAM Usage',
            value:       ramVal,
            chartColors: [const Color(0xFF1E88E5), const Color(0xFF0D47A1)],
          ),
          SystemUsageItem(
            imagepath:   AppImages.time,
            iconColor:   const Color(0xFFE040FB),
            label:       'Charge Cycles',
            value:       cyclesVal,
            chartColors: [const Color(0xFFE040FB), const Color(0xFF9A3CFF)],
          ),
        ];

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(14),
            vertical:   getHeight(3),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end:   Alignment.bottomCenter,
              colors: [
                Color(0xFF3440A0),
                Color(0xFF232C6D),
                Color(0xFF1B2153),
                Color(0xFF13173A),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4103AC), width: 1),
          ),
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: state is SystemUsageLoading ? 0.3 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Heading ──
                    Text(
                      AppText.systemUsage,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize:   getFont(12),
                        fontWeight: FontWeight.w600,
                        color:      Colors.white,
                      ),
                    ),
                    SizedBox(height: getHeight(5)),

                    // ── Cards Row ──
                    Row(
                      children: List.generate(items.length, (index) {
                        final item   = items[index];
                        final isLast = index == items.length - 1;
                        return Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _SystemCard(item: item)),
                              if (!isLast) SizedBox(width: getWidth(8)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ── Loading Indicator ──
              if (state is SystemUsageLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9A3CFF),
                      strokeWidth: 2,
                    ),
                  ),
                ),

              // ── Error + Retry ──
              if (state is SystemUsageError)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (state as SystemUsageError).message,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: () => context.read<SystemUsageCubit>().loadSystemUsage(),
                          icon: const Icon(Icons.refresh_rounded, color: Colors.redAccent, size: 22),
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

// ─────────────────────────────────────────────────────────────
// SYSTEM CARD
// ─────────────────────────────────────────────────────────────

class _SystemCard extends StatelessWidget {
  final SystemUsageItem item;
  const _SystemCard({required this.item});

  List<FlSpot> _generateSpots() {
    final rand = Random(item.label.hashCode);
    return List.generate(
      12,
      (i) => FlSpot(i.toDouble(), 20 + rand.nextDouble() * 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpots();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B235C),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF4103AC), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon + Label + Value ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              getWidth(8), getHeight(2), getWidth(8), getHeight(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  item.imagepath,
                  width:  getWidth(16),
                  height: getWidth(16),
                  color:  item.iconColor,
                ),
                SizedBox(height: getHeight(6)),
                Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize:   getFont(8),
                    fontWeight: FontWeight.w400,
                    color:      AppColors.allsmalltextcolor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: getHeight(2)),
                Text(
                  item.value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize:   getFont(12),
                    fontWeight: FontWeight.w600,
                    color:      Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Spark Line Chart ──
          SizedBox(
            height: getHeight(20),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                clipData:   const FlClipData.all(),
                gridData:   const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots:            spots,
                    isCurved:         true,
                    curveSmoothness:  0.2,
                    barWidth:         1.5,
                    isStrokeCapRound: true,
                    dotData:          const FlDotData(show: false),
                    color:            item.chartColors.first,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                        colors: [
                          item.chartColors.first.withOpacity(0.4),
                          item.chartColors.last.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}