import 'package:battery_saver_app/bloc/Nav_bar/nav_cubit.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/view/data_usage/data_usage_screen.dart';
import 'package:battery_saver_app/view/home/app_home_screen.dart';
import 'package:battery_saver_app/view/profile/profile_screen.dart';
import 'package:battery_saver_app/view/tools/tools_screen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/svg.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  final pages = const [
    AppHomeScreen(),
    DataUsageScreen(),
    ToolsScreen(),
    ProfileScreen(),
  ];

  /// Helper widget — selected icon gets purple circle, unselected stays plain
  Widget _navIcon({
    required String assetPath,
    required String selectedAssetPath,
    required bool isSelected,
  }) {
    return Container(
      width: getWidth(25),
      height: getHeight(25),
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF6C2BD9), // purple background
              shape: BoxShape.circle,
            )
          : const BoxDecoration(
              // color: Colors.transparent,
              shape: BoxShape.circle,
            ),
      child: Center(
        child: SvgPicture.asset(
         isSelected ? selectedAssetPath : assetPath,
          width: getWidth(40),
          height: getHeight(40),
          colorFilter: const ColorFilter.mode(
            AppColors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, selectedIndex) {
          final cubit = context.read<NavCubit>();

          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: CurvedNavigationBar(
              color: AppColors.bottomsheetcolor,
              backgroundColor: AppColors.bottomsheetbackground,
              buttonBackgroundColor: AppColors.bottomsheetcolorl,
              index: selectedIndex, // sync bar with cubit state
              items: [
                CurvedNavigationBarItem(
                  child: _navIcon(
                    assetPath: AppIcons.homeicon,
                    isSelected: selectedIndex == 0, 
                    selectedAssetPath: AppIcons.filledhome,

                  ),
                  label: AppText.hometext,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: AppColors.white,
                  ),
                ),
                CurvedNavigationBarItem(
                  child: _navIcon(
                    assetPath: AppIcons.usageicon,
                    isSelected: selectedIndex == 1,
                     selectedAssetPath: AppIcons.filledusage,
                  ),
                  label: AppText.usage,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: AppColors.white,
                  ),
                ),
                CurvedNavigationBarItem(
                  child: _navIcon(
                    assetPath: AppIcons.toolsicon,
                    isSelected: selectedIndex == 2,
                     selectedAssetPath: AppIcons.filledTools,
                  ),
                  label: AppText.tools,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: AppColors.white,
                  ),
                ),
                CurvedNavigationBarItem(
                  child: _navIcon(
                    assetPath: AppIcons.profileicon,
                    isSelected: selectedIndex == 3, 
                    selectedAssetPath: AppIcons.filledprofile,
                  ),
                  label: AppText.profiletext,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: AppColors.white,
                  ),
                ),
              ],
              onTap: (i) {
                cubit.changeIndex(i);
              },
            ),
          );
        },
      ),
    );
  }
}