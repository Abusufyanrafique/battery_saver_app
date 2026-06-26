import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:flutter/material.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;

  const BaseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
     this.width, 
     this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
         gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:AppColors.drawerGradient
        ),
        borderRadius: BorderRadius.circular(12),
          border: Border.all(
          color: AppColors.appWidgetBorderColor,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}