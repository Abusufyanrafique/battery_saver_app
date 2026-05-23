import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_status_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_usage_by_apps_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/battery_usage_graph_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/optimization_suggestions_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/system_usage_widget.dart';
import 'package:flutter/material.dart';

class DataUsageScreen extends StatelessWidget {
  const DataUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1035),
      appBar: AppBar(
        title:  Text("Data Usage",
        style:AppTextStyles.bodyLarge.copyWith(
          fontSize: getFont(24),
          fontWeight: FontWeight.w700,
        )
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1035),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20),
          child: Column(
            children:  [
              BatteryStatusWidget(),
           
          SizedBox(height: getHeight(6),),
                  BatteryUsageGraphWidget(),
          
          SizedBox(height: getHeight(12),),
          // Default values ke saath
            BatteryUsageByAppsWidget(
            onViewAll: () {
              Navigator.pushNamed(context, '/BatteryUsageScreen');
            },
          ),
           SizedBox(height: getHeight(12),),
           SystemUsageWidget(),
           SizedBox(height: getHeight(12),),
            OptimizationSuggestionsWidget(
             title: 'Close background apps',
             subtitle: '6 apps are running in background',
             onViewAll: () {
              Navigator.pushNamed(context, '/OptimizationScreen');
            },
            onOptimize: () {
              // optimize logic here
            },
          ),
            ],
          ),
        ),
      ),
    );
  }
}