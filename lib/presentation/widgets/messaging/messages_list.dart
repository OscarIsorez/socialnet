import 'package:flutter/material.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/user.dart';
import 'message_bubble.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({
    super.key,
    required this.messages,
    required this.currentUser,
    this.participants = const [],
    this.isGroupChat = false,
  });

  final List<Message> messages;
  final User currentUser;
  final List<User> participants;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId == currentUser.id;

        // Find sender info for group chats
        User? sender;
        if (isGroupChat && !isCurrentUser) {
          try {
            sender = participants.firstWhere(
              (user) => user.id == message.senderId,
            );
          } catch (e) {
            sender = User(
              id: message.senderId,
              email: '',
              profileName: 'Unknown User',
              createdAt: DateTime.now(),
            );
          }
        }

        // Show sender name in group chats for non-current users
        final showSenderName = isGroupChat && !isCurrentUser;

        return MessageBubble(
          message: message,
          isCurrentUser: isCurrentUser,
          sender: sender,
          showSenderName: showSenderName,
        );
      },
    );
  }
}
