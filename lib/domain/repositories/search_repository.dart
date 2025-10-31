import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/event.dart';
import '../entities/location_point.dart';
import '../entities/search_filters.dart';
import '../entities/user.dart';

/// Repository for searching events and users
///
/// This repository provides methods for searching through events and users
/// with various filtering options. It abstracts the data source layer and
/// provides clean error handling through Either.
abstract class SearchRepository {
  /// Searches for events based on a text query
  ///
  /// [query] The search text to match against event titles and descriptions
  /// [filters] Optional filters to narrow down results
  ///
  /// Returns [Right(List<Event>)] on success or [Left(Failure)] on error.
  /// Empty list is returned if no matches found (not an error).
  Future<Either<Failure, List<Event>>> searchEvents(
    String query, {
    SearchFilters? filters,
  });

  /// Searches for users based on a text query
  ///
  /// [query] The search text to match against user names and emails
  /// Only searches public profiles
  ///
  /// Returns [Right(List<User>)] on success or [Left(Failure)] on error.
  /// Empty list is returned if no matches found (not an error).
  Future<Either<Failure, List<User>>> searchUsers(String query);

  /// Filters events based on specified criteria
  ///
  /// [filters] The filters to apply to the event list
  ///
  /// Returns [Right(List<Event>)] on success or [Left(Failure)] on error.
  Future<Either<Failure, List<Event>>> filterEvents(SearchFilters filters);

  /// Gets suggested events based on user interests and location
  ///
  /// [userId] The user ID to get suggestions for
  /// [location] Optional location to prioritize nearby events
  ///
  /// Returns [Right(List<Event>)] on success or [Left(Failure)] on error.
  Future<Either<Failure, List<Event>>> getSuggestedEvents(
    String userId, {
    LocationPoint? location,
  });
}
