import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/profile/account_settings_widget.dart';
import 'package:battery_saver_app/widgets/profile/battery_summary_widget.dart';
import 'package:battery_saver_app/widgets/profile/premium_banner_widget.dart';
import 'package:battery_saver_app/widgets/profile/profile_header_widget.dart';
import 'package:battery_saver_app/widgets/profile/sign_out_button_widget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: AppBar(
        title: Text("Profile",
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: getFont(24),
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.allscreenBackgroundColor,
       leading:   IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Image(
                image: AssetImage(AppImages.chevron),
              ),
            ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
          child: Column(
            children: [
              ProfileHeaderWidget(
                name: "Abu Sufyan",
                email: "abusufyan@gmail.com",
                memberSince: "Jan 2024",
                isPremium: true,
                profileScore: 92,
                scoreLabel: "Excellent",
                onEditTap: () {
                  print("Edit profile tapped");
                },
              ),
              SizedBox(height: getHeight(20)),

                BatterySummaryWidget(),

              SizedBox(height: getHeight(12)),

              PremiumBannerWidget(
                onManageTap: () {
                  Navigator.pushNamed(context, '/ManagePlanScreen');
                },
              ),

              SizedBox(height: getHeight(12)),

              AccountSettingsWidget(),

              SizedBox(height:getHeight(16) ,),

              SignOutButtonWidget(
                onTap: () {},
              ),

              SizedBox(height: getHeight(16)),
            ],
          ),
        ),
      ),
    );
  }
}