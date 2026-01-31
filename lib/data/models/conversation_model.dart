import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.participantIds,
    super.lastMessage,
    required super.updatedAt,
    super.unreadCount = 0,
    required super.type,
    super.groupName,
    super.groupImageUrl,
    super.groupDescription,
    super.lastMessageId,
  });

  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      participantIds: conversation.participantIds,
      lastMessage: conversation.lastMessage,
      updatedAt: conversation.updatedAt,
      unreadCount: conversation.unreadCount,
      type: conversation.type,
      groupName: conversation.groupName,
      groupImageUrl: conversation.groupImageUrl,
      groupDescription: conversation.groupDescription,
      lastMessageId: conversation.lastMessageId,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime updatedAt;
    final updatedAtValue = json['updatedAt'];
    if (updatedAtValue is Timestamp) {
      updatedAt = updatedAtValue.toDate();
    } else if (updatedAtValue is String) {
      updatedAt = DateTime.parse(updatedAtValue);
    } else {
      updatedAt = DateTime.now();
    }

    return ConversationModel(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      updatedAt: updatedAt,
      unreadCount: json['unreadCount'] as int? ?? 0,
      type: ConversationType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
      ),
      groupName: json['groupName'] as String?,
      groupImageUrl: json['groupImageUrl'] as String?,
      groupDescription: json['groupDescription'] as String?,
      lastMessageId: json['lastMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'updatedAt': updatedAt.toIso8601String(),
      'unreadCount': unreadCount,
      'type': type.toString().split('.').last,
      'groupName': groupName,
      'groupImageUrl': groupImageUrl,
      'groupDescription': groupDescription,
      'lastMessageId': lastMessageId,
    };
  }

  Map<String, dynamic> toFirestoreJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'unreadCount': unreadCount,
      'type': type.toString().split('.').last,
      'groupName': groupName,
      'groupImageUrl': groupImageUrl,
      'groupDescription': groupDescription,
      'lastMessageId': lastMessageId,
    };
  }
}
