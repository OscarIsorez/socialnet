import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/event.dart';
import '../../entities/location_point.dart';
import '../../repositories/search_repository.dart';

/// Use case for getting suggested events based on user interests and location
///
/// Returns personalized event recommendations
///
/// Example:
/// ```dart
/// final result = await getSuggestedEventsUseCase(
///   GetSuggestedEventsParams(
///     userId: 'user123',
///     location: LocationPoint(latitude: 46.5802, longitude: 0.3337),
///   ),
/// );
/// ```
class GetSuggestedEventsUseCase
    implements UseCase<List<Event>, GetSuggestedEventsParams> {
  final SearchRepository repository;

  GetSuggestedEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(
    GetSuggestedEventsParams params,
  ) async {
    return await repository.getSuggestedEvents(
      params.userId,
      location: params.location,
    );
  }
}

class GetSuggestedEventsParams extends Equatable {
  final String userId;
  final LocationPoint? location;

  const GetSuggestedEventsParams({required this.userId, this.location});

  @override
  List<Object?> get props => [userId, location];
}
