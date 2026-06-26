// ─────────────────────────────────────────────
//  MAIN DRAWER WIDGET
// ─────────────────────────────────────────────
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/routes/app_routes.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';


class PhoneOptimizerDrawer extends StatelessWidget {
  final String selectedItem;
  final ValueChanged<String> onItemSelected;

  const PhoneOptimizerDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });


  @override
  Widget build(BuildContext context) {
    final List<_DrawerItem> _mainItems = [
  _DrawerItem(
    AppText.hometext,
    AppImages.menuhome,
    AppColors.drawerHomeColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.home),
  ),
  _DrawerItem(
    AppText.junkCleaner,
    AppImages.menujunk,
    AppColors.drawerJunkCleanerColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.junkCleanerScreen),
  ),
  _DrawerItem(
    AppText.phoneBoost,
    AppImages.menuphoneboost,
    AppColors.drawerPhoneBoostColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.phoneBoostScreen),
  ),
  _DrawerItem(
    AppText.batterySaver,
    AppImages.menubatterysaver,
    AppColors.drawerBatterySaverColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.batterySaverScreen),
  ),
  _DrawerItem(
    AppText.cpuCooler,
    AppImages.menuCPUCooler,
    AppColors.drawerCpuCoolerColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.cpuCoolerScreen),
  ),
  _DrawerItem(
    AppText.securityScan,
    AppImages.menusecurityscan,
    AppColors.drawerSecurityScanColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.securityScanScreen),
  ),
  _DrawerItem(
    AppText.notificationCleaner,
    AppImages.menunotificationcleaner,
    AppColors.drawerNotificationCleanerColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.notificationCleanerScreen),
  ),
  _DrawerItem(
    AppText.appManager,
    AppImages.menuappsmanager,
    AppColors.drawerAppManagerColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.appManagerScreen),
  ),
  _DrawerItem(
    AppText.fileManager,
    AppImages.menufilemanager,
    AppColors.drawerFileManagerColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.fileManagerScreen),
  ),
  _DrawerItem(
    AppText.dataUsage,
    AppImages.menudatausage,
    AppColors.drawerDataUsageColor.withOpacity(0.20),
    onTap: () => context.push(AppRoutes.tooldataUsageScreen),
  ),
];
   final List<_DrawerItem> _bottomItems = [
  _DrawerItem(
    AppText.settings,
    AppImages.menusettings,
    AppColors.drawerSettingsColor.withOpacity(0.20),
    // onTap: () => context.push(AppRoutes.settings),
  ),
  _DrawerItem(
    AppText.feedback,
    AppImages.menufeedback,
    AppColors.drawerFeedbackColor.withOpacity(0.20),
  ),
  _DrawerItem(
    AppText.rateUs,
    AppImages.menurateus,
    AppColors.drawerRateUsColor.withOpacity(0.20),
  ),
  _DrawerItem(
    AppText.shareApp,
    AppImages.menushareapp,
    AppColors.drawerShareAppColor.withOpacity(0.20),
  ),
  _DrawerItem(
    AppText.privacyPolicy,
    AppImages.menuprivacyPolicy,
    AppColors.drawerPrivacyPolicyColor.withOpacity(0.20),
  ),
];
    return Drawer(
      width: getWidth(270),

      //  BACKGROUND GRADIENT ADDED
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:AppColors.drawerGradient
          ),
        ),

        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(),

            // ── Main menu ───────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                   SizedBox(height: getHeight(8)),

                  ..._mainItems.map(
                    (item) => _DrawerTile(
                      item: item,
                      isSelected: selectedItem == item.label,
                      onTap: () => onItemSelected(item.label),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(
                      color: Color(0xFF373C62),
                      thickness: 1,
                    ),
                  ),

                  ..._bottomItems.map(
                    (item) => _DrawerTile(
                      item: item,
                      isSelected: selectedItem == item.label,
                      onTap: () => onItemSelected(item.label),
                    ),
                  ),

                   SizedBox(height: getHeight(16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.drawerHeaderGradient,
              ),
            ),
            child: Container(
              width: getWidth(40),
              height: getHeight(40),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.drawerGradient,
                ),
              ),
              child: Container(
  width: getWidth(40),
  height: getHeight(40),
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: AppColors.drawerGradient
    ),
  ),
  
  alignment: Alignment.center,
  child: SvgPicture.asset(
    AppIcons.cleanicon,
    width: getWidth(20),
    height: getHeight(20),
  ),
),
            ),
          ),

          SizedBox(width: getWidth(14)),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.phoneOptimizerdrawer,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
               SizedBox(height: getHeight(2)),
              Text(
                AppText.versiontext,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.allsmalltextcolor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DRAWER TILE
// ─────────────────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final _DrawerItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            item.onTap?.call(); 
            onTap(); 
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              gradient: isSelected
                  ?  LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.selectedTileTop,
                        AppColors.selectedTileMid,
                        AppColors.selectedTileBottom,
                        
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: getWidth(24),
                  height: getHeight(24),
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:Image.asset(item.imagepath)
                ),

                 SizedBox(width: getWidth(10)),

                Expanded(
                  child: Text(
                    item.label,
                    style:AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(14),
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF989CDF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class _DrawerItem {
  final String label;
  final String imagepath;
  final Color iconColor;
  final VoidCallback? onTap;

  const _DrawerItem(
    this.label, 
    this.imagepath, 
    this.iconColor, 
    {this.onTap});
}