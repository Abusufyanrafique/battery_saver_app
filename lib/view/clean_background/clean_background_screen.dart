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
        context.push('/CleaningCompleteScreen');
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

                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
                  buildWhen: (prev, curr) =>
                      prev.scanProgress != curr.scanProgress,
                  builder: (context, state) {
                    return ScanningProgressWidget(progress: state.scanProgress);
                  },
                ),

                SizedBox(height: getHeight(24)),

                // FIX: BlocBuilder se cleanResult check karo
                // cleanResult null ho (scanning chal rahi ho) toh placeholder show karo
                // cleanResult aa jaye toh real data show karo
                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
                  buildWhen: (prev, curr) =>
                      prev.cleanResult != curr.cleanResult,
                  builder: (context, state) {
                    if (state.cleanResult == null) {
                      return CleanResultGridWidget.fromData(
                        const CleanResultData(
                          junkRemoved:  '-- MB',
                          appsClosed:   '-- Apps',
                          cacheCleared: '-- MB',
                          residualFiles: '-- MB',
                          beforeGB: 0,
                          afterGB:  0,
                          totalGB:  0,
                        ),
                      );
                    }
                    return CleanResultGridWidget.fromData(state.cleanResult!);
                  },
                ),

                SizedBox(height: getHeight(24)),

                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
                  buildWhen: (prev, curr) =>
                      prev.appsSelected != curr.appsSelected,
                  builder: (context, state) {
                    return AppsRunningInBackgroundWidget(
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

                BlocBuilder<CleanBackgroundBloc, CleanBackgroundState>(
                  buildWhen: (prev, curr) => prev.phase != curr.phase,
                  builder: (context, state) {
                    final isReady = state.phase == CleanPhase.cleanReady;
                    return CleanButtonWidget(
                      text: 'Clean Now (375 MB)',
                      onPressed: isReady
                          ? () {
                              context.push('/CleaningCompleteScreen');
                              context
                                  .read<CleanBackgroundBloc>()
                                  .add(StartCleaningEvent());
                              Future.delayed(
                                const Duration(milliseconds: 1500),
                                () {
                                  if (context.mounted) {
                                    context
                                        .read<CleanBackgroundBloc>()
                                        .add(StartCleaningEvent());
                                  }
                                },
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