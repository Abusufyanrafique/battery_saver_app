// account_settings_widget.dart

import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class SettingsItem {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
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
          icon: Icons.person_outline_rounded,
          title: 'Personal Information',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.palette_outlined,
          title: 'Theme',
          trailingText: 'Dark',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.language_rounded,
          title: 'Language',
          trailingText: 'English',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.cloud_upload_outlined,
          title: 'Backup & Restore',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.headset_mic_outlined,
          title: 'Help & Support',
          onTap: () {},
        ),
        SettingsItem(
          icon: Icons.info_outline_rounded,
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
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xFF5A3FBF),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: getWidth(18),
                  color: const Color(0xFF9A80E8),
                ),
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