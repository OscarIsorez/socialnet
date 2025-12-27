import 'package:flutter/material.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/user.dart';
import '../../routes/app_router.dart';
import '../../widgets/messaging/conversation_tile.dart';
import '../../widgets/messaging/create_conversation_sheet.dart';
import '../../widgets/messaging/empty_conversations_state.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  // Mock data - replace with actual data from your backend/BLoC
  final List<Conversation> _conversations = [
    Conversation(
      id: 'user-1',
      participantIds: ['current-user', 'alice-id'],
      lastMessage: Message(
        id: 'msg-1',
        senderId: 'alice-id',
        receiverId: 'current-user',
        content: 'Hey! How are you doing?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: MessageType.text,
      ),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      unreadCount: 1,
      type: ConversationType.individual,
    ),
    Conversation(
      id: 'group-1',
      participantIds: ['current-user', 'alice-id', 'bob-id', 'charlie-id'],
      lastMessage: Message(
        id: 'msg-2',
        senderId: 'alice-id',
        receiverId: 'group-1',
        content: 'Check out this new Flutter update!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: MessageType.text,
      ),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      type: ConversationType.group,
      groupName: 'Flutter Developers',
    ),
    Conversation(
      id: 'user-2',
      participantIds: ['current-user', 'bob-id'],
      lastMessage: Message(
        id: 'msg-3',
        senderId: 'bob-id',
        receiverId: 'current-user',
        content: 'Thanks for the help earlier',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: MessageType.text,
      ),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      type: ConversationType.individual,
    ),
    Conversation(
      id: 'group-2',
      participantIds: ['current-user', 'charlie-id', 'dave-id', 'eve-id'],
      lastMessage: Message(
        id: 'msg-4',
        senderId: 'charlie-id',
        receiverId: 'group-2',
        content: 'Anyone up for hiking?',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: MessageType.text,
      ),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 2,
      type: ConversationType.group,
      groupName: 'Weekend Plans',
    ),
  ];

  // Mock users data - this would come from your user repository/BLoC
  final List<User> _users = [
    User(
      id: 'alice-id',
      email: 'alice@example.com',
      profileName: 'Alice Johnson',
      createdAt: DateTime.now(),
    ),
    User(
      id: 'bob-id',
      email: 'bob@example.com',
      profileName: 'Bob Smith',
      createdAt: DateTime.now(),
    ),
    User(
      id: 'charlie-id',
      email: 'charlie@example.com',
      profileName: 'Charlie Wilson',
      createdAt: DateTime.now(),
    ),
  ];

  final User _currentUser = User(
    id: 'current-user',
    email: 'current@example.com',
    profileName: 'Current User',
    createdAt: DateTime.now(),
  );

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateConversationSheet(
        onNewContact: _navigateToNewContact,
        onCreateGroup: _navigateToCreateGroup,
      ),
    );
  }

  void _navigateToNewContact() {
    // Navigate to contact search/add page
    // Navigator.pushNamed(context, AppRouter.newContact);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to add new contact')),
    );
  }

  void _navigateToCreateGroup() {
    // Navigate to group creation page
    // Navigator.pushNamed(context, AppRouter.createGroup);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to create group')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _conversations.isEmpty
          ? EmptyConversationsState(onStartConversation: _showCreateOptions)
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return ConversationTile(
                  conversation: conversation,
                  currentUser: _currentUser,
                  participants: _users,
                  onTap: () => _navigateToChat(conversation),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _navigateToChat(Conversation conversation) {
    Navigator.pushNamed(context, AppRouter.chat, arguments: conversation.id);
  }
}
