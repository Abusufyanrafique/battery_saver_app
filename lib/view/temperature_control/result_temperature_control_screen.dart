import 'package:battery_saver_app/bloc/temperature/temperature_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/temperature_control/result_temperature_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultTemperatureControlScreen extends StatefulWidget {
  const ResultTemperatureControlScreen({super.key});

  @override
  State<ResultTemperatureControlScreen> createState() =>
      _ResultTemperatureControlScreenState();
}

class _ResultTemperatureControlScreenState
    extends State<ResultTemperatureControlScreen> {
  @override
  void initState() {
    super.initState();
    // Screen open hote hi scanning shuru karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemperatureBloc>().add(TemperatureCoolDownStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocProvider.value(
      value: context.read<TemperatureBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),

        appBar: CustomAppBar(
          title: AppText.temperatureControl,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Image ──────────────────────────────────
                Container(
                  height: getHeight(200),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.resulttempimage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(30)),

                // ── Title + Subtitle (state ke hisaab se badle) ──
                BlocBuilder<TemperatureBloc, TemperatureState>(
                  builder: (context, state) {
                    final isDone = state.coolingStatus == CoolingStatus.done;

                    return Column(
                      children: [
                        Center(
                          child: Text(
                            isDone
                                ? 'Device Optimized!'
                                : AppText.optimizingdevicetemperature,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: getFont(20),
                              color: isDone
                                  ? const Color(0xFF3DDC84)
                                  : const Color(0xFF55D0FF),
                            ),
                          ),
                        ),
                        SizedBox(height: getHeight(4)),
                        Center(
                          child: Text(
                            isDone
                                ? 'Temperature reduced to ${state.tempCelsius.toStringAsFixed(1)}°C'
                                : AppText.pleasewait,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: getFont(14),
                              color: const Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: getHeight(30)),

                // ── Scan Result Widget ──────────────────────
                const ScanResultWidget(),

                SizedBox(height: getHeight(38)),

                // ── Cancel / Done Button ────────────────────
                BlocBuilder<TemperatureBloc, TemperatureState>(
                  builder: (context, state) {
                    final isDone = state.coolingStatus == CoolingStatus.done;

                    return CleanButtonWidget(
                      text: isDone ? 'Done' : AppText.cancletemp,
                      onPressed: () {
                        if (!isDone) {
                          context.read<TemperatureBloc>().add(
                            TemperatureCoolDownCancelled(),
                          );
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}