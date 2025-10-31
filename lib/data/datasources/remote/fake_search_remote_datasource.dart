import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../models/event_model.dart';
import '../../models/search_filters_model.dart';
import '../../models/user_model.dart';
import 'search_remote_datasource.dart';

class FakeSearchRemoteDataSource implements SearchRemoteDataSource {
  FakeSearchRemoteDataSource() {
    _seedData();
  }

  final List<EventModel> _events = <EventModel>[];
  final List<UserModel> _users = <UserModel>[];
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  void _seedData() {
    if (_events.isNotEmpty && _users.isNotEmpty) return;

    _seedEvents();
    _seedUsers();
  }

  void _seedEvents() {
    final now = DateTime.now();

    // Music Events
    _events.addAll([
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
        creatorId: 'user234',
        title: 'Soirée Jazz au Bar',
        description: 'Musique jazz live avec des artistes locaux.',
        category: EventCategory.music,
        subCategory: EventSubCategory.jazz,
        location: const LocationPoint(latitude: 46.5820, longitude: 0.3360),
        photoUrl: 'https://picsum.photos/400/300?random=21',
        startTime: now.add(const Duration(days: 3, hours: 21)),
        endTime: now.add(const Duration(days: 4, hours: 1)),
        isActive: true,
        verificationCount: 7,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      EventModel(
        id: _uuid.v4(),
        creatorId: 'user345',
        title: 'Festival Rap Underground',
        description: 'Battle de rap et freestyle avec les talents locaux.',
        category: EventCategory.music,
        subCategory: EventSubCategory.rap,
        location: const LocationPoint(latitude: 46.5790, longitude: 0.3380),
        photoUrl: 'https://picsum.photos/400/300?random=31',
        startTime: now.add(const Duration(days: 5, hours: 19)),
        endTime: now.add(const Duration(days: 5, hours: 23)),
        isActive: true,
        verificationCount: 12,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

    // Sports Events
    _events.addAll([
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
        creatorId: 'user567',
        title: 'Tournoi de Basketball 3x3',
        description: 'Compétition de basket en plein air, inscription libre.',
        category: EventCategory.sports,
        subCategory: EventSubCategory.basketball,
        location: const LocationPoint(latitude: 46.5845, longitude: 0.3320),
        photoUrl: 'https://picsum.photos/400/300?random=22',
        startTime: now.add(const Duration(days: 4, hours: 14)),
        endTime: now.add(const Duration(days: 4, hours: 18)),
        isActive: true,
        verificationCount: 8,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // Problem Events
    _events.addAll([
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

    // Social Events
    _events.addAll([
      EventModel(
        id: _uuid.v4(),
        creatorId: 'user890',
        title: 'Apéro entre voisins',
        description: 'Rencontre conviviale pour faire connaissance.',
        category: EventCategory.social,
        subCategory: EventSubCategory.meetup,
        location: const LocationPoint(latitude: 46.5808, longitude: 0.3345),
        photoUrl: 'https://picsum.photos/400/300?random=14',
        startTime: now.add(const Duration(days: 1, hours: 18)),
        endTime: now.add(const Duration(days: 1, hours: 21)),
        isActive: true,
        verificationCount: 4,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      EventModel(
        id: _uuid.v4(),
        creatorId: 'user901',
        title: 'Pique-nique au parc',
        description: 'Journée détente au grand air avec jeux et barbecue.',
        category: EventCategory.social,
        subCategory: EventSubCategory.meetup,
        location: const LocationPoint(latitude: 46.5795, longitude: 0.3365),
        photoUrl: 'https://picsum.photos/400/300?random=24',
        startTime: now.add(const Duration(days: 6, hours: 12)),
        endTime: now.add(const Duration(days: 6, hours: 16)),
        isActive: true,
        verificationCount: 6,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
    ]);

    // Add more random events
    for (int i = 0; i < 12; i++) {
      final offsetLat = (_random.nextDouble() - 0.5) / 100;
      final offsetLng = (_random.nextDouble() - 0.5) / 100;
      final eventCategory =
          EventCategory.values[_random.nextInt(EventCategory.values.length)];
      final subCategory = EventSubCategory
          .values[_random.nextInt(EventSubCategory.values.length)];

      _events.add(
        EventModel(
          id: _uuid.v4(),
          creatorId: 'user${100 + i}',
          title: 'Event ${eventCategory.name} #$i',
          description:
              'Découvrez cet événement ${eventCategory.name} dans votre quartier.',
          category: eventCategory,
          subCategory: subCategory,
          location: LocationPoint(
            latitude: 46.58 + offsetLat,
            longitude: 0.34 + offsetLng,
          ),
          photoUrl: 'https://picsum.photos/400/300?random=${40 + i}',
          startTime: now.add(Duration(hours: (i * 6) + 1)),
          endTime: now.add(Duration(hours: (i * 6) + 4)),
          isActive: _random.nextBool(),
          verificationCount: _random.nextInt(15),
          createdAt: now.subtract(Duration(hours: _random.nextInt(72))),
        ),
      );
    }
  }

  void _seedUsers() {
    final now = DateTime.now();

    _users.addAll([
      UserModel(
        id: 'user123',
        email: 'alice.martin@example.com',
        profileName: 'Alice Martin',
        photoUrl: 'https://i.pravatar.cc/150?img=1',
        isPublic: true,
        interests: const ['music', 'rock', 'concerts'],
        friendIds: const ['user456', 'user789'],
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      UserModel(
        id: 'user234',
        email: 'bob.dupont@example.com',
        profileName: 'Bob Dupont',
        photoUrl: 'https://i.pravatar.cc/150?img=2',
        isPublic: true,
        interests: const ['sports', 'football', 'music'],
        friendIds: const ['user123', 'user345'],
        createdAt: now.subtract(const Duration(days: 75)),
      ),
      UserModel(
        id: 'user345',
        email: 'claire.bernard@example.com',
        profileName: 'Claire Bernard',
        photoUrl: 'https://i.pravatar.cc/150?img=3',
        isPublic: true,
        interests: const ['music', 'jazz', 'arts'],
        friendIds: const ['user234', 'user456'],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      UserModel(
        id: 'user456',
        email: 'david.rousseau@example.com',
        profileName: 'David Rousseau',
        photoUrl: 'https://i.pravatar.cc/150?img=4',
        isPublic: true,
        interests: const ['sports', 'basketball', 'football'],
        friendIds: const ['user123', 'user567'],
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      UserModel(
        id: 'user567',
        email: 'emma.petit@example.com',
        profileName: 'Emma Petit',
        photoUrl: 'https://i.pravatar.cc/150?img=5',
        isPublic: true,
        interests: const ['social', 'meetup', 'cooking'],
        friendIds: const ['user456', 'user678'],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'user678',
        email: 'francois.leroy@example.com',
        profileName: 'François Leroy',
        photoUrl: 'https://i.pravatar.cc/150?img=6',
        isPublic: false,
        interests: const ['music', 'rap', 'sports'],
        friendIds: const ['user567'],
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      UserModel(
        id: 'user789',
        email: 'gaelle.moreau@example.com',
        profileName: 'Gaëlle Moreau',
        photoUrl: 'https://i.pravatar.cc/150?img=7',
        isPublic: true,
        interests: const ['social', 'problem', 'community'],
        friendIds: const ['user123', 'user890'],
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: 'user890',
        email: 'hugo.simon@example.com',
        profileName: 'Hugo Simon',
        photoUrl: 'https://i.pravatar.cc/150?img=8',
        isPublic: true,
        interests: const ['music', 'social', 'meetup'],
        friendIds: const ['user789', 'user901'],
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      UserModel(
        id: 'user901',
        email: 'isabelle.laurent@example.com',
        profileName: 'Isabelle Laurent',
        photoUrl: 'https://i.pravatar.cc/150?img=9',
        isPublic: true,
        interests: const ['social', 'outdoor', 'sports'],
        friendIds: const ['user890'],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);

    // Add more random users
    for (int i = 0; i < 15; i++) {
      final isPublic = _random.nextBool();
      _users.add(
        UserModel(
          id: 'user${1000 + i}',
          email: 'user${1000 + i}@example.com',
          profileName: 'User ${1000 + i}',
          photoUrl: 'https://i.pravatar.cc/150?img=${10 + i}',
          isPublic: isPublic,
          interests: _getRandomInterests(),
          friendIds: const [],
          createdAt: now.subtract(Duration(days: _random.nextInt(100))),
        ),
      );
    }
  }

  List<String> _getRandomInterests() {
    final allInterests = [
      'music',
      'sports',
      'social',
      'arts',
      'tech',
      'cooking',
      'travel',
      'reading',
    ];
    final count = _random.nextInt(4) + 1;
    allInterests.shuffle(_random);
    return allInterests.take(count).toList();
  }

  @override
  Future<List<EventModel>> searchEvents(
    String query, {
    SearchFiltersModel? filters,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final lowerQuery = query.toLowerCase();
    var results = _events.where((event) {
      final titleMatch = event.title.toLowerCase().contains(lowerQuery);
      final descMatch = event.description.toLowerCase().contains(lowerQuery);
      return titleMatch || descMatch;
    }).toList();

    // Apply filters if provided
    if (filters != null) {
      results = _applyFilters(results, filters);
    }

    // Sort by relevance (verification count and creation date)
    results.sort((a, b) {
      final aScore =
          a.verificationCount * 10 +
          (a.isActive ? 5 : 0) -
          DateTime.now().difference(a.createdAt).inHours;
      final bScore =
          b.verificationCount * 10 +
          (b.isActive ? 5 : 0) -
          DateTime.now().difference(b.createdAt).inHours;
      return bScore.compareTo(aScore);
    });

    return results;
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final lowerQuery = query.toLowerCase();

    // Only search public profiles
    final results = _users.where((user) {
      if (!user.isPublic) return false;

      final nameMatch = user.profileName.toLowerCase().contains(lowerQuery);
      final emailMatch = user.email.toLowerCase().contains(lowerQuery);

      return nameMatch || emailMatch;
    }).toList();

    // Sort by number of friends (more popular users first)
    results.sort((a, b) => b.friendIds.length.compareTo(a.friendIds.length));

    return results;
  }

  @override
  Future<List<EventModel>> filterEvents(SearchFiltersModel filters) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    var results = List<EventModel>.from(_events);
    results = _applyFilters(results, filters);

    // Sort by start time
    results.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    return results;
  }

  @override
  Future<List<EventModel>> getSuggestedEvents(
    String userId, {
    LocationPoint? location,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    // Find user to get their interests
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => _users.first,
    );

    var results = _events.where((event) => event.isActive).toList();

    // Filter by interests
    if (user.interests.isNotEmpty) {
      results = results.where((event) {
        final categoryMatch = user.interests.contains(
          event.category.name.toLowerCase(),
        );
        final subCategoryMatch = user.interests.contains(
          event.subCategory.name.toLowerCase(),
        );
        return categoryMatch || subCategoryMatch;
      }).toList();
    }

    // If location provided, sort by distance
    if (location != null) {
      results.sort((a, b) {
        final distA = _haversineDistanceKm(location, a.location);
        final distB = _haversineDistanceKm(location, b.location);
        return distA.compareTo(distB);
      });
    }

    // Limit to top 20 suggestions
    return results.take(20).toList();
  }

  List<EventModel> _applyFilters(
    List<EventModel> events,
    SearchFiltersModel filters,
  ) {
    return events.where((event) {
      // Category filter
      if (filters.category != null && event.category != filters.category) {
        return false;
      }

      // SubCategory filter
      if (filters.subCategory != null &&
          event.subCategory != filters.subCategory) {
        return false;
      }

      // Active status filter
      if (filters.isActive != null && event.isActive != filters.isActive) {
        return false;
      }

      // Verification count filter
      if (filters.minVerificationCount != null &&
          event.verificationCount < filters.minVerificationCount!) {
        return false;
      }

      // Location and radius filter
      if (filters.location != null && filters.radiusKm != null) {
        final distance = _haversineDistanceKm(
          filters.location!,
          event.location,
        );
        if (distance > filters.radiusKm!) {
          return false;
        }
      }

      // Date range filter
      if (event.startTime != null) {
        if (filters.startDate != null &&
            event.startTime!.isBefore(filters.startDate!)) {
          return false;
        }
        if (filters.endDate != null &&
            event.startTime!.isAfter(filters.endDate!)) {
          return false;
        }
      }

      return true;
    }).toList();
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
}
