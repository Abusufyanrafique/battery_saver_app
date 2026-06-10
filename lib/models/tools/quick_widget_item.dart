import 'package:battery_saver_app/models/tools/tool_item.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/view/file_manager/file_manager_screen.dart';
import 'package:flutter/material.dart';

class QuickWidgetItem {
  final String label;
  final String svgIcon; 
  final Color? color;
  final Color borderColor;
  final int? percentage;

  const QuickWidgetItem({
    required this.label,
    required this.svgIcon,
     this.color,
    this.percentage, 
    required this.borderColor,
  });
}
 
// ─────────────────────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────────────────────
 
final List<ToolItem> toolsData = [
  ToolItem(
    title: AppText.junkCleaner,
    subtitle: AppText.removeunnecessaryfilesandcache,
    iconColor: const Color(0xFFB39DDB),
    // iconBgColor: const Color(0xFF3D2B6B),
    imagepath: AppImages.containerrocket,
    // backgroundImage: ,
     route: '/JunkCleanerScreen',
  ),
  ToolItem(
    title: AppText.phoneBoostcreentext,
    subtitle:AppText.boostandimproveperformance,
    imagepath: AppImages.containerphoneboost,
    iconColor: const Color(0xFF80DEEA),
    // iconBgColor: const Color(0xFF1A3A4A), 
    route: '/PhoneBoostScreen',
  ),
  ToolItem(
    title: AppText.batterySavertext,
    subtitle: AppText.saverpowerandextendbatterylife,
    imagepath: AppImages.containerbattery,
    iconColor: const Color(0xFF69F0AE), 
    route: '/BatterySaverScreen',
  ),
  ToolItem(
    title: AppText.cpuCooler,
    subtitle: AppText.cooldownandreducetemperature,
    imagepath: AppImages.containercpucooler,
    route: '/CpuCoolerScreen',
  ),
  ToolItem(
    title: AppText.securityScantext,
    subtitle: AppText.protectyourdevicefromthreats,
    imagepath: AppImages.containersecurity,
    route: '/SecurityScanScreen',
  ),
  ToolItem(
    title: AppText.notificationCleanertext,
    subtitle: AppText.cleanunnecessarynotification,
    imagepath: AppImages.containernotification,
    iconColor: const Color(0xFF80DEEA),
    route: '/NotificationCleanerScreen',
  ),
  ToolItem(
    title: AppText.appManagertext,
    subtitle: AppText.manageinstalledappseasily,
    imagepath: AppImages.containerappmanager,
    iconColor: const Color(0xFFB39DDB),
     route: '/appManagerScreen',
  ),
  ToolItem(
    title: AppText.fileManager,
    subtitle: AppText.managefilesandfreeupspace,
    imagepath: AppImages.containerfile,
    // icon: Icons.folder_rounded,
    iconColor: const Color(0xFFFFCC80),
    // iconBgColor: const Color(0xFF3A2B1A),
    onTap:(context) {
       Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FileManagerPage(),
        ),
      );
    },
    //  route: '/FileManagerScreen',
  ),
  ToolItem(
    title: AppText.dataUsagetext,
    subtitle: AppText.monitordatausageinrealtime,
    imagepath: AppImages.containerdatausage,
    // icon: Icons.data_usage_rounded,
    iconColor: const Color(0xFF80DEEA),
    // iconBgColor: const Color(0xFF1A3A4A),
     route: '/tooldataUsageScreen',
  ),
];
 
final List<QuickWidgetItem> quickWidgetsData = [
 
  QuickWidgetItem(
    label: AppText.batterytext,
    svgIcon:AppIcons.greencricle,
    // color: const Color(0xFF69F0AE),
    borderColor: const Color(0xFF00FF09),
    percentage: 72,
  ),
  QuickWidgetItem(
    label: AppText.optimizetext,
    svgIcon:AppIcons.quickwidgetOptimize,
    // color: const Color(0xFFE040FB),
    borderColor: const Color(0xFF9A3CFF),
  ),
  QuickWidgetItem(
    label: AppText.cleantext,
    svgIcon:AppIcons.deleteicon,
    borderColor: const Color(0xFFFF00D9),
    
  ),
  QuickWidgetItem(
    label: AppText.boost,
    svgIcon:AppIcons.bluecricle,
    borderColor: const Color(0xFF5592FF),
    percentage: 68,
  ),
];

 