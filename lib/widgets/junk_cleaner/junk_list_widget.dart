import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/models/junk/junk_item.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class JunkListWidget extends StatelessWidget {
  final List<JunkItem> items;
  final void Function(int index) onToggle;

  const JunkListWidget({
    super.key,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.drawerGradient
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.appWidgetBorderColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(items.length, (index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () => onToggle(index),
                  child: JunkItemTile(item: items[index]),
                ),
                if (index < items.length - 1)
                  const Divider(
                    color: AppColors.appdividercolor,
                    height: 1,
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
          _CheckCircle(isChecked: item.isChecked),
          SizedBox(width: getWidth(14)),
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            item.size,
            style: TextStyle(
              color: AppColors.allsmalltextcolor,
              fontSize: getFont(12),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: getWidth(10)),
          Container(
            width: getWidth(22),
            height: getHeight(22),
            decoration: BoxDecoration(
              color: item.isChecked
                  ? AppColors.junkcheckboxcolor
                  : AppColors.junkcheckbox2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: item.isChecked
                ? const Icon(
                  Icons.check, 
                  color: AppColors.checkiconcolor,
                   size: 14)
                : null,
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
        color: isChecked ? AppColors.checkiconcolor : Colors.transparent,
        border: isChecked ? null : Border.all(color: Colors.white38, width: 1.5),
      ),
      child: isChecked
          ? const Icon(Icons.check, color:AppColors.white, size: 14)
          : null,
    );
  }
}