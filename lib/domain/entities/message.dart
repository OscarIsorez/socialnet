import 'package:equatable/equatable.dart';

enum MessageType { text, activityInvitation }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.senderId,
    required this.conversationId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.receiverId, // Optional: for individual messages
  });

  final String id;
  final String senderId;
  final String conversationId; // Always link to conversation
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final String? receiverId; // Optional: for individual messages

  Message copyWith({
    String? id,
    String? senderId,
    String? conversationId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    String? receiverId,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      receiverId: receiverId ?? this.receiverId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    conversationId,
    content,
    timestamp,
    isRead,
    type,
    receiverId,
  ];
}
