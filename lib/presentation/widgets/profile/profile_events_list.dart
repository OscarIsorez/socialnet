import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';
import '../event/event_card.dart';

class ProfileEventsList extends StatelessWidget {
  const ProfileEventsList({
    super.key,
    required this.events,
    this.isLoading = false,
  });

  final List<Event> events;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No events created yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start creating events to share with others!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 0 : 8,
            16,
            index == events.length - 1 ? 16 : 8,
          ),
          child: EventCard(event: events[index]),
        );
      },
    );
  }
}
