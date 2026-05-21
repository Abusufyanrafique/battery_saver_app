
import 'package:battery_saver_app/widgets/battery_health/battery_app_bar.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_capacity_card.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_health_card.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_tips_card.dart';
import 'package:battery_saver_app/widgets/battery_health/health_details_card.dart';
import 'package:flutter/material.dart';

class ResultBatteryHealthScreen extends StatelessWidget {
  const ResultBatteryHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: const BatteryAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          children: const [
            BatteryHealthCard(
              percentage: 85,
              status: 'Good',
              description: 'Your battery is in good condition.',
            ),
            SizedBox(height: 12),

            BatteryCapacityCard(
              designCapacity: '5000mah',
              currentCapacity: '4250mah',
            ),
            SizedBox(height: 12),

            HealthDetailsCard(
              voltage: '3.9V',
              temperature: '32°C',
              chargingCycles: '286 Cycles',
              manufactureDate: 'Jan 2026',
            ),
            SizedBox(height: 12),

            BatteryTipsCard(
              tip: 'Avoid overcharging your device',
              subTip: 'Keep battery between 20%–80%',
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}