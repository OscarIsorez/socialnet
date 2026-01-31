import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/conversation.dart';
import '../../repositories/messaging_repository.dart';

class CreateConversationUseCase
    implements UseCase<Conversation, CreateConversationParams> {
  const CreateConversationUseCase(this.repository);

  final MessagingRepository repository;

  @override
  Future<Either<Failure, Conversation>> call(
    CreateConversationParams params,
  ) async {
    return repository.createConversation(params.participantIds);
  }
}

class CreateConversationParams extends Equatable {
  const CreateConversationParams({required this.participantIds});

  final List<String> participantIds;

  @override
  List<Object> get props => [participantIds];
}
