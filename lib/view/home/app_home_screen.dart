import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/bloc/cpu_cooler/cpu_cooler_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/utils/helper/battery_helpers.dart';
import 'package:battery_saver_app/widgets/app_drawer/phone_optimizer_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


// ════════════════════════════════════════════════════════
//  SCREEN
// ════════════════════════════════════════════════════════
class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedItem = 'Home';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: PhoneOptimizerDrawer(
        selectedItem: _selectedItem,
        onItemSelected: (item) {
          setState(() => _selectedItem = item);
          Navigator.pop(context);
        },
      ),
      backgroundColor: const Color(0xFF080C20),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: const [
              _TopBar(),
              SizedBox(height: 16),
              _BatteryCard(),
              SizedBox(height: 14),
              _StatsRow(),
              SizedBox(height: 14),
              _OptimizeBanner(),
              SizedBox(height: 14),
              _FeatureGrid(),
              SizedBox(height: 14),
              _CleanBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  TOP BAR
// ════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              width: getWidth(36),
              height: getHeight(36),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F4E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image(image: AssetImage(AppImages.meun)),
            ),
          ),
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppText.battery,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: getFont(24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFE39C6),
                              Color(0xFF5C0EE3),
                              Color(0xFF55D0FF),
                            ],
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          );
                        },
                        child: Text(
                          AppText.optimizer,
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: getFont(24),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: getWidth(36),
            height: getHeight(36),
            decoration: BoxDecoration(
              color: const Color(0xFF0E112F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Color(0xFF5C0EE3)),
            ),
            child: Image(image: AssetImage(AppImages.setting)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  BATTERY CARD
// ════════════════════════════════════════════════════════
class _BatteryCard extends StatelessWidget {
  const _BatteryCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BatterySaverBloc, BatterySaverState>(
      builder: (context, state) {
        final int battery = state.batteryLevel;

    final BatteryHealthStatus status =
        healthFromLevel(battery);

    final String healthStatus =
        batteryHealthLabel(status);

    final Color healthColor =
        batteryHealthColor(status);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(19, 10, 16, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF0EBA),
                Color(0xFF5C0EE3),
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText.batteryLevel,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 🔋 REAL BATTERY
                    Row(
                      children: [
                        Text(
                          battery == 0 ? "--" : "$battery%",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: getFont(32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.bolt,
                          color: state.isCharging
                              ? Colors.white
                              : Colors.white54,
                          size: 28,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ⚡ CHARGING
                    Row(
                      children: [
                        Container(
                          width: getWidth(12),
                          height: getHeight(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isCharging
                                ? const Color(0xFF00FF09)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isCharging ? "Charging" : "Not Charging",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: getFont(16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 💚 HEALTH
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
      batteryHealthLabel(status),
      style: TextStyle(
        color: batteryHealthColor(status),
        fontWeight: FontWeight.w600,
      ),
    ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 110,
                height: 120,
                child: Image.asset(
                  AppImages.bigbattery,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════
//  STATS ROW
// ════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CpuCoolerBloc, CpuCoolerState>(
      builder: (context, cpuState) {
        return BlocBuilder<BatterySaverBloc, BatterySaverState>(
          builder: (context, batteryState) {

            // 🔋 Battery Health
            final batteryStatus =
                healthFromLevel(batteryState.batteryLevel);

            // 💻 CPU Health (simple logic using temperature)
            final cpuHealth = cpuState.temperature >= 80
                ? BatteryHealthStatus.critical
                : cpuState.temperature >= 60
                    ? BatteryHealthStatus.low
                    : cpuState.temperature >= 40
                        ? BatteryHealthStatus.moderate
                        : BatteryHealthStatus.good;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF181C3B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF414669),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  // 🔋 Remaining TIME
                  _StatItem(
                    iconPath: AppImages.remaining,
                    iconColor: const Color(0xFFFF6B9D),
                    value: batteryState.remainingTime.isEmpty
                        ? 'Calculating...'
                        : batteryState.remainingTime,
                    label: 'Remaining',
                  ),

                  const _StatDivider(),

                  // 🌡 Temperature
                  _StatItem(
                    iconPath: "assets/images/home/temp.png",
                    iconColor: const Color(0xFFFF9800),
                    value: cpuState.temperature == 0
                        ? 'N/A'
                        : '${cpuState.temperature.toStringAsFixed(1)}°C',
                    label: 'Temperature',
                  ),

                  const _StatDivider(),

                  // 💚 Health (CPU)
                  _StatItem(
                    iconPath: AppImages.goodhe,
                    iconColor: batteryHealthColor(cpuHealth),
                    value: batteryHealthLabel(cpuHealth),
                    label: 'Health',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
class _StatItem extends StatelessWidget {
  final String iconPath;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.iconPath,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: getWidth(32),
          height: getHeight(32),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(14),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(12),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFF414669),
    );
  }
}

// ════════════════════════════════════════════════════════
//  OPTIMIZE BANNER
// ════════════════════════════════════════════════════════
class _OptimizeBanner extends StatelessWidget {
  const _OptimizeBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/OptimizeScreen');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFE39C6),
              Color(0xFF5C0EE3),
              Color(0xFF5C0EE3),
            ],
            stops: [0.0, 0.25, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCDD0E4), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: getWidth(40),
              height: getHeight(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFE39C6), Color(0xFF5C0EE3)],
                ),
              ),
              child: Image(image: AssetImage(AppImages.homerocket))
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.optimizeNow,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    AppText.improvebatteryperformance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: getHeight(24),
              width: getWidth(84),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      AppText.optimize,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w500,
                        color:  Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.white, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  FEATURE GRID
// ════════════════════════════════════════════════════════
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static List<_FeatureData> features = [
    _FeatureData(
      iconPath: AppImages.batteryhome1,
      chevronColor: Color(0xFF9A3CFF),
      gradientColors: [Color(0xFF181C3B)],
      title: 'Battery Saver',
      subtitle: 'Save power and extend battery life',
      iconBgColor: Color(0xFF9A3CFF),
       route: '/BatterySaverHomeScreen',
     
    ),
    _FeatureData(
      iconPath: AppImages.powerboost1,
      chevronColor: Color(0xFF9A3CFF),
      gradientColors: [Color(0xFF1A1000)],
      title: 'Power Boost',
      subtitle: 'Boost performance when needed',
      iconBgColor: Color(0xFF55D0FF).withOpacity(0.20), route: '/PowerBoostHomeScreen',
         
    ),
    _FeatureData(
      iconPath: AppImages.tempcontrol1,
      gradientColors: [Color(0xFF001A3A), Color(0xFF000D1F)],
      title: 'Temperature Control',
      subtitle: 'Keep your device cool',
      chevronColor: Color(0xFF5C0EE3),
      iconBgColor: Color(0xFF5C0EE3),
       route: '/TemperatureControlScreen',
         
    ),
    _FeatureData(
      iconPath: AppImages.battery1,
      chevronColor: Color(0xFFFE39E0),
      gradientColors: [Color(0xFF001A10), Color(0xFF000D08)],
      title: 'Battery Health',
      subtitle: 'Monitor and protect your battery',
      iconBgColor: Color(0xFFFE39C6),
       iconGradient: [
    Color(0xFFFE39C6),
    Color(0xFF5C0EE3),
  ],
       route: '/BatteryHealthScreen',
          
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2,
      children: features.map((f) => _FeatureCard(data: f)).toList(),
    );
  }
}

class _FeatureData {
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final Color chevronColor;
  final String iconPath;
  final Color iconBgColor;
  final String route;
  final List<Color>? iconGradient;

  const _FeatureData({
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.chevronColor,
    required this.iconPath,
    required this.iconBgColor,
     required this.route, 
     this.iconGradient, 
    
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.route.isNotEmpty) {
          context.push(data.route);
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(0xFF181C3B),
          border: Border.all(color: const Color(0xFF414669), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: getWidth(40),
              height: getHeight(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.iconBgColor,
              ),
              child:   Container(
  width: getWidth(40),
  height: getHeight(40),
  decoration: BoxDecoration(
    shape: BoxShape.circle,

    color: data.iconGradient == null
        ? data.iconBgColor
        : null,

    gradient: data.iconGradient != null
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.iconGradient!,
          )
        : null,
  ),

  child: Center(
    child: Image.asset(
      data.iconPath,
      width: 20,
      height: 20,
      fit: BoxFit.contain,
    ),
  ),
),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: data.chevronColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  CLEAN BANNER
// ════════════════════════════════════════════════════════
class _CleanBanner extends StatelessWidget {
  const _CleanBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/CleanBackGroundScreen');
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 14),
        decoration: BoxDecoration(
          color: const Color(0xFF181C3B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF9EF377), width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.cleanBackgroundApps,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(14),
                      color: Color(0xFF9DF474),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppText.stopunusedappsrunninginthebackground,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: getFont(12),
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image(image: AssetImage(AppImages.checkbox1))
            ),
            const SizedBox(width: 10),
            Container(
              height: getHeight(32),
              width: getWidth(94),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9DF474), Color(0xFF5B8E44)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      AppText.cleanNow,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(10),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: getWidth(10),),
                    Center(child: Image(
                      image: AssetImage(AppImages.cleaneNow),
                      height: getHeight(22),
                      width: getWidth(10),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}