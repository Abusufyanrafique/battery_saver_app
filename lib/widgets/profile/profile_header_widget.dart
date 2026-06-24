// profile_header_widget.dart

import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String email;
  final String memberSince;
  final bool isPremium;
  final int profileScore;
  final String scoreLabel;
  final VoidCallback? onEditTap;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.email,
    required this.memberSince,
    this.isPremium = true,
    this.profileScore = 92,
    this.scoreLabel = 'Excellent',
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(390),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(6),
        // vertical: getHeight(0),
      ),
      decoration: BoxDecoration(
        // color: const Color(0xFF0D1035),
        // border: Border(
        //   bottom: BorderSide(
        //     color: const Color(0xFF9A3CFF).withOpacity(0.4),
        //     width: 1,
        //   ),
        // ),
      ),
      child: Row(
        children: [
          // ───────── AVATAR ─────────
          _AvatarSection(onEditTap: onEditTap),

          SizedBox(width: getWidth(16)),

          // ───────── USER INFO ─────────
          Expanded(
            child: _UserInfoSection(
              name: name,
              email: email,
              memberSince: memberSince,
              isPremium: isPremium,
            ),
          ),

          SizedBox(width: getWidth(20)),

          // ───────── PROFILE SCORE ─────────
          _ProfileScoreCard(
            score: profileScore,
            label: scoreLabel,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AVATAR SECTION
// ─────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final VoidCallback? onEditTap;

  const _AvatarSection({this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidth(90),
      height: getWidth(90),
      child: Stack(
        children: [
          // Gradient border circle
          Container(
            width: getWidth(90),
            height: getWidth(90),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:AppColors.profilehearderGradientColors
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0D1035),
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:AppColors.purpletextGradientColors
                  ).createShader(bounds),
                  child: Icon(
                    Icons.person_rounded,
                    size: getWidth(38),
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          // Edit button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                width: getWidth(22),
                height: getWidth(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1F5E),
                  border: Border.all(
                    color: const Color(0xFF9A3CFF),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: getWidth(12),
                  color: const Color(0xFF9A3CFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// USER INFO SECTION
// ─────────────────────────────────────────────────────────────

class _UserInfoSection extends StatelessWidget {
  final String name;
  final String email;
  final String memberSince;
  final bool isPremium;

  const _UserInfoSection({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Name
        Text(
          name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: getFont(20),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),

        SizedBox(height: getHeight(4)),

        // Premium badge
        if (isPremium)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: const Color(0xFFFF2D9B),
                size: getWidth(16),
              ),
              SizedBox(width: getWidth(4)),
             ShaderMask(
  shaderCallback: (bounds) => const LinearGradient(
    colors:AppColors.pinkBlueGradientColors
  ).createShader(
    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
  ),
  child: Text(
    AppText.premiumUser,
    style: AppTextStyles.bodyMedium.copyWith(
      fontSize: getFont(13),
      fontWeight: FontWeight.w600,
      color: AppColors.white, 
    ),
  ),
)
            ],
          ),

        SizedBox(height: getHeight(4)),

        // Email
        Text(
          email,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(12),
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),

        SizedBox(height: getHeight(4)),

        // Member since
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: Colors.white70,
              size: getWidth(14),
            ),
            SizedBox(width: getWidth(4)),
            Text(
              'Member since $memberSince',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(10),
                fontWeight: FontWeight.w400,
                color: AppColors.allsmalltextcolor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROFILE SCORE CARD
// ─────────────────────────────────────────────────────────────

class _ProfileScoreCard extends StatelessWidget {
  final int score;
  final String label;

  const _ProfileScoreCard({
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(90),
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(10),
        vertical: getHeight(10),
      ),
      decoration: BoxDecoration(
       gradient: LinearGradient(colors: [
        Color(0xFF1B2153),
        Color(0xFF13173A)
       ]),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF4103AC),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            AppText.profileScore,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(10),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          SizedBox(height: getHeight(6)),

          // Shield icon
          Image(image: AssetImage(AppImages.profilescore)),

          SizedBox(height: getHeight(4)),

          // Score
          Text(
            '$score/100',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(10),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          SizedBox(height: getHeight(2)),

          // Label
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(10),
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFE39C6),
            ),
          ),
        ],
      ),
    );
  }
}