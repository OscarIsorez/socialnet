import 'package:flutter/material.dart';

import '../../../domain/entities/conversation.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.conversation,
    this.size = 40,
  });

  final Conversation conversation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: conversation.isGroup
              ? Colors.purple[100]
              : Colors.blue[100],
          backgroundImage: conversation.groupImageUrl != null
              ? NetworkImage(conversation.groupImageUrl!)
              : null,
          child: conversation.groupImageUrl == null
              ? Icon(
                  conversation.isGroup ? Icons.group : Icons.person,
                  color: conversation.isGroup
                      ? Colors.purple[700]
                      : Colors.blue[700],
                  size: size * 0.5,
                )
              : null,
        ),
        if (conversation.unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                conversation.unreadCount > 99
                    ? '99+'
                    : conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
