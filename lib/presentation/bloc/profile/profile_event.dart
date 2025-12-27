import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  const UpdateProfile(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class LoadUserEvents extends ProfileEvent {
  const LoadUserEvents(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
