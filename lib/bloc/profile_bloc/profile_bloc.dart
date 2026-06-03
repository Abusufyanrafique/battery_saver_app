// profile_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

// ─────────────────────────────────────────────────────────────
// REPOSITORY INTERFACE
// ─────────────────────────────────────────────────────────────

abstract class ProfileRepository {
  Future<ProfileData> fetchProfile();
  Future<void> signOut();
}

// ─────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  // Pass RealProfileRepository() from outside (or via DI).
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileEditTapped>(_onEditTapped);
    on<ProfileManagePlanTapped>(_onManagePlanTapped);
    on<ProfileSettingsTapped>(_onSettingsTapped);
    on<ProfileSignOutRequested>(_onSignOutRequested);
    on<ProfileSignOutConfirmed>(_onSignOutConfirmed);
    on<ProfileSignOutCancelled>(_onSignOutCancelled);
  }

  // ── Load ──────────────────────────────────────────────────

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final data = await _repository.fetchProfile();
      emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // ── Edit profile ──────────────────────────────────────────

  void _onEditTapped(ProfileEditTapped event, Emitter<ProfileState> emit) {}

  // ── Manage plan ───────────────────────────────────────────

  void _onManagePlanTapped(
      ProfileManagePlanTapped event, Emitter<ProfileState> emit) {}

  // ── Settings row tapped ───────────────────────────────────

  void _onSettingsTapped(
      ProfileSettingsTapped event, Emitter<ProfileState> emit) {}

  // ── Sign-out flow ─────────────────────────────────────────

  void _onSignOutRequested(
    ProfileSignOutRequested event,
    Emitter<ProfileState> emit,
  ) {
    final current = state;
    if (current is ProfileLoaded) {
      emit(ProfileSignOutConfirming(current.data));
    }
  }

  Future<void> _onSignOutConfirmed(
    ProfileSignOutConfirmed event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileSignOutConfirming) {
      emit(ProfileSigningOut(current.data));
      try {
        await _repository.signOut();
        emit(const ProfileSignedOut());
      } catch (e) {
        emit(ProfileLoaded(current.data));
      }
    }
  }

  void _onSignOutCancelled(
    ProfileSignOutCancelled event,
    Emitter<ProfileState> emit,
  ) {
    final current = state;
    if (current is ProfileSignOutConfirming) {
      emit(ProfileLoaded(current.data));
    }
  }
}