# Redemtion Social Network - Architecture Overview

This document provides a comprehensive overview of the Redemton social networking application's architecture, designed to help AI models understand the codebase structure and generate contextually appropriate code.

## Table of Contents

1. [Architectural Principles](#architectural-principles)
2. [Layer Overview](#layer-overview)
3. [Core Design Patterns](#core-design-patterns)
4. [Dependency Management](#dependency-management)
5. [Module Structure](#module-structure)
6. [State Management](#state-management)
7. [Data Flow](#data-flow)
8. [Error Handling](#error-handling)
9. [Testing Strategy](#testing-strategy)
10. [Code Generation Guidelines](#code-generation-guidelines)

## Architectural Principles

### Clean Architecture
The project strictly follows Clean Architecture principles by Robert C. Martin, with clear separation of concerns across four distinct layers:

- **Domain Layer**: Pure business logic, no external dependencies
- **Data Layer**: Data access and repository implementations
- **Presentation Layer**: UI components and state management
- **Core Layer**: Cross-cutting concerns and shared utilities

### Dependency Rule
Dependencies flow inward only: 
- Presentation → Domain ← Data
- Core is accessible by all layers but depends on none
- Domain layer has no knowledge of frameworks or external concerns

### SOLID Principles
- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Clients depend only on interfaces they use
- **Dependency Inversion**: Depend on abstractions, not concretions

## Layer Overview

### 1. Domain Layer (`lib/domain/`)

The innermost layer containing pure business logic and business rules.

```
domain/
├── entities/           # Core business models (User, Event, Message, etc.)
├── repositories/       # Abstract repository contracts
└── usecases/          # Application-specific business logic
    ├── auth/          # Authentication use cases
    ├── calendar/      # Calendar-related use cases
    ├── events/        # Event management use cases
    ├── messaging/     # Chat and messaging use cases
    ├── notifications/ # Notification handling
    ├── search/        # Search functionality
    └── social/        # Social features (profiles, friends)
```

**Key Characteristics:**
- No Flutter imports allowed
- All entities are immutable and extend `Equatable`
- Use cases return `Either<Failure, Success>` from the `dartz` package
- Repository interfaces define contracts without implementation details

**Example Entity Pattern:**
```dart
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  
  const User({required this.id, required this.email, required this.displayName});
  
  User copyWith({String? id, String? email, String? displayName}) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
  );
  
  @override
  List<Object> get props => [id, email, displayName];
}
```

### 2. Data Layer (`lib/data/`)

Implements domain repository contracts and manages data sources.

```
data/
├── models/            # DTOs with JSON serialization
├── datasources/       # Data source interfaces and implementations
│   ├── local/         # Local storage (SQLite, SharedPreferences)
│   └── remote/        # API clients and fake implementations
└── repositories/      # Repository implementations
```

**Key Characteristics:**
- Models extend domain entities and add JSON serialization
- Repository implementations coordinate multiple data sources
- Exception handling and conversion to domain `Failure` objects
- Current phase uses fake data sources with realistic delays

**Repository Implementation Pattern:**
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, User>> signIn(SignInParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signIn(params);
        return Right(user);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
```

### 3. Presentation Layer (`lib/presentation/`)

Flutter UI components, state management, and user interaction handling.

```
presentation/
├── bloc/              # Feature-specific BLoCs
│   ├── auth/          # Authentication state management
│   ├── calendar/      # Calendar state management
│   ├── event/         # Event-related state
│   ├── friends/       # Social connections
│   ├── map/           # Map and location state
│   ├── messaging/     # Chat state management
│   ├── notifications/ # Notification state
│   ├── profile/       # User profile management
│   └── search/        # Search functionality
├── mixins/            # Reusable widget behaviors
├── pages/             # Screen implementations
├── routes/            # Navigation configuration
└── widgets/           # Reusable UI components
    ├── common/        # Generic widgets
    ├── auth/          # Auth-specific widgets
    ├── event/         # Event-related widgets
    └── map/           # Map-related widgets
```

**BLoC Pattern:**
Each feature follows the BLoC pattern with Events, States, and BLoC classes:

```dart
// Events
abstract class AuthEvent extends Equatable {}
class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  // ...
}

// States  
abstract class AuthState extends Equatable {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  // ...
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  // ...
}
```

### 4. Core Layer (`lib/core/`)

Cross-cutting concerns and shared utilities.

```
core/
├── constants/         # App-wide constants and configuration
├── error/            # Error handling and failure types
├── network/          # Network connectivity utilities
├── theme/            # Material Design theming
├── usecases/         # Base use case contracts
└── utils/            # Generic utilities and validators
```

## Core Design Patterns

### 1. Repository Pattern
Abstracts data access logic and provides a uniform interface for data operations.

### 2. Use Case Pattern
Encapsulates single application-specific business rules and coordinates repository operations.

### 3. BLoC Pattern
Manages state and business logic for UI components, ensuring separation of concerns.

### 4. Factory Pattern
Used in dependency injection to create instances based on runtime conditions.

### 5. Strategy Pattern
Applied in data source selection (fake vs. real implementations).

## Dependency Management

### Dependency Injection Container (`injection_container.dart`)

The application uses `get_it` for service location and dependency injection:

```dart
final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // Use Cases
  getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  
  // Repositories  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );
  
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => FakeAuthRemoteDataSource(), // Will be replaced with real implementation
  );
  
  // BLoCs
  getIt.registerFactory(() => AuthBloc(signInUseCase: getIt()));
}
```

### Dependency Graph
```
Pages → BLoCs → Use Cases → Repository Interfaces → Repository Implementations → Data Sources
                     ↑
               Core Utilities
```

## Module Structure

The application is organized around these core modules:

### 1. Authentication Module
- **Purpose**: User registration, login, logout, password reset
- **Key Components**: AuthBloc, SignInUseCase, AuthRepository
- **Data Sources**: FakeAuthRemoteDataSource (will become FirebaseAuthRemoteDataSource)

### 2. Events Module
- **Purpose**: Create, discover, and manage local events
- **Key Components**: EventBloc, CreateEventUseCase, EventRepository
- **Features**: Location-based events, event verification, user-created events

### 3. Social Module  
- **Purpose**: User profiles, friend connections, social interactions
- **Key Components**: ProfileBloc, SocialRepository
- **Features**: Profile management, friend requests, social graph

### 4. Map Module
- **Purpose**: Location services, map display, nearby event discovery
- **Key Components**: MapBloc, LocationService
- **Integration**: Google Maps, geolocation services

### 5. Search Module
- **Purpose**: Event and user search, filtering, recommendations
- **Key Components**: SearchBloc, SearchRepository
- **Features**: Event filtering, user search, suggested events

### 6. Calendar Module
- **Purpose**: Personal calendar, availability planning
- **Key Components**: CalendarBloc, CalendarRepository
- **Features**: Availability tracking, event scheduling

### 7. Messaging Module
- **Purpose**: In-app messaging and chat
- **Key Components**: MessagingBloc, ChatRepository
- **Features**: Direct messages, event-based chat

### 8. Notifications Module
- **Purpose**: Push notifications, in-app alerts
- **Key Components**: NotificationBloc, NotificationRepository
- **Features**: Event reminders, social notifications

## State Management

### BLoC Architecture
Each module follows a consistent BLoC structure:

1. **Events**: User actions or external triggers
2. **States**: UI representation states (loading, success, error)
3. **BLoC**: Business logic and state transitions

### State Types
Common state patterns across the application:

```dart
abstract class BaseState extends Equatable {}

class InitialState extends BaseState {}
class LoadingState extends BaseState {}
class SuccessState<T> extends BaseState {
  final T data;
  const SuccessState(this.data);
}
class ErrorState extends BaseState {
  final String message;
  const ErrorState(this.message);
}
```

## Data Flow

### 1. User Interaction Flow
```
User Interaction → Widget → BLoC Event → BLoC Business Logic → Use Case → Repository → Data Source → External API/Database
                                    ↓
UI Update ← Widget ← BLoC State ← BLoC ← Use Case Result ← Repository Result ← Data Source Response
```

### 2. Authentication Flow Example
```dart
// 1. User presses login button
onPressed: () => context.read<AuthBloc>().add(SignInRequested(email, password))

// 2. BLoC receives event
@override
Stream<AuthState> mapEventToState(AuthEvent event) async* {
  if (event is SignInRequested) {
    yield AuthLoading();
    final result = await signInUseCase(SignInParams(email: event.email, password: event.password));
    yield result.fold(
      (failure) => AuthError(failure.message),
      (user) => AuthAuthenticated(user),
    );
  }
}

// 3. UI reacts to state changes
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return CircularProgressIndicator();
    if (state is AuthAuthenticated) return HomeScreen();
    if (state is AuthError) return ErrorWidget(state.message);
    return LoginForm();
  },
)
```

## Error Handling

### Failure Types
The application uses a consistent error handling approach:

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Network connection error');
}

class ServerFailure extends Failure {
  const ServerFailure([String? message]) : super(message ?? 'Server error');
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}
```

### Error Propagation
1. **Data Sources**: Throw specific exceptions
2. **Repositories**: Catch exceptions and convert to `Failure` objects
3. **Use Cases**: Return `Either<Failure, Success>`
4. **BLoCs**: Handle failures and emit error states
5. **UI**: Display user-friendly error messages

## Testing Strategy

### Test Structure
```
test/
├── unit/
│   ├── domain/
│   ├── data/
│   └── core/
├── widget/
│   └── presentation/
└── integration/
```

### Testing Principles
1. **Domain Layer**: Unit tests for entities and use cases
2. **Data Layer**: Mock external dependencies, test repository logic
3. **Presentation Layer**: Widget tests for UI components, BLoC tests for state management
4. **Integration Tests**: End-to-end user flows

### Mock Strategy
- Use `mockito` for creating test doubles
- Mock repository interfaces in BLoC tests
- Mock data sources in repository tests
- Use fake data for integration tests

## Code Generation Guidelines

When generating code for this project, consider these guidelines:

### 1. Follow Existing Patterns
- **Use Cases**: Always return `Either<Failure, Success>`
- **Entities**: Extend `Equatable` and provide `copyWith` methods
- **Models**: Extend entities and add `fromJson`/`toJson`
- **BLoCs**: Follow event-driven architecture with proper state management

### 2. Dependency Injection
- Register new services in `injection_container.dart`
- Use interfaces for testability
- Follow the established dependency graph

### 3. Error Handling
- Create specific `Failure` types for new domains
- Handle exceptions at repository level
- Provide meaningful error messages for users

### 4. File Organization
- Place files in appropriate layer directories
- Follow the established naming conventions
- Create feature-specific subdirectories when needed

### 5. Documentation
- Add comprehensive documentation for public APIs
- Include usage examples for complex components
- Document business rules and constraints

### 6. Testing
- Write tests for all new business logic
- Create widget tests for new UI components
- Add integration tests for complete user flows

### 7. State Management
- Use BLoC pattern for all feature state management
- Create specific events for user actions
- Design states that represent UI needs clearly

### 8. Data Layer Considerations
- Currently using fake data sources with realistic delays
- Prepare for future integration with real backends
- Maintain repository interface contracts when switching implementations

This architecture ensures maintainability, testability, and scalability while following Flutter and Clean Architecture best practices. The modular structure allows for independent development of features while maintaining consistent patterns across the application.