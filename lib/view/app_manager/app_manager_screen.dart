import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/widgets/app_manager/app_list_container.dart';
import 'package:battery_saver_app/widgets/app_manager/app_manager_tabBar.dart';
import 'package:battery_saver_app/widgets/app_manager/stats_card.dart';
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
    AppModel(name: 'WhatsApp', iconAsset: 'assets/icons/whatsapp.png', sizeMB: 452),
    AppModel(name: 'Facebook', iconAsset: 'assets/icons/facebook.png', sizeMB: 412),
    AppModel(name: 'Instagram', iconAsset: 'assets/icons/instagram.png', sizeMB: 398),
    AppModel(name: 'YouTube', iconAsset: 'assets/icons/notification_cleaner/youtubeicon.svg', sizeMB: 278),
    AppModel(name: 'Telegram', iconAsset: 'assets/icons/telegram.png', sizeMB: 245),
    AppModel(name: 'Spotify', iconAsset: 'assets/icons/spotify.png', sizeMB: 234),
  ];


  double get _totalSizeGB {
    final totalMB = _apps.fold<double>(0, (sum, a) => sum + a.sizeMB);
    return totalMB / 1024;
  }

  void _toggleApp(int index) {
    setState(() {
      _apps[index].isSelected = !_apps[index].isSelected;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────
            _AppManagerAppBar(),

            // ── Scrollable Content ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      totalApps: _apps.length,
                      totalSizeGB: _totalSizeGB,
                    ),
                    const SizedBox(height: 20),
                    

                    // App List
                    AppListContainer(
                      apps: _apps,
                      onToggle: _toggleApp,
                    ),
                    const SizedBox(height: 100), // bottom padding for button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Uninstall Button ──────────────────────────────
      // bottomNavigationBar: Container(
      //   // color: AppColors.background,
      //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      //   child: UninstallButton(
      //     selectedCount: _selectedCount,
      //     onUninstall: _onUninstall,
      //   ),
      // ),
    );
  }
}

// ── App Bar Widget (local, simple enough to stay here) ──────────
class _AppManagerAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon:  Icon(Icons.arrow_back_ios,
                color: AppColors.textwhitecolor, 
                size: 18),
            onPressed: () => Navigator.maybePop(context),
          ),
           Expanded(
            child: Text(
              'App Manager',
              textAlign: TextAlign.center,
              style:AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(24),
                fontWeight:FontWeight.w700,
              )
            ),
          ),
           SizedBox(width: getWidth(48)), // balance the back button
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