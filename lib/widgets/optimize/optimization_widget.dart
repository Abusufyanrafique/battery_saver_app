import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';


enum TaskStatus { completed, inProgress, pending }

class OptimizationTask {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color iconColor;
  final TaskStatus status;
  final bool isSpecial;

  const OptimizationTask({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.iconColor,
    required this.status,
    this.isSpecial = false,
  });
}

class OptimizationWidget extends StatelessWidget {
  OptimizationWidget({super.key});

  final List<OptimizationTask> tasks = const [
    OptimizationTask(
      title: AppText.cleaningJunkFiles,
      subtitle: AppText.removingUnnecessaryFiles,
      imagePath: AppImages.deleteimage,
      iconColor: AppColors.junkFiles,
      status: TaskStatus.completed,
    ),
    OptimizationTask(
      title: AppText.closingBackgroundApps,
      subtitle: AppText.stoppingBackgroundProcesses,
      imagePath: AppImages.optimizerocket,
      iconColor: AppColors.backgroundApps,
      status: TaskStatus.completed,
    ),
    OptimizationTask(
      title: AppText.optimizingSystemResources,
      subtitle: AppText.improvingSystemPerformance,
      imagePath: AppImages.optimizeresource,
      iconColor: AppColors.systemResources,
      status: TaskStatus.inProgress,
    ),
    OptimizationTask(
      title: AppText.checkingBatteryHealth,
      subtitle: AppText.analyzingBatteryStatus,
      imagePath: AppImages.checkingoptimize,
      iconColor: AppColors.batteryHealth,
      status: TaskStatus.pending,
      isSpecial: true,
    ),
    OptimizationTask(
      title: AppText.balancingTemperature,
      subtitle: AppText.ensuringOptimalTemperature,
      imagePath: AppImages.optimizetemp,
      iconColor: AppColors.temperature,
      status: TaskStatus.pending,
      isSpecial: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(
                color: Color(0xFF838283),
                height: 1,
                thickness: 0.5,
                indent: 17,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                return _TaskTile(task: tasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final OptimizationTask task;

  const _TaskTile({required this.task});

  Widget _buildStatus() {
    switch (task.status) {
      case TaskStatus.completed:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.completed, width: 1.5),
          ),
          child: Icon(Icons.check,
              size: 10, color: AppColors.completed),
        );

      case TaskStatus.inProgress:
        return SizedBox(
          width: getWidth(12),
          height: getHeight(12),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                const AlwaysStoppedAnimation(AppColors.inProgress),
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
              color: task.isSpecial
                  ? const Color(0xFF1A1F4E)
                  : const Color(0xFF232C6D),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(task.imagePath),
            ),
          ),

          SizedBox(width: getWidth(12)),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.subtitle,
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
          colors: [
            AppColors.dotGradient1,
            AppColors.dotGradient2,
          ],
        ),
      ),
    );
  }
}