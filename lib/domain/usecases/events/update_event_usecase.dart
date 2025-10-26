import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

class UpdateEventUseCase extends UseCase<Event, UpdateEventParams> {
  UpdateEventUseCase(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, Event>> call(UpdateEventParams params) {
    return _repository.updateEvent(params.event);
  }
}

class UpdateEventParams extends Equatable {
  const UpdateEventParams(this.event);

  final Event event;

  @override
  List<Object?> get props => [event];
}
