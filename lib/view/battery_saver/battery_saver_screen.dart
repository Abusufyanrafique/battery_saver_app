import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/helper/battery_helpers.dart';
import 'package:battery_saver_app/view/file_manager/file_manager_screen.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/battery_saver/battery_mode_list_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatterySaverScreen extends StatelessWidget {
  const BatterySaverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocProvider(
      create: (_) => BatterySaverBloc()
        ..add(const BatterySaverInitialized()),
      child: const _BatterySaverBody(),
    );
  }
}

class _BatterySaverBody extends StatelessWidget {
  const _BatterySaverBody();

  // ─────────────────────────────────────────────
  // MODES (dynamic + safe)
  // ─────────────────────────────────────────────
  List<BatteryModeItem> getModes(BatterySaverState state) {
    return [
      BatteryModeItem(
        title: 'Power Saving Mode',
        subtitle: remainingTimeFromLevel(
          state.batteryLevel,
          modeIndex: 1,
        ),
        svgicon: AppIcons.powersavemode,
        iconBgColor: const Color(0xFF2FE55D),
      ),

      BatteryModeItem(
        title: 'Super Saving Mode',
        subtitle: remainingTimeFromLevel(
          state.batteryLevel,
          modeIndex: 2,
        ),
        svgicon: AppIcons.supersavingmode,
        iconBgColor: const Color(0xFF55D0FF),
      ),

      BatteryModeItem(
        title: 'Custom Mode',
        subtitle: state.isCharging
            ? 'Charging'
            : remainingTimeFromLevel(
                state.batteryLevel,
                modeIndex: 3,
              ),
        svgicon: AppIcons.custommode,
        iconBgColor: const Color(0xFF989CDF),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BatterySaverBloc, BatterySaverState>(
      listenWhen: (p, c) =>
          p.applySuccess != c.applySuccess ||
          p.errorMessage != c.errorMessage,
      listener: (context, state) {
        final modes = getModes(state);

        if (state.applySuccess) {
          _showSnackBar(
            context,
            message: '${modes[state.appliedIndex].title} applied!',
            color: const Color(0xFF2FE55D),
            icon: Icons.check_circle_outline,
          );
        }

        if (state.errorMessage != null) {
          _showSnackBar(
            context,
            message: state.errorMessage!,
            color: Colors.redAccent,
            icon: Icons.error_outline,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.allscreenBackgroundColor,
        appBar: const CustomAppBar(title: 'Battery Saver'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: getHeight(63)),

                // ── BATTERY UI ─────────────────────────
                BlocBuilder<BatterySaverBloc, BatterySaverState>(
                  buildWhen: (p, c) =>
                      p.batteryLevel != c.batteryLevel ||
                      p.isCharging != c.isCharging ||
                      p.remainingTime != c.remainingTime,
                  builder: (context, state) {
                    return SizedBox(
                      height: getHeight(200),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const FileManagerPage(),
    ),
  );
                            },
                            child: Image.asset(
                              AppImages.batterysaverimage,
                              height: getHeight(200),
                            ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.isCharging)
                                const Icon(
                                  Icons.bolt,
                                  color: Color(0xFF2FE55D),
                                  size: 16,
                                ),

                              Text(
                                state.batteryLevel == 0
                                    ? '...'
                                    : '${state.batteryLevel}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              Text(
                                state.isCharging
                                    ? 'Charging'
                                    : state.remainingTime,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: getHeight(64)),

                // ── STATUS ─────────────────────────────
                BlocBuilder<BatterySaverBloc, BatterySaverState>(
                  buildWhen: (p, c) =>
                      p.healthStatus != c.healthStatus,
                  builder: (context, state) {
                    return Center(
                      child: Text(
                        'Battery Status: ${state.healthStatus}',
                        style: TextStyle(
                          // color: healthColor(state.healthStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: getHeight(150)),

                // ── MODE LIST ───────────────────────────
                BlocBuilder<BatterySaverBloc, BatterySaverState>(
                  buildWhen: (p, c) =>
                      p.selectedIndex != c.selectedIndex ||
                      p.appliedIndex != c.appliedIndex ||
                      p.batteryLevel != c.batteryLevel ||
                      p.isCharging != c.isCharging,
                  builder: (context, state) {
                    final modes = getModes(state);

                    return BatteryModeListWidget(
                      items: modes,
                      selectedIndex: state.selectedIndex,
                      appliedIndex: state.appliedIndex,
                      onSelect: (i) => context
                          .read<BatterySaverBloc>()
                          .add(BatterySaverModeSelected(i)),
                    );
                  },
                ),

                SizedBox(height: getHeight(60)),

                // ── APPLY BUTTON ────────────────────────
                BlocBuilder<BatterySaverBloc, BatterySaverState>(
                  builder: (context, state) {
                    return CleanButtonWidget(
                      text: state.isApplying ? 'Applying...' : 'Apply',
                      onPressed: state.isApplying
                          ? null
                          : () => context
                              .read<BatterySaverBloc>()
                              .add(const BatterySaverApplyPressed()),
                    );
                  },
                ),

                SizedBox(height: getHeight(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}