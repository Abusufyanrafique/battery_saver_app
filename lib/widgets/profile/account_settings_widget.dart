// account_settings_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ──────────────────────────────────────────────────────────
// MODEL
// ──────────────────────────────────────────────────────────

class SettingsItem {
  final String svgicon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const SettingsItem({
   
    required this.title,
    this.trailingText,
    this.onTap, 
    required this.svgicon,
  });
}

// ─────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────

class AccountSettingsWidget extends StatelessWidget {
  final List<SettingsItem>? items;

  const AccountSettingsWidget({
    super.key,
    this.items,
  });

  List<SettingsItem> _defaultItems(BuildContext context) => [
        SettingsItem(
         svgicon:AppIcons.profileperson ,
          title: AppText.personalInformation,
          onTap: () {},
        ),
        SettingsItem(
       svgicon:AppIcons.profilenoti ,
          title: AppText.notificationsprofile,
          onTap: () {},
        ),
        SettingsItem(
          svgicon:AppIcons.profiletheme ,
          title: AppText.theme,
          trailingText: AppText.dark,
          onTap: () {},
        ),
        SettingsItem(
          svgicon:AppIcons.profilelanguage ,
          title: AppText.language,
          trailingText: AppText.english,
          onTap: () {},
        ),
        SettingsItem(
          svgicon: AppIcons.profilebackaup,
          title: AppText.backupRestore,
          onTap: () {},
        ),
        SettingsItem(
          svgicon:AppIcons.profilehelp ,
          title: AppText.helpSupport,
          onTap: () {},
        ),
        SettingsItem(
         svgicon:AppIcons.profileinfo ,
          title: AppText.aboutBatteryOptimizer,
          trailingText:AppText.version,
          onTap: () {},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final settingsList = items ?? _defaultItems(context);

    return SizedBox(
      height: getHeight(300),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getWidth(16),
          vertical: getHeight(8),
        ),
        decoration: BoxDecoration(
           gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:AppColors.drawerGradient,
        ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.appWidgetBorderColor,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───────── HEADING ─────────
            Text(
              AppText.accountSettings,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),

            SizedBox(height: getHeight(6)),

            // ───────── ITEMS ─────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(settingsList.length, (index) {
                  final item = settingsList[index];
                  final isLast = index == settingsList.length - 1;

                 return Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    _SettingsRow(item: item),
    if (!isLast)
      Divider(
        color: AppColors.dividercolor,
        height: 1,
        thickness: 1,
         indent: 33,
         endIndent: 10,
      ),
  ],
);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SETTINGS ROW
// ─────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final SettingsItem item;

  const _SettingsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: getHeight(2)),
        child: Row(
          children: [
            // ── Icon Circle ──
            Container(
              width: getWidth(30),
              height: getWidth(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1B2153),
                border: Border.all(
                  color: AppColors.appWidgetBorderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  height: getHeight(14),
                  width: getWidth(14),
                  item.svgicon,
                )
              ),
            ),

            SizedBox(width: getWidth(12)),

            // ── Title ──
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ),

            // ── Trailing Text (optional) ──
            if (item.trailingText != null) ...[
              Text(
                item.trailingText!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF989CDF),
                ),
              ),
              SizedBox(width: getWidth(29)),
            ],

            // ── Arrow ──
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: getWidth(12),
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}