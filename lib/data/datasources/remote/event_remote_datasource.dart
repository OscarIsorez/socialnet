import '../../models/event_model.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/entities/location_point.dart';

abstract class EventRemoteDataSource {
  Future<EventModel> createEvent(EventModel event);

  Future<List<EventModel>> getNearbyEvents(
    LocationPoint center,
    double radiusKm, {
    EventCategory? category,
  });

  Future<EventModel> updateEvent(EventModel event);

  Future<void> verifyEvent(String eventId, bool stillActive);
}
