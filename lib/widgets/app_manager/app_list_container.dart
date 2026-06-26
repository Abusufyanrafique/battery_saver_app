import 'package:battery_saver_app/bloc/app_manager/app_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'app_list_tile.dart';

class AppListContainer extends StatelessWidget {
  final List<dynamic> apps;
  final Function(int index) onToggle;
  final bool isApkMode;
  final void Function(String)? onInstall;

  static const Color _gradientTop    = Color(0xFF232C6D);
  static const Color _gradientMid    = Color(0xFF1B2153);
  static const Color _gradientBottom = Color(0xFF13173A);

  const AppListContainer({
    super.key,
    required this.apps,
    required this.onToggle,
    this.isApkMode = false,
    this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradientTop, _gradientMid, _gradientBottom],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ListView.builder(
          shrinkWrap: false,
          physics: const BouncingScrollPhysics(),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            return AppListTile(
    app: apps[index],
    onToggle: () => onToggle(index),
    showDivider: index != apps.length - 1,
    isApkMode: isApkMode,
    onInstall: (isApkMode && onInstall != null)
        ? () => onInstall!((apps[index] as ApkFileModel).path)
        : null,
  );
          },
        ),
      ),
    );
  }
}