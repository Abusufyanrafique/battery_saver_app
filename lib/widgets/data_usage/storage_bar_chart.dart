import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class StorageBarChart extends StatelessWidget {
  const StorageBarChart({super.key});

  // --- Chart Data (MB values per day 1–30) ---
  static const List<double> _data = [
    130, 220, 160, 500, 150, 170, 140, 160, 130, 380,
    120, 100, 130, 110, 100, 130, 390, 200, 170, 480,
    260, 210, 190, 200, 170, 250, 180, 170, 230, 150,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(160),
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      decoration: BoxDecoration(
      color: AppColors.allscreenBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          // maxY: 550,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF373C62),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Day ${group.x + 1}\n${rod.toY.toInt()} MB',
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
                interval: 250,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('0', style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 11)),
                        Text('MB', style: TextStyle(color: Color(0xFFD9D9D9), fontSize: 10)),
                      ],
                    );
                  }
                  return Text(
                    '${value.toInt()} MB',
                    style: const TextStyle(
                      color: Color(0xFFD9D9D9),
                      fontSize: 11,
                    ),
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
                  final int day = value.toInt() + 1;
                  // Show labels only at 1, 5, 10, 15, 20, 25, 30
                  if ([1, 5, 10, 15, 20, 25, 30].contains(day)) {
                    return Text(
                      '$day',
                      style: const TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 11,
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 250,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFF1E2E45),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_data.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _data[index],
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