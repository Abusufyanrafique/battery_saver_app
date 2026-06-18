import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/clean_result_grid_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/performance_boost_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/result_action_buttons_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/storage_comparison_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CleaningCompleteScreen extends StatelessWidget {
  const CleaningCompleteScreen({super.key});

  // ─── Estimate helpers ─────────────────────────────────────────────────────

  double _estimatedRamGBFromApps(int selectedApps) =>
      (selectedApps * 0.12).clamp(0.5, double.infinity);

  String _estimatedSpeed(double progress) =>
      '+${(progress.clamp(0.1, 1.0) * 35).toStringAsFixed(0)}%';

  String _estimatedBattery(double ramGB, double progress) =>
      '+${(ramGB * 35 * progress.clamp(0.1, 1.0)).clamp(5, 120).toStringAsFixed(0)}m';

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final state = context.watch<CleanBackgroundBloc>().state;

    final performance  = state.performanceData;
    final progress     = state.scanProgress;
    final selectedApps = state.appsSelected.where((e) => e).length;

    // ── Performance values ────────────────────────────────────────────────────
    // Only PerformanceBoostWidget still needs these passed as params.
    // CleanResultGridWidget & StorageComparisonWidget read BLoC themselves.
    final estimatedRamGB = _estimatedRamGBFromApps(selectedApps);

    final speedValue = (performance?.speedImproved?.isNotEmpty == true)
        ? performance!.speedImproved
        : _estimatedSpeed(progress);

    final ramValue = (performance?.ramFreed?.isNotEmpty == true)
        ? performance!.ramFreed
        : '+${estimatedRamGB.toStringAsFixed(1)} GB';

    final batteryValue = (performance?.batterySaved?.isNotEmpty == true)
        ? performance!.batterySaved
        : _estimatedBattery(estimatedRamGB, progress);

    // ─────────────────────────────────────────────────────────────────────────

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: AppText.cleaningComplete),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Hero image ─────────────────────────────────────────────────
              Container(
                height: getHeight(140),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.cleaningcomplete),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: getHeight(18)),

              // ── Title ──────────────────────────────────────────────────────
              Center(
                child: Text(
                  AppText.greatYouDeviceisNowClean,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: getFont(20),
                    color: const Color(0xFF2FE55D),
                  ),
                ),
              ),

              SizedBox(height: getHeight(4)),

              Center(
                child: Text(
                  AppText.wehavesuccessfullycleanedunnecessarfiles,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: getFont(14),
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
              ),

              SizedBox(height: getHeight(20)),

              // ── Clean Summary heading ──────────────────────────────────────
              Text(
                'Clean Summary',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textwhitecolor,
                ),
              ),

              SizedBox(height: getHeight(4)),

              // ── Grid — reads BLoC itself, no params needed ─────────────────
              const CleanResultGridWidget(),

              SizedBox(height: getHeight(20)),

              // ── Performance Boost — only widget that still needs params ─────
              PerformanceBoostWidget(
                speedValue:   speedValue,
                ramValue:     ramValue,
                batteryValue: batteryValue,
              ),

              SizedBox(height: getHeight(20)),

              // ── Storage Comparison — reads BLoC itself, no params needed ───
              const StorageComparisonWidget(),

              SizedBox(height: getHeight(20)),

              // ── Action buttons ─────────────────────────────────────────────
              ResultActionButtonsWidget(
                onViewDetails: () {},
                onDone: () => context.go('/home'),
                onCleanAgain: () {
                  context.read<CleanBackgroundBloc>().add(CleanAgainEvent());
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}