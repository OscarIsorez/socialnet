import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class SignInUseCase extends UseCase<User, SignInParams> {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) {
    return _repository.signIn(params.email, params.password);
  }
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
