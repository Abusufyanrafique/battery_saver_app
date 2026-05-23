import 'package:battery_saver_app/bloc/Nav_bar/nav_cubit.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
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

  @override
  Widget build(BuildContext context) {
     SizeConfig().init(context); 
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) {
          final cubit = context.read<NavCubit>();

          return Scaffold(
            body: pages[index],

            bottomNavigationBar: CurvedNavigationBar(
              color: Color(0xFF181C3B),
              backgroundColor: Color(0xFF0E112F),

              items:  [
                CurvedNavigationBarItem(
                 child: SvgPicture.asset(AppIcons.homeicon),
                  label: 'Home',
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: Colors.white
                  )
                ),
                CurvedNavigationBarItem(
                  child:SvgPicture.asset(AppIcons.usageicon),
                  label: 'Usage',
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: Colors.white
                  )
                ),
                CurvedNavigationBarItem(
                  child:SvgPicture.asset(AppIcons.toolsicon),
                  label: 'Tools',
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: Colors.white
                  )
                ),
                CurvedNavigationBarItem(
                 child:SvgPicture.asset(AppIcons.profileicon),
                  label: 'profile',
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(16),
                    color: Colors.white
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