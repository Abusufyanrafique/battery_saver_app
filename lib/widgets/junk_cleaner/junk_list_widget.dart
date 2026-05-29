import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/models/junk/junk_item.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class JunkListWidget extends StatelessWidget {
  final List<JunkItem> items;

  const JunkListWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
         gradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF232C6D), // top light blue
      Color(0xFF1B2153), // middle
      Color(0xFF13173A), // bottom dark blue
    ],
  ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(items.length, (index) {
            return Column(
              children: [
                JunkItemTile(item: items[index]),
                if (index < items.length - 1)
                  Divider(
                    color: const Color(0xFF373C62),
                    height: 1,
                    // indent: 16,
                    // endIndent: 16,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class JunkItemTile extends StatelessWidget {
  final JunkItem item;

  const JunkItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          // Left checkbox
          _CheckCircle(isChecked: item.isChecked),
           SizedBox(width: getWidth(14)),

          // Label
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                color: Colors.white,
                fontWeight: FontWeight.w500
              )
            ),
          ),

          // Size
          Text(
            item.size,
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: getFont(12),
              fontWeight: FontWeight.w400,
            ),
          ),
           SizedBox(width: getWidth(10)),

          // Right checkmark
         Container(
  width: getWidth(22),
  height: getHeight(22),
  decoration: BoxDecoration(
    color: const Color(0xFF1C2A8F),
    borderRadius: BorderRadius.circular(6),
  ),
  child: const Icon(
    Icons.check,
    color: Color(0xFF55D0FF),
    size: 14,
  ),
),
        ],
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isChecked;

  const _CheckCircle({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(20),
      height: getHeight(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF55D0FF),
        border: isChecked
            ? null
            : Border.all(color: Colors.white38, width: 1.5),
      ),
      child: isChecked
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }
}