part of 'event_bloc.dart';

enum EventStatus { initial, loading, success, failure }

enum EventOperation { none, create, update, verify }

class EventState extends Equatable {
  const EventState({
    this.status = EventStatus.initial,
    this.operation = EventOperation.none,
    this.event,
    this.eventId,
    this.message,
  });

  final EventStatus status;
  final EventOperation operation;
  final Event? event;
  final String? eventId;
  final String? message;

  EventState copyWith({
    EventStatus? status,
    EventOperation? operation,
    Event? event,
    String? eventId,
    String? message,
    bool clearEvent = false,
    bool clearEventId = false,
    bool clearMessage = false,
  }) {
    return EventState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      event: clearEvent ? null : event ?? this.event,
      eventId: clearEventId ? null : eventId ?? this.eventId,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, operation, event, eventId, message];
}
