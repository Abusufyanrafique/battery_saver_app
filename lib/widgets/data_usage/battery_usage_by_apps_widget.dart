import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:battery_saver_app/bloc/battery_usage_home/battery_usage_bloc_home.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';

class BatteryUsageByAppsWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const BatteryUsageByAppsWidget({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BatteryUsageHomeBloc()
        ..add(const LoadBatteryUsageHome()),
      child: SizedBox(
        height: getHeight(150),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: getWidth(14),
            vertical: getHeight(6),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3440A0),
                Color(0xFF232C6D),
                Color(0xFF1B2153),
                Color(0xFF13173A),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Battery Usage by Apps',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(12),
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'View All',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(11),
                        color: const Color(0xFF9A3CFF),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: getHeight(6)),

              Expanded(
                child: BlocBuilder<BatteryUsageHomeBloc,
                    BatteryUsageHomeState>(
                  builder: (context, state) {
                    if (state is BatteryUsageHomeLoading ||
                        state is BatteryUsageHomeInitial) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is BatteryUsageHomeError) {
                      return Center(child: Text(state.message));
                    }

                    if (state is BatteryUsageHomeLoaded) {
                      return Column(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: state.items
                            .take(4)
                            .map((item) => _AppUsageRow(item: item))
                            .toList(),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppUsageRow extends StatelessWidget {
  final AppUsageItem item;

  const _AppUsageRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(item.svgIcon, width: 16, height: 16),
        SizedBox(width: getWidth(8)),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.appName,
                  style: const TextStyle(color: Colors.white)),
              LinearProgressIndicator(
                color: Color(0xFF891BFF),
                backgroundColor: Color(0xFF343964),
                value: item.percentage / 100,
              ),
            ],
          ),
        ),

        Text(
          "${item.percentage}%",
          style: TextStyle(color: item.percentageColor),
        ),
      ],
    );
  }
}