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
              color: Theme.of(context).colorScheme.outline,
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
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person_add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            title: const Text('New Contact'),
            subtitle: const Text('Start a conversation with someone'),
            onTap: () {
              Navigator.pop(context);
              onNewContact();
            },
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.group_add,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
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
