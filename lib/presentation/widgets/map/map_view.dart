import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';

class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.events,
    required this.center,
    required this.mapController,
    required this.onMarkerTapped,
    this.onMapPositionChanged,
  });

  final List<Event> events;
  final LocationPoint center;
  final MapController mapController;
  final Function(Event) onMarkerTapped;
  final Function(MapCamera, bool)? onMapPositionChanged;

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return AppColors.musicCategory;
      case EventCategory.sports:
        return AppColors.sportsCategory;
      case EventCategory.social:
        return AppColors.socialCategory;
      case EventCategory.problem:
        return AppColors.problemCategory;
      case EventCategory.other:
        return AppColors.otherCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(center.latitude, center.longitude),
        initialZoom: 13.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        onPositionChanged: onMapPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.socialnet',
        ),
        MarkerLayer(
          markers: events.map((event) {
            return Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(event.location.latitude, event.location.longitude),
              child: GestureDetector(
                onTap: () => onMarkerTapped(event),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getCategoryColor(event.category),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(event.category),
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return Icons.music_note;
      case EventCategory.sports:
        return Icons.sports_soccer;
      case EventCategory.social:
        return Icons.people;
      case EventCategory.problem:
        return Icons.warning;
      case EventCategory.other:
        return Icons.place;
    }
  }
}
