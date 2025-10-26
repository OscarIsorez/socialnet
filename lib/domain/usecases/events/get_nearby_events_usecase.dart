import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/event.dart';
import '../../entities/location_point.dart';
import '../../repositories/event_repository.dart';

class GetNearbyEventsUseCase
    extends UseCase<List<Event>, GetNearbyEventsParams> {
  GetNearbyEventsUseCase(this._repository);

  final EventRepository _repository;

  @override
  Future<Either<Failure, List<Event>>> call(GetNearbyEventsParams params) {
    return _repository.getNearbyEvents(
      params.center,
      params.radiusKm,
      category: params.category,
    );
  }
}

class GetNearbyEventsParams extends Equatable {
  const GetNearbyEventsParams({
    required this.center,
    required this.radiusKm,
    this.category,
  });

  final LocationPoint center;
  final double radiusKm;
  final EventCategory? category;

  @override
  List<Object?> get props => [center, radiusKm, category];
}
