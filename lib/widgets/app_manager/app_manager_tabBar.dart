import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _TabItem(
              label: AppText.installedApps,
              isSelected: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
            _TabItem(
              label: AppText.files,
              isSelected: selectedIndex == 1,
              onTap: () => onTabChanged(1),
            ),
          ],
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.appmanagerline,
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
             SizedBox(height: getHeight(6)),
            if (isSelected)
              Container(
                height: getHeight(2),
                width: getWidth(80),
                decoration: BoxDecoration(
                  color: AppColors.checkiconcolor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}