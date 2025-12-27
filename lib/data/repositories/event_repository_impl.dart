import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/remote/event_remote_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({
    required EventRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  final EventRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final created = await _remoteDataSource.createEvent(
        EventModel.fromEntity(event),
      );
      return Right(created);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getNearbyEvents(
    LocationPoint center,
    double radiusKm, {
    EventCategory? category,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _remoteDataSource.getNearbyEvents(
        center,
        radiusKm,
        category: category,
      );
      final events = models.map<Event>((model) => model).toList();
      return Right(events);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updated = await _remoteDataSource.updateEvent(
        EventModel.fromEntity(event),
      );
      return Right(updated);
    } on ValidationException catch (error) {
      return Left(ValidationFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEvent(
    String eventId,
    bool stillActive,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.verifyEvent(eventId, stillActive);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getUserCreatedEvents(
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final events = await _remoteDataSource.getUserCreatedEvents(userId);
      return Right(events.map((model) => model as Event).toList());
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message));
    }
  }
}
