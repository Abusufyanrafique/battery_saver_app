import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/app_manager/app_list_container.dart';
import 'package:battery_saver_app/widgets/app_manager/app_manager_tabBar.dart';
import 'package:battery_saver_app/widgets/app_manager/stats_card.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';

class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});

  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
  int _selectedTabIndex = 0;

  // Sample data - in real app, fetch from device
  final List<AppModel> _apps = [
    AppModel(name: AppText.whatapp, iconAsset: AppIcons.whatsappicon, sizeMB: 452),
    AppModel(name: AppText.facebook, iconAsset: AppIcons.facebookicon, sizeMB: 412),
    AppModel(name: AppText.instagram, iconAsset: AppIcons.instagramicon, sizeMB: 398),
    AppModel(name: AppText.youTube, iconAsset: AppIcons.youtubeicon, sizeMB: 278),
    AppModel(name: AppText.telegram, iconAsset: AppIcons.telegram, sizeMB: 245),
    AppModel(name: AppText.spotify, iconAsset: AppIcons.spotify, sizeMB: 234),
  ];

  // APK Files list — same structure, just different data
  final List<AppModel> _apkFiles = [
    AppModel(name: AppText.whatapp, iconAsset: AppIcons.whatsappicon, sizeMB: 52.4),
    AppModel(name: AppText.facebook, iconAsset: AppIcons.facebookicon, sizeMB: 62.7),
    AppModel(name: AppText.instagram, iconAsset: AppIcons.instagramicon, sizeMB: 45.3),
    AppModel(name: AppText.youTube, iconAsset: AppIcons.youtubeicon, sizeMB: 4.8),
    AppModel(name: AppText.telegram, iconAsset: AppIcons.telegram, sizeMB: 91.7),
    AppModel(name: AppText.spotify, iconAsset: AppIcons.spotify, sizeMB: 58.6),
    // AppModel(name: AppText.threads, iconAsset: AppIcons.threads, sizeMB: 40.4),
  ];

  List<AppModel> get _currentList =>
      _selectedTabIndex == 0 ? _apps : _apkFiles;

  double get _totalSizeGB {
    final totalMB = _currentList.fold<double>(0, (sum, a) => sum + a.sizeMB);
    return totalMB / 1024;
  }

  void _toggleApp(int index) {
    setState(() {
      _currentList[index].isSelected = !_currentList[index].isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: CustomAppBar(title: AppText.appManager),
      body: Column(
        children: [
          // ── Scrollable Content ───────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  AppManagerTabBar(
                    selectedIndex: _selectedTabIndex,
                    onTabChanged: (i) =>
                        setState(() => _selectedTabIndex = i),
                  ),
                  SizedBox(height: getHeight(16)),
                  // Stats Card
                  StatsCard(
                    totalApps: _currentList.length,
                    totalSizeGB: _totalSizeGB,
                  ),
                  SizedBox(height: getHeight(20)),

                  // App List — switches based on selected tab
                  AppListContainer(
                 apps: _currentList,
                 onToggle: _toggleApp,
                 isApkMode: _selectedTabIndex == 1, // ← bas yeh add karo
                 ),
                  SizedBox(height: getHeight(200)),
             CleanButtonWidget(
                text: "Uninstall (0)",
                onPressed: () {},
              ),
               
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppModel {
  final String name;
  final String iconAsset;
  final double sizeMB;
  bool isSelected;

  AppModel({
    required this.name,
    required this.iconAsset,
    required this.sizeMB,
    this.isSelected = false,
  });

  String get formattedSize {
    if (sizeMB >= 1024) {
      return '${(sizeMB / 1024).toStringAsFixed(2)} GB';
    }
    return '${sizeMB.toStringAsFixed(0)} MB';
  }
}