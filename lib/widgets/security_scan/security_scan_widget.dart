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
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4103AC), width: 1),
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
                    color: Color(0xFF373C62),
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

          const SizedBox(width: 14),

          // ── Title ───────────────────────────────────────────────────────
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w500,
                color: Colors.white,
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
          color: Color(0xFF00FF09),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: getWidth(20),
      height: getHeight(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF00FF09)
            : const Color(0xFF373C62), // grey when pending
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 12)
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
          color: Color(0xFF2FE55D),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: getWidth(20),
      height: getHeight(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF2FE55D)
            : const Color(0xFF373C62), // grey when pending
        borderRadius: BorderRadius.circular(6),
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 12)
          : null,
    );
  }
}