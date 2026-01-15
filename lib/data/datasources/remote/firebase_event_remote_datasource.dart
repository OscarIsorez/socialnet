import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/exceptions.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';
import '../../models/event_model.dart';
import 'event_remote_datasource.dart';

class FirebaseEventRemoteDataSource implements EventRemoteDataSource {
  const FirebaseEventRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'events';
  final Uuid _uuid = const Uuid();

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      // Generate new ID if not provided
      final eventId = event.id.isEmpty ? _uuid.v4() : event.id;

      final eventWithId = event.copyWith(
        id: eventId,
        createdAt: DateTime.now(),
      );

      final eventData = eventWithId.toJson();

      // Add server timestamp for better consistency
      eventData['serverTimestamp'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collectionName).doc(eventId).set(eventData);

      return eventWithId;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to create event: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error creating event: $e');
    }
  }

  @override
  Future<List<EventModel>> getNearbyEvents(
    LocationPoint center,
    double radiusKm, {
    EventCategory? category,
  }) async {
    try {
      // Firebase doesn't support direct geospatial queries for complex radius searches
      // We'll use a bounding box approach and then filter by distance
      final boundingBox = _calculateBoundingBox(center, radiusKm);

      Query query = _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .where('location.lat', isGreaterThanOrEqualTo: boundingBox.minLat)
          .where('location.lat', isLessThanOrEqualTo: boundingBox.maxLat);

      // Add category filter if provided
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      final querySnapshot = await query.get();

      final events = <EventModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final event = EventModel.fromJson(data);

          // Filter by longitude and exact distance
          if (event.location.longitude >= boundingBox.minLng &&
              event.location.longitude <= boundingBox.maxLng) {
            final distance = _calculateDistance(center, event.location);
            if (distance <= radiusKm) {
              events.add(event);
            }
          }
        } catch (e) {
          // Skip malformed documents but log for debugging
          print('Failed to parse event document ${doc.id}: $e');
          continue;
        }
      }

      // Sort by distance (closest first)
      events.sort((a, b) {
        final distanceA = _calculateDistance(center, a.location);
        final distanceB = _calculateDistance(center, b.location);
        return distanceA.compareTo(distanceB);
      });

      return events;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch nearby events: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error fetching events: $e');
    }
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      if (event.id.isEmpty) {
        throw const ValidationException('Event ID is required for updates');
      }

      final docRef = _firestore.collection(_collectionName).doc(event.id);

      // Check if event exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw const NotFoundException('Event not found');
      }

      final eventData = event.toJson();
      eventData['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(eventData);

      return event;
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw const NotFoundException('Event not found');
      }
      throw ServerException(message: 'Failed to update event: ${e.message}');
    } catch (e) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      throw ServerException(message: 'Unexpected error updating event: $e');
    }
  }

  @override
  Future<void> verifyEvent(String eventId, bool stillActive) async {
    try {
      if (eventId.isEmpty) {
        throw const ValidationException('Event ID is required');
      }

      final docRef = _firestore.collection(_collectionName).doc(eventId);

      // Use a transaction to ensure atomic updates
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          throw const NotFoundException('Event not found');
        }

        final data = docSnapshot.data()!;
        final currentVerificationCount = data['verificationCount'] as int? ?? 0;

        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (!stillActive) {
          updates['isActive'] = false;
        } else {
          updates['verificationCount'] = currentVerificationCount + 1;
        }

        transaction.update(docRef, updates);
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw const NotFoundException('Event not found');
      }
      throw ServerException(message: 'Failed to verify event: ${e.message}');
    } catch (e) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      throw ServerException(message: 'Unexpected error verifying event: $e');
    }
  }

  @override
  Future<List<EventModel>> getUserCreatedEvents(String userId) async {
    try {
      if (userId.isEmpty) {
        throw const ValidationException('User ID is required');
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final events = <EventModel>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final event = EventModel.fromJson(data);
          events.add(event);
        } catch (e) {
          // Skip malformed documents but continue processing others
          print('Failed to parse event document ${doc.id}: $e');
          continue;
        }
      }

      return events;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to fetch user events: ${e.message}',
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(
        message: 'Unexpected error fetching user events: $e',
      );
    }
  }

  /// Calculate bounding box for geospatial queries
  _BoundingBox _calculateBoundingBox(LocationPoint center, double radiusKm) {
    // Convert radius from km to degrees (approximate)
    // 1 degree of latitude ≈ 111 km
    // 1 degree of longitude ≈ 111 km * cos(latitude)
    const kmPerDegreeLat = 111.0;
    final kmPerDegreeLng = kmPerDegreeLat * cos(center.latitude * pi / 180);

    final deltaLat = radiusKm / kmPerDegreeLat;
    final deltaLng = radiusKm / kmPerDegreeLng;

    return _BoundingBox(
      minLat: center.latitude - deltaLat,
      maxLat: center.latitude + deltaLat,
      minLng: center.longitude - deltaLng,
      maxLng: center.longitude + deltaLng,
    );
  }

  /// Calculate distance between two points using Haversine formula
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

/// Helper class for bounding box calculations
class _BoundingBox {
  const _BoundingBox({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
}
