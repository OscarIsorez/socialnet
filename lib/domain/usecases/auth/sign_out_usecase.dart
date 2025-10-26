import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class SignOutUseCase extends UseCase<void, NoParams> {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.signOut();
  }
}
