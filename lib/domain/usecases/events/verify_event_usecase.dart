import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/event_repository.dart';

class VerifyEventUseCase extends UseCase<void, VerifyEventParams> {
  VerifyEventUseCase(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, void>> call(VerifyEventParams params) {
    return _repository.verifyEvent(params.eventId, params.stillActive);
  }
}

class VerifyEventParams extends Equatable {
  const VerifyEventParams({required this.eventId, required this.stillActive});

  final String eventId;
  final bool stillActive;

  @override
  List<Object?> get props => [eventId, stillActive];
}
