// lib/screens/result_battery_health_screen.dart

import 'package:battery_saver_app/bloc/battery_health/battery_health_bloc.dart';
import 'package:battery_saver_app/bloc/battery_health/battery_health_event.dart';
import 'package:battery_saver_app/bloc/battery_health/battery_health_state.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
 //  Correct import
import 'package:battery_saver_app/data/repositories/battery_repository.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_capacity_card.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_health_card.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_tips_card.dart';
import 'package:battery_saver_app/widgets/battery_health/health_details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultBatteryHealthScreen extends StatelessWidget {
  // BatteryHealthScreen se real data GoRouter extra ke zariye aata hai
  final BatteryHealthModel? passedData;

  const ResultBatteryHealthScreen({super.key, this.passedData});

  @override
  Widget build(BuildContext context) {
    // Agar passedData already hai to BlocProvider bilkul zaroorat nahi
    // Data already BatteryHealthScreen ne fetch karke pass kar diya hai
    if (passedData != null) {
      return Scaffold(
        backgroundColor:AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title: AppText.batteryHealth),
        body: _buildBody(passedData!),
      );
    }

    // Sirf tab naya BLoC banao jab passedData null ho (direct navigation case)
    return BlocProvider(
      create: (_) => BatteryHealthBloc(repository: BatteryRepository())
        ..add(const LoadBatteryHealth()),
      child: Scaffold(
         backgroundColor:AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title: AppText.batteryHealth),
        body: BlocBuilder<BatteryHealthBloc, BatteryHealthState>(
          builder: (context, state) {
            if (state is BatteryHealthLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              );
            }

            if (state is BatteryHealthError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<BatteryHealthBloc>()
                          .add(const RefreshBatteryHealth()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is BatteryHealthLoaded) {
              return _buildBody(state.data);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  //  Alag method — ek baar likhao, dono cases mein reuse ho
  Widget _buildBody(BatteryHealthModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          BatteryHealthCard(
            percentage: data.healthPercent,
            status: data.healthStatus,
            description: data.healthDescription,
          ),
          const SizedBox(height: 12),

          BatteryCapacityCard(
            designCapacity: data.formattedDesignCapacity,
            currentCapacity: data.formattedCurrentCapacity,
          ),
          const SizedBox(height: 12),

          HealthDetailsCard(
            voltage: data.formattedVoltage,
            temperature: data.formattedTemperature,
            chargingCycles: data.formattedCycles,
            manufactureDate: data.deviceModel,
          ),
          const SizedBox(height: 12),

          BatteryTipsCard(
            tip: _getTipForStatus(data.healthStatus),
            subTip: _getSubTipForStatus(data.healthStatus),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getTipForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return 'Avoid overcharging your device';
      case 'fair':
        return 'Reduce screen brightness to save battery';
      case 'poor':
        return 'Consider replacing your battery soon';
      default:
        return 'Keep battery between 20%–80%';
    }
  }

  String _getSubTipForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return 'Keep battery between 20%–80%';
      case 'fair':
        return 'Avoid extreme temperatures';
      case 'poor':
        return 'Battery degradation detected';
      default:
        return 'Monitor battery regularly';
    }
  }
}
class BatteryHealthModel {
  final int batteryLevel;
  final String batteryState;
  final double voltage;
  final double temperature;
  final int chargingCycles;
  final String manufactureDate;
  final int designCapacity;
  final int currentCapacity;
  final String healthStatus;
  final int healthPercent;
  final String deviceModel;
  final String osVersion;

  const BatteryHealthModel({
    required this.batteryLevel,
    required this.batteryState,
    required this.voltage,
    required this.temperature,
    required this.chargingCycles,
    required this.manufactureDate,
    required this.designCapacity,
    required this.currentCapacity,
    required this.healthStatus,
    required this.healthPercent,
    required this.deviceModel,
    required this.osVersion,
  });

  String get formattedVoltage => '${voltage.toStringAsFixed(1)} V';
  String get formattedTemperature => '${temperature.toStringAsFixed(0)}°C';
  String get formattedDesignCapacity => '$designCapacity mAh';
  String get formattedCurrentCapacity => '$currentCapacity mAh';
  String get formattedCycles =>
      chargingCycles > 0 ? '$chargingCycles Cycles' : 'N/A';

  String get healthDescription {
    switch (healthStatus.toLowerCase()) {
      case 'good':
        return 'Your battery is in good condition.';
      case 'fair':
        return 'Battery health is moderate. Consider reducing usage.';
      case 'poor':
        return 'Battery health is poor. Consider replacement.';
      default:
        return 'Battery status unknown.';
    }
  }
}