import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // Read result data from the existing BLoC provided higher in the tree.
    // If this screen is pushed on a fresh route where the BLoC is not
    // inherited, wrap it with BlocProvider.value and pass the bloc instance.
    final state = context.watch<CleanBackgroundBloc>().state;
    final result = state.cleanResult;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1633),
        appBar: CustomAppBar(title: AppText.cleaningComplete),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
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

              // Title
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

              Text(
                'Clean Summary',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textwhitecolor,
                ),
              ),

              SizedBox(height: getHeight(4)),

              // Grid driven by BLoC result data
              CleanResultGridWidget(
                items: [
                  CleanResultItem(
                    iconPath: AppIcons.files,
                    title: 'Junk Removed',
                    value: result?.junkRemoved ?? '0 MB',
                    subtitle: 'Space Freed',
                    valueColor: const Color(0xFFFE39C6),
                  ),
                  CleanResultItem(
                    iconPath: AppIcons.appsClosed,
                    title: 'Apps Closed',
                    value: result?.appsClosed ?? '0',
                    subtitle: 'Background',
                    valueColor: const Color(0xFFEDB309),
                  ),
                  CleanResultItem(
                    iconPath: AppIcons.cacheCleared,
                    title: 'Cache Cleared',
                    value: result?.cacheCleared ?? '0 MB',
                    subtitle: 'Cache',
                    valueColor: const Color(0xFF55D0FF),
                  ),
                  CleanResultItem(
                    iconPath: AppIcons.files2,
                    title: 'Residual Files Removed',
                     value: result?.residualFiles ?? '0',
                    subtitle: 'Files',
                    valueColor: const Color(0xFF9A3CFF),
                  ),
                ],
              ),

              SizedBox(height: getHeight(20)),

              const PerformanceBoostWidget(),

              SizedBox(height: getHeight(20)),

              // Storage driven by BLoC result data
              StorageComparisonWidget(
                beforeGB: result?.beforeGB ?? 0.0,
                afterGB: result?.afterGB ?? 0.0,
                totalGB: result?.totalGB ?? 0.0,
              ),

              SizedBox(height: getHeight(20)),

              ResultActionButtonsWidget(
                onViewDetails: () {
                  // View Details action
                },
                onDone: () {
                  context.go('/home');
                },
                onCleanAgain: () {
                  // Reset BLoC and go back to scanning screen
                  context
                      .read<CleanBackgroundBloc>()
                      .add(CleanAgainEvent());
                  context.pop(); // back to CleanBackGroundScreen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}