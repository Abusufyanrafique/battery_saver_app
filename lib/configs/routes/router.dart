import 'package:battery_saver_app/view/auth/login_screen.dart';
import 'package:battery_saver_app/view/home/app_home_screen.dart';
import 'package:battery_saver_app/view/onboarding/onboarding_screen.dart';
import 'package:battery_saver_app/view/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [

    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const AppHomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

     GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),

  ],
);