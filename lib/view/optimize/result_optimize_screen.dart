import 'dart:math' as math;
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';

// ─── Colors ────────────────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFF080C2A);
  static const card = Color(0xFF0F1540);
  static const cardBorder = Color(0xFF1E2660);
  static const green = Color(0xFF00E676);
  static const greenDark = Color(0xFF00C853);
  static const purple = Color(0xFF7C4DFF);
  static const cyan = Color(0xFF00E5FF);
  static const amber = Color(0xFFFFAB40);
  static const pink = Color(0xFFFF4081);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF8892B0);
  static const textMuted = Color(0xFF4A5580);
}

// ─── Main Screen ────────────────────────────────────────────────────────────
class OptimizationResultScreen extends StatefulWidget {
  const OptimizationResultScreen({super.key});

  @override
  State<OptimizationResultScreen> createState() =>
      _OptimizationResultScreenState();
}

class _OptimizationResultScreenState extends State<OptimizationResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _scoreCtrl;
  late Animation<double> _scoreBefore;
  late Animation<double> _scoreAfter;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreBefore = Tween<double>(begin: 0, end: 72).animate(
      CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut),
    );
    _scoreAfter = Tween<double>(begin: 0, end: 92).animate(
      CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scoreCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Image(
                      image: AssetImage(AppImages.optimizationComplete),
                    ),
                    const SizedBox(height: 20),
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildPerformanceCard(),
                    const SizedBox(height: 16),
                    _buildRecommendations(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 22),
            ),
          ),
          Expanded(
            child: Text(
              'Optimization Result',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: getFont(18),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final items = [
      _SummaryItem(
        icon: Icons.battery_charging_full_outlined,
        color: AppColors.green,
        label: 'Battery Saved',
        value: '+2h 30m',
        sub: 'Extended',
      ),
      _SummaryItem(
        icon: Icons.memory_outlined,
        color: AppColors.purple,
        label: 'RAM Freed',
        value: '+1.2 GB',
        sub: 'Memory Cleared',
      ),
      _SummaryItem(
        icon: Icons.delete_sweep_outlined,
        color: AppColors.cyan,
        label: 'Junk Cleaned',
        value: '850 MB',
        sub: 'Space Freed',
      ),
      _SummaryItem(
        icon: Icons.thermostat_outlined,
        color: AppColors.amber,
        label: 'Temp Reduced',
        value: '-4°C',
        sub: 'Device Cooled',
      ),
    ];

    return _CardWrapper(
      title: 'Optimization Summary',
      child: SizedBox(
        height: getHeight(110),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return _SummaryTile(item: items[index]);
          },
        ),
      ),
    );
  }

  // ── Performance Card ─────────────────────────────────────────────────────
  Widget _buildPerformanceCard() {
    return _CardWrapper(
      title: 'Performance Improvement',
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Performance Score',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: getFont(11),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Before',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: getFont(11),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _scoreBefore,
                          builder: (_, __) => _ScoreRing(
                            score: _scoreBefore.value,
                            max: 100,
                            color: AppColors.purple,
                            size: getWidth(64),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Icon(Icons.arrow_forward,
                          color: AppColors.textSecondary, size: 18),
                    ),
                    Column(
                      children: [
                        Text(
                          'After',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: getFont(11),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _scoreAfter,
                          builder: (_, __) => _ScoreRing(
                            score: _scoreAfter.value,
                            max: 100,
                            color: AppColors.green,
                            size: getWidth(64),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 90,
            color: AppColors.cardBorder,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Battery Health',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: getFont(11),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: getWidth(52),
                  height: getHeight(52),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withOpacity(0.12),
                    border: Border.all(
                      color: AppColors.green.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.monitor_heart_outlined,
                      color: AppColors.green, size: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  'Improved',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.green,
                    fontSize: getFont(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Recommendations ──────────────────────────────────────────────────────
  Widget _buildRecommendations() {
    final recs = [
      _RecItem(
        icon: Icons.bolt,
        color: AppColors.green,
        title: 'Enable Auto Optimize',
        sub: 'Automatically optimize your device regularly',
      ),
      _RecItem(
        icon: Icons.battery_saver_outlined,
        color: AppColors.pink,
        title: 'Turn On Battery Saver',
        sub: 'Save more power and extend battery life',
      ),
      _RecItem(
        icon: Icons.cleaning_services_outlined,
        color: AppColors.cyan,
        title: 'Clean Apps Regularly',
        sub: 'Keep your device fast and smooth',
      ),
    ];

    return _CardWrapper(
      title: 'Recommendations',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recs.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.cardBorder,
          height: 1,
          thickness: 0.5,
        ),
        itemBuilder: (context, index) => _RecTile(item: recs[index]),
      ),
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, getHeight(24)),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _BottomBtn(
            icon: Icons.bar_chart,
            label: 'View Details',
            color: const Color(0xFF55D0FF),
            flex: 2,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: getHeight(52),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, Color(0xFF00BFA5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Back to Home',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: getFont(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _BottomBtn(
            icon: Icons.rocket_launch_outlined,
            label: 'Boost Again',
            color: const Color(0xFF55D0FF),
            flex: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _CardWrapper extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Summary Item Model ──────────────────────────────────────────────────────
class _SummaryItem {
  final IconData icon;
  final Color color;
  final String label, value, sub;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
  });
}

// ─── Summary Tile ─────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final _SummaryItem item;

  const _SummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    // Fixed width per tile so they show evenly in horizontal scroll
    return Container(
      width: getWidth(78),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color:Color(0xFF4103AC), width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(9),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.value,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(11),
              fontWeight: FontWeight.w700,
              color:Color(0xFF00FF09),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(8),
              color:Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score Ring ───────────────────────────────────────────────────────────────
class _ScoreRing extends StatelessWidget {
  final double score, max, size;
  final Color color;

  const _ScoreRing({
    required this.score,
    required this.max,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: score / max, color: color),
        child: Center(
          child: Text(
            score.toInt().toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(15)
            )
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width - 8) / 2;

    final trackPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Rec Item Model ───────────────────────────────────────────────────────────
class _RecItem {
  final IconData icon;
  final Color color;
  final String title, sub;

  const _RecItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.sub,
  });
}

// ─── Rec Tile ─────────────────────────────────────────────────────────────────
class _RecTile extends StatelessWidget {
  final _RecItem item;

  const _RecTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: getWidth(40),
            height: getHeight(40),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
              border:
                  Border.all(color: item.color.withOpacity(0.3), width: 0.8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.sub,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(10),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD9D9D9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: Color(0xFF989CDF), size: 20),
        ],
      ),
    );
  }
}

// ─── Bottom Btn ───────────────────────────────────────────────────────────────
class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int flex;

  const _BottomBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: getHeight(52),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5C0EE3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(11),
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}