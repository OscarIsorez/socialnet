import '../../../domain/entities/location_point.dart';
import '../../models/event_model.dart';
import '../../models/search_filters_model.dart';
import '../../models/user_model.dart';

/// Remote data source for search operations
abstract class SearchRemoteDataSource {
  /// Searches for events based on a text query and optional filters
  Future<List<EventModel>> searchEvents(
    String query, {
    SearchFiltersModel? filters,
  });

  /// Searches for users based on a text query
  /// Only returns public profiles
  Future<List<UserModel>> searchUsers(String query);

  /// Filters events based on specified criteria
  Future<List<EventModel>> filterEvents(SearchFiltersModel filters);

  /// Gets suggested events based on user interests and location
  Future<List<EventModel>> getSuggestedEvents(
    String userId, {
    LocationPoint? location,
  });
}
