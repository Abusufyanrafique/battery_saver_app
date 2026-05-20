import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// ════════════════════════════════════════════════════════
//  SCREEN
// ════════════════════════════════════════════════════════
class AppHomeScreen extends StatelessWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F4E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image(image: AssetImage(AppImages.meun))
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
                  fontWeight: FontWeight.w700
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
              child:  Text(
                'Optimizer',
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: getFont(24),
                  fontWeight: FontWeight.w700
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
              color: const Color(0xFF1A1F4E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image(image: AssetImage(AppImages.setting))
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
                  style:AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(16),
                    fontWeight: FontWeight.w600,
                  )
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    Text(
                      '72%',
                       style:AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(32),
                    fontWeight: FontWeight.w600,
                  )
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
                     style:AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(16),
                    fontWeight: FontWeight.w500,
                  )
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children:  [
                    Icon(Icons.favorite_border,
                        color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Good Health',
                     style:AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(16),
                    fontWeight: FontWeight.w500,
                  )
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



class _BatteryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 48),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      arcPaint,
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7B2FBE), Color(0xFF4A0CA3)],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: 50, height: 80))
      ..style = PaintingStyle.fill;

    final bodyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 18, cy - 36, 36, 68),
        const Radius.circular(8));
    canvas.drawRRect(bodyRect, bodyPaint);

    final tipPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 8, cy - 42, 16, 8),
          const Radius.circular(3)),
      tipPaint,
    );

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00CFFF), Color(0xFF0055FF)],
      ).createShader(Rect.fromLTWH(cx - 14, cy - 28, 28, 52))
      ..style = PaintingStyle.fill;

    final fillHeight = 52 * 0.72;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 14, cy - 28 + (52 - fillHeight), 28, fillHeight),
          const Radius.circular(4)),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════
//  STATS ROW
// ════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: getHeight(60),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF181C3B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F5A), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:  [
          _StatItem(
           iconPath: AppImages.remaining,
            iconColor: Color(0xFFFF6B9D),
            value: '12 h 45 m',
            label: 'Remaining',
          ),
          _StatDivider(),
          _StatItem(
            iconPath: AppImages.hometempimage,
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
  final String iconPath; // 👈 now image path
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
    return Column(
      children: [
        // 👇 Image instead of Icon
        Image.asset(
          iconPath,
          width: 22,
          height: 22,
          color: iconColor, // optional tint
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8A91B8),
          ),
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
      color: const Color(0xFF2A2F5A),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111638),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F5A), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7B2FBE), Color(0xFFCC44FF)],
              ),
            ),
            child: const Icon(Icons.rocket_launch_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Optimize Now',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                SizedBox(height: 3),
                Text('Improve battery performance',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF8A91B8))),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color(0xFF4A4FCC), width: 1.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Text('Optimize',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
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

  static const List<_FeatureData> features = [
    _FeatureData(
      icon: Icons.battery_saver_rounded,
      iconColor: Color(0xFFFF6B9D),
      gradientColors: [Color(0xFF3A0050), Color(0xFF1A0030)],
      title: 'Battery Saver',
      subtitle: 'Save power and extend battery life',
    ),
    _FeatureData(
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFFFFCC00),
      gradientColors: [Color(0xFF1A1000), Color(0xFF0D0800)],
      title: 'Power Boost',
      subtitle: 'Boost performance when needed',
    ),
    _FeatureData(
      icon: Icons.ac_unit_rounded,
      iconColor: Color(0xFF00CFFF),
      gradientColors: [Color(0xFF001A3A), Color(0xFF000D1F)],
      title: 'Temperature Control',
      subtitle: 'Keep your device cool',
    ),
    _FeatureData(
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFF3DDC84),
      gradientColors: [Color(0xFF001A10), Color(0xFF000D08)],
      title: 'Battery Health',
      subtitle: 'Monitor and protect your battery',
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
      childAspectRatio: 1.55,
      children: features.map((f) => _FeatureCard(data: f)).toList(),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;

  const _FeatureData({
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;

  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradientColors,
        ),
        border: Border.all(color: const Color(0xFF2A2F5A), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.iconColor.withOpacity(0.15),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(data.subtitle,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8A91B8),
                        height: 1.3),
                    maxLines: 2),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: Color(0xFF4A4FCC), size: 18),
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
        color: const Color(0xFF111638),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F5A), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Clean Background Apps',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3DDC84),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stop unused apps running\nin the background',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A91B8),
                    height: 1.4,
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
              color: const Color(0xFF1A3A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_box_rounded,
                color: Color(0xFF3DDC84), size: 34),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6B3A), Color(0xFF3DDC84)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Clean Now',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}