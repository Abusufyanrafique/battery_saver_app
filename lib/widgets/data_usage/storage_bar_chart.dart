import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StorageBarChart extends StatelessWidget {
  final List<double>? data;
  final UsagePeriod period;

  const StorageBarChart({
    super.key,
    this.data,
    this.period = UsagePeriod.today,
  });

  // Default static data — jab real data na ho
  static const List<double> _defaultData = [
    130, 220, 160, 500, 150, 170, 140, 160, 130, 380,
    120, 100, 130, 110, 100, 130, 390, 200, 170, 480,
    260, 210, 190, 200,
  ];

  List<double> get _chartData => (data != null && data!.isNotEmpty)
      ? data!
      : _defaultData;

  @override
  Widget build(BuildContext context) {
    final chartValues = _chartData;
    final maxY = chartValues.reduce((a, b) => a > b ? a : b) * 1.2;
    final interval = (maxY / 2).ceilToDouble();

    return Container(
      height: getHeight(160),
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.allscreenBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF373C62),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = period == UsagePeriod.today
                    ? 'Hour ${group.x + 1}'
                    : 'Day ${group.x + 1}';
                return BarTooltipItem(
                  '$label\n${rod.toY.toInt()} MB',
                  const TextStyle(
                    color: Color(0xFF5BC8F5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: interval > 0 ? interval : 250,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('0',
                            style: TextStyle(
                                color: Color(0xFFD9D9D9), fontSize: 11)),
                        Text('MB',
                            style: TextStyle(
                                color: Color(0xFFD9D9D9), fontSize: 10)),
                      ],
                    );
                  }
                  return Text(
                    '${value.toInt()} MB',
                    style: const TextStyle(
                        color: Color(0xFFD9D9D9), fontSize: 11),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt() + 1;
                  final labels = period == UsagePeriod.today
                      ? [1, 6, 12, 18, 24]
                      : [1, 5, 10, 15, 20, 25, 30];
                  if (labels.contains(index)) {
                    return Text(
                      '$index',
                      style: const TextStyle(
                          color: Color(0xFFD9D9D9), fontSize: 11),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval > 0 ? interval : 250,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0xFF1E2E45),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(chartValues.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: chartValues[index],
                  color: const Color(0xFF55D0FF),
                  width: 4,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}