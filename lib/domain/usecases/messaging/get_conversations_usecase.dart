import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/conversation.dart';
import '../../repositories/messaging_repository.dart';

class GetConversationsUseCase
    implements UseCase<List<Conversation>, GetConversationsParams> {
  const GetConversationsUseCase(this.repository);

  final MessagingRepository repository;

  @override
  Future<Either<Failure, List<Conversation>>> call(
    GetConversationsParams params,
  ) async {
    return repository.getConversations(params.userId);
  }
}

class GetConversationsParams extends Equatable {
  const GetConversationsParams({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}
