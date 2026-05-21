import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(12),
            fontWeight: FontWeight.w500,
            color:AppColors.allsmalltextcolor,
          )
        ),

        Text(
          value,
          style:AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(12),
            fontWeight: FontWeight.w500,
            color:Colors.white
          )
        ),
      ],
    );
  }
}