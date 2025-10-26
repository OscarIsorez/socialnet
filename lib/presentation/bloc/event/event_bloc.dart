import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/events/create_event_usecase.dart';
import '../../../domain/usecases/events/update_event_usecase.dart';
import '../../../domain/usecases/events/verify_event_usecase.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc({
    required CreateEventUseCase createEventUseCase,
    required UpdateEventUseCase updateEventUseCase,
    required VerifyEventUseCase verifyEventUseCase,
  }) : _createEventUseCase = createEventUseCase,
       _updateEventUseCase = updateEventUseCase,
       _verifyEventUseCase = verifyEventUseCase,
       super(const EventState()) {
    on<CreateEventRequested>(_onCreateEventRequested);
    on<UpdateEventRequested>(_onUpdateEventRequested);
    on<VerifyEventRequested>(_onVerifyEventRequested);
    on<EventStatusReset>(_onEventStatusReset);
  }

  final CreateEventUseCase _createEventUseCase;
  final UpdateEventUseCase _updateEventUseCase;
  final VerifyEventUseCase _verifyEventUseCase;

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EventStatus.loading,
        operation: EventOperation.create,
        clearMessage: true,
      ),
    );

    final result = await _createEventUseCase(CreateEventParams(event.event));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EventStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (createdEvent) => emit(
        state.copyWith(
          status: EventStatus.success,
          event: createdEvent,
          eventId: createdEvent.id,
        ),
      ),
    );
  }

  Future<void> _onUpdateEventRequested(
    UpdateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EventStatus.loading,
        operation: EventOperation.update,
        clearMessage: true,
      ),
    );

    final result = await _updateEventUseCase(UpdateEventParams(event.event));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EventStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (updatedEvent) => emit(
        state.copyWith(
          status: EventStatus.success,
          event: updatedEvent,
          eventId: updatedEvent.id,
        ),
      ),
    );
  }

  Future<void> _onVerifyEventRequested(
    VerifyEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EventStatus.loading,
        operation: EventOperation.verify,
        clearMessage: true,
      ),
    );

    final result = await _verifyEventUseCase(
      VerifyEventParams(eventId: event.eventId, stillActive: event.stillActive),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EventStatus.failure,
          message: _mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: EventStatus.success,
          event: null,
          eventId: event.eventId,
          clearEvent: true,
        ),
      ),
    );
  }

  void _onEventStatusReset(EventStatusReset event, Emitter<EventState> emit) {
    emit(const EventState());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message ?? 'Validation error';
    }

    if (failure is NetworkFailure) {
      return 'No internet connection';
    }

    return failure.message ?? 'Something went wrong. Please try again.';
  }
}
