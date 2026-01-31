import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialnet/domain/entities/event.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../routes/app_router.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_events_list.dart';
import '../../widgets/profile/edit_profile_bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId; // If null, shows current user's profile

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    // Get current user ID from AuthBloc instead of hardcoded value
    _loadUserProfile();
  }

  void _loadUserProfile() {
    if (widget.userId != null) {
      // If userId is provided, use it
      context.read<ProfileBloc>().add(LoadProfile(widget.userId!));
    } else {
      // If no userId provided, get current user from AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<ProfileBloc>().add(LoadProfile(authState.user.id));
      } else {
        // User not authenticated, show error or redirect
        // For now, we'll just show an empty state
      }
    }
  }

  void _showEditProfile() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => EditProfileBottomSheet(
          user: state.user,
          onSave: (updatedUser) {
            context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Reload profile when authentication state changes
        if (authState is Authenticated && widget.userId == null) {
          context.read<ProfileBloc>().add(LoadProfile(authState.user.id));
        } else if (authState is Unauthenticated) {
          // Handle unauthenticated state - maybe navigate to login
        }
      },
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // Check if we need to load profile when auth state is ready
            if (state is ProfileInitial && widget.userId == null) {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                // Delay the profile load to avoid calling during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<ProfileBloc>().add(
                      LoadProfile(authState.user.id),
                    );
                  }
                });
              } else {
                // User not authenticated, show message
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 64),
                      SizedBox(height: 16),
                      Text('Please sign in to view your profile'),
                    ],
                  ),
                );
              }
            }

            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final userId = widget.userId ?? 'current-user';
                        context.read<ProfileBloc>().add(LoadProfile(userId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded || state is ProfileUpdating) {
              final user = state is ProfileLoaded
                  ? state.user
                  : (state as ProfileUpdating).user;
              final events = state is ProfileLoaded
                  ? state.userEvents
                  : <Event>[];
              final isEventsLoading =
                  state is ProfileLoaded && state.isEventsLoading;
              final isUpdating = state is ProfileUpdating;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        user.profileName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      if (widget.userId == null) ...[
                        // Only show for current user
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.notifications,
                          ),
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRouter.settings),
                          icon: Icon(
                            Icons.settings_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: isUpdating ? null : _showEditProfile,
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: ProfileHeader(user: user, isUpdating: isUpdating),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created Events',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ProfileEventsList(events: events, isLoading: isEventsLoading),
                ],
              );
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
}
