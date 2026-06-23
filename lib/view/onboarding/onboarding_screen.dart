import 'package:battery_saver_app/bloc/onboarding/onboarding_cubit.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/data/database/shared_preferences/onboarding_pref.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/view/onboarding/onboarding_screen1.dart';
import 'package:battery_saver_app/view/onboarding/onboarding_screen2.dart';
import 'package:battery_saver_app/view/onboarding/onboarding_screen3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  final pages = const [
    OnboardingScreen1(),
    OnboardingScreen2(),
    OnboardingScreen3(),
  ];

  Future<void> _finishOnboarding() async {
    await OnboardingPref.setSeen();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        backgroundColor: AppColors.allscreenBackgroundColor,
        body: BlocBuilder<OnboardingCubit, int>(
          builder: (context, index) {
            final cubit = context.read<OnboardingCubit>();

            return Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) {
                      cubit.changePage(i);
                    },
                    children: pages,
                  ),
                ),

                // ─── INDICATOR ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(10),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: index == i
                            ? AppColors.indicatorActive
                            : AppColors.indicatorInactive,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ),

                SizedBox(height: getHeight(20)),

                // ─── BUTTONS ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [

                      // BUTTON
                      Container(
                        height: getHeight(60),
                        width: getWidth(390),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.buttonGradient,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (index == pages.length - 1) {
                                _finishOnboarding();
                              } else {
                                cubit.nextPage(_controller);
                              }
                            },
                            child: Center(
                              child: Text(
                                index == pages.length - 1
                                    ? "Get Started"
                                    : "Next",
                                style: AppTextStyles.displayMedium.copyWith(
                                  fontSize: getFont(16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // SKIP
                      TextButton(
                        onPressed: () {
                          _finishOnboarding();
                        },
                        child: Text(
                          "Skip",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: getFont(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}