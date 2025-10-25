import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/friend_request.dart';
import '../entities/user.dart';

abstract class SocialRepository {
  Future<Either<Failure, User>> getUserProfile(String userId);

  Future<Either<Failure, User>> updateProfile(User user);

  Future<Either<Failure, List<User>>> searchUsers(String query);

  Future<Either<Failure, void>> sendFriendRequest(
    String fromUserId,
    String toUserId,
  );

  Future<Either<Failure, void>> respondToFriendRequest(
    String requestId,
    FriendRequestStatus status,
  );

  Future<Either<Failure, List<User>>> getFriends(String userId);

  Future<Either<Failure, List<FriendRequest>>> getIncomingRequests(
    String userId,
  );
}
