import 'package:battery_saver_app/view/auth/login_screen.dart';
import 'package:battery_saver_app/view/auth/sign_up_screen.dart';
import 'package:battery_saver_app/view/battery_health/battery_health_screen.dart';
import 'package:battery_saver_app/view/battery_health/result_battery_health_screen.dart';
import 'package:battery_saver_app/view/battery_saver/battery_saver_screen.dart';
import 'package:battery_saver_app/view/battery_saver_home_screen/battery_saver_home_screen.dart';
import 'package:battery_saver_app/view/battery_saver_home_screen/result_battery_saver_screen.dart';
import 'package:battery_saver_app/view/bottom_nav/bottom_bar_screen.dart';
import 'package:battery_saver_app/view/cpu_cooler/cpu_cooler.dart';
import 'package:battery_saver_app/view/home/app_home_screen.dart';
import 'package:battery_saver_app/view/junk_cleaner/junk_cleaner_screen.dart';
import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';
import 'package:battery_saver_app/view/onboarding/onboarding_screen.dart';
import 'package:battery_saver_app/view/phone_boost/phone_boost_screen.dart';
import 'package:battery_saver_app/view/power_boost/power_boost_home_screen.dart';
import 'package:battery_saver_app/view/power_boost/result_power_boost_screen.dart';
import 'package:battery_saver_app/view/security_scan/security_scan_screen.dart';
import 'package:battery_saver_app/view/splash/splash_screen.dart';
import 'package:battery_saver_app/view/temperature_control/result_temperature_control_screen.dart';
import 'package:battery_saver_app/view/temperature_control/temperature_control_screen.dart';
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
            //  auth routes
     GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),

     GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignUpScreen(),
    ),
      GoRoute(
      path: AppRoutes.bottomBar,
      builder: (context, state) => const BottomBarScreen(),
    ),
    GoRoute(
      path: AppRoutes.batterySaverHome,
      builder: (context, state) => const BatterySaverHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.resultBatterySaver,
      builder: (context, state) => const ResultBatterySaverScreen(),
    ),
     GoRoute(
      path: AppRoutes.powerBoostHome,
      builder: (context, state) => const PowerBoostHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.resultPowerBoost,
      builder: (context, state) => const ResultPowerBoostScreen(),
    ),
     GoRoute(
      path: AppRoutes.temperatureControlScreen,
      builder: (context, state) => const TemperatureControlScreen(),
    ),
     GoRoute(
      path: AppRoutes.resultTemperatureControlScreen,
      builder: (context, state) => const ResultTemperatureControlScreen(),
    ),
     GoRoute(
      path: AppRoutes.batteryHealthScreen,
      builder: (context, state) => const BatteryHealthScreen(),
    ),
     GoRoute(
      path: AppRoutes.resultBatteryHealthScreen,
      builder: (context, state) => const ResultBatteryHealthScreen(),
    ),
    // ========================tools screen routes =======================

      GoRoute(
      path: AppRoutes.junkCleanerScreen,
      builder: (context, state) => const JunkCleanerScreen(),
    ),

      GoRoute(
      path: AppRoutes.phoneBoostScreen,
      builder: (context, state) => const PhoneBoostScreen(),
    ),
      GoRoute(
      path: AppRoutes.batterySaverScreen,
      builder: (context, state) => const BatterySaverScreen(),
    ),
     GoRoute(
      path: AppRoutes.cpuCoolerScreen,
      builder: (context, state) => const CpuCoolerScreen(),
    ),
     GoRoute(
      path: AppRoutes.securityScanScreen,
      builder: (context, state) => const SecurityScanScreen(),
    ),
      GoRoute(
      path: AppRoutes.notificationCleanerScreen,
      builder: (context, state) => const NotificationCleanerScreen(),
    ),

  ],
);