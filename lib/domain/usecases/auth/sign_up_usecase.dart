import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase extends UseCase<User, SignUpParams> {
  SignUpUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return _repository.signUp(
      params.email,
      params.password,
      params.profileName,
    );
  }
}

class SignUpParams extends Equatable {
  const SignUpParams({
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
