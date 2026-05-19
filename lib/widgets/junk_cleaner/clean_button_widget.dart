import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class CleanButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const CleanButtonWidget({
    super.key,
    this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: getHeight(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF55D0FF), // Left
              Color(0xFF226883), // Right
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0xFF55D0FF),
          //     blurRadius: 14,
          //     offset: Offset(0, 5),
          //   ),
          // ],
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.displayMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color:Colors.white ,
            )
          ),
        ),
      ),
    );
  }
}