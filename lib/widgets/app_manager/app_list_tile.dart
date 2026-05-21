import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/view/app_manager/app_manager_screen.dart';
import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  final AppModel app;
  final VoidCallback onToggle;
  final bool showDivider;

  const AppListTile({
    super.key,
    required this.app,
    required this.onToggle,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, 
            vertical: 10
            ),
          child: Row(
            children: [
              // App Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  app.iconAsset,
                  width: getWidth(36),
                  height: getHeight(36),
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  Icon(
                      Icons.apps,
                      color: AppColors.bluetextcolor,
                      size: 20,
                    ),
                  ),
                ),
              ),
               SizedBox(width: getWidth(12)),

              // App Name
              Expanded(
                child: Text(
                  app.name,
                  style:AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    color: AppColors.textwhitecolor,
                    fontWeight: FontWeight.w500
                  )
                ),
              ),

              // Size
              Text(
                app.formattedSize,
                 style:AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    color: AppColors.allsmalltextcolor,
                    fontWeight: FontWeight.w500
                  )
              ),
               SizedBox(width: getWidth(12)),

              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: getWidth(16),
                  height: getHeight(16),
                  decoration: BoxDecoration(
                    color: app.isSelected
                        ? AppColors.bodercolor
                        : null,
                    border: Border.all(
                      color: app.isSelected
                          ? AppColors.bodercolor
                          : AppColors.bodercolor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: app.isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
           Divider(
            color: Color(0xFF373C62),
            height: 1,
          ),
      ],
    );
  }
}