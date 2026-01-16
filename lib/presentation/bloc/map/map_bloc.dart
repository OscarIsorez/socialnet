import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

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
    on<MapLocationRequested>(_onMapLocationRequested);
    on<MapCenterChanged>(_onMapCenterChanged);
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

  Future<void> _onMapLocationRequested(
    MapLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MapStatus.loading,
        selectedCategory: event.category,
        clearMessage: true,
      ),
    );

    try {
      // Try to get current location
      final position = await _getCurrentLocation();
      final center = LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Load events for current location
      final result = await _getNearbyEventsUseCase(
        GetNearbyEventsParams(
          center: center,
          radiusKm: 5.0, // Default radius
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
        (events) => emit(
          state.copyWith(
            status: MapStatus.success,
            events: events,
            center: center,
            radiusKm: 5.0,
          ),
        ),
      );
    } catch (e) {
      // Fallback to default location if location services fail
      const defaultCenter = LocationPoint(latitude: 48.8566, longitude: 2.3522);

      final result = await _getNearbyEventsUseCase(
        GetNearbyEventsParams(
          center: defaultCenter,
          radiusKm: 5.0,
          category: event.category,
        ),
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: MapStatus.failure,
            message: _mapFailureToMessage(failure),
            center: defaultCenter,
            radiusKm: 5.0,
          ),
        ),
        (events) => emit(
          state.copyWith(
            status: MapStatus.success,
            events: events,
            center: defaultCenter,
            radiusKm: 5.0,
            message:
                'Using default location. Enable location services for better results.',
          ),
        ),
      );
    }
  }

  Future<void> _onMapCenterChanged(
    MapCenterChanged event,
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

  Future<Position> _getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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
