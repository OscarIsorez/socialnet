import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/search_repository.dart';

/// Use case for searching users by text query
///
/// Only searches public user profiles
///
/// Example:
/// ```dart
/// final result = await searchUsersUseCase(
///   SearchUsersParams(query: 'john'),
/// );
/// ```
class SearchUsersUseCase implements UseCase<List<User>, SearchUsersParams> {
  final SearchRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) async {
    // Validate query is not empty and meets minimum length
    if (params.query.trim().isEmpty) {
      return Left(ValidationFailure('Search query cannot be empty'));
    }

    if (params.query.trim().length < 2) {
      return Left(
        ValidationFailure('Search query must be at least 2 characters'),
      );
    }

    return await repository.searchUsers(params.query);
  }
}

class SearchUsersParams extends Equatable {
  final String query;

  const SearchUsersParams({required this.query});

  @override
  List<Object?> get props => [query];
}
