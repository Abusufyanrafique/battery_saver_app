// battery_usage_graph_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

enum GraphFilter { h24, d7, d30 }

class BatteryUsageGraphWidget extends StatefulWidget {
  const BatteryUsageGraphWidget({super.key});

  @override
  State<BatteryUsageGraphWidget> createState() =>
      _BatteryUsageGraphWidgetState();
}

class _BatteryUsageGraphWidgetState extends State<BatteryUsageGraphWidget> {
  GraphFilter _selected = GraphFilter.h24;

  final Map<GraphFilter, List<FlSpot>> _data = {
    GraphFilter.h24: const [
      FlSpot(0, 95), FlSpot(1, 88), FlSpot(2, 80), FlSpot(3, 72),
      FlSpot(4, 60), FlSpot(5, 55), FlSpot(6, 50), FlSpot(7, 48),
      FlSpot(8, 50), FlSpot(9, 28), FlSpot(10, 55), FlSpot(11, 72),
    ],
    GraphFilter.d7: const [
      FlSpot(0, 80), FlSpot(1, 65), FlSpot(2, 50), FlSpot(3, 40),
      FlSpot(4, 60), FlSpot(5, 55), FlSpot(6, 70),
    ],
    GraphFilter.d30: const [
      FlSpot(0, 90), FlSpot(1, 75), FlSpot(2, 60), FlSpot(3, 80),
      FlSpot(4, 55), FlSpot(5, 40), FlSpot(6, 65), FlSpot(7, 70),
      FlSpot(8, 50), FlSpot(9, 72),
    ],
  };

  final Map<GraphFilter, List<String>> _xLabels = {
    GraphFilter.h24: const ['12 AM', '4 AM', '8 AM', '12 AM', '4 AM', '8 AM', '12 AM'],
    GraphFilter.d7:  const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    GraphFilter.d30: const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10'],
  };

  @override
  Widget build(BuildContext context) {
    final spots  = _data[_selected]!;
    final labels = _xLabels[_selected]!;

    return SizedBox(
      height: getHeight(190),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(10),
          vertical: getHeight(8),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3440A0),
              Color(0xFF232C6D),
              Color(0xFF1B2153),
              Color(0xFF13173A),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF4103AC), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── HEADER ─────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Battery Usage Graph',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(13),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(getWidth(2)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111434),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FilterTab(
                        label: '24H',
                        isSelected: _selected == GraphFilter.h24,
                        onTap: () => setState(() => _selected = GraphFilter.h24),
                      ),
                      _FilterTab(
                        label: '7D',
                        isSelected: _selected == GraphFilter.d7,
                        onTap: () => setState(() => _selected = GraphFilter.d7),
                      ),
                      _FilterTab(
                        label: '30D',
                        isSelected: _selected == GraphFilter.d30,
                        onTap: () => setState(() => _selected = GraphFilter.d30),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: getHeight(4)),

            // ───────── CHART ─────────
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  clipData: const FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 25,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.07),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (_) => FlLine(
                      color: Colors.white.withOpacity(0.07),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: getWidth(30),
                        getTitlesWidget: (value, _) => Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            fontSize: getFont(8),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: getHeight(22),
                        interval: _selected == GraphFilter.h24
                            ? (spots.length / (labels.length - 1))
                            : 1,
                        getTitlesWidget: (value, meta) {
                          if (_selected == GraphFilter.h24) {
                            final step =
                                (spots.length - 1) / (labels.length - 1);
                            for (int i = 0; i < labels.length; i++) {
                              if ((value - i * step).abs() < 0.1) {
                                return Padding(
                                  padding: EdgeInsets.only(top: getHeight(4),right: 10),
                                  child: Text(
                                    labels[i],
                                    style: TextStyle(
                                      fontSize: getFont(8),
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          }
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: getHeight(4)),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  fontSize: getFont(8),
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: const Color(0xFFAA44FF),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, _) => spot == spots.last,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 3,
                          color: const Color(0xFFFF2D9B),
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF7B2FFF).withOpacity(0.5),
                            const Color(0xFF3D1A8E).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFFFF2D9B),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()}%',
                            const TextStyle(
                              fontFamily: '',
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: getHeight(6)),

            // ───────── LEGEND ─────────
            Row(
              children: [
                _LegendDot(color: const Color(0xFF9A3CFF)),
                SizedBox(width: getWidth(5)),
                Text(
                  'Battery Level',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: getFont(10),
                    color:AppColors.allsmalltextcolor,
                  ),
                ),
                SizedBox(width: getWidth(12)),
                _LegendDot(color: const Color(0xFF3069F7)),
                SizedBox(width: getWidth(5)),
                Text(
                  'Charging',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(10),
                    fontWeight: FontWeight.w500,
                    color:AppColors.allsmalltextcolor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FILTER TAB
// ─────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(14),
          vertical: getHeight(7),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF19BD),
                    Color(0xFF0E112F),
                    Color(0xFFFF19BD),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style:AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(10),
         color: isSelected ? Colors.white : Color(0xFF9A3CFF),

          )
            
          
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// LEGEND DOT
// ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(10),
      height: getWidth(10),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}