import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/social_repository.dart';

class UpdateUserProfile {
  UpdateUserProfile(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, User>> call(User user) async {
    return await _repository.updateProfile(user);
  }
}
