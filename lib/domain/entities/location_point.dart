import 'package:equatable/equatable.dart';

/// Simple latitude/longitude value object. This keeps the domain layer decoupled
/// from Firebase-specific types while still letting the data layer map values to
/// `GeoPoint` or other provider-specific representations.
class LocationPoint extends Equatable {
  const LocationPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  LocationPoint copyWith({double? latitude, double? longitude}) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
