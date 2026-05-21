import 'package:flutter/material.dart';

class ToolItem {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color iconBgColor;
  final String? imagepath;
  final String route;
 
  const ToolItem({
    required this.title,
    required this.subtitle,
    this.icon,
     this.iconColor,
    required this.iconBgColor,  
    this.imagepath, 
    required this.route,
  });
}