import 'package:battery_saver_app/bloc/battery_saver_bloc_home/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver_home_screen/battery_saver_home_screen_widgets.dart';
import 'package:battery_saver_app/widgets/battery_saver_home_screen/result_battery_saver_widgets.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResultBatterySaverScreen extends StatelessWidget {
  const ResultBatterySaverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocBuilder<BatterySaverHomeBloc, BatterySaverHomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.allscreenBackgroundColor,
          appBar: CustomAppBar(title: AppText.batterySaver),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getHeight(20)),

                  // Image
                  Container(
                    height: getHeight(200),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage(AppImages.resultbatterysaver),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title — mode ke mutabiq dynamic text
                  Center(
                    child: Text(
                      AppText.batterySaverIsActive,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(20),
                        fontWeight: FontWeight.w600,
                        color: AppColors.checkiconcolor,
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(8)),

                  // Dynamic subtitle — selected mode ka naam show karo
                  Center(
                    child: Text(
                      _getModeDescription(state.selectedMode),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        color: AppColors.allsmalltextcolor,
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(24)),

                  // BatteryLifeWidget — real BLoC data se
                  BatteryLifeWidget(
                    batteryLifeInfo: state.batteryLifeInfo,
                    batteryLevel: state.batteryLevel,
                    isCharging: state.isCharging,
                  ),

                  SizedBox(height: getHeight(24)),

                  // Done button
                  CleanButtonWidget(
                    text: AppText.done,
                    onPressed: () {
                      context
                          .read<BatterySaverHomeBloc>();
                          // .add(const DeactivateBatterySaver());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getModeDescription(SaverMode mode) {
    switch (mode) {
      case SaverMode.smart:
        return AppText.yourDeviceIsNowInSmartSaverModeToExtendBatteryLife;
      case SaverMode.ultra:
        return 'Your device is now in Ultra Saver mode for maximum battery life.';
      case SaverMode.custom:
        return 'Your device is now in Custom Saver mode with your preferred settings.';
    }
  }
}