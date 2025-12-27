import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../bloc/map/map_bloc.dart';
import '../../routes/app_router.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  static const LocationPoint _defaultCenter = LocationPoint(
    latitude: 46.58,
    longitude: 0.34,
  );
  static const double _defaultRadiusKm = 5;

  final DateFormat _dateFormat = DateFormat('EEE d MMM HH:mm');
  final MapController _mapController = MapController();

  EventCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents({EventCategory? category}) {
    context.read<MapBloc>().add(
      MapEventsRequested(
        center: _defaultCenter,
        radiusKm: _defaultRadiusKm,
        category: category,
      ),
    );
  }

  void _onCategorySelected(EventCategory? category) {
    setState(() => _selectedCategory = category);
    _loadEvents(category: category);
  }

  void _onMarkerTapped(Event event) {
    _showEventBottomSheet(event);
  }

  void _showEventBottomSheet(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _EventDetailSheet(
        event: event,
        dateFormat: _dateFormat,
        onViewDetails: () {
          Navigator.pop(context);
          Navigator.of(
            context,
          ).pushNamed(AppRouter.eventDetail, arguments: event);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state.message != null && state.status == MapStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final bool showInPlaceLoader =
            state.status == MapStatus.loading && state.events.isEmpty;

        return Stack(
          children: [
            Column(
              children: [
                _CategoryFilterBar(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategorySelected,
                ),
                if (state.status == MapStatus.loading &&
                    state.events.isNotEmpty)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: showInPlaceLoader
                      ? const _CenteredProgress()
                      : _MapView(
                          events: state.events,
                          center: _defaultCenter,
                          mapController: _mapController,
                          onMarkerTapped: _onMarkerTapped,
                        ),
                ),
              ],
            ),
            if (state.events.isNotEmpty)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: 'recenterMap',
                  onPressed: () {
                    _mapController.move(
                      LatLng(_defaultCenter.latitude, _defaultCenter.longitude),
                      13.0,
                    );
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),
          ],
        );
      },
    );

    if (widget.embedded) {
      return Column(
        children: [
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
        actions: [
          IconButton(
            tooltip: 'Recharger',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadEvents(category: _selectedCategory),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRouter.createEvent),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Nouvel événement'),
      ),
      body: content,
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tous'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
            ),
          ),
          ...EventCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_displayLabel(category)),
                selected: selectedCategory == category,
                onSelected: (selected) => selected
                    ? onCategorySelected(category)
                    : onCategorySelected(null),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayLabel(EventCategory category) {
    final name = category.name;
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}

class _CenteredProgress extends StatelessWidget {
  const _CenteredProgress();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _MapView extends StatelessWidget {
  const _MapView({
    required this.events,
    required this.center,
    required this.mapController,
    required this.onMarkerTapped,
  });

  final List<Event> events;
  final LocationPoint center;
  final MapController mapController;
  final Function(Event) onMarkerTapped;

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return Colors.purple;
      case EventCategory.sports:
        return Colors.orange;
      case EventCategory.social:
        return Colors.blue;
      case EventCategory.problem:
        return Colors.red;
      case EventCategory.other:
        return Colors.grey;
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
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(event.category),
                    color: Colors.white,
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

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({
    required this.event,
    required this.dateFormat,
    required this.onViewDetails,
  });

  final Event event;
  final DateFormat dateFormat;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final start = event.startTime;
    final end = event.endTime;
    final dateText = start != null
        ? dateFormat.format(start)
        : 'Date à confirmer';
    final durationText = start != null && end != null
        ? '${dateFormat.format(start)} - ${DateFormat('HH:mm').format(end)}'
        : dateText;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  event.category.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  durationText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${event.verificationCount} confirmations',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onViewDetails,
              icon: const Icon(Icons.info_outline),
              label: const Text('Voir les détails'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
