part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.events = const <Event>[],
    this.center,
    this.radiusKm,
    this.selectedCategory,
    this.message,
  });

  final MapStatus status;
  final List<Event> events;
  final LocationPoint? center;
  final double? radiusKm;
  final EventCategory? selectedCategory;
  final String? message;

  MapState copyWith({
    MapStatus? status,
    List<Event>? events,
    LocationPoint? center,
    double? radiusKm,
    EventCategory? selectedCategory,
    String? message,
    bool clearMessage = false,
  }) {
    return MapState(
      status: status ?? this.status,
      events: events != null ? List<Event>.unmodifiable(events) : this.events,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    events,
    center,
    radiusKm,
    selectedCategory,
    message,
  ];
}
