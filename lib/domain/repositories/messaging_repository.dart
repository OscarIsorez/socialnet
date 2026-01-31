import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class MessagingRepository {
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);

  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  Future<Either<Failure, Message>> sendMessage(Message message);

  Future<Either<Failure, Conversation>> createConversation(
    List<String> participantIds,
  );

  Future<Either<Failure, Conversation?>> getExistingConversation(
    List<String> participantIds,
  );

  Future<Either<Failure, void>> markConversationAsRead(
    String conversationId,
    String userId,
  );

  Stream<List<Conversation>> watchConversations(String userId);

  Stream<List<Message>> watchMessages(String conversationId);
}
