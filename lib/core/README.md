# Core Layer

Shared infrastructure and application-level utilities that are reusable across feature modules.

## Contents

- `constants/`: Hard-coded values such as colour palette and app-wide strings.
- `error/`: Data-source exceptions and domain `Failure` representations.
- `network/`: Connectivity helpers used by repositories.
- `theme/`: ThemeData definition and typography tokens.
- `usecases/`: Base `UseCase` contract plus parameter helpers.
- `utils/`: Generic helpers (form validators, date formatting, etc.).

## Guidelines

- Keep this layer UI-agnostic and free of business rules.
- Avoid importing feature-specific code. Anything here should be safe to use anywhere else in the project.
- Add concise comments when behaviour is not obvious (e.g., why a network check branches on different return types).
