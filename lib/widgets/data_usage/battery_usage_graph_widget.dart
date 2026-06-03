import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum GraphFilter { h24, d7, d30 }

class BatteryUsageGraphWidget extends StatefulWidget {
  const BatteryUsageGraphWidget({super.key});

  @override
  State<BatteryUsageGraphWidget> createState() =>
      _BatteryUsageGraphWidgetState();
}

class _BatteryUsageGraphWidgetState extends State<BatteryUsageGraphWidget> {
  GraphFilter _selected = GraphFilter.h24;

  // ── Filter history list by selected range
  List<BatteryReading> _filterHistory(
    List<BatteryReading> history,
    GraphFilter filter,
  ) {
    final now = DateTime.now();
    final Duration range;
    switch (filter) {
      case GraphFilter.h24:
        range = const Duration(hours: 24);
        break;
      case GraphFilter.d7:
        range = const Duration(days: 7);
        break;
      case GraphFilter.d30:
        range = const Duration(days: 30);
        break;
    }
    final cutoff = now.subtract(range);
    return history.where((r) => r.time.isAfter(cutoff)).toList();
  }

  // ── Convert BatteryReading list → FlSpot list
  List<FlSpot> _toSpots(List<BatteryReading> readings) {
    if (readings.isEmpty) return [const FlSpot(0, 0)];
    final first = readings.first.time.millisecondsSinceEpoch.toDouble();
    return readings.map((r) {
      final x = (r.time.millisecondsSinceEpoch.toDouble() - first) / 60000; // minutes
      return FlSpot(x, r.level.toDouble());
    }).toList();
  }

  // ── Bottom axis labels
  Widget _bottomLabel(double value, List<BatteryReading> filtered) {
    if (filtered.isEmpty) return const SizedBox.shrink();

    final first = filtered.first.time.millisecondsSinceEpoch.toDouble();
    final last = filtered.last.time.millisecondsSinceEpoch.toDouble();
    final totalMinutes = (last - first) / 60000;
    final step = totalMinutes / 4; // 5 labels

    String label = '';
    for (int i = 0; i <= 4; i++) {
      if ((value - i * step).abs() < step * 0.15) {
        final ms = first + i * step * 60000;
        final dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
        switch (_selected) {
          case GraphFilter.h24:
            label =
                '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            break;
          case GraphFilter.d7:
            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            label = days[dt.weekday - 1];
            break;
          case GraphFilter.d30:
            label = '${dt.day}/${dt.month}';
            break;
        }
        break;
      }
    }

    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: getHeight(4)),
      child: Text(
        label,
        style: TextStyle(fontSize: getFont(7), color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatterySaverBloc, BatterySaverState>(
      buildWhen: (prev, curr) => prev.batteryHistory != curr.batteryHistory,
      builder: (context, state) {
        final filtered = _filterHistory(state.batteryHistory, _selected);
        final spots = _toSpots(filtered);
        final maxX = spots.last.x;
        final interval = maxX > 0 ? maxX / 4 : 1;

        return SizedBox(
          height: getHeight(178),
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
                // ── HEADER
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
                            onTap: () =>
                                setState(() => _selected = GraphFilter.h24),
                          ),
                          _FilterTab(
                            label: '7D',
                            isSelected: _selected == GraphFilter.d7,
                            onTap: () =>
                                setState(() => _selected = GraphFilter.d7),
                          ),
                          _FilterTab(
                            label: '30D',
                            isSelected: _selected == GraphFilter.d30,
                            onTap: () =>
                                setState(() => _selected = GraphFilter.d30),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: getHeight(4)),

                // ── CHART
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No data yet',
                            style: TextStyle(
                              color: Color(0xFF4103AC),
                              fontSize: getFont(11),
                            ),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 100,
                            minX: 0,
                            maxX: maxX == 0 ? 1 : maxX,
                            clipData: const FlClipData.all(),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              drawHorizontalLine: true,
                              horizontalInterval: 25,
                              verticalInterval:
                                  interval > 0 ? interval.toDouble() : 1,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: Color(0xFF4103AC),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (_) => FlLine(
                                color: Color(0xFF4103AC),
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
                                  interval: interval > 0 ? interval.toDouble() : 1.0,
                                  getTitlesWidget: (value, meta) =>
                                      _bottomLabel(value, filtered),
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
                                  checkToShowDot: (spot, _) =>
                                      spot == spots.last,
                                  getDotPainter: (spot, _, __, ___) =>
                                      FlDotCirclePainter(
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
                                getTooltipColor: (_) =>
                                    const Color(0xFFFF2D9B),
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      '${spot.y.toInt()}%',
                                      const TextStyle(
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

                // ── LEGEND
                Row(
                  children: [
                    _LegendDot(color: const Color(0xFF9A3CFF)),
                    SizedBox(width: getWidth(5)),
                    Text(
                      'Battery Level',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: getFont(10),
                        color: AppColors.allsmalltextcolor,
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
                        color: AppColors.allsmalltextcolor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── FILTER TAB (same as before)
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
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(10),
            color: isSelected ? Colors.white : const Color(0xFF9A3CFF),
          ),
        ),
      ),
    );
  }
}

// ── LEGEND DOT (same as before)
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