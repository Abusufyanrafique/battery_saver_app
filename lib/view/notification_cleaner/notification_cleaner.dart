import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

// ─── DATA MODEL ───────────────────────────────

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

  SocialStatItem copyWith({bool? isChecked}) {
    return SocialStatItem(
      label: label,
      count: count,
      svgAssetPath: svgAssetPath,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

// ─── SCREEN ───────────────────────────────

class NotificationCleanerScreen extends StatelessWidget {
  const NotificationCleanerScreen({super.key});

  static  final List<SocialStatItem> _items = [
    SocialStatItem(
      label: 'WhatsApp',
      count: 45,
      svgAssetPath: AppIcons.whatsappicon,
    ),
    SocialStatItem(
      label: 'Facebook',
      count: 32,
      svgAssetPath: AppIcons.facebookicon,
    ),
    SocialStatItem(
      label: 'Instagram',
      count: 21,
      svgAssetPath: AppIcons.instagramicon,
    ),
    SocialStatItem(
      label: 'YouTube',
      count: 16,
      svgAssetPath:AppIcons.youtubeicon,
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

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),

      //  AppBar inside Scaffold (avoid white flash)
      appBar: CustomAppBar(title:AppText.notificationCleaner),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        //  stable gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1633),
              Color(0xFF0B122B),
              Color(0xFF070C1F),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ───── IMAGE ─────
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

                // ───── TITLE ─────
                Center(
                  child: Text(
                    "126",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(32),
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(6)),

                Center(
                  child: Text(
                    AppText.notifications,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(16),
                      color: Colors.white70,
                    ),
                  ),
                ),

                Center(
                  child: Text(
                   AppText.foundinapps,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(18),
                      color: const Color(0xFF55D0FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(94)),

                // ───── LIST ─────
                SocialStatsWidget(items: _items),

                SizedBox(height: getHeight(24)),

                // ───── BUTTON ─────
                CleanButtonWidget(
                  text: AppText.cleanNow,
                  onPressed: () {},
                ),

                SizedBox(height: getHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── LIST WIDGET ───────────────────────────────

class SocialStatsWidget extends StatelessWidget {
  final List<SocialStatItem> items;

  const SocialStatsWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        border: Border.all(color: const Color(0xFF4103AC), width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _SocialStatRow(item: item),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFF373C62),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── ROW ───────────────────────────────

class _SocialStatRow extends StatelessWidget {
  final SocialStatItem item;

  const _SocialStatRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [

          // SVG ICON
          SvgPicture.asset(
            item.svgAssetPath,
            width: getWidth(20),
            height: getHeight(20),
          ),

          const SizedBox(width: 14),

          // LABEL
          Expanded(
            child: Text(
              item.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          // COUNT
          Text(
            '${item.count}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(12),
              color: const Color(0xFFD9D9D9),
            ),
          ),

          const SizedBox(width: 12),

          // CHECK ICON
          if (item.isChecked)
            Container(
              width: getWidth(20),
              height: getHeight(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A8F),
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