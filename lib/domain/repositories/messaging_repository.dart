import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class MessagingRepository {
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);

  Future<Either<Failure, List<Message>>> getMessages(
    String userId,
    String otherUserId,
  );

  Future<Either<Failure, Message>> sendMessage(Message message);

  Future<Either<Failure, void>> markConversationAsRead(
    String conversationId,
    String userId,
  );
}
