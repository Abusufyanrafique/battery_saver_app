import 'package:battery_saver_app/bloc/power_boost/power_boost_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/power_boost/power_boost_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PowerBoostHomeScreen extends StatefulWidget {
  const PowerBoostHomeScreen({super.key});

  @override
  State<PowerBoostHomeScreen> createState() => _PowerBoostHomeScreenState();
}

class _PowerBoostHomeScreenState extends State<PowerBoostHomeScreen> {

  @override
  void initState() {
    super.initState();

    //  Load real power boost data
    context.read<PowerBoostBloc>().add(LoadPowerBoostDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,

      appBar: CustomAppBar(
        title: AppText.powerBoost,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: BlocBuilder<PowerBoostBloc, PowerBoostState>(
            builder: (context, state) {

              return Column(
                children: [
                  SizedBox(height: getHeight(10)),

                  // Image
                  Container(
                    height: getHeight(200),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage(AppImages.powerboostimage),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(30)),

                  // RAM INFO (REAL DATA)
                  // Text(
                  //   "RAM Used: ${state.ramUsedGB}",
                  //   style: AppTextStyles.bodySmall.copyWith(
                  //     fontSize: getFont(16),
                  //     color: Colors.white,
                  //   ),
                  // ),

                  // SizedBox(height: getHeight(10)),

                  // Text(
                  //   "Running Apps: ${state.runningAppsCount}",
                  //   style: AppTextStyles.bodySmall.copyWith(
                  //     fontSize: getFont(16),
                  //     color: Colors.white70,
                  //   ),
                  // ),

                  SizedBox(height: getHeight(30)),

                  // Title 1
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF55D0FF),
                          Color(0xFF4103AC),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        AppText.boostPerformance,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Title 2
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFE39C6),
                          Color(0xFF9A3CFF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        AppText.whenYouNeedIt,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(10)),

                  // Description
                  Center(
                    child: Text(
                      AppText.clearMemoryOptimizeSystem,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        color: const Color(0xFFD9D9D9),
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(60)),

                  // System Widget (can also use state later)
                  SystemOptimizeWidget(),

                  SizedBox(height: getHeight(38)),

                  // Button
                  CleanButtonWidget(
                    text: AppText.boostNow,
                    onPressed: () {
                      context.read<PowerBoostBloc>().add(StartBoostEvent());

                      context.push('/ResultPowerBoostScreen');
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}