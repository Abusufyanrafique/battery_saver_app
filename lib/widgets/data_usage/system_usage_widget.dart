// system_usage_widget.dart

import 'dart:math';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class SystemUsageItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final List<Color> chartColors;

  const SystemUsageItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.chartColors,
  });
}

// ─────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────

class SystemUsageWidget extends StatelessWidget {
  final String cpuUsage;
  final String temperature;
  final String ramUsage;
  final int chargeCycles;

  const SystemUsageWidget({
    super.key,
    this.cpuUsage = '32%',
    this.temperature = '36°C',
    this.ramUsage = '68%',
    this.chargeCycles = 142,
  });

  @override
  Widget build(BuildContext context) {
    final List<SystemUsageItem> items = [
      SystemUsageItem(
        icon: Icons.memory_rounded,
        iconColor: const Color(0xFF9A3CFF),
        label: 'CPU Usge',
        value: cpuUsage,
        chartColors: [const Color(0xFF9A3CFF), const Color(0xFF4103AC)],
      ),
      SystemUsageItem(
        icon: Icons.thermostat_rounded,
        iconColor: const Color(0xFFE53935),
        label: 'Temperature',
        value: temperature,
        chartColors: [const Color(0xFFE53935), const Color(0xFF7B1FA2)],
      ),
      SystemUsageItem(
        icon: Icons.storage_rounded,
        iconColor: const Color(0xFF1E88E5),
        label: 'RAM Usage',
        value: ramUsage,
        chartColors: [const Color(0xFF1E88E5), const Color(0xFF0D47A1)],
      ),
      SystemUsageItem(
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFFE040FB),
        label: 'Charge Cycles',
        value: '$chargeCycles',
        chartColors: [const Color(0xFFE040FB), const Color(0xFF9A3CFF)],
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(14),
        vertical: getHeight(5),
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
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ───────── HEADING ─────────
          Text(
            'System Usage',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(12),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          SizedBox(height: getHeight(5)),

          // ───────── CARDS ROW ─────────
          Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SYSTEM CARD
// ─────────────────────────────────────────────────────────────

class _SystemCard extends StatelessWidget {
  final SystemUsageItem item;

  const _SystemCard({required this.item});

  // Random spark line data
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
        gradient: LinearGradient(colors: [
           Color(0xFF1B235C),
           Color(0xFF1B2153),
            Color(0xFF13173A),
        ]),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon + Label + Value ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              getWidth(8),
              getHeight(2),
              getWidth(8),
              getHeight(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.icon,
                  color: item.iconColor,
                  size: getWidth(16),
                ),
                SizedBox(height: getHeight(6)),
                Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(8),
                    fontWeight: FontWeight.w400,
                    color:AppColors.allsmalltextcolor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: getHeight(2)),
                Text(
                  item.value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                clipData: const FlClipData.all(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    color: item.chartColors.first,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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