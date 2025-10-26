# Domain Layer

Pure business logic expressed through entities, repository contracts, and use cases. This layer is platform-agnostic and contains no Flutter imports.

## Contents

- `entities/`: Equatable value objects representing core business concepts (User, Event, Message, etc.).
- `repositories/`: Abstract contracts describing the operations required from the data layer.
- `usecases/`: Application-specific actions that orchestrate repositories and return `Either<Failure, Success>` results.

## Guidelines

- Entities must remain immutable; provide `copyWith` helpers when necessary.
- Use cases should expose a single `call` method and rely on parameter objects for extensibility.
- Never import from `presentation` or `data` here. The direction of dependency always points inward.
