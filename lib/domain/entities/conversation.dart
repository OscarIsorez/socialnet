import 'package:equatable/equatable.dart';

import 'message.dart';

enum ConversationType { individual, group }

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
    required this.type,
    this.groupName,
    this.groupImageUrl,
    this.groupDescription,
    this.lastMessageId,
  });

  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final DateTime updatedAt;
  final int unreadCount;
  final ConversationType type;
  final String? groupName;
  final String? groupImageUrl;
  final String? groupDescription; // For group chats
  final String? lastMessageId; // Reference to last message

  bool get isGroup => type == ConversationType.group;
  bool get isIndividual => type == ConversationType.individual;
  int get memberCount => participantIds.length;

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    Message? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
    ConversationType? type,
    String? groupName,
    String? groupImageUrl,
    String? groupDescription,
    String? lastMessageId,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      type: type ?? this.type,
      groupName: groupName ?? this.groupName,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
      groupDescription: groupDescription ?? this.groupDescription,
      lastMessageId: lastMessageId ?? this.lastMessageId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    participantIds,
    lastMessage,
    updatedAt,
    unreadCount,
    type,
    groupName,
    groupImageUrl,
    groupDescription,
    lastMessageId,
  ];
}
