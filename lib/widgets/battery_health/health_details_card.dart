import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

import 'base_card.dart';
import 'info_row.dart';

class HealthDetailsCard extends StatelessWidget {
  final String voltage;
  final String temperature;
  final String chargingCycles;
  final String manufactureDate;

  const HealthDetailsCard({
    super.key,
    required this.voltage,
    required this.temperature,
    required this.chargingCycles,
    required this.manufactureDate,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Health Details',
            style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      color: AppColors.textwhitecolor,
                      fontWeight: FontWeight.w600,
                    ),
          ),

           SizedBox(height: getHeight(20)),

          InfoRow(label: 'Battery Voltage', value: voltage),
           SizedBox(height: getHeight(20)),
          InfoRow(
            label: 'Battery Temperature',
            value: temperature,
          ),
  SizedBox(height: getHeight(20)),
          InfoRow(
            label: 'Charging Cycles',
            value: chargingCycles,
          ),
  SizedBox(height: getHeight(20)),
          InfoRow(
            label: 'Manufacture Date',
            value: manufactureDate,
          ),
        ],
      ),
    );
  }
}