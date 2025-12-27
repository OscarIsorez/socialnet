import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialnet/core/constants/app_colors.dart';
import 'package:socialnet/domain/entities/event.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_event.dart';
import '../../bloc/profile/profile_state.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_events_list.dart';
import '../../widgets/profile/edit_profile_bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId; // If null, shows current user's profile

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile - for now use 'current-user' as default
    final userId = widget.userId ?? 'current-user';
    context.read<ProfileBloc>().add(LoadProfile(userId));
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      user.profileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    if (widget.userId ==
                        null) // Only show edit for current user
                      IconButton(
                        onPressed: isUpdating ? null : _showEditProfile,
                        icon: const Icon(Icons.edit, color: Colors.white),
                      ),
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
                        Icon(Icons.event, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Created Events',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}
