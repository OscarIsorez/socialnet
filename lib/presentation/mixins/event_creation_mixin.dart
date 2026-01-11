import 'package:flutter/material.dart';

import '../../domain/entities/location_point.dart';
import '../widgets/event/event_creation_dialog.dart';
import '../widgets/event/location_selection_overlay.dart';

mixin EventCreationMixin<T extends StatefulWidget> on State<T> {
  void startEventCreation({
    LocationPoint? defaultCenter,
    VoidCallback? onEventCreated,
  }) {
    final center =
        defaultCenter ?? const LocationPoint(latitude: 46.58, longitude: 0.34);

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return LocationSelectionOverlay(
            initialCenter: center,
            onLocationSelected: (selectedLocation) =>
                _showEventCreationDialog(selectedLocation, onEventCreated),
            onCancel: () => Navigator.of(context).pop(),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showEventCreationDialog(
    LocationPoint selectedLocation,
    VoidCallback? onEventCreated,
  ) {
    Navigator.of(context).pop(); // Close the location overlay

    // Small delay to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) {
            return EventCreationDialog(
              selectedLocation: selectedLocation,
              onEventCreated: onEventCreated ?? () {},
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }
}
