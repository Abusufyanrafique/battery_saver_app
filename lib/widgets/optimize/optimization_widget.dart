import 'package:battery_saver_app/bloc/optimization_bloc/optimization_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Task metadata (sirf display info) ───────────────────────────────────────
class _TaskMeta {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color iconColor;
  final bool isSpecial;

  const _TaskMeta({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.iconColor,
    this.isSpecial = false,
  });
}

// Task ki real status ab Bloc se aayegi — is list mein sirf UI info hai
const List<_TaskMeta> _tasksMeta = [
  _TaskMeta(
    title: AppText.cleaningJunkFiles,
    subtitle: AppText.removingUnnecessaryFiles,
    imagePath: AppImages.deleteimage,
    iconColor: AppColors.junkFiles,
  ),
  _TaskMeta(
    title: AppText.closingBackgroundApps,
    subtitle: AppText.stoppingBackgroundProcesses,
    imagePath: AppImages.optimizerocket,
    iconColor: AppColors.backgroundApps,
  ),
  _TaskMeta(
    title: AppText.optimizingSystemResources,
    subtitle: AppText.improvingSystemPerformance,
    imagePath: AppImages.optimizeresource,
    iconColor: AppColors.systemResources,
  ),
  _TaskMeta(
    title: AppText.checkingBatteryHealth,
    subtitle: AppText.analyzingBatteryStatus,
    imagePath: AppImages.checkingoptimize,
    iconColor: AppColors.batteryHealth,
    isSpecial: true,
  ),
  _TaskMeta(
    title: AppText.balancingTemperature,
    subtitle: AppText.ensuringOptimalTemperature,
    imagePath: AppImages.optimizetemp,
    iconColor: AppColors.temperature,
    isSpecial: true,
  ),
];

// ─── Main Widget ─────────────────────────────────────────────────────────────
class OptimizationWidget extends StatelessWidget {
  const OptimizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OptimizationBloc, OptimizationState>(
      builder: (context, state) {
        return Container(
          height: getHeight(375),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.optimizationInProgress,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: getHeight(10)),
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tasksMeta.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFF838283),
                    height: 1,
                    thickness: 0.5,
                    indent: 17,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) {
                    // Bloc state se real status le rahe hain
                    final taskStatus = state.taskStatuses[index];
                    final meta = _tasksMeta[index];
                    return _TaskTile(meta: meta, status: taskStatus);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Task Tile ────────────────────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final _TaskMeta meta;
  final TaskStatus status;

  const _TaskTile({required this.meta, required this.status});

  Widget _buildStatus() {
    switch (status) {
      case TaskStatus.completed:
      case TaskStatus.done:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.completed, width: 1.5),
          ),
          child: Icon(Icons.check, size: 10, color: AppColors.completed),
        );

      case TaskStatus.inProgress:
        return SizedBox(
          width: getWidth(12),
          height: getHeight(12),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.inProgress),
          ),
        );

      case TaskStatus.pending:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DotIndicator(),
            SizedBox(width: 3),
            _DotIndicator(),
            SizedBox(width: 3),
            _DotIndicator(),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(60),
      child: Row(
        children: [
          Container(
            width: getWidth(40),
            height: getHeight(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: meta.isSpecial
                  ? const Color(0xFF1A1F4E)
                  : const Color(0xFF232C6D),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(meta.imagePath),
            ),
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta.subtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(10),
                    fontWeight: FontWeight.w600,
                    color: AppColors.allsmalltextcolor,
                  ),
                ),
              ],
            ),
          ),
          _buildStatus(),
        ],
      ),
    );
  }
}

// ─── Dot Indicator (same as before) ──────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  const _DotIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.dotGradient1, AppColors.dotGradient2],
        ),
      ),
    );
  }
}