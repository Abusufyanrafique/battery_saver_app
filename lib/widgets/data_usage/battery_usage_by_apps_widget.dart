import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:battery_saver_app/bloc/battery_usage_home/battery_usage_bloc_home.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
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
                    AppText.batteryUsagebyApps,
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
                child: BlocBuilder<BatteryUsageHomeBloc, BatteryUsageHomeState>(
                  builder: (context, state) {
                    if (state is BatteryUsageHomeLoading ||
                        state is BatteryUsageHomeInitial) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is BatteryUsageHomeError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: Colors.white70,
                             fontSize: 11,
                             ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (state is BatteryUsageHomeLoaded) {
                      if (state.items.isEmpty) {
                        return const Center(
                          child: Text(
                            'No data for today',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
        // App Icon
        SvgPicture.asset(
          item.svgIcon, 
          width: getWidth(16), 
          height: getHeight(16)
          ),
        SizedBox(width: getWidth(8)),

        // App Name + Progress Bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App name + screen time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.appName,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(8),
                      color: Color(0xFFD9D9D9)
                    )
                  ),
                  Text(
                    item.usageTime,   // "2h 30m" — real screen time
                    style:  TextStyle(
                      color: Color(0xFFD9D9D9),
                      fontSize: getFont(10),
                    ),
                  ),
                  
                ],
              ),
               SizedBox(height: getHeight(2)),
              LinearProgressIndicator(
                color: const Color(0xFF891BFF),
                backgroundColor: const Color(0xFF343964),
                value: (item.percentage / 100).clamp(0.0, 1.0),
                minHeight: 4,
              ),
            ],
          ),
        ),

        SizedBox(width: getWidth(8)),

        // Battery % (estimated)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text(
            //   "${item.percentage}%",
            //   style: TextStyle(
            //     color: item.percentageColor,
            //     fontSize: 11,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            Text(
              "${item.batteryPercent.toStringAsFixed(1)}%",
              style:  TextStyle(
                color: item.percentageColor,
                fontSize: getFont(9),
              ),
            ),
          ],
        ),
        Icon(Icons.chevron_right,
        color: Color(0xFF909294),
        )
      ],
      
    );
  }
}
Color _appColor(String packageName) {
  switch (packageName) {
    case 'com.instagram.android':
      return const Color(0xFFFE39C6); // Pink

    case 'com.google.android.youtube':
      return const Color(0xFFF02767); // Red

    case 'com.whatsapp':
      return const Color(0xFF9A3CFF); // Green

    case 'com.facebook.katana':
      return const Color(0xFF39DDFE); // Blue

    default:
      return const Color(0xFF39DDFE); // Cyan
  }
}