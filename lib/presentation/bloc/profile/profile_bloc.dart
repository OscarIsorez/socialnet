import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/events/get_user_created_events.dart';
import '../../../domain/usecases/social/get_user_profile.dart';
import '../../../domain/usecases/social/update_user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required GetUserCreatedEvents getUserCreatedEvents,
  }) : _getUserProfile = getUserProfile,
       _updateUserProfile = updateUserProfile,
       _getUserCreatedEvents = getUserCreatedEvents,
       super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<LoadUserEvents>(_onLoadUserEvents);
  }

  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final GetUserCreatedEvents _getUserCreatedEvents;

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await _getUserProfile(event.userId);
    result.fold(
      (failure) => emit(ProfileError(failure.message ?? 'Unknown error')),
      (user) {
        emit(ProfileLoaded(user: user));
        // Automatically load user's events
        add(LoadUserEvents(event.userId));
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(ProfileUpdating(event.user));

      final result = await _updateUserProfile(event.user);
      result.fold(
        (failure) => emit(ProfileError(failure.message ?? 'Unknown error')),
        (updatedUser) {
          emit(
            ProfileLoaded(
              user: updatedUser,
              userEvents: (state is ProfileLoaded)
                  ? (state as ProfileLoaded).userEvents
                  : [],
            ),
          );
        },
      );
    }
  }

  Future<void> _onLoadUserEvents(
    LoadUserEvents event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isEventsLoading: true));

      final result = await _getUserCreatedEvents(event.userId);
      result.fold(
        (failure) {
          // Don't emit error for events loading failure, just stop loading
          emit(currentState.copyWith(isEventsLoading: false));
        },
        (events) {
          emit(
            currentState.copyWith(userEvents: events, isEventsLoading: false),
          );
        },
      );
    }
  }
}
