import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.conversationId,
    required super.content,
    required super.timestamp,
    super.isRead = false,
    super.type = MessageType.text,
    super.receiverId,
  });

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      senderId: message.senderId,
      conversationId: message.conversationId,
      content: message.content,
      timestamp: message.timestamp,
      isRead: message.isRead,
      type: message.type,
      receiverId: message.receiverId,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime timestamp;
    final timestampValue = json['timestamp'];
    if (timestampValue is Timestamp) {
      timestamp = timestampValue.toDate();
    } else if (timestampValue is String) {
      timestamp = DateTime.parse(timestampValue);
    } else {
      timestamp = DateTime.now();
    }

    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      conversationId: json['conversationId'] as String,
      content: json['content'] as String,
      timestamp: timestamp,
      isRead: json['isRead'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      receiverId: json['receiverId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'conversationId': conversationId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'receiverId': receiverId,
    };
  }

  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'senderId': senderId,
      'conversationId': conversationId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'receiverId': receiverId,
    };
  }
}
