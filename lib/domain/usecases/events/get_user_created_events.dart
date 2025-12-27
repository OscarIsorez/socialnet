import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

class GetUserCreatedEvents {
  GetUserCreatedEvents(this._repository);

  final EventRepository _repository;

  Future<Either<Failure, List<Event>>> call(String userId) async {
    return await _repository.getUserCreatedEvents(userId);
  }
}
