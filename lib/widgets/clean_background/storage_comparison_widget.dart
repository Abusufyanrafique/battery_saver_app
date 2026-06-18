import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StorageComparisonWidget extends StatelessWidget {
  const StorageComparisonWidget({super.key});

  // ─── Estimate helpers ─────────────────────────────────────────────────────

  /// Parse a formatted string like "512 MB" or "1.2 GB" → double in GB.
  static double _parseGB(String? formatted) {
    if (formatted == null || formatted.isEmpty) return 0.0;
    final lower = formatted.toLowerCase().trim();
    final number =
        double.tryParse(RegExp(r'[\d.]+').stringMatch(lower) ?? '') ?? 0.0;
    return lower.contains('gb') ? number : number / 1024;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CleanBackgroundBloc>().state;

    final result = state.cleanResult;
    final progress = state.scanProgress;
    final selectedApps = state.appsSelected.where((e) => e).length;

    // ── Estimate RAM context ──────────────────────────────────────────────────
    //
    // result.beforeGB comes from real system_info2 RAM readings during scan.
    // If not yet available, fall back to app-count estimate (min 0.5 GB).
    final estimatedUsedGB =
        (selectedApps * 0.12).clamp(0.5, double.infinity);

    final usedRamGB = (result?.beforeGB != null && result!.beforeGB > 0)
        ? result.beforeGB
        : estimatedUsedGB;

    // ── totalGB ───────────────────────────────────────────────────────────────
    //
    // BLoC sets totalGB from SysInfo.getTotalPhysicalMemory().
    // Guard: if it comes back as 0 or very small, use a safe default (4 GB).
    final rawTotal = result?.totalGB ?? 0.0;
    final totalGB = (rawTotal > 0.5) ? rawTotal : (usedRamGB * 2).clamp(2.0, 8.0);

    // ── Junk + cache freed (for afterGB estimate) ─────────────────────────────
    final junkGB = _parseGB(result?.junkRemoved);
    final cacheGB = _parseGB(result?.cacheCleared);

    final estimatedJunkGB = usedRamGB * progress * 0.20;
    final estimatedCacheGB = usedRamGB * progress * 0.15;

    final freedGB = (junkGB > 0 || cacheGB > 0)
        ? junkGB + cacheGB
        : estimatedJunkGB + estimatedCacheGB;

    // ── beforeGB / afterGB ────────────────────────────────────────────────────
    final beforeGB = (result?.beforeGB != null && result!.beforeGB > 0)
        ? result.beforeGB
        : usedRamGB;

    final rawAfter = result?.afterGB ?? 0.0;
    final afterGB = (rawAfter > 0)
        ? rawAfter
        : (usedRamGB - freedGB).clamp(0.1, usedRamGB);

    // ─────────────────────────────────────────────────────────────────────────

    return Container(
      padding: EdgeInsets.all(getWidth(12)),
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
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Title ───────────────────────────────────────────────────────────
          Text(
            'Storage Comparison',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(10)),

          // ── Before / Arrow / After row ───────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // BEFORE
              Expanded(
                child: _StorageColumn(
                  label: 'Before Cleaning',
                  valueGB: beforeGB,
                  totalGB: totalGB,
                  valueColor: AppColors.textwhitecolor,
                  usedColor: AppColors.textwhitecolor,
                  barColor: const Color(0xFFFF19BD),
                ),
              ),

              // PIPE + ARROW + PIPE
              Container(
                width: getWidth(70),
                padding: EdgeInsets.symmetric(horizontal: getWidth(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left pipe
                    Container(
                      width: 2,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF838283),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    SizedBox(width: getWidth(16)),

                    // Arrow
                    Container(
                      width: getWidth(30),
                      height: getWidth(30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4103AC),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF00E676),
                        size: 18,
                      ),
                    ),

                    SizedBox(width: getWidth(6)),

                    // Right pipe
                    Container(
                      width: 2,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF838283),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // AFTER
              Expanded(
                child: _StorageColumn(
                  label: 'After Cleaning',
                  valueGB: afterGB,
                  totalGB: totalGB,
                  valueColor: const Color(0xFF00E676),
                  usedColor: const Color(0xFF00E676),
                  barColor: const Color(0xFF00E676),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Internal column ──────────────────────────────────────────────────────────

class _StorageColumn extends StatelessWidget {
  final String label;
  final double valueGB;
  final double totalGB;
  final Color valueColor;
  final Color usedColor;
  final Color barColor;

  const _StorageColumn({
    required this.label,
    required this.valueGB,
    required this.totalGB,
    required this.valueColor,
    required this.usedColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalGB > 0
        ? (valueGB / totalGB).clamp(0.0, 1.0)
        : 0.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color: AppColors.allsmalltextcolor,
            ),
          ),

          SizedBox(height: getHeight(6)),

          Text(
            '${valueGB.toStringAsFixed(1)} GB',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(12),
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),

          SizedBox(height: getHeight(2)),

          Text(
            'used',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color: usedColor,
            ),
          ),

          SizedBox(height: getHeight(4)),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                Container(
                  height: getHeight(4),
                  width: getWidth(80),
                  color: Colors.white.withOpacity(0.12),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: getHeight(4),
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: getHeight(8)),

          Text(
            'Total ${totalGB.toStringAsFixed(1)} GB',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color: AppColors.allsmalltextcolor,
            ),
          ),
        ],
      ),
    );
  }
}