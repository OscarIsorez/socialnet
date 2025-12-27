import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../core/error/exceptions.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../models/event_model.dart';
import 'event_remote_datasource.dart';

class FakeEventRemoteDataSource implements EventRemoteDataSource {
  FakeEventRemoteDataSource() {
    _seedEvents();
  }

  final List<EventModel> _events = <EventModel>[];
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  void _seedEvents() {
    if (_events.isNotEmpty) return;

    final now = DateTime.now();
    _events.addAll([
      // Events created by current user
      EventModel(
        id: _uuid.v4(),
        creatorId: 'current-user',
        title: 'Flutter Meetup - Building Great Apps',
        description:
            'Join us for an evening of Flutter development discussions and networking. We\'ll cover the latest features and best practices.',
        category: EventCategory.social,
        subCategory: EventSubCategory.meetup,
        location: const LocationPoint(latitude: 46.5802, longitude: 0.3337),
        photoUrl: 'https://picsum.photos/400/300?random=1',
        startTime: now.add(const Duration(days: 3, hours: 18)),
        endTime: now.add(const Duration(days: 3, hours: 21)),
        isActive: true,
        verificationCount: 12,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      EventModel(
        id: _uuid.v4(),
        creatorId: 'current-user',
        title: 'Morning Hiking Trail',
        description:
            'Early morning hike through the local trails. Great for fitness and nature lovers.',
        category: EventCategory.sports,
        subCategory: EventSubCategory.general,
        location: const LocationPoint(latitude: 46.585, longitude: 0.340),
        photoUrl: 'https://picsum.photos/400/300?random=2',
        startTime: now.add(const Duration(days: 1, hours: 7)),
        endTime: now.add(const Duration(days: 1, hours: 10)),
        isActive: true,
        verificationCount: 8,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      // Other events
      EventModel(
        id: _uuid.v4(),
        creatorId: 'user123',
        title: 'Concert de Rock au Centre-Ville',
        description: 'Groupes locaux sur scene en plein air.',
        category: EventCategory.music,
        subCategory: EventSubCategory.rock,
        location: const LocationPoint(latitude: 46.5802, longitude: 0.3337),
        photoUrl: 'https://picsum.photos/400/300?random=11',
        startTime: now.add(const Duration(days: 2, hours: 20)),
        endTime: now.add(const Duration(days: 2, hours: 23)),
        isActive: true,
        verificationCount: 3,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      EventModel(
        id: _uuid.v4(),
        creatorId: 'user456',
        title: 'Match de football amical',
        description: 'Match entre voisins, tout le monde est bienvenu.',
        category: EventCategory.sports,
        subCategory: EventSubCategory.football,
        location: const LocationPoint(latitude: 46.583, longitude: 0.3452),
        photoUrl: 'https://picsum.photos/400/300?random=12',
        startTime: now.add(const Duration(days: 1, hours: 17)),
        endTime: now.add(const Duration(days: 1, hours: 19)),
        isActive: true,
        verificationCount: 5,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      EventModel(
        id: _uuid.v4(),
        creatorId: 'user789',
        title: 'Fuite d\'eau Rue de la Paix',
        description:
            'Signalement d\'une fuite importante pres du numero 12, besoin de verifier.',
        category: EventCategory.problem,
        subCategory: EventSubCategory.waterLeak,
        location: const LocationPoint(latitude: 46.5815, longitude: 0.335),
        photoUrl: 'https://picsum.photos/400/300?random=13',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: null,
        isActive: true,
        verificationCount: 8,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ]);

    for (int i = 0; i < 15; i++) {
      final offsetLat = (_random.nextDouble() - 0.5) / 100;
      final offsetLng = (_random.nextDouble() - 0.5) / 100;
      final EventCategory eventCategory =
          EventCategory.values[i % EventCategory.values.length];
      final EventSubCategory subCategory =
          EventSubCategory.values[i % EventSubCategory.values.length];

      _events.add(
        EventModel(
          id: _uuid.v4(),
          creatorId: 'user$i',
          title: 'Community ${eventCategory.name.toUpperCase()} Event #$i',
          description:
              'Rencontre communautaire autour de ${eventCategory.name}.',
          category: eventCategory,
          subCategory: subCategory,
          location: LocationPoint(
            latitude: 46.58 + offsetLat,
            longitude: 0.34 + offsetLng,
          ),
          photoUrl: 'https://picsum.photos/400/300?random=${20 + i}',
          startTime: now.add(Duration(hours: i + 1)),
          endTime: now.add(Duration(hours: i + 3)),
          isActive: true,
          verificationCount: _random.nextInt(10),
          createdAt: now.subtract(Duration(hours: _random.nextInt(48))),
        ),
      );
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final created = event.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
    _events.add(created);
    return created;
  }

  @override
  Future<List<EventModel>> getNearbyEvents(
    LocationPoint center,
    double radiusKm, {
    EventCategory? category,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return _events.where((event) {
      final distance = _haversineDistanceKm(center, event.location);
      final withinRadius = distance <= radiusKm;
      final matchesCategory = category == null || event.category == category;
      return withinRadius && matchesCategory && event.isActive;
    }).toList();
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final index = _events.indexWhere((existing) => existing.id == event.id);
    if (index == -1) {
      throw const ServerException(message: 'Event not found');
    }
    _events[index] = event;
    return event;
  }

  @override
  Future<void> verifyEvent(String eventId, bool stillActive) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index == -1) {
      throw const ServerException(message: 'Event not found');
    }

    final event = _events[index];
    if (!stillActive) {
      _events[index] = event.copyWith(isActive: false);
    } else {
      _events[index] = event.copyWith(
        verificationCount: event.verificationCount + 1,
      );
    }
  }

  double _haversineDistanceKm(LocationPoint a, LocationPoint b) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(b.latitude - a.latitude);
    final dLon = _degreesToRadians(b.longitude - a.longitude);

    final lat1 = _degreesToRadians(a.latitude);
    final lat2 = _degreesToRadians(b.latitude);

    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  @override
  Future<List<EventModel>> getUserCreatedEvents(String userId) async {
    await _simulateNetworkDelay();
    return _events.where((event) => event.creatorId == userId).toList();
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
