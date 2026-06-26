import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/bloc/phone_boost/phone_boost_bloc.dart' hide RunningAppInfo;
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<CleanBackgroundBloc>(
          create: (_) => CleanBackgroundBloc()..add(StartScanningEvent()),
        ),
        BlocProvider<PhoneBoostBloc>(
          create: (_) => PhoneBoostBloc()..add(const PhoneBoostStarted()),
        ),
      ],
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
                      color: AppColors.checkiconcolor,
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
                      color: AppColors.allsmalltextcolor,
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
                const CleanResultGridWidget(),

                SizedBox(height: getHeight(24)),

                // ── Running Apps Widget ───────────────────────────
                BlocBuilder<PhoneBoostBloc, PhoneBoostState>(
                  builder: (context, state) {
                    final apps = state.topApps;

                    if (apps.isEmpty) {
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
                            colors: AppColors.drawerGradient
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color:AppColors.appWidgetBorderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 60),
                             SizedBox(height: getHeight(12)),
                             Text(
                              AppText.nobackgroundAppsFound,
                              style: TextStyle(
                                fontSize: getFont(18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    
                    final convertedApps = apps
                        .map(
                          (e) => RunningAppInfo(
                            appName: e.name,
                            packageName: e.packageName,
                            sizeFormatted: '${e.memoryMb} MB',
                            iconBytes: null,
                          ),
                        )
                        .toList();

                    return AppsRunningInBackgroundWidget(
                      apps: convertedApps,
                      selected: state.selectedApps,
                      allSelected: state.allSelected,
                      onToggleItem: (index) {
                        context.read<PhoneBoostBloc>().add(
                              PhoneBoostSelectAppEvent(index),
                            );
                      },
                      onToggleAll: () {
                        context.read<PhoneBoostBloc>().add(
                              PhoneBoostToggleAllEvent(),
                            );
                      },
                    );
                  },
                ),

                SizedBox(height: getHeight(24)),

                // ── Clean Button ──────────────────────────────────
                
                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
                  buildWhen: (prev, curr) =>
                      prev.phase != curr.phase ||
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
                              context
                                  .read<CleanBackgroundBloc>()
                                  .add(StartCleaningEvent());

                              context.read<PhoneBoostBloc>().add(
                                    const PhoneBoostCleanSelectedEvent(),
                                  );
                            }
                          : null, 
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