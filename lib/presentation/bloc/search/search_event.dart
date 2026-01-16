part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search for events by text query with optional filters
class SearchEventsRequested extends SearchEvent {
  const SearchEventsRequested({required this.query, this.filters});

  final String query;
  final SearchFilters? filters;

  @override
  List<Object?> get props => [query, filters];
}

/// Event to search for users by text query
class SearchUsersRequested extends SearchEvent {
  const SearchUsersRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to filter events by criteria without text search
class FilterEventsRequested extends SearchEvent {
  const FilterEventsRequested(this.filters);

  final SearchFilters filters;

  @override
  List<Object?> get props => [filters];
}

/// Event to get suggested events based on user interests and location
class GetSuggestedEventsRequested extends SearchEvent {
  const GetSuggestedEventsRequested({required this.userId, this.location});

  final String userId;
  final LocationPoint? location;

  @override
  List<Object?> get props => [userId, location];
}

/// Event to update current search filters
class UpdateFiltersRequested extends SearchEvent {
  const UpdateFiltersRequested(this.filters);

  final SearchFilters filters;

  @override
  List<Object?> get props => [filters];
}

/// Event to clear all search results and reset state
class ClearSearchRequested extends SearchEvent {
  const ClearSearchRequested();
}

/// Event to clear only search results but keep filters
class ClearSearchResultsRequested extends SearchEvent {
  const ClearSearchResultsRequested();
}

/// Event to update search query without triggering search (for typing)
class UpdateQueryRequested extends SearchEvent {
  const UpdateQueryRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
