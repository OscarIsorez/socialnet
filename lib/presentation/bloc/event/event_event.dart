part of 'event_bloc.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventRequested extends EventEvent {
  const CreateEventRequested(this.event);

  final Event event;

  @override
  List<Object?> get props => [event];
}

class UpdateEventRequested extends EventEvent {
  const UpdateEventRequested(this.event);

  final Event event;

  @override
  List<Object?> get props => [event];
}

class VerifyEventRequested extends EventEvent {
  const VerifyEventRequested({
    required this.eventId,
    required this.stillActive,
  });

  final String eventId;
  final bool stillActive;

  @override
  List<Object?> get props => [eventId, stillActive];
}

class EventStatusReset extends EventEvent {
  const EventStatusReset();
}
