
import 'package:battery_saver_app/bloc/battery_saver_bloc_home/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver_home_screen/battery_saver_home_screen_widgets.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
                  
class BatterySaverHomeScreen extends StatefulWidget {
  const BatterySaverHomeScreen({super.key});

  @override
  State<BatterySaverHomeScreen> createState() => _BatterySaverHomeScreenState();
}

class _BatterySaverHomeScreenState extends State<BatterySaverHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Screen open hote hi real battery info load karo
    context.read<BatterySaverHomeBloc>().add(const LoadBatteryInfo());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

 return BlocConsumer<BatterySaverHomeBloc, BatterySaverHomeState>(
  listenWhen: (previous, current) =>
      previous.status != BatterySaverStatus.active &&
      current.status == BatterySaverStatus.active,
  listener: (context, state) {
    context.push(
      '/ResultBatterySaverScreen',
      extra: context.read<BatterySaverHomeBloc>(), 
    );
  },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.allscreenBackgroundColor,
          appBar: CustomAppBar(title: AppText.batterySaver),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getHeight(20)),

                  // Battery image
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

                  SizedBox(height: getHeight(16)),

// =========── Real Battery Level Badge ─────────────────────────── keep in mind ===+++++++++++++
                  // _BatteryLevelBadge(state: state),

                  SizedBox(height: getHeight(20)),

                  // Gradient Title
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFE39C6), Color(0xFF9A3CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        AppText.batterySaverDescription,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(12)),

                  Center(
                    child: Text(
                      AppText.optimizeSystemSettings,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: getHeight(22)),

                  // Mode Card — BLoC se connected
                  BatterySaverModeCard(
                    selected: state.selectedMode,
                    onChanged: (mode) {
                      context
                          .read<BatterySaverHomeBloc>()
                          .add(SelectSaverMode(mode));
                    },
                  ),

                  SizedBox(height: getHeight(20)),

                  // Activate Button
                  CleanButtonWidget(
                    text: state.isActivating
                        ? 'Activating...'
                        : AppText.activateBatterySaver,
                    onPressed: state.isActivating
                        ? null
                        : () {
                            context
                                .read<BatterySaverHomeBloc>()
                                .add(const ActivateBatterySaver());
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
}

// ─── Battery Level Badge Widget ───────────────────────────────────────────────

class _BatteryLevelBadge extends StatelessWidget {
  final BatterySaverHomeState state;

  const _BatteryLevelBadge({required this.state});

  Color get _levelColor {
    final level = state.batteryLevel ?? 50;
    if (state.isCharging) return const Color(0xFF55D0FF);
    if (level >= 60) return const Color(0xFF00FF09);
    if (level >= 30) return const Color(0xFFFFD700);
    return const Color(0xFFFF4444);
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return Center(
        child: SizedBox(
          height: getHeight(20),
          width: getWidth(20),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFE39C6),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2153),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _levelColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Battery icon color-coded
            Icon(
              state.isCharging
                  ? Icons.battery_charging_full_rounded
                  : _batteryIcon(state.batteryLevel ?? 50),
              color: _levelColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              state.batteryLevelText,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w700,
                color: _levelColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '• ${state.chargeStatusText}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: getFont(12),
                color: const Color(0xFFD9D9D9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _batteryIcon(int level) {
    if (level >= 90) return Icons.battery_full_rounded;
    if (level >= 60) return Icons.battery_5_bar_rounded;
    if (level >= 40) return Icons.battery_3_bar_rounded;
    if (level >= 20) return Icons.battery_2_bar_rounded;
    return Icons.battery_1_bar_rounded;
  }
}