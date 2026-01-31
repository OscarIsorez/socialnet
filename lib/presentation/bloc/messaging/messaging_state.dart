part of 'messaging_bloc.dart';

enum MessagingStatus { initial, loading, success, failure }

class MessagingState extends Equatable {
  const MessagingState({
    this.status = MessagingStatus.initial,
    this.conversations = const [],
    this.currentMessages = const [],
    this.currentConversationId,
    this.currentConversation,
    this.createdConversation,
    this.message,
  });

  final MessagingStatus status;
  final List<Conversation> conversations;
  final List<Message> currentMessages;
  final String? currentConversationId;
  final Conversation? currentConversation;
  final Conversation? createdConversation;
  final String? message;

  bool get isLoading => status == MessagingStatus.loading;
  bool get isSuccess => status == MessagingStatus.success;
  bool get isFailure => status == MessagingStatus.failure;

  MessagingState copyWith({
    MessagingStatus? status,
    List<Conversation>? conversations,
    List<Message>? currentMessages,
    String? currentConversationId,
    Conversation? currentConversation,
    Conversation? createdConversation,
    String? message,
    bool clearCurrentConversation = false,
    bool clearCreatedConversation = false,
    bool clearCurrentMessages = false,
    bool clearMessage = false,
  }) {
    return MessagingState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      currentMessages: clearCurrentMessages
          ? []
          : (currentMessages ?? this.currentMessages),
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      currentConversation: clearCurrentConversation
          ? null
          : (currentConversation ?? this.currentConversation),
      createdConversation: clearCreatedConversation
          ? null
          : (createdConversation ?? this.createdConversation),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversations,
    currentMessages,
    currentConversationId,
    currentConversation,
    createdConversation,
    message,
  ];
}
