import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class SignInRequested extends AuthEvent {
  const SignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.profileName,
  });

  final String email;
  final String password;
  final String profileName;

  @override
  List<Object?> get props => [email, password, profileName];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
