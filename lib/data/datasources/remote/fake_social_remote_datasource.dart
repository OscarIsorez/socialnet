import 'dart:async';

import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'social_remote_datasource.dart';

class FakeSocialRemoteDataSource implements SocialRemoteDataSource {
  FakeSocialRemoteDataSource() {
    _seedUsers();
  }

  final List<UserModel> _users = <UserModel>[];

  void _seedUsers() {
    if (_users.isNotEmpty) return;

    final now = DateTime.now();
    _users.addAll([
      UserModel(
        id: 'current-user',
        email: 'current.user@example.com',
        profileName: 'Current User',
        photoUrl: 'https://picsum.photos/200/200?random=1',
        isPublic: true,
        interests: ['Flutter', 'Mobile Development', 'Hiking'],
        friendIds: ['alice-id', 'bob-id'],
        createdAt: now.subtract(const Duration(days: 365)),
      ),
      UserModel(
        id: 'alice-id',
        email: 'alice@example.com',
        profileName: 'Alice Johnson',
        photoUrl: 'https://picsum.photos/200/200?random=2',
        isPublic: true,
        interests: ['Photography', 'Travel', 'Flutter'],
        friendIds: ['current-user', 'charlie-id'],
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      UserModel(
        id: 'bob-id',
        email: 'bob@example.com',
        profileName: 'Bob Smith',
        photoUrl: 'https://picsum.photos/200/200?random=3',
        isPublic: true,
        interests: ['Sports', 'Gaming', 'Music'],
        friendIds: ['current-user'],
        createdAt: now.subtract(const Duration(days: 150)),
      ),
      UserModel(
        id: 'charlie-id',
        email: 'charlie@example.com',
        profileName: 'Charlie Wilson',
        photoUrl: 'https://picsum.photos/200/200?random=4',
        isPublic: false,
        interests: ['Cooking', 'Movies', 'Reading'],
        friendIds: ['alice-id'],
        createdAt: now.subtract(const Duration(days: 100)),
      ),
    ]);
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    await _simulateNetworkDelay();

    final user = _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => throw const NotFoundException('User not found'),
    );

    return user;
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await _simulateNetworkDelay();

    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      throw const NotFoundException('User not found');
    }

    _users[index] = user;
    return user;
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    await _simulateNetworkDelay();

    if (query.isEmpty) return [];

    return _users.where((user) {
      final searchQuery = query.toLowerCase();
      return user.profileName.toLowerCase().contains(searchQuery) ||
          user.email.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    await _simulateNetworkDelay();
    // Mock implementation - in real app this would send a friend request
  }

  @override
  Future<void> respondToFriendRequest(String requestId, String status) async {
    await _simulateNetworkDelay();
    // Mock implementation - in real app this would respond to friend request
  }

  @override
  Future<List<UserModel>> getFriends(String userId) async {
    await _simulateNetworkDelay();

    final user = _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => throw const NotFoundException('User not found'),
    );

    return _users.where((u) => user.friendIds.contains(u.id)).toList();
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
