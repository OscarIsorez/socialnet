import 'package:flutter/material.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/messaging/message_input.dart';
import '../../widgets/messaging/messages_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.convId});

  final String convId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // Mock data - replace with actual data from your backend/BLoC
  late List<Message> _messages;
  late User _currentUser;
  late List<User> _participants;
  late Conversation _conversation;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _currentUser = User(
      id: 'current-user',
      email: 'current@example.com',
      profileName: 'Current User',
      createdAt: DateTime.now(),
    );

    // Mock users data - same as in conversations page
    final allUsers = [
      _currentUser,
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
      User(
        id: 'dave-id',
        email: 'dave@example.com',
        profileName: 'Dave Brown',
        createdAt: DateTime.now(),
      ),
      User(
        id: 'eve-id',
        email: 'eve@example.com',
        profileName: 'Eve Davis',
        createdAt: DateTime.now(),
      ),
    ];

    // Initialize conversation and participants based on conversation ID
    if (widget.convId == 'user-1') {
      _participants = [_currentUser, allUsers[1]]; // Alice
      _conversation = Conversation(
        id: widget.convId,
        participantIds: ['current-user', 'alice-id'],
        updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        type: ConversationType.individual,
      );
      _messages = [
        Message(
          id: 'msg-1',
          senderId: 'alice-id',
          receiverId: 'current-user',
          content: 'Hey! How are you doing?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          type: MessageType.text,
        ),
      ];
    } else if (widget.convId == 'group-1') {
      _participants = [
        _currentUser,
        allUsers[1],
        allUsers[2],
        allUsers[3],
      ]; // Alice, Bob, Charlie
      _conversation = Conversation(
        id: widget.convId,
        participantIds: ['current-user', 'alice-id', 'bob-id', 'charlie-id'],
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        type: ConversationType.group,
        groupName: 'Flutter Developers',
      );
      _messages = [
        Message(
          id: 'msg-2',
          senderId: 'alice-id',
          receiverId: 'group-1',
          content: 'Check out this new Flutter update!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: MessageType.text,
        ),
      ];
    } else if (widget.convId == 'user-2') {
      _participants = [_currentUser, allUsers[2]]; // Bob
      _conversation = Conversation(
        id: widget.convId,
        participantIds: ['current-user', 'bob-id'],
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        type: ConversationType.individual,
      );
      _messages = [
        Message(
          id: 'msg-3',
          senderId: 'bob-id',
          receiverId: 'current-user',
          content: 'Thanks for the help earlier',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: MessageType.text,
        ),
      ];
    } else if (widget.convId == 'group-2') {
      _participants = [
        _currentUser,
        allUsers[3],
        allUsers[4],
        allUsers[5],
      ]; // Charlie, Dave, Eve
      _conversation = Conversation(
        id: widget.convId,
        participantIds: ['current-user', 'charlie-id', 'dave-id', 'eve-id'],
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        type: ConversationType.group,
        groupName: 'Weekend Plans',
      );
      _messages = [
        Message(
          id: 'msg-4',
          senderId: 'charlie-id',
          receiverId: 'group-2',
          content: 'Anyone up for hiking?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: MessageType.text,
        ),
      ];
    } else {
      // Default fallback
      _participants = [_currentUser, allUsers[1]];
      _conversation = Conversation(
        id: widget.convId,
        participantIds: ['current-user', 'alice-id'],
        updatedAt: DateTime.now(),
        type: ConversationType.individual,
      );
      _messages = [];
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final newMessage = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUser.id,
      receiverId: _conversation.isGroup
          ? widget.convId
          : _participants.firstWhere((u) => u.id != _currentUser.id).id,
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
  }

  String _getChatTitle() {
    if (_conversation.isGroup) {
      return _conversation.groupName ?? 'Group Chat';
    }

    final otherUser = _participants.firstWhere(
      (user) => user.id != _currentUser.id,
    );
    return otherUser.profileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getChatTitle()),
            if (_conversation.isGroup)
              Text(
                '${_conversation.memberCount} members',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          if (_conversation.isGroup)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // Navigate to group info
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group info coming soon')),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MessagesList(
              messages: _messages,
              currentUser: _currentUser,
              participants: _participants,
              isGroupChat: _conversation.isGroup,
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            hintText: _conversation.isGroup
                ? 'Message ${_conversation.groupName ?? 'group'}...'
                : 'Message ${_getChatTitle()}...',
          ),
        ],
      ),
    );
  }
}
