import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/remote/messaging_remote_datasource.dart';
import '../models/message_model.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  const MessagingRepositoryImpl({required this.remoteDataSource});

  final MessagingRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(
    String userId,
  ) async {
    try {
      final conversations = await remoteDataSource.getConversations(userId);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get conversations: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(
    String conversationId,
  ) async {
    try {
      final messages = await remoteDataSource.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get messages: $e'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final sentMessage = await remoteDataSource.sendMessage(messageModel);
      return Right(sentMessage);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> createConversation(
    List<String> participantIds,
  ) async {
    try {
      final conversation = await remoteDataSource.createConversation(
        participantIds,
      );
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, Conversation?>> getExistingConversation(
    List<String> participantIds,
  ) async {
    try {
      final conversation = await remoteDataSource.getExistingConversation(
        participantIds,
      );
      return Right(conversation);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to check existing conversation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markConversationAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      await remoteDataSource.markConversationAsRead(conversationId, userId);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to mark conversation as read: $e'),
      );
    }
  }

  @override
  Stream<List<Conversation>> watchConversations(String userId) {
    return remoteDataSource
        .watchConversations(userId)
        .map((models) => models.map((model) => model as Conversation).toList());
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return remoteDataSource
        .watchMessages(conversationId)
        .map((models) => models.map((model) => model as Message).toList());
  }
}
