import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Base class for all use cases in the domain layer. Each use case exposes a
/// single `call` method. Parameters are wrapped into a dedicated object to keep
/// method signatures lightweight and future-proof.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Simple marker class to use when a use case does not require parameters.
class NoParams {
  const NoParams();
}
