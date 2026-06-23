import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  static const List<FeatureData> _features = [
    FeatureData(
      iconPath: AppImages.batteryhome1,
      chevronColor: Color(0xFF9A3CFF),
      gradientColors: [Color(0xFF181C3B)],
      title: AppText.batterySaverhome,
      subtitle: AppText.savepowerandextendbatterylife,
      iconBgColor: Color(0xFF9A3CFF),
      route: '/BatterySaverHomeScreen',
      trailingIconPath: AppImages.homearrow1,
    ),
    FeatureData(
      iconPath: AppImages.powerboost1,
      chevronColor: Color(0xFF9A3CFF),
      gradientColors: [Color(0xFF1A1000)],
      title: AppText.powerBoosthome,
      subtitle: AppText.boostperformancewhenneeded,
      iconBgColor: Color(0x3355D0FF),
      route: '/PowerBoostHomeScreen',
      trailingIconPath: AppImages.powerboostarrow,
    ),
    FeatureData(
      iconPath: AppImages.tempcontrol1,
      gradientColors: [Color(0xFF001A3A), Color(0xFF000D1F)],
      title: AppText.temperatureControlhome,
      subtitle: AppText.keepyourdevicecool,
      chevronColor: Color(0xFF5C0EE3),
      iconBgColor: Color(0xFF5C0EE3),
      route: '/TemperatureControlScreen',
      trailingIconPath: AppImages.tempcontrolarrow,
    ),
    FeatureData(
      iconPath: AppImages.battery1,
      chevronColor: Color(0xFFFE39E0),
      gradientColors: [Color(0xFF001A10), Color(0xFF000D08)],
      title: AppText.batteryHealthhome,
      subtitle: AppText.monitorandprotectyourbattery,
      iconBgColor: Color(0xFFFE39C6),
      trailingIconPath: AppImages.batteryhealtharrow,
      iconGradient: [Color(0xFFFE39C6), Color(0xFF5C0EE3)],
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
      children: _features.map((f) => FeatureCard(data: f)).toList(),
    );
  }
}

class FeatureData {
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final Color chevronColor;
  final String iconPath;
  final Color iconBgColor;
  final String route;
  final List<Color>? iconGradient;
  final String trailingIconPath;

  const FeatureData({
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.chevronColor,
    required this.iconPath,
    required this.iconBgColor,
    required this.route,
    required this.trailingIconPath,
    this.iconGradient,
  });
}

class FeatureCard extends StatelessWidget {
  final FeatureData data;

  const FeatureCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.route.isNotEmpty) context.push(data.route);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF181C3B),
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
                color: data.iconGradient == null ? data.iconBgColor : null,
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
                  width: getWidth(20),
                  height: getHeight(20),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: getWidth(6)),
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
                  SizedBox(height: getHeight(3)),
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
            Image.asset(
              data.trailingIconPath,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}