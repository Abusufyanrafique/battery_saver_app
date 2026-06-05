import 'package:battery_saver_app/bloc/app_manager/app_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'app_list_tile.dart';

class AppListContainer extends StatelessWidget {
  final List<dynamic> apps; // RealAppModel ya ApkFileModel dono
  final Function(int index) onToggle;
  final bool isApkMode;

  const AppListContainer({
    super.key,
    required this.apps,
    required this.onToggle,
    this.isApkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
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
            );
          },
        ),
      ),
    );
  }
}