import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/map/map_bloc.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/animated_create_event_button.dart';
import '../../widgets/common/centered_progress.dart';
import '../../widgets/event/event_creation_dialog.dart';
import '../../widgets/event/location_selection_overlay.dart';
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
    latitude: 48.8566,
    longitude: 2.3522,
  );

  final DateFormat _dateFormat = DateFormat('EEE d MMM HH:mm');
  final MapController _mapController = MapController();

  EventCategory? _selectedCategory;
  LocationPoint? _currentCenter;
  Timer? _mapMoveTimer;
  bool _isMapMoving = false;

  @override
  void initState() {
    super.initState();
    _loadEventsFromLocation();
  }

  @override
  void dispose() {
    _mapMoveTimer?.cancel();
    super.dispose();
  }

  void _loadEventsFromLocation({EventCategory? category}) {
    context.read<MapBloc>().add(MapLocationRequested(category: category));
  }

  void _loadEventsForCenter(LocationPoint center, {EventCategory? category}) {
    context.read<MapBloc>().add(
      MapCenterChanged(
        center: center,
        radiusKm: _calculateRadiusFromZoom(),
        category: category,
      ),
    );
  }

  void _onCategorySelected(EventCategory? category) {
    setState(() => _selectedCategory = category);
    if (_currentCenter != null) {
      _loadEventsForCenter(_currentCenter!, category: category);
    } else {
      _loadEventsFromLocation(category: category);
    }
  }

  double _calculateRadiusFromZoom() {
    final zoom = _mapController.camera.zoom;
    // Approximate radius calculation based on zoom level
    // Higher zoom = smaller radius, lower zoom = larger radius
    return max(1.0, min(50.0, 50.0 / pow(2, zoom - 10)));
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;

    setState(() => _isMapMoving = true);

    // Cancel previous timer
    _mapMoveTimer?.cancel();

    // Set new timer to load events after map stops moving
    _mapMoveTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isMapMoving = false);

        final center = LocationPoint(
          latitude: camera.center.latitude,
          longitude: camera.center.longitude,
        );

        _currentCenter = center;
        _loadEventsForCenter(center, category: _selectedCategory);
      }
    });
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

  void _startEventCreation() {
    final center = _currentCenter ?? _defaultCenter;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return LocationSelectionOverlay(
            initialCenter: center,
            onLocationSelected: _showEventCreationDialog,
            onCancel: () => Navigator.of(context).pop(),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showEventCreationDialog(LocationPoint selectedLocation) {
    Navigator.of(context).pop(); // Close the location overlay

    // Small delay to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) {
            return EventCreationDialog(
              selectedLocation: selectedLocation,
              onEventCreated: () {
                // Refresh events for current area after creation
                if (_currentCenter != null) {
                  _loadEventsForCenter(
                    _currentCenter!,
                    category: _selectedCategory,
                  );
                } else {
                  _loadEventsFromLocation(category: _selectedCategory);
                }
              },
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
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

            // Track current center from state
            if (state.center != null) {
              _currentCenter = state.center;
            }
          },
        ),
        BlocListener<EventBloc, EventState>(
          listener: (context, state) {
            if (state.status == EventStatus.success &&
                state.operation == EventOperation.create) {
              // Refresh events for current area after successful creation
              if (_currentCenter != null) {
                _loadEventsForCenter(
                  _currentCenter!,
                  category: _selectedCategory,
                );
              } else {
                _loadEventsFromLocation(category: _selectedCategory);
              }
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
                        : Stack(
                            children: [
                              MapView(
                                events: state.events,
                                center:
                                    state.center ??
                                    _currentCenter ??
                                    _defaultCenter,
                                mapController: _mapController,
                                onMarkerTapped: _onMarkerTapped,
                                onMapPositionChanged: _onMapPositionChanged,
                              ),
                              if (_isMapMoving)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Recherche...',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
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
                          _loadEventsFromLocation(category: _selectedCategory);
                        },
                        child: const Icon(Icons.my_location),
                      ),
                      AnimatedCreateEventButton(
                        heroTag: 'createEvent',
                        onPressed: _startEventCreation,
                        size: CreateEventButtonSize.large,
                        text: 'Créer ',
                        icon: Icons.add_location_alt_outlined,
                        showPulse: true,
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
            onPressed: () {
              if (_currentCenter != null) {
                _loadEventsForCenter(
                  _currentCenter!,
                  category: _selectedCategory,
                );
              } else {
                _loadEventsFromLocation(category: _selectedCategory);
              }
            },
          ),
        ],
      ),
      // Remove duplicate FloatingActionButton as it's already in the Stack
      body: content,
    );
  }
}
