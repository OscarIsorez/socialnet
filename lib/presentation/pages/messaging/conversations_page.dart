import 'package:flutter/material.dart';

import '../../routes/app_router.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Conversation ${index + 1}'),
            subtitle: const Text('Last message preview...'),
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.chat,
              arguments: 'user-${index + 1}',
            ),
          );
        },
      ),
    );
  }
}
