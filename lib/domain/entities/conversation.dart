import 'package:equatable/equatable.dart';

import 'message.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final DateTime updatedAt;
  final int unreadCount;

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    Message? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    participantIds,
    lastMessage,
    updatedAt,
    unreadCount,
  ];
}
