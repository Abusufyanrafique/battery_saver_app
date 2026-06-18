import 'package:battery_saver_app/bloc/temperature/temperature_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/temperature_control/result_temperature_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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

                // ── CIRCULAR COOLING UI ─────────────────────────────
                BlocBuilder<TemperatureBloc, TemperatureState>(
                  builder: (context, state) {
                    final isDone =
                        state.coolingStatus == CoolingStatus.done;

                    return Center(
                      child: Column(
                        children: [
                          Container(
                            height: getHeight(200),
                            width: getHeight(200),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/battery_saver/tempc.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [

                                // dark overlay
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.35),
                                  ),
                                ),

                                // ICON
                               Positioned(
  top: getHeight(55),
  child: SvgPicture.asset(
    'assets/icons/battery_saver/tempc.svg',
    height: getHeight(40),
  ),
),

                                // COOLING TEXT
                                Positioned(
                                  top: getHeight(120),
                                  child: Text(
                                    isDone ? 'Cooling...' : 'COOLING',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: getFont(14),
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF55D0FF),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),

                                // TEMPERATURE
                                Positioned(
                                  bottom: getHeight(30),
                                  child: Text(
                                    '${state.tempCelsius.toStringAsFixed(1)}°C',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontSize: getFont(22),
                                      fontWeight: FontWeight.bold,
                                      color: isDone
                                          ? const Color(0xFF55D0FF)
                                          : const Color(0xFF55D0FF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: getHeight(30)),

                // ── TITLE + SUBTITLE ─────────────────────────────
                BlocBuilder<TemperatureBloc, TemperatureState>(
                  builder: (context, state) {
                    final isDone =
                        state.coolingStatus == CoolingStatus.done;

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

                // ── RESULT WIDGET ─────────────────────────────
                const ScanResultWidget(),

                SizedBox(height: getHeight(38)),

                // ── BUTTON ─────────────────────────────
                BlocBuilder<TemperatureBloc, TemperatureState>(
                  builder: (context, state) {
                    final isDone =
                        state.coolingStatus == CoolingStatus.done;

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