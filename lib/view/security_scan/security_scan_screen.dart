import 'package:battery_saver_app/bloc/security_scan/security_scan_bloc.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/security_scan/security_scan_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecurityScanScreen extends StatelessWidget {
  const SecurityScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecurityScanBloc()..add(const SecurityScanStarted()),
      child: const _SecurityScanView(),
    );
  }
}

class _SecurityScanView extends StatefulWidget {
  const _SecurityScanView();

  @override
  State<_SecurityScanView> createState() => _SecurityScanViewState();
}

class _SecurityScanViewState extends State<_SecurityScanView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),
      appBar: CustomAppBar(title: AppText.securityScan),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1633),
              Color(0xFF0B122B),
              Color(0xFF070C1F),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<SecurityScanBloc, SecurityScanState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ───── SHIELD IMAGE (pulse when scanning) ─────
                    _buildShieldImage(state),

                    const SizedBox(height: 20),

                    // ───── PROGRESS / PERCENTAGE ─────
                    _buildProgressText(state),

                    const SizedBox(height: 6),

                    // ───── SAFE / SCANNING label ─────
                    Text(
                      state.isScanning ? 'Scanning...' : AppText.safe,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        color: const Color(0xFFD9D9D9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ───── THREAT STATUS ─────
                    _buildThreatStatus(state),

                    SizedBox(height: getHeight(99)),

                    // ───── SCAN LIST ─────
                    SecurityScanWidget(
                      items: [
                        SecurityScanItem(
                          title: "Virus Scan",
                          isCompleted: state.completedItems[0],
                          isScanning: state.isScanning && !state.completedItems[0],
                        ),
                        SecurityScanItem(
                          title: "Privacy Scan",
                          isCompleted: state.completedItems[1],
                          isScanning: state.isScanning &&
                              state.completedItems[0] &&
                              !state.completedItems[1],
                        ),
                        SecurityScanItem(
                          title: "Vulnerability Scan",
                          isCompleted: state.completedItems[2],
                          isScanning: state.isScanning &&
                              state.completedItems[1] &&
                              !state.completedItems[2],
                        ),
                        SecurityScanItem(
                          title: "System Protection",
                          isCompleted: state.completedItems[3],
                          isScanning: state.isScanning &&
                              state.completedItems[2] &&
                              !state.completedItems[3],
                        ),
                      ],
                    ),

                    SizedBox(height: getHeight(64)),

                    // ───── BUTTON ─────
                    CleanButtonWidget(
                      text: state.isScanning ? 'Scanning...' : AppText.scanAgain,
                      onPressed: state.isScanning
                          ? null
                          : () => context
                              .read<SecurityScanBloc>()
                              .add(const SecurityScanStarted()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShieldImage(SecurityScanState state) {
    if (state.isScanning) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          height: getHeight(200),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage(AppImages.securityscanimage),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    return Container(
      height: getHeight(200),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage(AppImages.securityscanimage),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildProgressText(SecurityScanState state) {
    if (state.isScanning) {
      // Animated progress percentage
      return TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: state.progress),
        duration: const Duration(milliseconds: 400),
        builder: (_, value, __) => Text(
          '$value%',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: getFont(30),
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Text(
      state.isDone ? '${state.progress}%' : '0%',
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: getFont(30),
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildThreatStatus(SecurityScanState state) {
    if (state.isScanning) {
      return Text(
        'Please wait...',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: getFont(16),
          color: const Color(0xFF55D0FF),
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (state.isDone && !state.isSafe) {
      return Text(
        '${state.threatsFound} threat${state.threatsFound > 1 ? 's' : ''} found!',
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: getFont(16),
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return Text(
      AppText.nothreatsfound,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: getFont(16),
        color: const Color(0xFF2FE55D),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}