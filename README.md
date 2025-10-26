# Redemton Social Network Prototype

Redemton is a location-first social networking experience that combines local events, availability planning, and lightweight messaging. The current milestone establishes the Clean Architecture scaffolding plus an end-to-end authentication flow backed by in-memory fake data sources.

## Highlights

- Clean Architecture split into `core`, `data`, `domain`, and `presentation` layers
- Dependency injection via `get_it`
- BLoC for presentation logic (`flutter_bloc`)
- Auth module implemented with fake remote data source (sign in / sign up / sign out)
- Splash routing that reacts to authentication state
- Reusable validators, theming, and networking utilities

## Project Structure

```
lib/
├── core/            # Cross-cutting concerns (theme, constants, errors, utils)
├── data/            # Models, repositories, and fake remote data sources
├── domain/          # Entities, repositories, and use cases
├── presentation/    # UI pages, BLoCs, routes, and widgets
└── injection_container.dart
```

Each directory has its own README to explain responsibilities and patterns.

## Tech Stack

- Flutter 3.19+
- Dart 3.9+
- `flutter_bloc`, `get_it`, `dartz`, `equatable`
- `connectivity_plus` for network detection
- Firebase packages included as placeholders for future integration

## Getting Started

1. Install dependencies:
	```powershell
	flutter pub get
	```
2. Run the app:
	```powershell
	flutter run
	```
3. Use the built-in fake account or create a new one:
	- Email: `demo@redemton.com`
	- Password: `password123`

## Testing

```powershell
flutter test
```

## Roadmap Snapshot

- Phase 1 (Complete): Foundation scaffolding + Authentication module with fake data
- Upcoming: Map/events module, social graph, calendar, messaging, notifications, search

Please refer to `Comprehensive Flutter Development.txt` for the detailed implementation plan.
