import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/event.dart';
import '../../entities/search_filters.dart';
import '../../repositories/search_repository.dart';

/// Use case for searching events by text query and optional filters
///
/// Example:
/// ```dart
/// final result = await searchEventsUseCase(
///   SearchEventsParams(
///     query: 'concert',
///     filters: SearchFilters(category: EventCategory.music),
///   ),
/// );
/// ```
class SearchEventsUseCase implements UseCase<List<Event>, SearchEventsParams> {
  final SearchRepository repository;

  SearchEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(SearchEventsParams params) async {
    // Validate query is not empty
    if (params.query.trim().isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    return await repository.searchEvents(params.query, filters: params.filters);
  }
}

class SearchEventsParams extends Equatable {
  final String query;
  final SearchFilters? filters;

  const SearchEventsParams({required this.query, this.filters});

  @override
  List<Object?> get props => [query, filters];
}
