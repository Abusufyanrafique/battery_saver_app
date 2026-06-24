import 'dart:math' as math;
import 'package:battery_saver_app/bloc/optimization_bloc/optimization_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/clean_background/result_action_buttons_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

// ─── Main Screen ─────────────────────────────────────────────────────────────
class OptimizationResultScreen extends StatelessWidget {
  const OptimizationResultScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    context.read<OptimizationBloc>().add(LoadResultDataEvent());
    return const _ResultView();
  }
}

class _ResultView extends StatefulWidget {
  const _ResultView();

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _scoreCtrl;
  late Animation<double> _scoreBefore;
  late Animation<double> _scoreAfter;

  // Real score values jo Bloc se aayenge
  int _lastScoreBefore = 0;
  int _lastScoreAfter = 0;

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

    // Default values — Bloc se data aane par rebuild hoga
    _scoreBefore = Tween<double>(begin: 0, end: 0).animate(_scoreCtrl);
    _scoreAfter = Tween<double>(begin: 0, end: 0).animate(_scoreCtrl);
  }

  /// Bloc se real scores milne par animation re-run karo.
  /// Both values are genuinely measured — before at session start,
  /// after at result-load time. Falls back to 0 only if no session
  /// baseline exists (user reached this screen without optimizing).
  void _animateScores(int before, int after) {
    if (before == _lastScoreBefore && after == _lastScoreAfter) return;
    _lastScoreBefore = before;
    _lastScoreAfter = after;

    _scoreBefore = Tween<double>(begin: 0, end: before.toDouble()).animate(
      CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut),
    );
    _scoreAfter = Tween<double>(begin: 0, end: after.toDouble()).animate(
      CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut),
    );
    _scoreCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OptimizationBloc, OptimizationState>(
      listener: (context, state) {
        // Real before/after scores aaye — animate karo.
        // scoreBefore can be null if no session was started; treat as 0.
        if (state.resultStatus == ResultLoadStatus.loaded &&
            state.scoreAfter != null) {
          _animateScores(state.scoreBefore ?? 0, state.scoreAfter!);
        }
      },
      builder: (context, state) {
        // Loading skeleton dikhao
        if (state.resultStatus == ResultLoadStatus.loading ||
            state.resultStatus == ResultLoadStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.allscreenBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF55D0FF)),
            ),
          );
        }

        if (state.resultStatus == ResultLoadStatus.error) {
          return Scaffold(
            backgroundColor: AppColors.allscreenBackgroundColor,
            appBar: CustomAppBar(title: AppText.optimizationResult),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? AppText.couldnotloaddevicedata,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(title: AppText.optimizationResult),
          backgroundColor: AppColors.allscreenBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
              child: Column(
                children: [
                  // ── Top image + text (design same) ──
                  Image(
                    image: AssetImage(AppImages.optimizationComplete),
                    height: getHeight(150),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: getHeight(4)),
                  Text(
                    AppText.optimizationComplete,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.checkiconcolor,
                    ),
                  ),
                  SizedBox(height: getHeight(2)),
                  Text(
                    AppText.yourdeviceisnowoptimized,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: getHeight(10)),

                  // ── Summary Card with REAL values only ──
                  _buildSummaryCard(state),
                  SizedBox(height: getHeight(10)),

                  // ── Performance Card with REAL score + real charge status ──
                  _buildPerformanceCard(state),
                  SizedBox(height: getHeight(10)),

                  // ── Recommendations (design same, no change needed) ──
                  _buildRecommendations(),
                  SizedBox(height: getHeight(10)),

                  ResultActionButtonsWidget(
                    onViewDetails: () {},
                    onDone: () => context.go('/bottombar'),
                    onCleanAgain: () {
                      // Dobara load karo
                      context
                          .read<OptimizationBloc>()
                          .add(LoadResultDataEvent());
                    },
                  ),
                  SizedBox(height: getHeight(6)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Summary Card — REAL values only ──────────────────────────────────────
  Widget _buildSummaryCard(OptimizationState state) {
    final items = <_SummaryItem>[
      _SummaryItem(
        iconsvg: AppIcons.optimizebattery,
        color: AppColors.batterycolor,
        valueColor: AppColors.batterycolor,
        label: AppText.batterySaved,
        value: state.batteryPercentSavedDuringSession != null
            ? '${state.batteryPercentSavedDuringSession! >= 0 ? '+' : ''}${state.batteryPercentSavedDuringSession}%'
            : '${state.batteryLevelNow ?? '--'}%',
        sub: state.estimatedBatterySavedText != null
    ? AppText.extended
    : AppText.extendedtext,
      ),

      // Real measured cache cleared (this was always genuinely real).
      _SummaryItem(
        iconsvg: AppIcons.optimizedelete,
        color: AppColors.checkiconcolor,
        valueColor:AppColors.checkiconcolor ,
        label: AppText.junkCleared,
        value: state.junkClearedText,
        sub: AppText.spaceFreed,
      ),

      // Replaces the old fake "RAM Freed" tile with real measured disk
      // space recovered by the cache clear — genuinely verifiable.
      _SummaryItem(
        iconsvg: AppIcons.optimizeram,
        color: AppColors.optimizeramcolor,
        valueColor: AppColors.optimizeramcolor,
        label: AppText.ramFreedtext,
        value: state.diskSpaceFreedText,
        sub: AppText.memoryClearedtext,
      ),

      
      if (state.temperatureCelsius != null)
        _SummaryItem(
          iconsvg: AppIcons.optimizetemp,
          color: AppColors.temcolor,
          valueColor:AppColors.temcolor ,
          label: AppText.temperatureChange,
          value: '${state.temperatureCelsius!.toStringAsFixed(1)}°C',
          sub:AppText.deviceCooled,
        ),
    ];

    return _CardWrapper(
      title: AppText.optimizationSummary,
      child: SizedBox(
        height: getHeight(82),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(width: getWidth(8)),
          itemBuilder: (context, index) => _SummaryTile(item: items[index]),
        ),
      ),
    );
  }

  // ── Performance Card — REAL before/after scores, honest charge status ────
  Widget _buildPerformanceCard(OptimizationState state) {
    return _CardWrapper(
      title: AppText.performanceImprovement,
      child: IntrinsicHeight(
        child: Row(
          children: [
  
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0),
                    child: Text(
                      AppText.performanceScore,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: getFont(10),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppText.before,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: getFont(10),
                            ),
                          ),
                          SizedBox(height: getHeight(6)),
                          AnimatedBuilder(
                            animation: _scoreBefore,
                            builder: (_, __) => _ScoreRing(
                              score: _scoreBefore.value,
                              max: 100,
                              color: AppColors.criclecolor,
                              size: getWidth(44),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: getWidth(40)),
                      Padding(
                        padding: EdgeInsets.only(top: getHeight(18)),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.white,
                          size: 12,
                        ),
                      ),
                      SizedBox(width: getWidth(20)),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppText.after,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: getFont(10),
                            ),
                          ),
                          SizedBox(height: getHeight(6)),
                          AnimatedBuilder(
                            animation: _scoreAfter,
                            builder: (_, __) => _ScoreRing(
                              score: _scoreAfter.value,
                              max: 100,
                              color: const Color(0xFF00FF09),
                              size: getWidth(44),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: getHeight(72),
              color: const Color(0xFF838283),
              margin: EdgeInsets.symmetric(horizontal: getWidth(12)),
            ),

            // Right: Charge status — honest label, not a fake "health"
            // diagnosis. Based only on the real current battery %.
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppText.chargeLevel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: getFont(10),
                    ),
                  ),
                  SizedBox(height: getHeight(10)),
                  SvgPicture.asset(
                    AppIcons.hearticon,
                    width: getWidth(26),
                    height: getHeight(26),
                  ),
                  SizedBox(height: getHeight(5)),
                  Text(
                    state.batteryLevelNow != null
                        ? '${state.batteryLevelNow}%'
                        : '--',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: state.isChargeLevelHealthy
                          ? AppColors.batterycolor
                          : AppColors.temcolor,
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recommendations (design same, no change needed) ───────────────────────
  Widget _buildRecommendations() {
    final recs = [
      _RecItem(
        imagepath: AppImages.containeroptimizeimage,
        color: AppColors.backgroundApps,
        title: AppText.enableAutoOptimize,
        sub: AppText.enableAutoOptimizeSub,
      ),
      _RecItem(
        imagepath: AppImages.containeroptimizebattery,
        color: AppColors.backgroundApps,
        title: AppText.turnOnBatterySaver,
        sub: AppText.turnOnBatterySaverSub,
      ),
      _RecItem(
        imagepath: AppImages.containeroptimizeappmanage,
        color: AppColors.backgroundApps,
        title: AppText.cleanAppsRegularly,
        sub: AppText.cleanAppsRegularlySub,
      ),
    ];

    return _CardWrapper(
      title: AppText.recommendations,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recs.length,
        separatorBuilder: (_, __) => const Divider(
          color: Color(0xFF838283),
          height: 1,
          thickness: 0.5,
        ),
        itemBuilder: (context, index) => _RecTile(item: recs[index]),
      ),
    );
  }
}

// ─── Reusable Widgets (design bilkul same) ────────────────────────────────────

class _CardWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:AppColors.drawerGradient
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.appWidgetBorderColor
          ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: getWidth(12), vertical: getHeight(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(14), fontWeight: FontWeight.w600)),
          SizedBox(height: getHeight(8)),
          child,
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String iconsvg, label, value, sub;
  final Color color, valueColor;
  const _SummaryItem({
    required this.iconsvg,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.valueColor,
  });
}

class _SummaryTile extends StatelessWidget {
  final _SummaryItem item;
  const _SummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          width: getWidth(78),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.systemCardGradient),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.appWidgetBorderColor,
               width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(item.iconsvg,
                  width: getWidth(20),
                  height: getHeight(20),
                  colorFilter:
                      ColorFilter.mode(item.color, BlendMode.srcIn)),
              SizedBox(height: getHeight(3)),
              Text(item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(8),
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: getHeight(2)),
              Text(item.value,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w600,
                      color: item.valueColor)),
              SizedBox(height: getHeight(3)),
              Text(item.sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(8),
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final double score, max, size;
  final Color color;
  const _ScoreRing(
      {required this.score,
      required this.max,
      required this.color,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: score / max, color: color),
        child: Center(
          child: Text(score.toInt().toString(),
              style:
                  AppTextStyles.bodyMedium.copyWith(fontSize: getFont(16))),
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
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFF232C6D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _RecItem {
  final String imagepath, title, sub;
  final Color color;
  const _RecItem(
      {required this.imagepath,
      required this.color,
      required this.title,
      required this.sub});
}

class _RecTile extends StatelessWidget {
  final _RecItem item;
  const _RecTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getHeight(6)),
      child: Row(
        children: [
          Container(
            width: getWidth(34),
            height: getHeight(34),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              shape: BoxShape.circle,
              border:
                  Border.all(color: item.color.withOpacity(0.3), width: 0.8),
            ),
            child: Image.asset(item.imagepath,
                width: 16, height: 16, fit: BoxFit.contain),
          ),
          SizedBox(width: getWidth(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(11),
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                SizedBox(height: getHeight(1)),
                Text(item.sub,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(9),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD9D9D9))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF989CDF), size: 18),
        ],
      ),
    );
  }
}