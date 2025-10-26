part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapEventsRequested extends MapEvent {
  const MapEventsRequested({
    required this.center,
    required this.radiusKm,
    this.category,
  });

  final LocationPoint center;
  final double radiusKm;
  final EventCategory? category;

  @override
  List<Object?> get props => [center, radiusKm, category];
}

class MapStateCleared extends MapEvent {
  const MapStateCleared();
}
