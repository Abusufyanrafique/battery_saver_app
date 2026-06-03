import 'package:flutter/material.dart';

class ToolItem {
  final String title;
  final String subtitle;
  final String? imagepath;
  final String? backgroundImage;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String? route;

  //  ADD THIS
  final void Function(BuildContext context)? onTap;

  const ToolItem({
    required this.title,
    required this.subtitle,
    this.imagepath,
    this.backgroundImage,
    this.icon,
    this.iconColor,
    this.iconBgColor,
     this.route,
    this.onTap,
  });
}