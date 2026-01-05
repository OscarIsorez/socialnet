import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/map/map_bloc.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/centered_progress.dart';
import '../../widgets/map/category_filter_bar.dart';
import '../../widgets/map/event_detail_sheet.dart';
import '../../widgets/map/map_view.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage>
    with AutomaticKeepAliveClientMixin {
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
      builder: (context) => EventDetailSheet(
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final content = MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
          listener: (context, state) {
            if (state.message != null && state.status == MapStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message!)));
            }
          },
        ),
        BlocListener<EventBloc, EventState>(
          listener: (context, state) {
            if (state.status == EventStatus.success &&
                state.operation == EventOperation.create) {
              // Refresh events after successful creation
              _loadEvents(category: _selectedCategory);
            }
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final bool showInPlaceLoader =
              state.status == MapStatus.loading && state.events.isEmpty;

          return Stack(
            children: [
              Column(
                children: [
                  CategoryFilterBar(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  if (state.status == MapStatus.loading &&
                      state.events.isNotEmpty)
                    const LinearProgressIndicator(minHeight: 2),
                  Expanded(
                    child: showInPlaceLoader
                        ? const CenteredProgress()
                        : MapView(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 12),
                      FloatingActionButton.small(
                        heroTag: 'recenterMap',
                        onPressed: () {
                          _mapController.move(
                            LatLng(
                              _defaultCenter.latitude,
                              _defaultCenter.longitude,
                            ),
                            13.0,
                          );
                        },
                        child: const Icon(Icons.my_location),
                      ),
                      FloatingActionButton.extended(
                        heroTag: 'createEvent',
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed(AppRouter.createEvent),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        elevation: 6,
                        icon: const Icon(
                          Icons.add_location_alt_outlined,
                          size: 24,
                        ),
                        label: const Text(
                          'Créer événement',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );

    if (widget.embedded) {
      return Column(children: [Expanded(child: content)]);
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
