import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

// ── Model ────────────────────────────────────────────────────────────────────
class SecurityScanItem {
  final String title;
  final bool isCompleted;
  final bool isScanning; // ye item abhi scan ho rahi hai

  const SecurityScanItem({
    required this.title,
    this.isCompleted = false,
    this.isScanning = false,
  });
}

// ── Main Widget ───────────────────────────────────────────────────────────────
class SecurityScanWidget extends StatelessWidget {
  final List<SecurityScanItem> items;

  const SecurityScanWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:AppColors.drawerGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.appWidgetBorderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SecurityScanTile(item: items[index]),
                if (index != items.length - 1)
                  const Divider(
                    color: AppColors.divider,
                    height: 1,
                    thickness: 1,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────
class SecurityScanTile extends StatelessWidget {
  final SecurityScanItem item;

  const SecurityScanTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // ── Left indicator ──────────────────────────────────────────────
          _LeftIndicator(
            isCompleted: item.isCompleted,
            isScanning: item.isScanning,
          ),

           SizedBox(width: getWidth(14)),

          // ── Title ───────────────────────────────────────────────────────
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w500,
                color:AppColors.white,
              ),
            ),
          ),

          // ── Right indicator ─────────────────────────────────────────────
          _RightIndicator(
            isCompleted: item.isCompleted,
            isScanning: item.isScanning,
          ),
        ],
      ),
    );
  }
}

// ── Left green circle / spinner ───────────────────────────────────────────────
class _LeftIndicator extends StatelessWidget {
  final bool isCompleted;
  final bool isScanning;

  const _LeftIndicator({required this.isCompleted, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    if (isScanning) {
      return SizedBox(
        width: getWidth(20),
        height: getHeight(20),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.securitysidecolor,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: getWidth(20),
      height: getHeight(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.securityiscomplete
            : AppColors.securtiyincomplete, // grey when pending
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: AppColors.white, size: 12)
          : null,
    );
  }
}

// ── Right rounded square / spinner ───────────────────────────────────────────
class _RightIndicator extends StatelessWidget {
  final bool isCompleted;
  final bool isScanning;

  const _RightIndicator({required this.isCompleted, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    if (isScanning) {
      return SizedBox(
        width: getWidth(20),
        height: getHeight(20),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.securitysidecolor,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: getWidth(20),
      height: getHeight(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.securityiscomplete
            : AppColors.securtiyincomplete, // grey when pending
        borderRadius: BorderRadius.circular(6),
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: AppColors.white, size: 12)
          : null,
    );
  }
}