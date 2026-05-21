import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'good':
        return const Color(0xFF4ADE80);

      case 'fair':
        return const Color(0xFFFBBF24);

      case 'poor':
        return const Color(0xFFF87171);

      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      status,
       style: AppTextStyles.bodySmall.copyWith(
              fontSize:getFont(14),
              fontWeight: FontWeight.w600,
              color: _statusColor,
            )
    );
  }
}