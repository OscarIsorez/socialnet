import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/social_repository.dart';

class GetUserProfile {
  GetUserProfile(this._repository);

  final SocialRepository _repository;

  Future<Either<Failure, User>> call(String userId) async {
    return await _repository.getUserProfile(userId);
  }
}
