import 'package:flutter/material.dart';

import '../../routes/app_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit profile'),
            onTap: () => Navigator.pushNamed(context, AppRouter.editProfile),
          ),
          ListTile(
            leading: const Icon(Icons.interests_outlined),
            title: const Text('Manage interests'),
            onTap: () => Navigator.pushNamed(context, AppRouter.interests),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification preferences'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
