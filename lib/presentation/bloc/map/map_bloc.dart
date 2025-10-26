import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../../domain/usecases/events/get_nearby_events_usecase.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required GetNearbyEventsUseCase getNearbyEventsUseCase})
    : _getNearbyEventsUseCase = getNearbyEventsUseCase,
      super(const MapState()) {
    on<MapEventsRequested>(_onMapEventsRequested);
    on<MapStateCleared>(_onMapStateCleared);
  }

  final GetNearbyEventsUseCase _getNearbyEventsUseCase;

  Future<void> _onMapEventsRequested(
    MapEventsRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MapStatus.loading,
        center: event.center,
        radiusKm: event.radiusKm,
        selectedCategory: event.category,
        clearMessage: true,
      ),
    );

    final result = await _getNearbyEventsUseCase(
      GetNearbyEventsParams(
        center: event.center,
        radiusKm: event.radiusKm,
        category: event.category,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MapStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (events) =>
          emit(state.copyWith(status: MapStatus.success, events: events)),
    );
  }

  void _onMapStateCleared(MapStateCleared event, Emitter<MapState> emit) {
    emit(const MapState());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection';
    }

    if (failure is ValidationFailure) {
      return failure.message ?? 'Validation error';
    }

    return failure.message ?? 'Unable to load events. Please try again.';
  }
}
