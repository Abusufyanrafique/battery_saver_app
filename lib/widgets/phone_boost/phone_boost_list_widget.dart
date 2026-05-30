import 'package:battery_saver_app/bloc/phone_boost/phone_boost_bloc.dart';

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// Known app icon map — package name → SVG asset path
const _knownIcons = <String, String>{
  'com.whatsapp':                   AppIcons.whatsappicon,
  'com.facebook.katana':            AppIcons.facebookicon,
  'com.instagram.android':          AppIcons.instagramicon,
  'com.google.android.youtube':     AppIcons.youtubeicon,
};

class PhoneBoostListWidget extends StatelessWidget {
  final List<RunningAppInfo> apps;

  const PhoneBoostListWidget({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No running apps found',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(apps.length, (i) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhoneBoostTile(app: apps[i]),
                if (i != apps.length - 1)
                  const Divider(
                      color: Color(0xFF373C62), height: 1, thickness: 1),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class PhoneBoostTile extends StatelessWidget {
  final RunningAppInfo app;

  const PhoneBoostTile({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final svgPath = _knownIcons[app.packageName];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [

          // ── App icon (SVG if known, else letter avatar) ──────────────────
          SizedBox(
            width: getWidth(26),
            height: getHeight(26),
            child: svgPath != null
                ? SvgPicture.asset(svgPath)
                : _LetterAvatar(name: app.name),
          ),

          SizedBox(width: getWidth(12)),

          // ── Name + MB ────────────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    app.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textwhitecolor,
                    ),
                  ),
                ),
                SizedBox(width: getWidth(8)),
                Text(
                  '${app.memoryMb} MB',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.allsmalltextcolor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: getWidth(12)),

          // ── Check badge ──────────────────────────────────────────────────
          Container(
            width: getWidth(24),
            height: getHeight(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2A8F),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.check, size: 14, color: Color(0xFF55D0FF)),
          ),
        ],
      ),
    );
  }
}

// Fallback when no SVG icon available — colored circle with first letter
class _LetterAvatar extends StatelessWidget {
  final String name;
  const _LetterAvatar({required this.name});

  static const _colors = [
    Color(0xFF6C63FF),
    Color(0xFF00C6AE),
    Color(0xFFFF6584),
    Color(0xFFFFAA00),
    Color(0xFF55D0FF),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[name.codeUnitAt(0) % _colors.length];
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}