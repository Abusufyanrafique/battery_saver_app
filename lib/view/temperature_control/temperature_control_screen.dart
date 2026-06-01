import 'package:battery_saver_app/bloc/temperature/temperature_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/temperature_control/temperature_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TemperatureControlScreen extends StatelessWidget {
  const TemperatureControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocProvider(
      create: (_) => TemperatureBloc()..add(TemperatureStarted()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),

        appBar: CustomAppBar(
          title: AppText.temperatureControl,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                SizedBox(height: getHeight(10)),

                // Image
                Container(
                  height: getHeight(200),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.temperaturecontorl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Center(
                  child: Text(
                    AppText.keepYourDeviceCool,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: getFont(20),
                      color: const Color(0xFF55D0FF),
                    ),
                  ),
                ),

                SizedBox(height: getHeight(6)),

                // Subtitle
                Center(
                  child: Text(
                    AppText.monitorandreducedevicetemperatureforbatter,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: getFont(14),
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                ),

                SizedBox(height: getHeight(30)),

                // Temperature Widget
                const TemperatureWidget(),

                SizedBox(height: getHeight(25)),

                // Button
                Builder(
                  builder: (context) => CleanButtonWidget(
                    text: AppText.coolDownNow,
                    onPressed: () {
                      context.read<TemperatureBloc>().add(TemperatureCoolDownStarted());
                      context.push('/ResultTemperatureControlScreen');
                    },
                  ),
                ),

                SizedBox(height: getHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}