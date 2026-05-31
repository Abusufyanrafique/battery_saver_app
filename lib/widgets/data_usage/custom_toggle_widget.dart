import 'package:battery_saver_app/bloc/data_usage/data_usage_cubit.dart';
import 'package:battery_saver_app/bloc/data_usage/data_usage_state.dart';
import 'package:battery_saver_app/models/data_usage/data_usage_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';


class CustomToggleWidget extends StatelessWidget {
  const CustomToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataUsageCubit, DataUsageState>(
      builder: (context, state) {
        final selected = context.read<DataUsageCubit>().currentPeriod;
        final isLoading = state is DataUsageLoading;

        return Container(
          height: getHeight(60),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFF232C6D), Color(0xFF1B2153), Color(0xFF13173A),
            ]),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: selected == UsagePeriod.today
                    ? Alignment.centerLeft : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF55D0FF), Color(0xFF0E5AA7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading ? null : () =>
                          context.read<DataUsageCubit>().togglePeriod(UsagePeriod.today),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: getFont(20),
                            fontWeight: FontWeight.w600,
                            color: selected == UsagePeriod.today
                                ? Colors.white : const Color(0xFF8A9BC5),
                          ),
                          child: const Text('Today'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading ? null : () =>
                          context.read<DataUsageCubit>().togglePeriod(UsagePeriod.thisMonth),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: getFont(20),
                            fontWeight: FontWeight.w600,
                            color: selected == UsagePeriod.thisMonth
                                ? Colors.white : const Color(0xFFD9D9D9),
                          ),
                          child: const Text('This Month'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}