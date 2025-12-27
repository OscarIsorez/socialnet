import '../../models/user_model.dart';

abstract class SocialRemoteDataSource {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateProfile(UserModel user);
  Future<List<UserModel>> searchUsers(String query);
  Future<void> sendFriendRequest(String fromUserId, String toUserId);
  Future<void> respondToFriendRequest(String requestId, String status);
  Future<List<UserModel>> getFriends(String userId);
}
