# Data Layer

Implements the bridge between domain repositories and external data sources. For the prototype we rely on fake in-memory services that mimic network latency.

## Contents

- `models/`: DTOs that extend domain entities and provide JSON mapping.
- `datasources/`: Contracts plus fake remote/local implementations.
- `repositories/`: Concrete `*RepositoryImpl` classes that coordinate data sources, handle errors, and return `Either<Failure, T>` results.

## Guidelines

- Always translate thrown exceptions into domain `Failure` objects within repository implementations.
- Keep data models immutable; use `copyWith` for modifications.
- Fake data sources should simulate realistic delays to exercise loading states in the UI.
- When integrating real backends, replace fake sources with API clients but keep the repository interface intact.
