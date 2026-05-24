import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/view/app_manager/app_manager_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // ── App Icon (SVG Support) ─────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SvgPicture.asset(
                  app.iconAsset,
                  width: getWidth(20),
                  height: getHeight(20),
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: const Icon(
                      Icons.apps,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              SizedBox(width: getWidth(12)),

              // ── App Name ─────────────────────────
              Expanded(
                child: Text(
                  app.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(14),
                    color: AppColors.textwhitecolor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ── Size ─────────────────────────
              Text(
                app.formattedSize,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: getFont(13),
                  color: AppColors.allsmalltextcolor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(width: getWidth(12)),

              // ── Checkbox (Selection) ─────────────────────────
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: getWidth(18),
                  height: getHeight(18),
                  decoration: BoxDecoration(
                    color: app.isSelected
                        ? AppColors.bodercolor
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.bodercolor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: app.isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),

        // ── Divider (clean + indented look) ─────────────────
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: getWidth(60)),
            child: Divider(
              color: Color(0xFF373C62).withOpacity(0.6),
              height: 1,
              thickness: 1,
            ),
          ),
      ],
    );
  }
}