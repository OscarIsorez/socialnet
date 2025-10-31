import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/remote/search_remote_datasource.dart';
import '../models/search_filters_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({
    required SearchRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final SearchRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Event>>> searchEvents(
    String query, {
    SearchFilters? filters,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final filtersModel = filters != null
          ? SearchFiltersModel.fromEntity(filters)
          : null;

      final models = await _remoteDataSource.searchEvents(
        query,
        filters: filtersModel,
      );

      final events = models.map<Event>((model) => model).toList();
      return Right(events);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (error) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _remoteDataSource.searchUsers(query);
      final users = models.map<User>((model) => model).toList();
      return Right(users);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (error) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> filterEvents(
    SearchFilters filters,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final filtersModel = SearchFiltersModel.fromEntity(filters);
      final models = await _remoteDataSource.filterEvents(filtersModel);
      final events = models.map<Event>((model) => model).toList();
      return Right(events);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (error) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getSuggestedEvents(
    String userId, {
    LocationPoint? location,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _remoteDataSource.getSuggestedEvents(
        userId,
        location: location,
      );
      final events = models.map<Event>((model) => model).toList();
      return Right(events);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    } catch (error) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }
}
