import 'package:battery_saver_app/bloc/clean_background_bloc/clean_background_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CleanResultItem {
  final String iconPath;
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;

  const CleanResultItem({
    required this.iconPath,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
  });
}

class CleanResultGridWidget extends StatelessWidget {
  final bool useFinalResult;

  const CleanResultGridWidget({super.key, this.useFinalResult = false});

  // ─── Format helper ────────────────────────────────────────────────────────
  static String _fmtGB(double gb) =>
      gb >= 1 ? '${gb.toStringAsFixed(1)} GB' : '${(gb * 1024).toInt()} MB';

  // ─── Check if a BLoC value is usable (not null/empty/zero) ────────────────
  static bool _hasValue(String? v) =>
      v != null &&
      v.isNotEmpty &&
      !v.startsWith('0 ') &&
      v != '0MB' &&
      v != '0 MB' &&
      v != '0.0 GB';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CleanBackgroundBloc>().state;

    final progress = state.scanProgress;

    String junkValue;
    String appsValue;
    String cacheValue;
    String residualValue;

    if (useFinalResult) {
      //  Summary screen mode — sirf finalCleanResult (removed apps ke
      //    proportion se calculate hua, LOCKED) use hota hai. Countdown ya
      //    live cleanResult ko yahan kabhi nahi dekha jata.
      final result = state.finalCleanResult;

      junkValue = result?.junkRemoved ?? '0 MB';
      appsValue = result?.appsClosed ?? '0 Apps';
      cacheValue = result?.cacheCleared ?? '0 MB';
      residualValue = result?.residualFiles ?? '0 MB';
    } else {
      final result = state.cleanResult;

      // Cleaning complete ho chuki ho ya cleaning chal rahi ho,
      // to hamesha LOCKED snapshot (result) use karo — naya estimate calculate mat karo.
      // Estimate sirf scanning/cleanReady phase mein chahiye, jab result null ho sakta hai.
      final isFinalized = state.phase == CleanPhase.completed ||
          state.phase == CleanPhase.cleaning;

      if (isFinalized && result != null) {
        // Locked summary — jo cleaning ke waqt save hui thi, usi se dikhao
        junkValue = result.junkRemoved;
        appsValue = result.appsClosed;
        cacheValue = result.cacheCleared;
        residualValue = result.residualFiles;
      } else {
        // ── Scanning/cleanReady phase: estimate dikhao (real data abhi build ho raha hai) ──
        final selectedApps = state.appsSelected.where((e) => e).length;

        final usedRamGB = (result?.beforeGB != null && result!.beforeGB > 0)
            ? result.beforeGB
            : (selectedApps * 0.12).clamp(0.5, double.infinity);

        final safeProgress = progress.clamp(0.1, 1.0);

        final estJunk = _fmtGB(usedRamGB * safeProgress * 0.20);
        final estCache = _fmtGB(usedRamGB * safeProgress * 0.15);
        final estResidual = _fmtGB(usedRamGB * safeProgress * 0.10);
        final estApps = '$selectedApps Apps';

        junkValue = _hasValue(result?.junkRemoved) ? result!.junkRemoved : estJunk;
        appsValue = _hasValue(result?.appsClosed) ? result!.appsClosed : estApps;
        cacheValue = _hasValue(result?.cacheCleared) ? result!.cacheCleared : estCache;
        residualValue =
            _hasValue(result?.residualFiles) ? result!.residualFiles : estResidual;
      }
    }

    final items = [
      CleanResultItem(
        iconPath: AppIcons.files,
        title: AppText.junkRemoved,
        value: junkValue,
        subtitle: AppText.spaceFreed,
        valueColor: const Color(0xFFFE39C6),
      ),
      CleanResultItem(
        iconPath: AppIcons.appsClosed,
        title: AppText.appsclosed,
        value: appsValue,
        subtitle: AppText.background,
        valueColor: const Color(0xFFEDB309),
      ),
      CleanResultItem(
        iconPath: AppIcons.cacheCleared,
        title: AppText.cacheCleared,
        value: cacheValue,
        subtitle: AppText.cache,
        valueColor: AppColors.checkiconcolor,
      ),
      CleanResultItem(
        iconPath: AppIcons.files2,
        title: AppText.residualFilesRemoved,
        value: residualValue,
        subtitle:AppText.filestext,
        valueColor: const Color(0xFF9A3CFF),
      ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : getWidth(8)),
              child: _CleanResultCard(item: item),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _CleanResultCard extends StatelessWidget {
  final CleanResultItem item;
  const _CleanResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(8),
        vertical: getHeight(2),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:AppColors.drawerGradient
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.appWidgetBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: getHeight(6)),
          SvgPicture.asset(
            item.iconPath,
            width: getWidth(20),
            height: getHeight(20),
          ),
          SizedBox(height: getHeight(4)),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(9),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),
          Text(
            item.value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(14),
              fontWeight: FontWeight.w600,
              color: item.valueColor,
            ),
          ),
          SizedBox(height: getHeight(4)),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(10),
              fontWeight: FontWeight.w500,
              color: AppColors.allsmalltextcolor,
            ),
          ),
        ],
      ),
    );
  }
}