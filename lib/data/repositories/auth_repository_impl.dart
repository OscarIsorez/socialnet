import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.signIn(email, password);
      return Right(user);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(
    String email,
    String password,
    String profileName,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final user = await _remoteDataSource.signUp(email, password, profileName);
      return Right(user);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }
}
