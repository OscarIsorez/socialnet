import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

class CreateEventUseCase extends UseCase<Event, CreateEventParams> {
  CreateEventUseCase(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, Event>> call(CreateEventParams params) {
    return _repository.createEvent(params.event);
  }
}

class CreateEventParams extends Equatable {
  const CreateEventParams(this.event);

  final Event event;

  @override
  List<Object?> get props => [event];
}
