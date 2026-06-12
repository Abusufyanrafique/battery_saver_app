import 'package:battery_saver_app/bloc/optimization_bloc/optimization_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/optimize/optimization_widget.dart';
import 'package:battery_saver_app/widgets/optimize/stop_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OptimizeScreen extends StatelessWidget {           // StatefulWidget → StatelessWidget
  const OptimizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // BlocProvider yahan wrap karo taake screen ke andar Bloc available ho
    return BlocProvider(
      create: (_) => OptimizationBloc()
        ..add(StartOptimizationEvent()), // screen khulte hi start
      child: const _OptimizeView(),
    );
  }
}

class _OptimizeView extends StatelessWidget {
  const _OptimizeView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.allscreenBackgroundColor,
        appBar: CustomAppBar(title: AppText.optimize1),
        body: BlocListener<OptimizationBloc, OptimizationState>(
          listener: (context, state) {
            // ── Complete hone par result screen pe jao ──
            if (state.isComplete) {
              context.push('/OptimizationResultScreen');
            }

            // ── Settings pe bheja — snackbar dikhao ──
            if (state.phase == OptimizationPhase.settingsOpened &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  duration: const Duration(seconds: 4),
                ),
              );
            }

            // ── Permission warning ──
            if (state.errorMessage != null &&
                state.phase == OptimizationPhase.running) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getHeight(40)),

                // ── Image (design same) ──
                Container(
                  height: getHeight(200),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.optimizeimage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: getHeight(20)),

                // ── Gradient Title ──
                Center(
                  child: Text(
                    AppText.optimizing,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.bluetextcolor,
                    ),
                  ),
                ),
                SizedBox(height: getHeight(6)),
                Center(
                  child: Text(
                    AppText.scanningdeviceandoptimizingperformance,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.allsmalltextcolor,
                    ),
                  ),
                ),
                SizedBox(height: getHeight(16)),

                // ── Task list widget ──
                const OptimizationWidget(),

                SizedBox(height: getHeight(20)),

                // ── Stop / Restart button ──
                BlocBuilder<OptimizationBloc, OptimizationState>(
                  builder: (context, state) {
                    return StopButton(
                      // Label dynamically change hoga
                      label: state.isRunning ? 'Stop' : 'Optimize Again',
                      onPressed: () {
                        if (state.isRunning) {
                          context
                              .read<OptimizationBloc>()
                              .add(StopOptimizationEvent());
                        } else {
                          context
                              .read<OptimizationBloc>()
                              .add(StartOptimizationEvent());
                        }
                      },
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