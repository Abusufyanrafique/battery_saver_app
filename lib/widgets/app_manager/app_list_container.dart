import 'package:battery_saver_app/view/app_manager/app_manager_screen.dart';
import 'package:flutter/material.dart';
import 'app_list_tile.dart';

class AppListContainer extends StatelessWidget {
  final List<AppModel> apps;
  final Function(int index) onToggle;

  const AppListContainer({
    super.key,
    required this.apps,
    required this.onToggle,
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            return AppListTile(
              app: apps[index],
              onToggle: () => onToggle(index),
              showDivider: index != apps.length - 1,
            );
          },
        ),
      ),
    );
  }
}