import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/event.dart';
import '../entities/location_point.dart';

abstract class EventRepository {
  Future<Either<Failure, Event>> createEvent(Event event);

  Future<Either<Failure, List<Event>>> getNearbyEvents(
    LocationPoint center,
    double radiusKm, {
    EventCategory? category,
  });

  Future<Either<Failure, Event>> updateEvent(Event event);

  Future<Either<Failure, void>> verifyEvent(String eventId, bool stillActive);

  Future<Either<Failure, List<Event>>> getUserCreatedEvents(String userId);
}
