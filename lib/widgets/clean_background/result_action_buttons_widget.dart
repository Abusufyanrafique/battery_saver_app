import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';


class ResultActionButtonsWidget extends StatelessWidget {
  final VoidCallback onViewDetails;
  final VoidCallback onDone;
  final VoidCallback onCleanAgain;

  const ResultActionButtonsWidget({
    super.key,
    required this.onViewDetails,
    required this.onDone,
    required this.onCleanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // View Details Button
        Expanded(
          child: _OutlineButton(
            onTap: onViewDetails,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.checkiconcolor,
                  size: getWidth(20),
                ),
                SizedBox(width: getWidth(6)),
                Text(
                  AppText.viewDetailstext,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.bluetextcolor,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: getWidth(8)),

        // Done Button (Green - Center)
        Expanded(
          child: GestureDetector(
            onTap: onDone,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: getHeight(14)),
              decoration: BoxDecoration(
                color: const Color(0xFF14CA3B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF00FF09)
                )
              ),
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: getWidth(10),),
    Icon(
      Icons.home_rounded,
      color: Colors.white,
      size: getWidth(22),
    ),

    SizedBox(width: getWidth(6)),

    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppText.done,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(12),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          AppText.backtoHome,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: getFont(10),
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    ),
  ],
)
            ),
          ),
        ),

        SizedBox(width: getWidth(8)),

        // Clean Again Button
        Expanded(
          child: _OutlineButton(
            onTap: onCleanAgain,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sync_rounded,
                  color: const Color(0xFF9A3CFF),
                  size: getWidth(20),
                ),
                SizedBox(width: getWidth(6)),
                Text(
                 AppText.cleanAgain,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9A3CFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _OutlineButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: getHeight(22)),
        decoration: BoxDecoration(
          color: Color(0xFF1B235C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4103AC),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}