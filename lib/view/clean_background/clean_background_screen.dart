import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/clean_background/apps_runningIn_background_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/clean_result_grid_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/scanning_progress_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CleanBackGroundScreen extends StatelessWidget {
  const CleanBackGroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CleanBackgroundBloc()..add(StartScanningEvent()),
      child: const _CleanBackGroundView(),
    );
  }
}

class _CleanBackGroundView extends StatelessWidget {
  const _CleanBackGroundView();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return BlocListener<CleanBackgroundBloc, CleanBackgroundState>(
      listenWhen: (prev, curr) => curr.phase == CleanPhase.completed,
      listener: (context, state) {
        final bloc = context.read<CleanBackgroundBloc>();
        context.push('/CleaningCompleteScreen', extra: bloc);
        
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.allscreenBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Image(
                image: AssetImage(AppImages.chevron),
              ),
            ),
            title: Text(
              AppText.cleanBackgroundApp,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(24),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // ── Banner Image ──────────────────────────────────
                Container(
                  height: getHeight(150),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.cleanbackg),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(14)),

                // ── Title ─────────────────────────────────────────
                Center(
                  child: Text(
                    AppText.scanning,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: getFont(20),
                      color: const Color(0xFF55D0FF),
                    ),
                  ),
                ),

                SizedBox(height: getHeight(4)),

                Center(
                  child: Text(
                    AppText.detectingandcleaningunnecessary,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: getFont(14),
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                ),

                SizedBox(height: getHeight(32)),

                // ── Progress Bar ──────────────────────────────────
                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
                  buildWhen: (prev, curr) =>
                      prev.scanProgress != curr.scanProgress,
                  builder: (context, state) {
                    return ScanningProgressWidget(progress: state.scanProgress);
                  },
                ),

                SizedBox(height: getHeight(24)),

                // ── Result Grid ───────────────────────────────────
                // Widget reads BLoC itself — no params needed
                const CleanResultGridWidget(),

                SizedBox(height: getHeight(24)),

                // ── Running Apps Widget ───────────────────────────
               BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
  buildWhen: (prev, curr) =>
      prev.runningApps != curr.runningApps ||
      prev.appsSelected != curr.appsSelected ||
      prev.allSelected != curr.allSelected,
  builder: (context, state) {
    if (state.runningApps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        decoration: BoxDecoration(
           gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFF4103AC),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: getHeight(60),
            ),
            SizedBox(height: getHeight(12)),
            Text(
              'No Background Apps Found',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(18),
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: getHeight(6)),
            Text(
              'Your device is already optimized.\nNo unnecessary background apps are running.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: getFont(13),
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return AppsRunningInBackgroundWidget(
      apps: state.runningApps,
      selected: state.appsSelected,
      allSelected: state.allSelected,
      onToggleItem: (index) => context
          .read<CleanBackgroundBloc>()
          .add(ToggleAppSelectionEvent(index)),
      onToggleAll: () => context
          .read<CleanBackgroundBloc>()
          .add(ToggleSelectAllAppsEvent()),
    );
  },
),

                SizedBox(height: getHeight(24)),

                // ── Clean Button ──────────────────────────────────
                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
  buildWhen: (prev, curr) =>
      prev.phase       != curr.phase ||
      prev.cleanResult != curr.cleanResult,
  builder: (context, state) {
    final isReady = state.phase == CleanPhase.cleanReady;
    final isCleaning = state.phase == CleanPhase.cleaning;

    final buttonText = isCleaning
        ? 'Cleaning...'
        : (state.cleanResult != null
            ? 'Clean Now (${state.cleanResult!.cacheCleared})'
            : 'Clean Now');

    return CleanButtonWidget(
      text: buttonText,
      onPressed: isReady
          ? () {
              context.read<CleanBackgroundBloc>().add(StartCleaningEvent());
            }
          : null, // cleanReady ke ilawa har phase mein disabled
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