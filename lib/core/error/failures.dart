import 'package:equatable/equatable.dart';

/// Represents a domain-level error. Failures are intentionally devoid of
/// framework-specific information so that they can easily flow through the
/// domain and presentation layers.
abstract class Failure extends Equatable {
  const Failure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message: message);
}
