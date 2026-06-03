// profile_event.dart

part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the Profile screen is opened.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// User tapped "Edit Profile" (avatar pencil icon).
class ProfileEditTapped extends ProfileEvent {
  const ProfileEditTapped();
}

/// User tapped "Manage Plan" on the premium banner.
class ProfileManagePlanTapped extends ProfileEvent {
  const ProfileManagePlanTapped();
}

/// User tapped a settings row item.
class ProfileSettingsTapped extends ProfileEvent {
  final SettingsItemType item;
  const ProfileSettingsTapped(this.item);

  @override
  List<Object?> get props => [item];
}

/// User tapped Sign Out.
class ProfileSignOutRequested extends ProfileEvent {
  const ProfileSignOutRequested();
}

/// User confirmed sign-out in dialog.
class ProfileSignOutConfirmed extends ProfileEvent {
  const ProfileSignOutConfirmed();
}

/// User cancelled sign-out dialog.
class ProfileSignOutCancelled extends ProfileEvent {
  const ProfileSignOutCancelled();
}

// ─── Enum for every tappable settings row ───────────────────
enum SettingsItemType {
  personalInformation,
  notifications,
  theme,
  language,
  backupRestore,
  helpSupport,
  aboutApp,
}