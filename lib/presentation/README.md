# Presentation Layer

Flutter UI, widgets, navigation, and state management live here. The layer consumes use cases through BLoCs and renders the results.

## Contents

- `bloc/`: Feature-specific BLoCs, events, and states.
- `pages/`: Screens grouped by feature (auth, map, events, etc.).
- `routes/`: Central router that maps named routes to pages.
- `widgets/`: Reusable UI components organised by domain (common, map, event, etc.).

## Guidelines

- BLoCs should only depend on domain use cases; avoid direct access to repositories.
- Keep pages lean: delegate logic to BLoCs and prefer extracting complex UI pieces into widgets.
- Use `BlocListener` for one-off side effects (navigation, snackbars) and `BlocBuilder` for rendering.
- Keep Material/Widget-specific constants in this layer; share theme tokens via the `core` layer when appropriate.
