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
      AppText.hometext, AppImages.menuhome, 
      Color(0xFF9A3CFF).withOpacity(0.20),
      onTap: () {
  context.push(AppRoutes.home);
}
      
      ),
    _DrawerItem(
      AppText.junkCleaner, AppImages.menujunk,
      Color(0xFF2FE55D).withOpacity(0.20),
        onTap: () {
          
  context.push(AppRoutes.junkCleanerScreen);
}
      ),
    _DrawerItem(
     AppText.phoneBoost, AppImages.menuphoneboost, 
      Color(0xFF55D0FF).withOpacity(0.20),
       onTap: () {
  context.push(AppRoutes.phoneBoostScreen);
}
      ),
    _DrawerItem(
      AppText.batterySaver, AppImages.menubatterysaver, 
      Color(0xFF00FF09).withOpacity(0.20),
        onTap: () {
          print("push to battery saver ");
  context.push(AppRoutes.batterySaverScreen);
}
      ),
    _DrawerItem(
      AppText.cpuCooler, AppImages.menuCPUCooler, 
      Color(0xFF1F8EFF).withOpacity(0.20),
      onTap: () {
  context.push(AppRoutes.cpuCoolerScreen);
}
      ),
    _DrawerItem(
      AppText.securityScan, AppImages.menusecurityscan, 
      Color(0xFF69FF89).withOpacity(0.20),
       onTap: () {
          
  context.push(AppRoutes.securityScanScreen);
}
      ),
    _DrawerItem(
     AppText.notificationCleaner, AppImages.menunotificationcleaner, 
      Color(0xFF891BFF).withOpacity(0.20),
       onTap: () {
  context.push(AppRoutes.notificationCleanerScreen);
}
      ),
    _DrawerItem(
      AppText.appManager, AppImages.menuappsmanager, 
      Color(0xFF37C8FF).withOpacity(0.20),
       onTap: () {
  context.push(AppRoutes.appManagerScreen);
}
      ),
    _DrawerItem(
      AppText.fileManager, AppImages.menufilemanager, 
      Color(0xFFF3D917).withOpacity(0.20),
       onTap: () {
  context.push(AppRoutes.fileManagerScreen);
}
      ),
    _DrawerItem(
     AppText.dataUsage, AppImages.menudatausage, 
      Color(0xFF27C3FE).withOpacity(0.20),
       onTap: () {

  context.push(AppRoutes.tooldataUsageScreen);
}
      ),
  ];

   final List<_DrawerItem> _bottomItems = [
    _DrawerItem(
      AppText.settings, AppImages.menusettings, 
      Color(0xFF989CDF).withOpacity(0.20), onTap: () {
    context.push("AppRoutes.settings");
}
      ),
    // ignore: deprecated_member_use
    _DrawerItem(
     AppText.feedback,AppImages.menufeedback, 
      Color(0xFF7075C9).withOpacity(0.20)
      ),
    _DrawerItem(
      AppText.rateUs, AppImages.menurateus, 
      Color(0xFFFFDD55).withOpacity(0.20)
      ),
    _DrawerItem(
      AppText.shareApp, AppImages.menushareapp, 
      Color(0xFF989CDF).withOpacity(0.20)
      ),
    _DrawerItem(
      AppText.privacyPolicy, AppImages.menuprivacyPolicy, 
      Color(0xFF878DF1).withOpacity(0.20)
      ),
  ];
    return Drawer(
      width: getWidth(240),

      //  BACKGROUND GRADIENT ADDED
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF232C6D),
              Color(0xFF1B2153),
              Color(0xFF13173A),
            ],
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

                  const SizedBox(height: 16),
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
                colors: [
                  Color(0xFF55D0FF),
                  Color(0xFF9A3CFF),
                  Color(0xFF1C2A8F),
                ],
              ),
            ),
            child: Container(
              width: getWidth(40),
              height: getHeight(40),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF232C6D),
                    Color(0xFF1B2153),
                    Color(0xFF13173A),
                  ],
                ),
              ),
              child: Container(
  width: getWidth(40),
  height: getHeight(40),
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [
        Color(0xFF232C6D),
        Color(0xFF1B2153),
        Color(0xFF13173A),
      ],
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