// profile_state.dart

part of 'profile_bloc.dart';

// ─────────────────────────────────────────────────────────────
// DATA MODEL  (immutable snapshot of what the screen shows)
// ─────────────────────────────────────────────────────────────

class ProfileData extends Equatable {
  final String name;
  final String email;
  final String memberSince;
  final bool isPremium;
  final int profileScore;
  final String scoreLabel;

  // Battery summary values
  final String batteryLife;
  final int chargingCycles;
  final int efficiency;
  final int batteryDrain;

  const ProfileData({
    required this.name,
    required this.email,
    required this.memberSince,
    required this.isPremium,
    required this.profileScore,
    required this.scoreLabel,
    required this.batteryLife,
    required this.chargingCycles,
    required this.efficiency,
    required this.batteryDrain,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        memberSince,
        isPremium,
        profileScore,
        scoreLabel,
        batteryLife,
        chargingCycles,
        efficiency,
        batteryDrain,
      ];
}

// ─────────────────────────────────────────────────────────────
// BASE STATE
// ─────────────────────────────────────────────────────────────

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial / before data is fetched.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Data is being loaded from repository / local cache.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Data loaded successfully — screen renders normally.
class ProfileLoaded extends ProfileState {
  final ProfileData data;

  const ProfileLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Something went wrong while loading.
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sign-out confirmation dialog should be shown (overlay state).
class ProfileSignOutConfirming extends ProfileState {
  final ProfileData data; // keep the screen visible behind the dialog

  const ProfileSignOutConfirming(this.data);

  @override
  List<Object?> get props => [data];
}

/// Sign-out is in progress (spinner on sign-out button).
class ProfileSigningOut extends ProfileState {
  final ProfileData data;

  const ProfileSigningOut(this.data);

  @override
  List<Object?> get props => [data];
}

/// Sign-out completed — screen/router should navigate to login.
class ProfileSignedOut extends ProfileState {
  const ProfileSignedOut();
}