import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class CpuInfoItem {
  final String imagePath;
  final String title;
  final String value;

  const CpuInfoItem({
    required this.imagePath,
    required this.title,
    required this.value,
  });
}

class CpuCoolerWidget extends StatelessWidget {
  final List<CpuInfoItem> items;

  const CpuCoolerWidget({
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
          color: Color(0xFF4103AC),
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
                CpuCoolerTile(item: items[index]),
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

class CpuCoolerTile extends StatelessWidget {
  final CpuInfoItem item;

  const CpuCoolerTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            item.imagePath,
            width: getWidth(24),
            height: getHeight(24),
          ),
           SizedBox(width: getWidth(16)),
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
          Text(
            item.value,
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: getFont(12),
              color: const Color(0xFFD9D9D9),
            ),
          ),
        ],
      ),
    );
  }
}