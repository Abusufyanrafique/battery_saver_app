import 'package:battery_saver_app/bloc/notification_cleaner/notification_bloc.dart';
import 'package:battery_saver_app/bloc/notification_cleaner/notification_event.dart';
import 'package:battery_saver_app/bloc/notification_cleaner/notification_state.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// ─────────────────────────────────────────────
/// DATA MODEL
class SocialStatItem {
  final String label;
  final int count;
  final String svgAssetPath;
  final bool isChecked;

  const SocialStatItem({
    required this.label,
    required this.count,
    required this.svgAssetPath,
    this.isChecked = true,
  });

  SocialStatItem copyWith({
    String? label,
    int? count,
    String? svgAssetPath,
    bool? isChecked,
  }) {
    return SocialStatItem(
      label: label ?? this.label,
      count: count ?? this.count,
      svgAssetPath: svgAssetPath ?? this.svgAssetPath,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

/// ─────────────────────────────────────────────
/// SCREEN
class NotificationCleanerScreen extends StatelessWidget {
  const NotificationCleanerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc()..add(LoadNotifications()),
      child: const _NotificationCleanerView(),
    );
  }
}

class _NotificationCleanerView extends StatelessWidget {
  const _NotificationCleanerView();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1633),
      appBar: CustomAppBar(title: AppText.notificationCleaner),
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
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ── IMAGE
                    Container(
                      height: getHeight(200),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage(AppImages.notificationcleanerimage),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: getHeight(16)),

                    /// ── TOTAL COUNT
                    Center(
                      child: Text(
                        state.status == NotificationStatus.loading
                            ? '...'
                            : '${state.totalCount}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(32),
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    SizedBox(height: getHeight(6)),

                    Center(
                      child: Text(
                        AppText.notifications,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: getFont(16),
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    Center(
                      child: Text(
                        state.status == NotificationStatus.cleaned
                            ? 'Cleaned Successfully!'
                            : AppText.foundinapps,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: getFont(18),
                          color: state.status == NotificationStatus.cleaned
                              ? Colors.greenAccent
                              : const Color(0xFF55D0FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: getHeight(24)),

                    /// ── PERMISSION
                    if (state.status == NotificationStatus.permissionDenied)
                      _PermissionCard(
                        onTap: () => context
                            .read<NotificationBloc>()
                            .add(RequestPermissionEvent()),
                      ),

                    /// ── LOADING (UPDATED)
                    if (state.status == NotificationStatus.loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF55D0FF),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Scanning notifications...',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    /// ── LIST
                    if (state.items.isNotEmpty)
                      SocialStatsWidget(
                        items: state.items,
                        onToggle: (index) => context
                            .read<NotificationBloc>()
                            .add(ToggleItemEvent(index)),
                      ),

                    SizedBox(height: getHeight(24)),

                    /// ── CLEAN BUTTON
                    CleanButtonWidget(
                      text: state.status == NotificationStatus.cleaning
                          ? 'Cleaning...'
                          : state.status == NotificationStatus.cleaned
                              ? 'Done ✓'
                              : AppText.cleanNow,
                      onPressed: state.status == NotificationStatus.loaded
                          ? () => context
                              .read<NotificationBloc>()
                              .add(CleanNotificationsEvent())
                          : null,
                    ),

                    SizedBox(height: getHeight(20)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// PERMISSION CARD
class _PermissionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PermissionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2153),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF55D0FF)),
      ),
      child: Column(
        children: [
          const Icon(Icons.notifications_off,
              color: Color(0xFF55D0FF), size: 40),
          const SizedBox(height: 12),
          const Text(
            'Notification Access Required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Allow notification access to see real notification counts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF55D0FF),
              foregroundColor: Colors.black,
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// LIST WIDGET
class SocialStatsWidget extends StatelessWidget {
  final List<SocialStatItem> items;
  final void Function(int index) onToggle;

  const SocialStatsWidget({
    super.key,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () => onToggle(index),
                child: _SocialStatRow(item: item),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, color: Color(0xFF373C62)),
            ],
          );
        }),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// ROW
class _SocialStatRow extends StatelessWidget {
  final SocialStatItem item;
  const _SocialStatRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(item.svgAssetPath, width: 20, height: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(item.label,
              style: const TextStyle(color: Colors.white))),
          Text('${item.count}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 12),
          Icon(
            item.isChecked ? Icons.check : Icons.circle_outlined,
            color: const Color(0xFF55D0FF),
            size: 16,
          )
        ],
      ),
    );
  }
}