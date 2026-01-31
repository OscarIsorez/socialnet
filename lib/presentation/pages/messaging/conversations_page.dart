import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialnet/presentation/bloc/auth/auth_state.dart';

import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/social/get_user_profile.dart';
import '../../../injection_container.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/messaging/messaging_bloc.dart';
import '../../routes/app_router.dart';
import '../../widgets/messaging/conversation_tile.dart';
import '../../widgets/messaging/create_conversation_sheet.dart';
import '../../widgets/messaging/empty_conversations_state.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage>
    with AutomaticKeepAliveClientMixin {
  final Map<String, User> _participantCache = {};
  final GetUserProfile _getUserProfile = getIt<GetUserProfile>();

  @override
  void initState() {
    super.initState();
    _initializeConversations();
  }

  void _initializeConversations() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<MessagingBloc>().add(
        WatchConversations(userId: authState.user.id),
      );
    }
  }

  Future<List<User>> _getParticipants(List<String> participantIds) async {
    final participants = <User>[];

    for (final id in participantIds) {
      if (_participantCache.containsKey(id)) {
        participants.add(_participantCache[id]!);
      } else {
        try {
          final result = await _getUserProfile(id);
          result.fold(
            (failure) {
              // If we can't load a participant, create a placeholder
              final placeholder = User(
                id: id,
                email: '',
                profileName: 'Unknown User',
                createdAt: DateTime.now(),
              );
              _participantCache[id] = placeholder;
              participants.add(placeholder);
            },
            (user) {
              _participantCache[id] = user;
              participants.add(user);
            },
          );
        } catch (e) {
          // Handle any unexpected errors
          final placeholder = User(
            id: id,
            email: '',
            profileName: 'Unknown User',
            createdAt: DateTime.now(),
          );
          _participantCache[id] = placeholder;
          participants.add(placeholder);
        }
      }
    }

    return participants;
  }

  @override
  bool get wantKeepAlive => true;

  void _showCreateConversationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateConversationSheet(
        onNewContact: _handleNewContact,
        onCreateGroup: _handleCreateGroup,
      ),
    );
  }

  void _handleNewContact() {
    Navigator.pushNamed(context, AppRouter.search);
  }

  void _handleCreateGroup() {
    // TODO: Implement group creation flow
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Group creation coming soon')));
  }

  void _openConversation(Conversation conversation, User? currentUser, List<User> participants) {
    Navigator.pushNamed(
      context,
      AppRouter.chat,
      arguments: {'conversation': conversation, 'currentUser': currentUser, 'participants': participants},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showCreateConversationSheet,
            tooltip: 'New Conversation',
          ),
        ],
      ),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        builder: (context, state) {
          if (state.isLoading && state.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? 'Failed to load conversations',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is Authenticated) {
                        context.read<MessagingBloc>().add(
                          LoadConversations(userId: authState.user.id),
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.conversations.isEmpty) {
            return EmptyConversationsState(
              onStartConversation: _showCreateConversationSheet,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context.read<MessagingBloc>().add(
                  LoadConversations(userId: authState.user.id),
                );
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                final authState = context.read<AuthBloc>().state;
                final currentUser = authState is Authenticated
                    ? authState.user
                    : null;

                return FutureBuilder<List<User>>(
                  future: _getParticipants(conversation.participantIds),
                  builder: (context, snapshot) {
                    final participants = snapshot.data ?? [];

                    return ConversationTile(
                      conversation: conversation,
                      currentUser: currentUser,
                      participants: participants,
                      onTap: () => _openConversation(conversation, currentUser, participants)
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
