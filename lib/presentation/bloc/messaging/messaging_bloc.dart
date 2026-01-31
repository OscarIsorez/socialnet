import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/messaging/create_conversation_usecase.dart';
import '../../../domain/usecases/messaging/get_conversations_usecase.dart';
import '../../../domain/usecases/messaging/get_messages_usecase.dart';
import '../../../domain/usecases/messaging/send_message_usecase.dart';
import '../../../domain/repositories/messaging_repository.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  MessagingBloc({
    required GetConversationsUseCase getConversationsUseCase,
    required GetMessagesUseCase getMessagesUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required CreateConversationUseCase createConversationUseCase,
    required MessagingRepository messagingRepository,
  }) : _getConversationsUseCase = getConversationsUseCase,
       _getMessagesUseCase = getMessagesUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _createConversationUseCase = createConversationUseCase,
       _messagingRepository = messagingRepository,
       super(const MessagingState()) {
    on<LoadConversations>(_onLoadConversations);
    on<WatchConversations>(_onWatchConversations);
    on<LoadMessages>(_onLoadMessages);
    on<WatchMessages>(_onWatchMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateConversation>(_onCreateConversation);
    on<GetOrCreateConversation>(_onGetOrCreateConversation);
  }

  final GetConversationsUseCase _getConversationsUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final CreateConversationUseCase _createConversationUseCase;
  final MessagingRepository _messagingRepository;

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading, clearMessage: true));

    final result = await _getConversationsUseCase(
      GetConversationsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MessagingStatus.failure,
          message: failure.message,
        ),
      ),
      (conversations) => emit(
        state.copyWith(
          status: MessagingStatus.success,
          conversations: conversations,
        ),
      ),
    );
  }

  Future<void> _onWatchConversations(
    WatchConversations event,
    Emitter<MessagingState> emit,
  ) async {
    emit(state.copyWith(status: MessagingStatus.loading, clearMessage: true));

    await emit.forEach<List<Conversation>>(
      _messagingRepository.watchConversations(event.userId),
      onData: (conversations) => state.copyWith(
        status: MessagingStatus.success,
        conversations: conversations,
      ),
      onError: (error, stackTrace) => state.copyWith(
        status: MessagingStatus.failure,
        message: 'Failed to watch conversations: $error',
      ),
    );
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessagingState> emit,
  ) async {
    // Find the conversation from the existing conversations list or created conversation
    final conversation =
        state.conversations
            .where((conv) => conv.id == event.conversationId)
            .firstOrNull ??
        (state.createdConversation?.id == event.conversationId
            ? state.createdConversation
            : null);

    emit(
      state.copyWith(
        status: MessagingStatus.loading,
        currentConversationId: event.conversationId,
        currentConversation: conversation,
        clearCurrentMessages: true,
        clearMessage: true,
      ),
    );

    final result = await _getMessagesUseCase(
      GetMessagesParams(conversationId: event.conversationId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MessagingStatus.failure,
          message: failure.message,
        ),
      ),
      (messages) {
        // Try to find the conversation again in case it was updated
        final updatedConversation =
            state.conversations
                .where((conv) => conv.id == event.conversationId)
                .firstOrNull ??
            (state.createdConversation?.id == event.conversationId
                ? state.createdConversation
                : null) ??
            conversation;

        return emit(
          state.copyWith(
            status: MessagingStatus.success,
            currentMessages: messages,
            currentConversation: updatedConversation,
          ),
        );
      },
    );
  }

  Future<void> _onWatchMessages(
    WatchMessages event,
    Emitter<MessagingState> emit,
  ) async {
    // Find the conversation from the existing conversations list or created conversation
    final conversation =
        state.conversations
            .where((conv) => conv.id == event.conversationId)
            .firstOrNull ??
        (state.createdConversation?.id == event.conversationId
            ? state.createdConversation
            : null);

    emit(
      state.copyWith(
        status: MessagingStatus.loading,
        currentConversationId: event.conversationId,
        currentConversation: conversation,
        clearCurrentMessages: true,
        clearMessage: true,
      ),
    );

    await emit.forEach<List<Message>>(
      _messagingRepository.watchMessages(event.conversationId),
      onData: (messages) {
        // Try to find the conversation again in case it was updated
        final updatedConversation =
            state.conversations
                .where((conv) => conv.id == event.conversationId)
                .firstOrNull ??
            (state.createdConversation?.id == event.conversationId
                ? state.createdConversation
                : null) ??
            conversation;

        return state.copyWith(
          status: MessagingStatus.success,
          currentMessages: messages,
          currentConversationId: event.conversationId,
          currentConversation: updatedConversation,
        );
      },
      onError: (error, stackTrace) => state.copyWith(
        status: MessagingStatus.failure,
        message: 'Failed to watch messages: $error',
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessagingState> emit,
  ) async {
    final result = await _sendMessageUseCase(
      SendMessageParams(message: event.message),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MessagingStatus.failure,
          message: failure.message,
        ),
      ),
      (message) {
        // Message will be updated via the stream subscription
        // No need to manually update the state
      },
    );
  }

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<MessagingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MessagingStatus.loading,
        clearCreatedConversation: true,
        clearMessage: true,
      ),
    );

    final result = await _createConversationUseCase(
      CreateConversationParams(participantIds: event.participantIds),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MessagingStatus.failure,
          message: failure.message,
        ),
      ),
      (conversation) => emit(
        state.copyWith(
          status: MessagingStatus.success,
          createdConversation: conversation,
        ),
      ),
    );
  }

  Future<void> _onGetOrCreateConversation(
    GetOrCreateConversation event,
    Emitter<MessagingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: MessagingStatus.loading,
        clearCreatedConversation: true,
        clearMessage: true,
      ),
    );

    // First check if conversation already exists
    final existingResult = await _messagingRepository.getExistingConversation(
      event.participantIds,
    );

    await existingResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: MessagingStatus.failure,
          message: failure.message,
        ),
      ),
      (existingConversation) async {
        if (existingConversation != null) {
          // Conversation already exists
          emit(
            state.copyWith(
              status: MessagingStatus.success,
              createdConversation: existingConversation,
            ),
          );
        } else {
          // Create new conversation
          final createResult = await _createConversationUseCase(
            CreateConversationParams(participantIds: event.participantIds),
          );

          createResult.fold(
            (failure) => emit(
              state.copyWith(
                status: MessagingStatus.failure,
                message: failure.message,
              ),
            ),
            (conversation) => emit(
              state.copyWith(
                status: MessagingStatus.success,
                createdConversation: conversation,
              ),
            ),
          );
        }
      },
    );
  }
}
