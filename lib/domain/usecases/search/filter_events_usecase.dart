import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/event.dart';
import '../../entities/search_filters.dart';
import '../../repositories/search_repository.dart';

/// Use case for filtering events based on criteria
///
/// This is different from search in that it doesn't use text matching,
/// only filter criteria like category, location, date range, etc.
///
/// Example:
/// ```dart
/// final result = await filterEventsUseCase(
///   FilterEventsParams(
///     filters: SearchFilters(
///       category: EventCategory.music,
///       isActive: true,
///     ),
///   ),
/// );
/// ```
class FilterEventsUseCase implements UseCase<List<Event>, FilterEventsParams> {
  final SearchRepository repository;

  FilterEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(FilterEventsParams params) async {
    // Validate that at least one filter is applied
    if (!params.filters.hasFilters) {
      return Left(ValidationFailure('At least one filter must be applied'));
    }

    return await repository.filterEvents(params.filters);
  }
}

class FilterEventsParams extends Equatable {
  final SearchFilters filters;

  const FilterEventsParams({required this.filters});

  @override
  List<Object?> get props => [filters];
}
