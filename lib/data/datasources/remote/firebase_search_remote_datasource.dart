import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error/exceptions.dart';
import '../../../domain/entities/location_point.dart';
import '../../models/event_model.dart';
import '../../models/search_filters_model.dart';
import '../../models/user_model.dart';
import 'search_remote_datasource.dart';

class FirebaseSearchRemoteDataSource implements SearchRemoteDataSource {
  const FirebaseSearchRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const String _eventsCollection = 'events';
  static const String _usersCollection = 'users';

  @override
  Future<List<EventModel>> searchEvents(
    String query, {
    SearchFiltersModel? filters,
  }) async {
    try {
      if (query.trim().isEmpty) {
        throw const ValidationException('Search query cannot be empty');
      }

      final lowerQuery = query.toLowerCase();

      // Firestore doesn't support full-text search, so we'll use a workaround
      // with array-contains for search terms or title/description filtering on client side
      Query eventsQuery = _firestore.collection(_eventsCollection);

      // Apply basic filters at query level if provided
      if (filters?.isActive != null) {
        eventsQuery = eventsQuery.where(
          'isActive',
          isEqualTo: filters!.isActive,
        );
      } else {
        // Default to active events if no specific filter provided
        eventsQuery = eventsQuery.where('isActive', isEqualTo: true);
      }

      if (filters?.category != null) {
        eventsQuery = eventsQuery.where(
          'category',
          isEqualTo: filters!.category!.name,
        );
      }

      final querySnapshot = await eventsQuery.limit(100).get();
      final events = <EventModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = EventModel.fromJson(data);

          // Client-side text search filtering
          final titleMatch = event.title.toLowerCase().contains(lowerQuery);
          final descMatch = event.description.toLowerCase().contains(
            lowerQuery,
          );

          if (titleMatch || descMatch) {
            events.add(event);
          }
        } catch (e) {
          print('Failed to parse event document ${doc.id}: $e');
          continue;
        }
      }

      // Apply additional filters
      var filteredEvents = events;
      if (filters != null) {
        filteredEvents = _applyEventFilters(events, filters);
      }

      // Sort by relevance (verification count and creation date)
      filteredEvents.sort((a, b) {
        final aScore =
            a.verificationCount * 10 -
            DateTime.now().difference(a.createdAt).inHours;
        final bScore =
            b.verificationCount * 10 -
            DateTime.now().difference(b.createdAt).inHours;
        return bScore.compareTo(aScore);
      });

      return filteredEvents;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to search events: ${e.message}');
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(message: 'Unexpected error searching events: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        throw const ValidationException('Search query cannot be empty');
      }

      final lowerQuery = query.toLowerCase();

      // Search only public profiles
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('isPublic', isEqualTo: true)
          .limit(50)
          .get();

      final users = <UserModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          // Add the document ID to the data since Firestore doesn't store it in document data
          data['id'] = doc.id;
          final user = UserModel.fromJson(data);

          // Client-side text search filtering
          final nameMatch = user.profileName.toLowerCase().contains(lowerQuery);
          final emailMatch = user.email.toLowerCase().contains(lowerQuery);

          if (nameMatch || emailMatch) {
            users.add(user);
          }
        } catch (e) {
          print('Failed to parse user document ${doc.id}: $e');
          continue;
        }
      }

      // Sort by number of friends (more popular users first)
      users.sort((a, b) => b.friendIds.length.compareTo(a.friendIds.length));

      return users;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to search users: ${e.message}');
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(message: 'Unexpected error searching users: $e');
    }
  }

  @override
  Future<List<EventModel>> filterEvents(SearchFiltersModel filters) async {
    try {
      Query eventsQuery = _firestore.collection(_eventsCollection);

      // Apply Firestore-level filters
      if (filters.isActive != null) {
        eventsQuery = eventsQuery.where(
          'isActive',
          isEqualTo: filters.isActive,
        );
      }

      if (filters.category != null) {
        eventsQuery = eventsQuery.where(
          'category',
          isEqualTo: filters.category!.name,
        );
      }

      if (filters.subCategory != null) {
        eventsQuery = eventsQuery.where(
          'subCategory',
          isEqualTo: filters.subCategory!.name,
        );
      }

      if (filters.minVerificationCount != null) {
        eventsQuery = eventsQuery.where(
          'verificationCount',
          isGreaterThanOrEqualTo: filters.minVerificationCount,
        );
      }

      // For date filters, we'll need to apply them on the client side
      // since Firestore has limitations on compound queries
      final querySnapshot = await eventsQuery.limit(200).get();
      final events = <EventModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = EventModel.fromJson(data);
          events.add(event);
        } catch (e) {
          print('Failed to parse event document ${doc.id}: $e');
          continue;
        }
      }

      // Apply remaining filters on client side
      final filteredEvents = _applyEventFilters(events, filters);

      // Sort by start time
      filteredEvents.sort((a, b) {
        if (a.startTime == null && b.startTime == null) return 0;
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return a.startTime!.compareTo(b.startTime!);
      });

      return filteredEvents;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to filter events: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error filtering events: $e');
    }
  }

  @override
  Future<List<EventModel>> getSuggestedEvents(
    String userId, {
    LocationPoint? location,
  }) async {
    try {
      if (userId.isEmpty) {
        throw const ValidationException('User ID is required');
      }

      // Get user to understand their interests
      UserModel? user;
      try {
        final userDoc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          // Add the document ID to the data since Firestore doesn't store it in document data
          userData['id'] = userDoc.id;
          user = UserModel.fromJson(userData);
        }
      } catch (e) {
        print('Failed to fetch user for suggestions: $e');
      }

      // Get active events
      Query eventsQuery = _firestore
          .collection(_eventsCollection)
          .where('isActive', isEqualTo: true);

      // If user has interests, try to filter by category
      if (user != null && user.interests.isNotEmpty) {
        final userCategories = _extractCategoriesFromInterests(user.interests);
        if (userCategories.isNotEmpty) {
          eventsQuery = eventsQuery.where('category', whereIn: userCategories);
        }
      }

      final querySnapshot = await eventsQuery.limit(100).get();
      final events = <EventModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = EventModel.fromJson(data);
          events.add(event);
        } catch (e) {
          print('Failed to parse event document ${doc.id}: $e');
          continue;
        }
      }

      var suggestions = events;

      // Filter by user interests if available
      if (user != null && user.interests.isNotEmpty) {
        final userInterests = user.interests; // Local non-nullable reference
        suggestions = suggestions.where((event) {
          final categoryMatch = userInterests.contains(event.category.name);
          final subCategoryMatch = userInterests.contains(
            event.subCategory.name,
          );
          return categoryMatch || subCategoryMatch;
        }).toList();
      }

      // If location provided, sort by distance
      if (location != null) {
        suggestions.sort((a, b) {
          final distA = _calculateDistance(location, a.location);
          final distB = _calculateDistance(location, b.location);
          return distA.compareTo(distB);
        });
      } else {
        // Sort by verification count and recency if no location
        suggestions.sort((a, b) {
          final aScore =
              a.verificationCount * 10 -
              DateTime.now().difference(a.createdAt).inHours;
          final bScore =
              b.verificationCount * 10 -
              DateTime.now().difference(b.createdAt).inHours;
          return bScore.compareTo(aScore);
        });
      }

      return suggestions.take(20).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get suggested events: ${e.message}',
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Unexpected error getting suggestions: $e',
      );
    }
  }

  List<EventModel> _applyEventFilters(
    List<EventModel> events,
    SearchFiltersModel filters,
  ) {
    return events.where((event) {
      // Location and radius filter
      if (filters.location != null && filters.radiusKm != null) {
        final distance = _calculateDistance(filters.location!, event.location);
        if (distance > filters.radiusKm!) return false;
      }

      // Date range filters
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

  List<String> _extractCategoriesFromInterests(List<String> interests) {
    final categories = <String>[];

    for (final interest in interests) {
      switch (interest.toLowerCase()) {
        case 'music':
        case 'rock':
        case 'jazz':
        case 'rap':
        case 'concerts':
          if (!categories.contains('music')) categories.add('music');
          break;
        case 'sports':
        case 'football':
        case 'basketball':
          if (!categories.contains('sports')) categories.add('sports');
          break;
        case 'social':
        case 'meetup':
        case 'community':
          if (!categories.contains('social')) categories.add('social');
          break;
        case 'problem':
          if (!categories.contains('problem')) categories.add('problem');
          break;
        default:
          if (!categories.contains('other')) categories.add('other');
          break;
      }
    }

    return categories;
  }

  double _calculateDistance(LocationPoint a, LocationPoint b) {
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
