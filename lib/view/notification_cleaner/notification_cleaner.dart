import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────

class SocialStatItem {
  final String label;
  final int count;
  final String svgAssetPath;
  final bool isChecked;

  const SocialStatItem({
    required this.label,
    required this.count,
    required this.svgAssetPath,
    this.isChecked = true,
  });
}

// ─── Main Screen ──────────────────────────────

class NotificationCleanerScreen extends StatelessWidget {
  const NotificationCleanerScreen({super.key});

  // ── Apna data yahan customize karo ──
  static const List<SocialStatItem> _items = [
    SocialStatItem(
      label: 'WhatsApp',
      count: 45,
      svgAssetPath: 'assets/icons/notification_cleaner/Whatsappicon.svg',
    ),
    SocialStatItem(
      label: 'Facebook',
      count: 32,
      svgAssetPath: 'assets/icons/notification_cleaner/facebookicon.svg',
    ),
    SocialStatItem(
      label: 'Instagram',
      count: 21,
      svgAssetPath: 'assets/icons/notification_cleaner/instagramicon.svg',
    ),
    SocialStatItem(
      label: 'YouTube',
      count: 16,
      svgAssetPath: 'assets/icons/notification_cleaner/youtubeicon.svg',
    ),
    SocialStatItem(
      label: 'Others',
      count: 12,
      svgAssetPath: 'assets/icons/others.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: 'Notification Cleaner'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: getHeight(200),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.notificationcleanerimage),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Center(
                child: Text(
                  "126",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(32),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: getHeight(6)),

              Center(
                child: Text(
                  "Notifications",
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Found in 8 apps",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(20),
                    color: Color(0xFF55D0FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: getHeight(64)),

              // ── SocialStatsWidget (PhoneBoostListWidget ki jagah) ──
              SocialStatsWidget(items: _items),

              SizedBox(height: getHeight(24)),

              // Button
              CleanButtonWidget(
                text: "Clean Now",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social Stats Widget ──────────────────────

class SocialStatsWidget extends StatelessWidget {
  final List<SocialStatItem> items;
  final Color cardColor;
  final Color dividerColor;
  final Color textColor;
  final Color checkBgColor;
  final double borderRadius;

  const SocialStatsWidget({
    super.key,
    required this.items,
    this.cardColor = const Color(0xFF112266),
    this.dividerColor = const Color(0xFF1E2E6A),
    this.textColor = Colors.white,
    this.checkBgColor = const Color(0xFF1A3A8A),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
         gradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF232C6D), // top light blue
      Color(0xFF1B2153), // middle
      Color(0xFF13173A), // bottom dark blue
    ],
  ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4103AC), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final isLast = index == items.length - 1;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SocialStatRow(
                  item: items[index],
                  textColor: textColor,
                  checkBgColor: checkBgColor,
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF373C62),
                    // indent: 16,
                    // endIndent: 16,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─── Single Row ───────────────────────────────

class _SocialStatRow extends StatelessWidget {
  final SocialStatItem item;
  final Color textColor;
  final Color checkBgColor;

  const _SocialStatRow({
    required this.item,
    required this.textColor,
    required this.checkBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // SVG Icon
          SvgPicture.asset(
            item.svgAssetPath,
            width: getWidth(20),
            height: getHeight(20),
          ),
          const SizedBox(width: 14),

          // Label
          Expanded(
            child: Text(
              item.label,
                style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(14),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            )
            ),
          ),

          // Count
          Text(
            '${item.count}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(12),
              color: Color(0xFFD9D9D9),
            )
          ),
          const SizedBox(width: 12),

          // Check Badge
          if (item.isChecked)
            Container(
              width: getWidth(14),
              height: getHeight(14),
              decoration: BoxDecoration(
                color: Color(0xFF1C2A8F),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF55D0FF),
                size: 12,
              ),
            ),
        ],
      ),
    );
  }
}