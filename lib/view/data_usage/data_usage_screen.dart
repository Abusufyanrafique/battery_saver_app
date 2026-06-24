import 'package:battery_saver_app/bloc/battery_status_cubit_usage/battery_status_cubit.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_status_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_usage_by_apps_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_usage_graph_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/optimization_suggestions_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/system_usage_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataUsageScreen extends StatelessWidget {
  const DataUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1035),
      appBar: AppBar(
        leading:  IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Image(
              image: AssetImage(AppImages.chevron),
            ),
          ),
        title:  Text(AppText.batteryUsage,
        style:AppTextStyles.bodyLarge.copyWith(
          fontSize: getFont(24),
          fontWeight: FontWeight.w700,
        )
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1035),
         actions: [
    Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: getWidth(34),
        height: getHeight(34),
        decoration: BoxDecoration(
          color: const Color(0xFF0E112F).withOpacity(0.20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF5C0EE3),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.calendar_month,
          color: Colors.white,
          size: 17,
        ),
      ),
    ),
  ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20),
          child: Column(
            children:  [
              BatteryStatusWidget(),
           
          SizedBox(height: getHeight(6),),
                  BatteryUsageGraphWidget(),
          
          SizedBox(height: getHeight(6),),
          // Default values ke saath
            BatteryUsageByAppsWidget(
            onViewAll: () {
              Navigator.pushNamed(context, '/BatteryUsageScreen');
            },
          ),
           SizedBox(height: getHeight(6),),
           SystemUsageWidget(),
           SizedBox(height: getHeight(6),),
           OptimizationSuggestionsWidget(
  backgroundAppsCount: 6, // ya cubit se real count
  onOptimize: () async {
    return await context.read<BatteryStatusCubit>().closeBackgroundAppsAndGetCount();
  },
  onViewAll: () {
    // navigate to full list
  },
)
            ],
          ),
        ),
      ),
    );
  }
}