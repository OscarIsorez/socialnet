import 'package:flutter/material.dart';

enum CreateEventButtonSize { small, medium, large, flexible }

class AnimatedCreateEventButton extends StatefulWidget {
  const AnimatedCreateEventButton({
    super.key,
    required this.onPressed,
    this.size = CreateEventButtonSize.medium,
    this.text = 'Nouvel événement',
    this.icon,
    this.heroTag,
    this.showPulse = true,
  });

  final VoidCallback onPressed;
  final CreateEventButtonSize size;
  final String text;
  final IconData? icon;
  final String? heroTag;
  final bool showPulse;

  @override
  State<AnimatedCreateEventButton> createState() =>
      _AnimatedCreateEventButtonState();
}

class _AnimatedCreateEventButtonState extends State<AnimatedCreateEventButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case CreateEventButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CreateEventButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case CreateEventButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
      case CreateEventButtonSize.flexible:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case CreateEventButtonSize.small:
        return 12;
      case CreateEventButtonSize.medium:
        return 14;
      case CreateEventButtonSize.large:
        return 16;
      case CreateEventButtonSize.flexible:
        return 14;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case CreateEventButtonSize.small:
        return 16;
      case CreateEventButtonSize.medium:
        return 20;
      case CreateEventButtonSize.large:
        return 24;
      case CreateEventButtonSize.flexible:
        return 20;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case CreateEventButtonSize.small:
        return 20;
      case CreateEventButtonSize.medium:
        return 24;
      case CreateEventButtonSize.large:
        return 28;
      case CreateEventButtonSize.flexible:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: _getPadding(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: widget.size == CreateEventButtonSize.flexible
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: _getIconSize(),
                      color: theme.colorScheme.onPrimary,
                    ),
                    SizedBox(
                      width: widget.size == CreateEventButtonSize.small ? 6 : 8,
                    ),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: _getFontSize(),
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (widget.showPulse) {
      final baseButton = button; // Capture the button before reassigning
      button = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: baseButton,
          );
        },
      );
    }

    // Add shimmer effect for extra appeal
    final buttonWithEffects = button; // Capture again before creating stack
    button = Stack(
      children: [
        buttonWithEffects,
        Positioned.fill(
          child: IgnorePointer(
            // Make shimmer overlay non-interactive
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(
                          _pulseController.value * 6.28,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.heroTag != null) {
      return Hero(tag: widget.heroTag!, child: button);
    }

    return button;
  }
}
