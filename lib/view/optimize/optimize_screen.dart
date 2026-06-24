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

class OptimizeScreen extends StatefulWidget {
  const OptimizeScreen({super.key});

  @override
  State<OptimizeScreen> createState() => _OptimizeScreenState();
}

class _OptimizeScreenState extends State<OptimizeScreen> {
  @override
  void initState() {
    super.initState();
    // ShellRoute se aa raha bloc — yahan StartOptimizationEvent add karo
    context.read<OptimizationBloc>().add(StartOptimizationEvent());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return const _OptimizeView();
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
          listenWhen: (previous, current) =>
              !previous.isComplete && current.isComplete,
          listener: (context, state) {
            if (state.phase == OptimizationPhase.complete) {
              // extra nahi chahiye — ShellRoute bloc share karega
              context.push('/OptimizationResultScreen');
            }

            if (state.phase == OptimizationPhase.settingsOpened &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  duration: const Duration(seconds: 4),
                ),
              );
            }

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
                Container(
                  height: getHeight(200),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.rooket),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: BlocBuilder<OptimizationBloc, OptimizationState>(
                    builder: (context, state) {
                      final percent = (state.progress * 100).round();
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            bottom: getHeight(55),
                            child: Text(
                              "$percent%",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: getFont(24),
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
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
                const OptimizationWidget(),
                SizedBox(height: getHeight(24)),
                BlocBuilder<OptimizationBloc, OptimizationState>(
                  builder: (context, state) {
                    return StopButton(
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