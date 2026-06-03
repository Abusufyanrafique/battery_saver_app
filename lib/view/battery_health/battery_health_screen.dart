// lib/screens/battery_health_screen.dart

import 'package:battery_saver_app/bloc/battery_health/battery_health_bloc.dart';
import 'package:battery_saver_app/bloc/battery_health/battery_health_event.dart';
import 'package:battery_saver_app/bloc/battery_health/battery_health_state.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/data/repositories/battery_repository.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_health/battery_health_widget%20.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BatteryHealthScreen extends StatelessWidget {
  const BatteryHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocProvider(
      create: (_) => BatteryHealthBloc(repository: BatteryRepository())
        ..add(const LoadBatteryHealth()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: AppText.batteryHealth),
        body: SafeArea(
          child: BlocBuilder<BatteryHealthBloc, BatteryHealthState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Image
                    Container(
                      height: getHeight(200),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage(AppImages.batteryhealthimageq),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title 1
                    Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFB8CBEF), Color(0xFF0E65B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          AppText.monitorProtect,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: getFont(20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Title 2
                    Text(
                      AppText.yourBattery,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(20),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7634C0),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      AppText.checkbatteryhealthandgettipstoextendbattery,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        color: const Color(0xFFD9D9D9),
                      ),
                    ),

                    SizedBox(height: getHeight(40)),

                    // State handling
                    if (state is BatteryHealthLoading)
                      const CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                      )
                    else if (state is BatteryHealthLoaded)
                      BatteryHealthWidget(
                        healthStatus: state.data.healthStatus,
                        healthPercent: state.data.healthPercent,
                        designCapacity: state.data.formattedDesignCapacity,
                        currentCapacity: state.data.formattedCurrentCapacity,
                        batteryVoltage: state.data.formattedVoltage,
                        batteryTemperature: state.data.formattedTemperature,
                      )
                    else if (state is BatteryHealthError)
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      const SizedBox.shrink(),

                    SizedBox(height: getHeight(24)),

                    CleanButtonWidget(
                      text: AppText.viewDetails,
                      onPressed: () {
                        if (state is BatteryHealthLoaded) {
                          context.push(
                            '/ResultBatteryHealthScreen',
                            extra: state.data, // data pass karo
                          );
                        }
                      },
                    ),

                    SizedBox(height: getHeight(20)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}