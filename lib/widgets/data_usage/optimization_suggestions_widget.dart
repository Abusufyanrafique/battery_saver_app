// optimization_suggestions_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

class OptimizationSuggestionsWidget extends StatefulWidget {
  final String title;
  final int backgroundAppsCount;
  final VoidCallback? onViewAll;

  /// Real close action - count return karta hai kitne apps close hue
  final Future<int> Function()? onOptimize;

  const OptimizationSuggestionsWidget({
    super.key,
    this.title = 'Close background apps',
    required this.backgroundAppsCount,
    this.onViewAll,
    this.onOptimize,
  });

  @override
  State<OptimizationSuggestionsWidget> createState() =>
      _OptimizationSuggestionsWidgetState();
}

class _OptimizationSuggestionsWidgetState
    extends State<OptimizationSuggestionsWidget> {
  bool _isOptimizing = false;
  int? _closedCount; // null = abhi optimize nahi hua

  String get _subtitle {
    if (_isOptimizing) return 'Closing apps...';
    if (_closedCount != null) return '$_closedCount apps closed successfully';
    return '${widget.backgroundAppsCount} apps are running in background';
  }

  Future<void> _handleOptimize() async {
    if (widget.onOptimize == null || _isOptimizing) return;

    setState(() {
      _isOptimizing = true;
      _closedCount = null;
    });

    final count = await widget.onOptimize!();

    if (!mounted) return;
    setState(() {
      _isOptimizing = false;
      _closedCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(14),
        vertical: getHeight(5),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3440A0),
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF4103AC), width: 1.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ───────── HEADER ROW ─────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppText.optimizationSuggestions,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAll,
                child: Text(
                  AppText.viewAlltext,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9A3CFF),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(7)),

          // ───────── SUGGESTION CARD ─────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(12),
              vertical: getHeight(12),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B235C),
                  Color(0xFF1B235C),
                  Color(0xFF13173A),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4103AC),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // ── Icon ──
                Container(
                  width: getWidth(30),
                  height: getWidth(30),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color(0xFF181C3B),
                        Color(0xFF9A3CFF),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _isOptimizing
                        ? SizedBox(
                            width: getWidth(16),
                            height: getWidth(16),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF1DBF),
                            ),
                          )
                        : Icon(
                            _closedCount != null
                                ? Icons.check_circle_rounded
                                : Icons.rocket_launch_rounded,
                            size: getWidth(22),
                            color: const Color(0xFFFF1DBF),
                          ),
                  ),
                ),

                SizedBox(width: getWidth(12)),

                // ── Text ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: getFont(13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: getHeight(3)),
                      Text(
                        _subtitle, 
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: getFont(9),
                          fontWeight: FontWeight.w400,
                          color: AppColors.allsmalltextcolor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: getWidth(8)),

                // ── Optimize Button ──
                GestureDetector(
                  onTap: _isOptimizing ? null : _handleOptimize,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(10),
                      vertical: getHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isOptimizing
                            ? const Color(0xFF6B6B8C)
                            : const Color(0xFF9A3CFF),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      _closedCount != null ? 'Done' : AppText.optimizetext1,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}