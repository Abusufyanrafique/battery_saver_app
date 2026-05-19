import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

// Model class
class BatteryModeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;

  const BatteryModeItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
  });
}

// Main Widget
class BatteryModeListWidget extends StatelessWidget {
  final List<BatteryModeItem> items;

  const BatteryModeListWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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
                BatteryModeTile(item: items[index]),
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

// Tile Widget
class BatteryModeTile extends StatelessWidget {
  final BatteryModeItem item;

  const BatteryModeTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              )
            ),
          ),

          // Subtitle
          Text(
            item.subtitle,
            style:  TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: getFont(14),
            ),
          ),

          const SizedBox(width: 8),

          // Arrow
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD9D9D9),
            size: 30,
          ),
        ],
      ),
    );
  }
}