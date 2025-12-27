import 'package:flutter/material.dart';

class CreateConversationSheet extends StatelessWidget {
  const CreateConversationSheet({
    super.key,
    required this.onNewContact,
    required this.onCreateGroup,
  });

  final VoidCallback onNewContact;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Start New Conversation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            title: const Text('New Contact'),
            subtitle: const Text('Start a conversation with someone'),
            onTap: () {
              Navigator.pop(context);
              onNewContact();
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.group_add, color: Colors.white),
            ),
            title: const Text('Create Group'),
            subtitle: const Text('Start a group conversation'),
            onTap: () {
              Navigator.pop(context);
              onCreateGroup();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
