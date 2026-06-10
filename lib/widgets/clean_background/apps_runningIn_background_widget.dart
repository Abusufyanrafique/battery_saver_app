import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class AppsRunningInBackgroundWidget extends StatelessWidget {
  final List<RunningAppInfo> apps;       //  Real data
  final List<bool> selected;
  final bool allSelected;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onToggleAll;

  const AppsRunningInBackgroundWidget({
    super.key,
    required this.apps,
    required this.selected,
    required this.allSelected,
    required this.onToggleItem,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    // Koi app nahi — widget hide karo
    if (apps.isEmpty) return const SizedBox.shrink();

    return Container(
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
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apps Running in Background',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textwhitecolor,
                ),
              ),
              GestureDetector(
                onTap: onToggleAll,
                child: Text(
                  allSelected ? 'Deselect All' : 'Select All',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9A3CFF),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(4)),

          // App List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              // selected list bounds check — safety
              final isSelected = index < selected.length ? selected[index] : false;
              final isLast = index == apps.length - 1;
              return Column(
                children: [
                  _AppTile(
                    app: apps[index],
                    isSelected: isSelected,
                    onTap: () => onToggleItem(index),
                  ),
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.only(left: getWidth(34)),
                      child: const Divider(
                        color: Color(0xFF838283),
                        height: 1,
                        thickness: 0.5,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final RunningAppInfo app;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppTile({
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // ✅ Package initial se placeholder icon
            Container(
              width: getWidth(36),
              height: getHeight(36),
              decoration: BoxDecoration(
                color: _colorFromPackage(app.packageName),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                app.appName.isNotEmpty
                    ? app.appName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getFont(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(width: getWidth(12)),

            // App Name & Size
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textwhitecolor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.sizeFormatted,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(11),
                      fontWeight: FontWeight.w500,
                      color: AppColors.allsmalltextcolor,
                    ),
                  ),
                ],
              ),
            ),

            // Check Icon
            Icon(
              isSelected
                  ? Icons.check_circle_outline_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? const Color(0xFF4CAF50)
                  : Colors.white.withOpacity(0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Package name se consistent color generate karo
  Color _colorFromPackage(String packageName) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFE1306C),
      const Color(0xFF1877F2),
      const Color(0xFF25D366),
      const Color(0xFFFF6B35),
      const Color(0xFF0099CC),
      const Color(0xFFAA00FF),
      const Color(0xFFFF5722),
    ];
    final index = packageName.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }
}