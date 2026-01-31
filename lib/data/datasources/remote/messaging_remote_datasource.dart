import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/conversation.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

abstract class MessagingRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage(MessageModel message);
  Future<ConversationModel> createConversation(List<String> participantIds);
  Future<ConversationModel?> getExistingConversation(
    List<String> participantIds,
  );
  Future<void> markConversationAsRead(String conversationId, String userId);
  Stream<List<ConversationModel>> watchConversations(String userId);
  Stream<List<MessageModel>> watchMessages(String conversationId);
}

class FirebaseMessagingRemoteDataSource implements MessagingRemoteDataSource {
  FirebaseMessagingRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      final conversations = <ConversationModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Get last message if exists
        if (data['lastMessageId'] != null) {
          try {
            final messageDoc = await _firestore
                .collection('conversations')
                .doc(doc.id)
                .collection('messages')
                .doc(data['lastMessageId'])
                .get();

            if (messageDoc.exists) {
              final messageData = messageDoc.data()!;
              messageData['id'] = messageDoc.id;
              data['lastMessage'] = MessageModel.fromJson(messageData);
            }
          } catch (e) {
            // Continue without last message if there's an error
          }
        }

        conversations.add(ConversationModel.fromJson(data));
      }

      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MessageModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final conversationRef = _firestore
          .collection('conversations')
          .doc(message.conversationId);
      final messagesRef = conversationRef.collection('messages');

      // Add message to subcollection using Firestore-compatible JSON
      final messageDoc = await messagesRef.add(message.toFirestoreJson());

      // Update conversation's last message and timestamp
      await conversationRef.update({
        'lastMessageId': messageDoc.id,
        'updatedAt': Timestamp.fromDate(message.timestamp),
      });

      // Return message with generated ID
      return MessageModel(
        id: messageDoc.id,
        senderId: message.senderId,
        conversationId: message.conversationId,
        content: message.content,
        timestamp: message.timestamp,
        isRead: message.isRead,
        type: message.type,
        receiverId: message.receiverId,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<ConversationModel> createConversation(
    List<String> participantIds,
  ) async {
    try {
      // Sort participant IDs for consistent ordering
      final sortedParticipantIds = List<String>.from(participantIds)..sort();

      final conversation = ConversationModel(
        id: '', // Will be set by Firestore
        participantIds: sortedParticipantIds,
        updatedAt: DateTime.now(),
        type: sortedParticipantIds.length == 2
            ? ConversationType.individual
            : ConversationType.group,
      );

      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toFirestoreJson());

      return ConversationModel(
        id: docRef.id,
        participantIds: conversation.participantIds,
        updatedAt: conversation.updatedAt,
        type: conversation.type,
        groupName: conversation.groupName,
        groupImageUrl: conversation.groupImageUrl,
        groupDescription: conversation.groupDescription,
        lastMessageId: conversation.lastMessageId,
      );
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  @override
  Future<ConversationModel?> getExistingConversation(
    List<String> participantIds,
  ) async {
    try {
      // Sort participant IDs for consistent matching
      final sortedParticipantIds = List<String>.from(participantIds)..sort();

      final querySnapshot = await _firestore
          .collection('conversations')
          .where('participantIds', isEqualTo: sortedParticipantIds)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return ConversationModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to check existing conversation: $e');
    }
  }

  @override
  Future<void> markConversationAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      // This could be implemented with a read receipts subcollection
      // For now, just mark messages as read for the user
      final messagesRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages');

      final batch = _firestore.batch();
      final unreadMessages = await messagesRef
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark conversation as read: $e');
    }
  }

  @override
  Stream<List<ConversationModel>> watchConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final conversations = <ConversationModel>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;

            // Get last message if exists
            if (data['lastMessageId'] != null) {
              try {
                final messageDoc = await _firestore
                    .collection('conversations')
                    .doc(doc.id)
                    .collection('messages')
                    .doc(data['lastMessageId'])
                    .get();

                if (messageDoc.exists) {
                  final messageData = messageDoc.data()!;
                  messageData['id'] = messageDoc.id;
                  data['lastMessage'] = MessageModel.fromJson(messageData);
                }
              } catch (e) {
                // Continue without last message if there's an error
              }
            }

            conversations.add(ConversationModel.fromJson(data));
          }

          return conversations;
        });
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return MessageModel.fromJson(data);
          }).toList();
        });
  }
}
