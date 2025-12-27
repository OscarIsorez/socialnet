import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/user.dart';
import 'conversation_avatar.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.currentUser,
    this.participants = const [],
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final User? currentUser;
  final List<User> participants;

  @override
  Widget build(BuildContext context) {
    final displayName = _getDisplayName();
    final lastMessageText = _getLastMessageText();
    final timeText = _formatTime(conversation.updatedAt);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ConversationAvatar(conversation: conversation),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontWeight: conversation.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.unreadCount > 0)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lastMessageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: conversation.unreadCount > 0
                  ? Colors.black87
                  : Colors.grey[600],
              fontWeight: conversation.unreadCount > 0
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                timeText,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              if (conversation.isGroup) ...[
                const SizedBox(width: 8),
                Text(
                  '${conversation.memberCount} members',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _getDisplayName() {
    if (conversation.isGroup) {
      return conversation.groupName ?? 'Group Chat';
    }

    // For individual conversations, show other participant's name
    if (participants.isNotEmpty) {
      final otherParticipant = participants.firstWhere(
        (user) => user.id != currentUser?.id,
        orElse: () => participants.first,
      );
      return otherParticipant.profileName;
    }

    return 'Unknown User';
  }

  String _getLastMessageText() {
    if (conversation.lastMessage == null) {
      return conversation.isGroup ? 'No messages yet' : 'Start a conversation';
    }

    final message = conversation.lastMessage!;
    if (conversation.isGroup && participants.isNotEmpty) {
      // For groups, show sender name
      final sender = participants.firstWhere(
        (user) => user.id == message.senderId,
        orElse: () => User(
          id: message.senderId,
          email: '',
          profileName: 'Unknown',
          createdAt: DateTime.now(),
        ),
      );
      return '${sender.profileName}: ${message.content}';
    }

    return message.content;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(dateTime);
    } else {
      // Older - show date
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
