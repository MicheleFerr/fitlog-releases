/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: shared
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Draggable action button con animazioni spring physics (motor package)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:motor/motor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/core/cache/user_cache_key_manager.dart';

/// Opzione aggiuntiva per il menu del long press
class DraggableActionOption {
  const DraggableActionOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
}

class DraggableActionButton extends StatefulWidget {
  const DraggableActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.positionKey,
    this.backgroundColor,
    this.foregroundColor,
    this.onShowHistory,
    this.additionalOptions,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String positionKey;
  final VoidCallback? onShowHistory;
  final List<DraggableActionOption>? additionalOptions;

  @override
  State<DraggableActionButton> createState() => _DraggableActionButtonState();
}

class _DraggableActionButtonState extends State<DraggableActionButton> {
  // Position tracking - only horizontal for spring animation
  double _dragOffsetX = 0;
  double _targetX = 0;
  double? _lastAnimatedX; // Track last position for smooth transitions
  bool _isDragging = false;
  bool _isOnLeft = false;
  bool _isHidden = false;
  bool _isAnimatingToHide = false; // Track slide-off animation
  bool _isAnimatingFromHidden = false; // Track slide-in animation
  bool _initialized = false;
  bool _showHideHint = false;
  Timer? _hintTimer;

  // Layout constants
  static const double _edgePadding = 16.0;
  static const double _hideThreshold = 60.0;
  static const double _buttonWidth = 160.0;
  static const double _bottomPadding = 16.0;

  // 📱 RESPONSIVE SIZING (Material Design Guidelines)
  // Screen < 460dp → FAB compatto circolare (56x56) solo icona "+"
  // Screen >= 460dp → FAB esteso rettangolare (160xH) icona + "Add Exercise"
  // Previene testo troncato su iPhone SE, schermi piccoli Android
  static const double _compactButtonSize = 56.0;
  static const double _compactScreenThreshold = 460.0;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  // 🔐 User-scoped cache keys
  String get _positionKey =>
      userCacheKeys.userScopedKey('fab_position_${widget.positionKey}');
  String get _hiddenKey =>
      userCacheKeys.userScopedKey('fab_hidden_${widget.positionKey}');
  String get _hideHintKey =>
      userCacheKeys.userScopedKey('fab_hide_hint_seen_${widget.positionKey}');

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getString(_positionKey);
    final savedHidden = prefs.getBool(_hiddenKey) ?? false;
    final hideHintSeen = prefs.getBool(_hideHintKey) ?? false;

    if (mounted) {
      setState(() {
        _isOnLeft = savedPosition == 'left';
        _isHidden = savedHidden;
        _initialized = true;
        _showHideHint = !savedHidden && !hideHintSeen;
      });
    }

    if (!savedHidden && !hideHintSeen) {
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 6), () {
        unawaited(_dismissHideHint());
      });
    }
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_positionKey, _isOnLeft ? 'left' : 'right');
    await prefs.setBool(_hiddenKey, _isHidden);
  }

  Future<void> _dismissHideHint() async {
    _hintTimer?.cancel();
    if (!_showHideHint) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hideHintKey, true);
      return;
    }

    if (mounted) {
      setState(() {
        _showHideHint = false;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideHintKey, true);
  }

  /// Toggle hide state with haptic feedback
  void _toggleHidden() {
    unawaited(_dismissHideHint());
    if (_isHidden) {
      // Coming back from hidden - start slide-in animation
      _startShowAnimation();
    } else {
      // Hiding - start slide-off animation
      _startHideAnimation();
    }
    HapticFeedback.lightImpact(); // Light haptic for both directions
    _savePosition();
  }

  /// Start the slide-in animation when showing button
  void _startShowAnimation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < _compactScreenThreshold;
    final buttonWidth = isCompact ? _compactButtonSize : _buttonWidth;

    // Set starting position off-screen
    _lastAnimatedX = _isOnLeft
        ? -buttonWidth -
              20 // Start from left off-screen
        : screenWidth + 20; // Start from right off-screen

    setState(() {
      _isHidden = false;
      _isAnimatingFromHidden = true;
      _isAnimatingToHide = false;
    });

    // Clear the flag after animation settles
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isAnimatingFromHidden = false;
        });
      }
    });
  }

  /// Start the slide-off animation before fully hiding
  void _startHideAnimation() {
    setState(() {
      _isAnimatingToHide = true;
      _isDragging = false;
      _dragOffsetX = 0;
    });

    // Wait for animation to complete, then show hidden tab smoothly
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _isAnimatingToHide) {
        setState(() {
          _isHidden = true;
          _isAnimatingToHide = false;
          // Reset last position so next show animation starts correctly
          _lastAnimatedX = null;
        });
      }
    });
  }

  double _getTargetX(double screenWidth, bool isCompact) {
    final buttonWidth = isCompact ? _compactButtonSize : _buttonWidth;
    return _isOnLeft ? _edgePadding : screenWidth - buttonWidth - _edgePadding;
  }

  void _onPanStart(DragStartDetails details) {
    unawaited(_dismissHideHint());
    setState(() {
      _isDragging = true;
      _dragOffsetX = 0;
    });
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffsetX += details.delta.dx;
    });
  }

  void _onPanEnd(DragEndDetails details, double screenWidth, bool isCompact) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final currentX = _targetX + _dragOffsetX;
    final buttonWidth = isCompact ? _compactButtonSize : _buttonWidth;

    // Check if dragging towards edge to hide
    final isDraggingToHide = _isOnLeft
        ? (currentX < -_hideThreshold || velocity < -800)
        : (currentX > screenWidth - buttonWidth + _hideThreshold ||
              velocity > 800);

    if (isDraggingToHide) {
      // Start slide-off animation instead of instant hide
      HapticFeedback.lightImpact(); // Lighter haptic for smoother feel
      _startHideAnimation();
      _savePosition();
      return;
    }

    // Determine snap side based on position
    final centerX = screenWidth / 2;
    final shouldSnapLeft = currentX + buttonWidth / 2 < centerX;

    setState(() {
      _isDragging = false;
      _isOnLeft = shouldSnapLeft;
      _dragOffsetX = 0;
    });

    HapticFeedback.mediumImpact();
    _savePosition();
  }

  void _showOptionsMenu(BuildContext context) {
    HapticFeedback.mediumImpact();

    // Use the new expandable menu widget
    _ExpandableExerciseMenu.show(
      context,
      onSingleExercise: widget.onPressed,
      onShowHistory: widget.onShowHistory,
      onHide: _toggleHidden,
      additionalOptions: widget.additionalOptions,
    );
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    // 📱 RESPONSIVE SIZING: Usa FAB compatto (solo icona) su schermi piccoli
    final isCompact = screenWidth < _compactScreenThreshold;
    final buttonWidth = isCompact ? _compactButtonSize : _buttonWidth;

    // Account for tab bar / nav bar height injected via MediaQuery
    final bottomInset = MediaQuery.of(context).padding.bottom + _bottomPadding;

    // When hidden, show only the tab handle
    if (_isHidden) {
      return _buildHiddenTab(context, colorScheme, bottomInset);
    }

    _targetX = _getTargetX(screenWidth, isCompact);

    // Calculate display position based on state
    double displayX;
    if (_isAnimatingToHide) {
      // Animate to off-screen position
      displayX = _isOnLeft
          ? -buttonWidth -
                20 // Slide left off screen
          : screenWidth + 20; // Slide right off screen
    } else if (_isDragging) {
      displayX = _targetX + _dragOffsetX;
    } else {
      displayX = _targetX;
    }

    // Use last known position as starting point to prevent jumping
    final fromX = _lastAnimatedX ?? _targetX;

    // Use slower motion for hide animation to make it visible
    final motion = _isDragging
        ? const NoMotion() // Instant follow during drag
        : _isAnimatingToHide
        ? const CupertinoMotion() // Smooth slide-off
        : const CupertinoMotion(); // Smooth spring for normal movement

    return SingleMotionBuilder(
      motion: motion,
      value: displayX,
      from: fromX, // Start from last position
      builder: (context, animatedX, child) {
        // Store last animated position for next transition
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _lastAnimatedX = animatedX;
        });

        // Don't clamp when animating to/from hide - let it go off screen
        final clampedX = (_isAnimatingToHide || _isAnimatingFromHidden)
            ? animatedX
            : animatedX.clamp(
                _edgePadding,
                screenWidth - buttonWidth - _edgePadding,
              );

        return Positioned(
          left: clampedX,
          bottom: bottomInset,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_showHideHint)
                Positioned(
                  top: -52,
                  left: _isOnLeft ? 0 : null,
                  right: _isOnLeft ? null : 0,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _showHideHint ? 1 : 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 250),
                        offset: _showHideHint
                            ? Offset.zero
                            : const Offset(0, 0.2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isOnLeft
                                    ? AppIcons.chevronLeft
                                    : AppIcons.chevronRight,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.l10n.dragToHideFabHint,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: (details) =>
                    _onPanEnd(details, screenWidth, isCompact),
                onLongPress: () => _showOptionsMenu(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    borderRadius: isCompact
                        ? BorderRadius.circular(28) // Circolare per compact
                        : BorderRadius.circular(16),
                    border: _isDragging
                        ? Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: AbsorbPointer(
                    absorbing: _isDragging,
                    child: isCompact
                        ? CompactActionButton(
                            onPressed: widget.onPressed,
                            icon: widget.icon,
                            tooltip: widget.label, // Label diventa tooltip
                            backgroundColor: widget.backgroundColor,
                            foregroundColor: widget.foregroundColor,
                          )
                        : PremiumActionButton(
                            onPressed: widget.onPressed,
                            icon: widget.icon,
                            label: widget.label,
                            backgroundColor: widget.backgroundColor,
                            foregroundColor: widget.foregroundColor,
                            showShadow: !_isDragging,
                            width: _buttonWidth,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build the hidden tab - simple, no animation needed
  Widget _buildHiddenTab(
    BuildContext context,
    ColorScheme colorScheme,
    double bottomInset,
  ) {
    final isLeftSide = _isOnLeft;

    return Positioned(
      bottom: bottomInset,
      left: isLeftSide ? 0 : null,
      right: isLeftSide ? null : 0,
      child: GestureDetector(
        onTap: _toggleHidden,
        onHorizontalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dx;
          if (isLeftSide && velocity > 200) {
            _toggleHidden();
          } else if (!isLeftSide && velocity < -200) {
            _toggleHidden();
          }
        },
        child: Container(
          width: 20,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: isLeftSide ? Radius.zero : const Radius.circular(8),
              bottomLeft: isLeftSide ? Radius.zero : const Radius.circular(8),
              topRight: isLeftSide ? const Radius.circular(8) : Radius.zero,
              bottomRight: isLeftSide ? const Radius.circular(8) : Radius.zero,
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(isLeftSide ? 1 : -1, 1),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isLeftSide ? AppIcons.chevronRight : AppIcons.chevronLeft,
              color: colorScheme.onSurfaceVariant,
              size: AppIconSize.small,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget wrapper for absolute positioning
class DraggableActionButtonWrapper extends StatelessWidget {
  const DraggableActionButtonWrapper({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.positionKey,
    required this.child,
    this.backgroundColor,
  });
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final String positionKey;
  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        DraggableActionButton(
          onPressed: onPressed,
          icon: icon,
          label: label,
          positionKey: positionKey,
          backgroundColor: backgroundColor,
        ),
      ],
    );
  }
}

/// Provider for global position preferences
class ActionButtonPosition {
  static String _userKey(String key) =>
      userCacheKeys.userScopedKey('fab_position_$key');

  static Future<bool> isOnLeft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey(key)) == 'left';
  }

  static Future<void> setPosition(String key, bool isLeft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey(key), isLeft ? 'left' : 'right');
  }

  static Future<void> resetAllPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final userPrefix = userCacheKeys.userScopedKey('fab_position_');
    final keys = prefs.getKeys().where((k) => k.startsWith(userPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// Expandable menu for Add Exercise FAB with advanced sets dropdown
/// Implements Option B from UX analysis with hierarchical navigation
class _ExpandableExerciseMenu extends StatefulWidget {
  const _ExpandableExerciseMenu();

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSingleExercise,
    VoidCallback? onShowHistory,
    VoidCallback? onHide,
    List<DraggableActionOption>? additionalOptions,
  }) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          context.l10n.addExercise,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Primary: Add Single Exercise
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onSingleExercise();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.addSingleExercise,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.l10n.addSingleExerciseHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Additional options (Advanced Sets)
          if (additionalOptions != null)
            ...additionalOptions.map((option) {
              return CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  option.onTap();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.icon,
                      color:
                          option.color ??
                          Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option.label,
                      style: TextStyle(
                        color:
                            option.color ??
                            Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: Text(context.l10n.cancel),
        ),
      ),
    );
  }

  @override
  State<_ExpandableExerciseMenu> createState() =>
      _ExpandableExerciseMenuState();
}

class _ExpandableExerciseMenuState extends State<_ExpandableExerciseMenu> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
