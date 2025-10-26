import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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

  Future<void> _onRefresh() async {
    _loadEvents(category: _selectedCategory);
  }

  void _onCategorySelected(EventCategory? category) {
    setState(() => _selectedCategory = category);
    _loadEvents(category: category);
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

        return Column(
          children: [
            _CategoryFilterBar(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            if (state.status == MapStatus.loading && state.events.isNotEmpty)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: showInPlaceLoader
                    ? const _CenteredProgress()
                    : _EventResultsList(state: state, dateFormat: _dateFormat),
              ),
            ),
          ],
        );
      },
    );

    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Explorer',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Recharger',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _loadEvents(category: _selectedCategory),
                ),
              ],
            ),
          ),
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 160),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _EventResultsList extends StatelessWidget {
  const _EventResultsList({required this.state, required this.dateFormat});

  final MapState state;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (state.events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun événement à afficher',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.status == MapStatus.failure
                      ? state.message ?? 'Une erreur est survenue.'
                      : 'Essayez d\'élargir le rayon ou d\'ajouter un événement.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = state.events[index];
        return _EventTile(event: event, dateFormat: dateFormat);
      },
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.dateFormat});

  final Event event;
  final DateFormat dateFormat;

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

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRouter.eventDetail, arguments: event),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(event.category.name.toUpperCase()),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      durationText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatCoordinates(event.location),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.verified_outlined),
                    tooltip: '${event.verificationCount} confirmations',
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(AppRouter.eventDetail, arguments: event),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCoordinates(LocationPoint location) {
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }
}
