import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/message.dart';
import '../../repositories/messaging_repository.dart';

class GetMessagesUseCase implements UseCase<List<Message>, GetMessagesParams> {
  const GetMessagesUseCase(this.repository);

  final MessagingRepository repository;

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return repository.getMessages(params.conversationId);
  }
}

class GetMessagesParams extends Equatable {
  const GetMessagesParams({required this.conversationId});

  final String conversationId;

  @override
  List<Object> get props => [conversationId];
}
