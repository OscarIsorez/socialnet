part of 'search_bloc.dart';

enum SearchStatus { initial, loading, success, failure }

enum SearchType { none, events, users, filter, suggestions }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.searchType = SearchType.none,
    this.events = const [],
    this.users = const [],
    this.filters,
    this.query = '',
    this.message,
  });

  final SearchStatus status;
  final SearchType searchType;
  final List<Event> events;
  final List<User> users;
  final SearchFilters? filters;
  final String query;
  final String? message;

  /// Returns true if search results are available
  bool get hasResults => events.isNotEmpty || users.isNotEmpty;

  /// Returns true if filters are applied
  bool get hasFilters => filters?.hasFilters ?? false;

  /// Returns true if currently loading
  bool get isLoading => status == SearchStatus.loading;

  /// Returns true if there was an error
  bool get hasError => status == SearchStatus.failure;

  SearchState copyWith({
    SearchStatus? status,
    SearchType? searchType,
    List<Event>? events,
    List<User>? users,
    SearchFilters? filters,
    String? query,
    String? message,
    bool clearFilters = false,
    bool clearMessage = false,
    bool clearResults = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      searchType: searchType ?? this.searchType,
      events: clearResults ? const [] : events ?? this.events,
      users: clearResults ? const [] : users ?? this.users,
      filters: clearFilters ? null : filters ?? this.filters,
      query: query ?? this.query,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    searchType,
    events,
    users,
    filters,
    query,
    message,
  ];
}
