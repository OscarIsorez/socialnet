part of 'messaging_bloc.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends MessagingEvent {
  const LoadConversations({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

class WatchConversations extends MessagingEvent {
  const WatchConversations({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

class LoadMessages extends MessagingEvent {
  const LoadMessages({required this.conversationId});

  final String conversationId;

  @override
  List<Object> get props => [conversationId];
}

class WatchMessages extends MessagingEvent {
  const WatchMessages({required this.conversationId});

  final String conversationId;

  @override
  List<Object> get props => [conversationId];
}

class SendMessage extends MessagingEvent {
  const SendMessage({required this.message});

  final Message message;

  @override
  List<Object> get props => [message];
}

class CreateConversation extends MessagingEvent {
  const CreateConversation({required this.participantIds});

  final List<String> participantIds;

  @override
  List<Object> get props => [participantIds];
}

class GetOrCreateConversation extends MessagingEvent {
  const GetOrCreateConversation({required this.participantIds});

  final List<String> participantIds;

  @override
  List<Object> get props => [participantIds];
}
