import 'package:battery_saver_app/bloc/data_usage/data_usage_cubit.dart';
import 'package:battery_saver_app/bloc/data_usage/data_usage_state.dart';
import 'package:battery_saver_app/data/repositories/data_usage_repository.dart';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:battery_saver_app/widgets/data_usage/app_usage_list_card.dart';
import 'package:battery_saver_app/widgets/data_usage/custom_toggle_widget.dart';
import 'package:battery_saver_app/widgets/data_usage/storage_bar_chart.dart';
import 'package:battery_saver_app/widgets/data_usage/usage_Info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/utils/app_text.dart';


class ToolDataUsageScreen extends StatelessWidget {
  const ToolDataUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DataUsageCubit(DataUsageRepository())..loadUsage(),
      child: const _DataUsageView(),
    );
  }
}

class _DataUsageView extends StatelessWidget {
  const _DataUsageView();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: CustomAppBar(title: AppText.dataUsage),
      body: BlocBuilder<DataUsageCubit, DataUsageState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Toggle
                SizedBox(
                  width: double.infinity,
                  child: const CustomToggleWidget(),
                ),
                SizedBox(height: getHeight(24)),

                // Total usage display
                if (state is DataUsageLoading) ...[
                   Center(
                    child: Column(
                      children: [
                        SizedBox(height: getHeight(16)),
                        CircularProgressIndicator(
                          color: Color(0xFF55D0FF),
                        ),
                        SizedBox(height: getHeight(8)),
                        Text(
                          AppText.loadingusagedata,
                          style: TextStyle(color: Color(0xFF8A9BC5), fontSize: 14)),
                      ],
                    ),
                  ),
                ] else if (state is DataUsageLoaded) ...[
                  _buildContent(context, state.data),
                ] else if (state is DataUsageError) ...[
                  _buildError(context, state.message),
                ] else ...[
                  // Initial — show placeholder
                  _buildContent(context, null),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DataUsageModel? data) {
    final totalText = data?.totalUsedFormatted.split(' ') ?? ['--', 'GB'];
    final wifiText = data?.wifiUsageFormatted ?? '--';

    return Column(
      children: [
        // Total used number
        Center(
          child: Text.rich(
            TextSpan(
              text: totalText[0] + ' ',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(32),
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: totalText.length > 1 ? totalText[1] : 'GB',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(24),
                    color: AppColors.textwhitecolor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Text(
            AppText.used,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: getFont(16),
              color: AppColors.allsmalltextcolor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: getHeight(8)),

        // Bar chart — real daily data
        StorageBarChart(
          data: data?.dailyDataMB,
          period: data?.period ?? UsagePeriod.today,
        ),

        SizedBox(height: getHeight(20)),

        // App usage list
        if (data != null)
          AppUsageListCard(
            items: data.appUsages.map((a) => AppUsageItem(
              name: a.name,
              svgAssetPath: a.svgAssetPath,
              usageMB: a.usageMB,
              maxMB: a.maxMB,
              barColor: a.barColor,
            )).toList(),
          ),

        SizedBox(height: getHeight(20)),

        // Wi-Fi usage card
        UsageInfoCard(
          label: AppText.wifiUsage,
          value: wifiText,
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.wifi_off, color: Color(0xFF55D0FF), size: 48),
          const SizedBox(height: 12),
          Text(
            'Could not load data\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8A9BC5), fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<DataUsageCubit>().retry(),
            child: const Text(
              AppText.retrytext, 
              style: TextStyle(color: Color(0xFF55D0FF))
              ),
          ),
        ],
      ),
    );
  }
}