import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/message.dart';
import '../../repositories/messaging_repository.dart';

class SendMessageUseCase implements UseCase<Message, SendMessageParams> {
  const SendMessageUseCase(this.repository);

  final MessagingRepository repository;

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return repository.sendMessage(params.message);
  }
}

class SendMessageParams extends Equatable {
  const SendMessageParams({required this.message});

  final Message message;

  @override
  List<Object> get props => [message];
}
