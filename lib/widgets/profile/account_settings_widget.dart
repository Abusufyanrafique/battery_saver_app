// account_settings_widget.dart

import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

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
          title: 'Personal Information',
          onTap: () {},
        ),
        SettingsItem(
       svgicon:AppIcons.profilenoti ,
          title: 'Notifications',
          onTap: () {},
        ),
        SettingsItem(
          svgicon:AppIcons.profiletheme ,
          title: 'Theme',
          trailingText: 'Dark',
          onTap: () {},
        ),
        SettingsItem(
          svgicon:AppIcons.profilelanguage ,
          title: 'Language',
          trailingText: 'English',
          onTap: () {},
        ),
        SettingsItem(
          svgicon: AppIcons.profilebackaup,
          title: 'Backup & Restore',
          onTap: () {},
        ),
        SettingsItem(
          svgicon:AppIcons.profilehelp ,
          title: 'Help & Support',
          onTap: () {},
        ),
        SettingsItem(
         svgicon:AppIcons.profileinfo ,
          title: 'About Battery Optimizer',
          trailingText: 'v2.4.1',
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
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4103AC),
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
                color: Colors.white,
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
                          color: Colors.white.withOpacity(0.08),
                          height: 1,
                          thickness: 1,
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
                  color: const Color(0xFF4103AC),
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
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
                  color: Colors.white,
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
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}