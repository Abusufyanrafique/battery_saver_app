import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

// Model
class SecurityScanItem {
  final String title;

  const SecurityScanItem({
    required this.title,
  });
}

// Main Widget
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
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1,
        ),
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

// Tile
class SecurityScanTile extends StatelessWidget {
  final SecurityScanItem item;

  const SecurityScanTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          //  Left green circle check
          Container(
            width: getWidth(20),
            height: getHeight(20),
            decoration: const BoxDecoration(
              color: Color(0xFF00FF09),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),

          const SizedBox(width: 14),

          // Title
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
          

          //  Right green rounded square check
          Container(
            width: getWidth(20),
            height: getHeight(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2FE55D),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}