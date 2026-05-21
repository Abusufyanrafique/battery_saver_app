import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:flutter/material.dart';


class AppManagerTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const AppManagerTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: 'Installed Apps',
          isSelected: selectedIndex == 0,
          onTap: () => onTabChanged(0),
        ),
        _TabItem(
          label: 'APK Files',
          isSelected: selectedIndex == 1,
          onTap: () => onTabChanged(1),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.bluetextcolor : AppColors.textwhitecolor,
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            if (isSelected)
              Container(
                height: 2,
                width: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF55D0FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}