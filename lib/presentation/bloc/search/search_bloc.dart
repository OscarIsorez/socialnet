import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../../domain/entities/search_filters.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/search/filter_events_usecase.dart';
import '../../../domain/usecases/search/get_suggested_events_usecase.dart';
import '../../../domain/usecases/search/search_events_usecase.dart';
import '../../../domain/usecases/search/search_users_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchEventsUseCase searchEventsUseCase,
    required SearchUsersUseCase searchUsersUseCase,
    required FilterEventsUseCase filterEventsUseCase,
    required GetSuggestedEventsUseCase getSuggestedEventsUseCase,
  }) : _searchEventsUseCase = searchEventsUseCase,
       _searchUsersUseCase = searchUsersUseCase,
       _filterEventsUseCase = filterEventsUseCase,
       _getSuggestedEventsUseCase = getSuggestedEventsUseCase,
       super(const SearchState()) {
    on<SearchEventsRequested>(_onSearchEventsRequested);
    on<SearchUsersRequested>(_onSearchUsersRequested);
    on<FilterEventsRequested>(_onFilterEventsRequested);
    on<GetSuggestedEventsRequested>(_onGetSuggestedEventsRequested);
    on<UpdateFiltersRequested>(_onUpdateFiltersRequested);
    on<ClearSearchRequested>(_onClearSearchRequested);
    on<ClearSearchResultsRequested>(_onClearSearchResultsRequested);
  }

  final SearchEventsUseCase _searchEventsUseCase;
  final SearchUsersUseCase _searchUsersUseCase;
  final FilterEventsUseCase _filterEventsUseCase;
  final GetSuggestedEventsUseCase _getSuggestedEventsUseCase;

  Future<void> _onSearchEventsRequested(
    SearchEventsRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        searchType: SearchType.events,
        query: event.query,
        clearMessage: true,
        clearResults: true,
      ),
    );

    final result = await _searchEventsUseCase(
      SearchEventsParams(query: event.query, filters: event.filters),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (events) => emit(
        state.copyWith(
          status: SearchStatus.success,
          events: events,
          filters: event.filters,
        ),
      ),
    );
  }

  Future<void> _onSearchUsersRequested(
    SearchUsersRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        searchType: SearchType.users,
        query: event.query,
        clearMessage: true,
        clearResults: true,
      ),
    );

    final result = await _searchUsersUseCase(
      SearchUsersParams(query: event.query),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (users) =>
          emit(state.copyWith(status: SearchStatus.success, users: users)),
    );
  }

  Future<void> _onFilterEventsRequested(
    FilterEventsRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        searchType: SearchType.filter,
        filters: event.filters,
        clearMessage: true,
        clearResults: true,
      ),
    );

    final result = await _filterEventsUseCase(
      FilterEventsParams(filters: event.filters),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (events) =>
          emit(state.copyWith(status: SearchStatus.success, events: events)),
    );
  }

  Future<void> _onGetSuggestedEventsRequested(
    GetSuggestedEventsRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SearchStatus.loading,
        searchType: SearchType.suggestions,
        clearMessage: true,
        clearResults: true,
      ),
    );

    final result = await _getSuggestedEventsUseCase(
      GetSuggestedEventsParams(userId: event.userId, location: event.location),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (events) =>
          emit(state.copyWith(status: SearchStatus.success, events: events)),
    );
  }

  void _onUpdateFiltersRequested(
    UpdateFiltersRequested event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(filters: event.filters, clearMessage: true));
  }

  void _onClearSearchRequested(
    ClearSearchRequested event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchState());
  }

  void _onClearSearchResultsRequested(
    ClearSearchResultsRequested event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(clearResults: true, clearMessage: true));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message ?? 'Validation error';
    }

    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    }

    return failure.message ?? 'Something went wrong. Please try again.';
  }
}
