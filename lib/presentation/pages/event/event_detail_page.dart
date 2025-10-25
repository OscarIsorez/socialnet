import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    final title = event?.title ?? 'Event details';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          event?.description ?? 'Detailed view for events will be implemented.',
        ),
      ),
    );
  }
}
