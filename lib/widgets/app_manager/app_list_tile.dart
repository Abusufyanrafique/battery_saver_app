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
  final bool isApkMode;

  const AppListTile({
    super.key,
    required this.app,
    required this.onToggle,
    this.showDivider = true,
    this.isApkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // ── App Icon ─────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SvgPicture.asset(
                  app.iconAsset,
                  width: getWidth(30),
                  height: getHeight(30),
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => Container(
                    width: getWidth(36),
                    height: getHeight(36),
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

              // ── App Name + Version (ONLY APK MODE) ─────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        color: AppColors.textwhitecolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: getHeight(2)),

                    // ✅ ONLY SHOW IN APK MODE
                    if (isApkMode)
                      Row(
                        children: [
                          Text(
                            "Version 1.0.0",
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: getFont(11),
                              color: AppColors.allsmalltextcolor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(width: getWidth(6)),

                          Text(
                            app.formattedSize,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: getFont(11),
                              color: AppColors.allsmalltextcolor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      // Normal mode → only size OR empty space behavior
                      Text(
                        app.formattedSize,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(11),
                          color: AppColors.allsmalltextcolor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: getWidth(8)),

              // ── Action Buttons ─────────────────────────
              if (isApkMode) ...[
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF55D0FF),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Install',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(12),
                        color: const Color(0xFF55D0FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: getWidth(4)),

                const Icon(
                  Icons.more_vert,
                  color: Color(0xFFD9D9D9),
                  size: 20,
                ),
              ] else ...[
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: getWidth(20),
                    height: getHeight(20),
                    decoration: BoxDecoration(
                      color: app.isSelected
                          ? Color(0xFF838283)
                          : Colors.transparent,
                      border: Border.all(
                        color: Color(0xFF838283),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: app.isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Divider ─────────────────────────────────────────
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: getWidth(60)),
            child: Divider(
              color: const Color(0xFF373C62).withOpacity(0.6),
              height: 1,
              thickness: 1,
            ),
          ),
      ],
    );
  }
}