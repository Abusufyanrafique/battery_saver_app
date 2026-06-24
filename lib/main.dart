import 'package:battery_saver_app/bloc/battery_saver_bloc_home/battery_saver_bloc.dart';
import 'package:battery_saver_app/bloc/battery_status_cubit_usage/battery_status_cubit.dart';
import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/bloc/cpu_cooler/cpu_cooler_bloc.dart';
import 'package:battery_saver_app/bloc/file_manager/file_manager_bloc.dart';
import 'package:battery_saver_app/bloc/optimization_bloc/optimization_bloc.dart';
import 'package:battery_saver_app/bloc/power_boost/power_boost_bloc.dart';
import 'package:battery_saver_app/bloc/temperature/temperature_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/routes/router.dart';
import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/utils/helper/battery_history_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
    // ── Hive initialize karo (Flutter path automatically set karta hai)
  await Hive.initFlutter();
 
  // ── BatteryReading ka adapter register karo
  Hive.registerAdapter(BatteryReadingAdapter());
 
  // ── Box pehle se kholo taake BLoC fast ho
  await Hive.openBox<BatteryReadingHive>('battery_history');
  // Notification listener initialize
  // await NotificationScannerService.startListening();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BatterySaverBloc>(
          create: (_) => BatterySaverBloc()
            ..add(const BatterySaverInitialized()),
        ),
         BlocProvider(
      create: (_) => CleanBackgroundBloc(),
    ),

        //  ADD MORE BLOCS HERE
       BlocProvider<BatterySaverHomeBloc>(
          create: (_) => BatterySaverHomeBloc(),
        ),
          BlocProvider<CpuCoolerBloc>(
      create: (_) => CpuCoolerBloc()
        ..add(CpuCoolerStartMonitoring()),
    ),
     BlocProvider<TemperatureBloc>(
          create: (_) => TemperatureBloc(),
        ),
        BlocProvider(
        create: (context) => BatteryStatusCubit(),
        ),
        BlocProvider(
        create: (_) => FileManagerBloc(),
       ),
        BlocProvider<OptimizationBloc>(
          create: (_) => OptimizationBloc(),
        ),
       BlocProvider<PowerBoostBloc>(
  create: (_) => PowerBoostBloc()
    ..add(LoadPowerBoostDataEvent()),
),
  BlocProvider<PowerBoostBloc>(
      create: (_) => PowerBoostBloc(),
    ),
    BlocProvider(
  create: (context) => BatteryStatusCubit()..startAutoRefresh(),
),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Battery Saver App',

        routerConfig: router,

        builder: (context, child) {
          return ColoredBox(
            color: AppColors.allscreenBackgroundColor,
            child: child ?? const SizedBox(),
          );
        },

        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.allscreenBackgroundColor,

          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),

          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
      ),
    );
  }
}