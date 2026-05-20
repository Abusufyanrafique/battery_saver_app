import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_drawer/phone_optimizer_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


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
              width: 36,
              height: 36,
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
                      text: 'Battery ',
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
                          'Optimizer',
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0E112F),
              borderRadius: BorderRadius.circular(8),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
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
                  'Battery Level',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '72%',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.bolt, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: getWidth(12),
                      height: getHeight(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00FF09),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Charging',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Good Health',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(16),
                        fontWeight: FontWeight.w500,
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
  }
}

// ════════════════════════════════════════════════════════
//  STATS ROW
// ════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF181C3B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF414669), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            iconPath: AppImages.remaining,
            iconColor: Color(0xFFFF6B9D),
            value: '12 h 45 m',
            label: 'Remaining',
          ),
          _StatDivider(),
          _StatItem(
            iconPath: "assets/images/home/temp.png",
            iconColor: Color(0xFFFF9800),
            value: '32°C',
            label: 'Temperature',
          ),
          _StatDivider(),
          _StatItem(
            iconPath: AppImages.goodhe,
            iconColor: Color(0xFF4A8EFF),
            value: 'Good',
            label: 'Health',
          ),
        ],
      ),
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
    return Container(
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
            child: SvgPicture.asset(
              AppIcons.rocket,
              width: getWidth(24),
              height: getHeight(26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimize Now',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Improve battery performance',
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
                    'Optimize',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A91B8),
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
      iconPath: AppIcons.homebatteryicon,
      chevronColor: Color(0xFF9A3CFF),
      gradientColors: [Color(0xFF181C3B)],
      title: 'Battery Saver',
      subtitle: 'Save power and extend battery life',
      iconBgColor: Color(0xFF9A3CFF),
    ),
    _FeatureData(
      iconPath: AppIcons.homepowericon,
      chevronColor: Color(0xFF9A3CFF),
      gradientColors: [Color(0xFF1A1000)],
      title: 'Power Boost',
      subtitle: 'Boost performance when needed',
      iconBgColor: Color(0xFF55D0FF),
    ),
    _FeatureData(
      iconPath: AppIcons.hometempicon,
      gradientColors: [Color(0xFF001A3A), Color(0xFF000D1F)],
      title: 'Temperature Control',
      subtitle: 'Keep your device cool',
      chevronColor: Color(0xFF5C0EE3),
      iconBgColor: Color(0xFF5C0EE3),
    ),
    _FeatureData(
      iconPath: AppIcons.homebatteryhe,
      chevronColor: Color(0xFFFE39E0),
      gradientColors: [Color(0xFF001A10), Color(0xFF000D08)],
      title: 'Battery Health',
      subtitle: 'Monitor and protect your battery',
      iconBgColor: Color(0xFFFE39C6),
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
      childAspectRatio: 1.9,
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

  const _FeatureData({
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.chevronColor,
    required this.iconPath,
    required this.iconBgColor,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
            child: Center(
              child: SvgPicture.asset(
                data.iconPath,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
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
                  maxLines: 1,
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
            size: 18,
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
                  'Clean Background Apps',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(12),
                    color: Color(0xFF9DF474),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stop unused apps running\nin the background',
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
            child: SvgPicture.asset(AppIcons.checkedbox),
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
            child: Row(
              children: [
                Text(
                  'Clean Now',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(10),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Image(image: AssetImage(AppImages.cleaneNow)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}