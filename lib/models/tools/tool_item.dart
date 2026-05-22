import 'package:flutter/material.dart';
class ToolItem {
  final String title;
  final String subtitle;
  final String? imagepath;
  final String? backgroundImage; // ← NEW
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String route;

  const ToolItem({
    required this.title,
    required this.subtitle,
    this.imagepath,
    this.backgroundImage, // ← NEW
    this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.route,
  });
}