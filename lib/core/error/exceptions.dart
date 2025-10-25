/// Exceptions thrown at the data-source layer. These are later translated into
/// domain-level [Failure] objects so that the presentation layer never needs to
/// deal with low-level concerns.
class ServerException implements Exception {
  const ServerException({this.message});

  final String? message;
}

class CacheException implements Exception {
  const CacheException({this.message});

  final String? message;
}

class AuthException implements Exception {
  const AuthException({this.message});

  final String? message;
}

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;
}
