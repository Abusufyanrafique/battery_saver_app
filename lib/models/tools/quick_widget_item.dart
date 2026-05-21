import 'package:battery_saver_app/models/tools/tool_item.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';

class QuickWidgetItem {
  final String label;
  final String svgIcon; //  change here
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
    title: 'Junk Cleaner',
    subtitle: 'Remove unnecessary\n files and cache',
    iconColor: const Color(0xFFB39DDB),
    iconBgColor: const Color(0xFF3D2B6B),
    imagepath: AppImages.junk,
     route: '/JunkCleanerScreen',
  ),
  ToolItem(
    title: 'Phone Boost',
    subtitle: 'Boost RAM and improve performance',
    imagepath: AppImages.phoneboost,
    iconColor: const Color(0xFF80DEEA),
    iconBgColor: const Color(0xFF1A3A4A), 
    route: '/PhoneBoostScreen',
  ),
  ToolItem(
    title: 'Battery Saver',
    subtitle: 'Saver power and\nextend battery life',
    imagepath: AppImages.toolbatterysaver,
    iconColor: const Color(0xFF69F0AE),
    iconBgColor: const Color(0xFF1A3A2A), 
    route: '/BatterySaverScreen',
  ),
  ToolItem(
    title: 'CPU Cooler',
    subtitle: 'Cool down CPU and\nreduce temperature',
    icon: Icons.ac_unit_rounded,
    // iconColor: const Color(0xFF90CAF9),
    iconBgColor: const Color(0xFF1A2A4A), 
    route: '/CpuCoolerScreen',
  ),
  ToolItem(
    title: 'Security Scan',
    subtitle: 'Protect your device\nfrom threats',
    imagepath: AppImages.toolsecurityscan,
    // icon: Icons.shield_rounded,
    // iconColor: const Color(0xFF69F0AE),
    iconBgColor: const Color(0xFF1A3A2A), 
    route: '/SecurityScanScreen',
  ),
  ToolItem(
    title: 'Notification Cleaner',
    subtitle: 'Clean unnecessary\nnotification',
    // icon: Icons.notifications_rounded,
    imagepath: AppImages.toolNotificationCleaner,
    iconColor: const Color(0xFF80DEEA),
    iconBgColor: const Color(0xFF1A3A4A), 
    route: '/NotificationCleanerScreen',
  ),
  ToolItem(
    title: 'App Manager',
    subtitle: 'Manage installed\napps easily',
    // icon: Icons.apps_rounded,
    imagepath: AppImages.toolappmanager,
    iconColor: const Color(0xFFB39DDB),
    iconBgColor: const Color(0xFF3D2B6B),
     route: '',
  ),
  ToolItem(
    title: 'File Manager',
    subtitle: 'Manage files and\nfree up space',
    imagepath: AppImages.toolFileManager,
    // icon: Icons.folder_rounded,
    iconColor: const Color(0xFFFFCC80),
    iconBgColor: const Color(0xFF3A2B1A),
     route: '',
  ),
  ToolItem(
    title: 'Data Usage',
    subtitle: 'Monitor data usage\nin real-time',
    imagepath: AppImages.toolDataUsage,
    // icon: Icons.data_usage_rounded,
    iconColor: const Color(0xFF80DEEA),
    iconBgColor: const Color(0xFF1A3A4A),
     route: '',
  ),
];
 
final List<QuickWidgetItem> quickWidgetsData = [
 
  QuickWidgetItem(
    label: 'Battery',
    svgIcon:AppIcons.quikwidgetBatteryIcon,
    // color: const Color(0xFF69F0AE),
    borderColor: const Color(0xFF00FF09),
    percentage: 72,
  ),
  QuickWidgetItem(
    label: 'Optimize',
    svgIcon:AppIcons.quickwidgetOptimize,
    // color: const Color(0xFFE040FB),
    borderColor: const Color(0xFF9A3CFF),
  ),
  QuickWidgetItem(
    label: 'Clean',
    svgIcon:AppIcons.quickwidgetcleanicon,
    borderColor: const Color(0xFFFF00D9),
    
  ),
  QuickWidgetItem(
    label: 'Boost',
    svgIcon:AppIcons.quickwidgetBoost,
    borderColor: const Color(0xFF5592FF),
    percentage: 68,
  ),
];

 