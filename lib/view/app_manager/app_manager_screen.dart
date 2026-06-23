import 'package:battery_saver_app/bloc/app_manager/app_manager_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/app_manager/app_list_container.dart';
import 'package:battery_saver_app/widgets/app_manager/app_manager_tabBar.dart';
import 'package:battery_saver_app/widgets/app_manager/stats_card.dart';
import 'package:battery_saver_app/widgets/app_manager/action_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppManagerScreen extends StatelessWidget {
  const AppManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocProvider(
      create: (_) => AppManagerBloc()..add(const AppManagerLoadApps()),
      child: const _AppManagerBody(),
    );
  }
}

class _AppManagerBody extends StatelessWidget {
  const _AppManagerBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: CustomAppBar(title: AppText.appManager),
      body: BlocBuilder<AppManagerBloc, AppManagerState>(
        builder: (context, state) {
          // ── Loading ───────────────────────────────────────────
          if (state.status == AppManagerStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF55D0FF)),
            );
          }

          // ── Error ─────────────────────────────────────────────
          if (state.status == AppManagerStatus.failure) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: AppColors.errorcolor),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: getHeight(16)),

                // ── Tab Bar ───────────────────────────────────
                AppManagerTabBar(
                  selectedIndex: state.selectedTabIndex,
                  onTabChanged: (i) => context
                      .read<AppManagerBloc>()
                      .add(AppManagerTabChanged(i)),
                ),

                SizedBox(height: getHeight(16)),

                // ── Stats Card ────────────────────────────────
                StatsCard(
                  totalApps: state.totalCount,
                  totalSizeGB: state.totalSizeGB,
                  isApkMode: state.isApkMode,
                ),

                SizedBox(height: getHeight(20)),

                // ── App List ──────────────────────────────────
                Expanded(
                  child: AppListContainer(
                    apps: state.isApkMode
                        ? state.apkFiles     // ApkFileModel list
                        : state.installedApps, // RealAppModel list
                    onToggle: (i) => context
                        .read<AppManagerBloc>()
                        .add(AppManagerToggleApp(i)),
                    isApkMode: state.isApkMode,
                  ),
                ),

                SizedBox(height: getHeight(12)),

                // ── Bottom Button ─────────────────────────────
                state.isApkMode
                    ? ActionBarWidget(
                        onShare: () {},
                        onDelete: () {},
                      )
                    : CleanButtonWidget(
                        text:
                            'Uninstall (${state.selectedApps.length})',
                        onPressed: state.selectedApps.isEmpty
                            ? null
                            : () => context
                                .read<AppManagerBloc>()
                                .add(const AppManagerUninstallSelected()),
                      ),

                SizedBox(height: getHeight(20)),
              ],
            ),
          );
        },
      ),
    );
  }
}