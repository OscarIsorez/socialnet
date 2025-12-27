import 'package:equatable/equatable.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.userEvents = const [],
    this.isEventsLoading = false,
  });

  final User user;
  final List<Event> userEvents;
  final bool isEventsLoading;

  ProfileLoaded copyWith({
    User? user,
    List<Event>? userEvents,
    bool? isEventsLoading,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      userEvents: userEvents ?? this.userEvents,
      isEventsLoading: isEventsLoading ?? this.isEventsLoading,
    );
  }

  @override
  List<Object?> get props => [user, userEvents, isEventsLoading];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}
