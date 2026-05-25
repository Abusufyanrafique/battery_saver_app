import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class AppUsageItem {
  final String name;
  final String svgAssetPath; // e.g. 'assets/icons/whatsapp.svg'
  final double usageMB;
  final double maxMB;
  final Color barColor;

  const AppUsageItem({
    required this.name,
    required this.svgAssetPath,
    required this.usageMB,
    required this.maxMB,
    required this.barColor,
  });

  double get fraction => (usageMB / maxMB).clamp(0.0, 1.0);

  String get usageLabel {
    if (usageMB >= 1024) {
      return '${(usageMB / 1024).toStringAsFixed(2)} GB';
    }
    return '${usageMB.toStringAsFixed(0)} MB';
  }
}

// ─── Single Row ───────────────────────────────────────────────────────────────

class _AppUsageRow extends StatefulWidget {
  final AppUsageItem item;
  final Duration animationDelay;

  const _AppUsageRow({
    required this.item,
    required this.animationDelay,
  });

  @override
  State<_AppUsageRow> createState() => _AppUsageRowState();
}

class _AppUsageRowState extends State<_AppUsageRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _widthAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(widget.animationDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Icon
          Container(
            width: getWidth(30),
            height: getHeight(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: SvgPicture.asset(
              item.svgAssetPath,
              width: getWidth(30),
              height: getHeight(30),
              fit: BoxFit.cover,
            ),
          ),
           SizedBox(width: getWidth(14)),

          // Name + Progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style:AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(14),
                    color: AppColors.textwhitecolor
                  )
                ),
                 SizedBox(height:getHeight(8) ),
                // Progress bar track
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        // Track
                        Container(
                          height: 5,
                          width: maxWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2A5A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        // Animated fill
                        AnimatedBuilder(
                          animation: _widthAnim,
                          builder: (_, __) => Container(
                            height: 5,
                            width: maxWidth * item.fraction * _widthAnim.value,
                            decoration: BoxDecoration(
                              color: item.barColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: item.barColor.withOpacity(0.5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
           SizedBox(width: getWidth(14)),

          // Usage label
          SizedBox(
            width: getWidth(68),
            child: Text(
              item.usageLabel,
              textAlign: TextAlign.right,
             style:AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    color: AppColors.allsmalltextcolor
                  )
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Card Widget ─────────────────────────────────────────────────────────

class AppUsageListCard extends StatelessWidget {
  final List<AppUsageItem> items;

  const AppUsageListCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2155), Color(0xFF0F1540)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4B4FBF).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B3FA0).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              _AppUsageRow(
                item: items[i],
                animationDelay: Duration(milliseconds: i * 150),
              ),
            ],
          );
        }),
      ),
    );
  }
}

