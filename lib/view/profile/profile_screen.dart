// profile_screen.dart  (only BlocProvider changed — rest is identical)

import 'package:battery_saver_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/data/repositories/real_profile_repository.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/profile/account_settings_widget.dart';
import 'package:battery_saver_app/widgets/profile/battery_summary_widget.dart';
import 'package:battery_saver_app/widgets/profile/premium_banner_widget.dart';
import 'package:battery_saver_app/widgets/profile/profile_header_widget.dart';
import 'package:battery_saver_app/widgets/profile/sign_out_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Map<SettingsItemType, String> _settingsRoutes = {
    SettingsItemType.personalInformation: '/PersonalInformationScreen',
    SettingsItemType.notifications: '/NotificationsScreen',
    SettingsItemType.theme: '/ThemeScreen',
    SettingsItemType.language: '/LanguageScreen',
    SettingsItemType.backupRestore: '/BackupRestoreScreen',
    SettingsItemType.helpSupport: '/HelpSupportScreen',
    SettingsItemType.aboutApp: '/AboutScreen',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      //  RealProfileRepository inject kar diya — real battery data aayega
      create: (_) => ProfileBloc(repository: RealProfileRepository())
        ..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// INTERNAL VIEW
// ─────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSignedOut) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/LoginScreen', (_) => false);
          return;
        }
        if (state is ProfileSignOutConfirming) {
          _showSignOutDialog(context);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.allscreenBackgroundColor,
            appBar: _buildAppBar(context),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppText.profile,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: getFont(24),
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.allscreenBackgroundColor,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Image(image: AssetImage(AppImages.chevron)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9A3CFF)),
      );
    }

    if (state is ProfileError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppText.failedtoloadprofile,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileLoadRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4103AC),
              ),
              child:  Text(AppText.retry),
            ),
          ],
        ),
      );
    }

    final data = _extractData(state)!;
    final isSigningOut = state is ProfileSigningOut;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
        child: Column(
          children: [
            ProfileHeaderWidget(
              name: data.name,
              email: data.email,
              memberSince: data.memberSince,
              isPremium: data.isPremium,
              profileScore: data.profileScore,
              scoreLabel: data.scoreLabel,
              onEditTap: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileEditTapped()),
            ),

            SizedBox(height: getHeight(20)),

            //  Real battery data pass ho raha hai yahan
            BatterySummaryWidget(
              batteryLife: data.batteryLife,
              chargingCycles: data.chargingCycles,
              efficiency: data.efficiency,
              batteryDrain: data.batteryDrain,
            ),

            SizedBox(height: getHeight(12)),

            PremiumBannerWidget(
              onManageTap: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileManagePlanTapped()),
            ),

            SizedBox(height: getHeight(12)),

            AccountSettingsWidget(
              items: _buildSettingsItems(context),
            ),

            SizedBox(height: getHeight(16)),

            SignOutButtonWidget(
              isLoading: isSigningOut,
              onTap: isSigningOut
                  ? null
                  : () => context
                      .read<ProfileBloc>()
                      .add(const ProfileSignOutRequested()),
            ),

            SizedBox(height: getHeight(16)),
          ],
        ),
      ),
    );
  }

  ProfileData? _extractData(ProfileState state) {
    if (state is ProfileLoaded) return state.data;
    if (state is ProfileSignOutConfirming) return state.data;
    if (state is ProfileSigningOut) return state.data;
    return null;
  }

  List<SettingsItem> _buildSettingsItems(BuildContext context) {
    void dispatch(SettingsItemType type) =>
        context.read<ProfileBloc>().add(ProfileSettingsTapped(type));

    return [
      SettingsItem(
        svgicon: AppIcons.profileperson,
        title: AppText.personalInformation,
        onTap: () => dispatch(SettingsItemType.personalInformation),
      ),
      SettingsItem(
        svgicon: AppIcons.profilenoti,
        title: AppText.notificationsprofile,
        onTap: () => dispatch(SettingsItemType.notifications),
      ),
      SettingsItem(
        svgicon: AppIcons.profiletheme,
        title:AppText.theme,
        trailingText: AppText.dark,
        onTap: () => dispatch(SettingsItemType.theme),
      ),
      SettingsItem(
        svgicon: AppIcons.profilelanguage,
        title: AppText.language,
        trailingText:AppText.english,
        onTap: () => dispatch(SettingsItemType.language),
      ),
      SettingsItem(
        svgicon: AppIcons.profilebackaup,
        title: AppText.backupRestore,
        onTap: () => dispatch(SettingsItemType.backupRestore),
      ),
      SettingsItem(
        svgicon: AppIcons.profilehelp,
        title: AppText.helpSupport,
        onTap: () => dispatch(SettingsItemType.helpSupport),
      ),
      SettingsItem(
        svgicon: AppIcons.profileinfo,
        title: AppText.aboutBatteryOptimizer,
        trailingText: AppText.version,
        onTap: () => dispatch(SettingsItemType.aboutApp),
      ),
    ];
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1B2153),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF4103AC), width: 1.2),
        ),
        title: Text(
       AppText.signOut,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          AppText.areyousureyouwanttosignout,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<ProfileBloc>()
                  .add(const ProfileSignOutCancelled());
            },
            child: Text(
              AppText.cancel,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: const Color(0xFF9A3CFF)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<ProfileBloc>()
                  .add(const ProfileSignOutConfirmed());
            },
            child: Text(
              AppText.signOut,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFFAD2020),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}