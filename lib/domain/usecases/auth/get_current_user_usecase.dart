import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase extends UseCase<User?, NoParams> {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User?>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
