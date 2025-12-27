import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/remote/social_remote_datasource.dart';
import '../models/user_model.dart';

class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl({
    required SocialRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final SocialRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> getUserProfile(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.getUserProfile(userId);
      return Right(user);
    } on NotFoundException {
      return const Left(NotFoundFailure('User not found'));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updated = await _remoteDataSource.updateProfile(
        UserModel.fromEntity(user),
      );
      return Right(updated);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final users = await _remoteDataSource.searchUsers(query);
      return Right(users.map((model) => model as User).toList());
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(
    String fromUserId,
    String toUserId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.sendFriendRequest(fromUserId, toUserId);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> respondToFriendRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.respondToFriendRequest(
        requestId,
        status.toString(),
      );
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFriends(String userId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final friends = await _remoteDataSource.getFriends(userId);
      return Right(friends.map((model) => model as User).toList());
    } on NotFoundException {
      return const Left(NotFoundFailure('User not found'));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getIncomingRequests(
    String userId,
  ) async {
    // TODO: Implement when friend request model is available
    return const Right([]);
  }
}
