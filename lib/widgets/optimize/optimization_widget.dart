import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';

enum TaskStatus { completed, inProgress, pending }

class OptimizationTask {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color iconColor;
  final TaskStatus status;
  final bool isSpecial; // 

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
      title: 'Cleaning Junk Files',
      subtitle: 'Removing unnecessary files',
      imagePath: AppImages.deleteimage,
      iconColor: Color(0xFFE57373),
      status: TaskStatus.completed,
    ),
    OptimizationTask(
      title: 'Closing Background Apps',
      subtitle: 'Stopping background processes',
      imagePath: AppImages.optimizerocket,
      iconColor: Color(0xFF9575CD),
      status: TaskStatus.completed,
    ),
    OptimizationTask(
      title: 'Optimizing System Resources',
      subtitle: 'Improving system performance',
      imagePath: AppImages.optimizeresource,
      iconColor: Color(0xFFBA68C8),
      status: TaskStatus.inProgress,
    ),

    //  SPECIAL 2 ITEMS
    OptimizationTask(
      title: 'Checking Battery Health',
      subtitle: 'Analyzing battery status',
      imagePath: AppImages.checkingoptimize,
      iconColor: Color(0xFF4DB6AC),
      status: TaskStatus.pending,
      isSpecial: true,
    ),
    OptimizationTask(
      title: 'Balancing Temperature',
      subtitle: 'Ensuring optimal temperature',
      imagePath: AppImages.optimizetemp,
      iconColor: Color(0xFFFFA726),
      status: TaskStatus.pending,
      isSpecial: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
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
        border: Border.all(color: const Color(0xFF1E2A5E), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.optimizationinProgress,
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
                endIndent: 20,
                indent: 17,
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

  Widget _buildStatusWidget() {
    switch (task.status) {
      case TaskStatus.completed:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
          ),
          child: const Icon(Icons.check, color: Color(0xFF4CAF50), size: 10),
        );

      case TaskStatus.inProgress:
        return  SizedBox(
          width: getWidth(12),
          height: getHeight(12),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Color(0xFF7986CB)),
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
      height: 60,
      child: Row(
        children: [
          //  IMAGE + CONDITIONAL STYLE
          Container(
            width: getWidth(40),
            height: getHeight(40),
            decoration: BoxDecoration(
               shape: BoxShape.circle,
              color: task.isSpecial
                  ? const Color(0xFF1A1F4E) // different theme
                  : const Color(0xFF232C6D),
              // borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: task.isSpecial
                    ? const Color(0xFF212650)
                    : const Color(0xFF212650),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                task.imagePath,
                fit: BoxFit.contain,
              ),
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

          _buildStatusWidget(),
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
        gradient: LinearGradient(colors: 
        [
          Color(0xFFDA2DF1),
          Color(0xFF55D0FF)
        ]),
        shape: BoxShape.circle,
        color: Color(0xFF7986CB),
      ),
    );
  }
}