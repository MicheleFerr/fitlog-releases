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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motor/motor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/premium_action_button.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';
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
  String get _positionKey => userCacheKeys.userScopedKey('fab_position_${widget.positionKey}');
  String get _hiddenKey => userCacheKeys.userScopedKey('fab_hidden_${widget.positionKey}');

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getString(_positionKey);
    final savedHidden = prefs.getBool(_hiddenKey) ?? false;

    if (mounted) {
      setState(() {
        _isOnLeft = savedPosition == 'left';
        _isHidden = savedHidden;
        _initialized = true;
      });
    }
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_positionKey, _isOnLeft ? 'left' : 'right');
    await prefs.setBool(_hiddenKey, _isHidden);
  }

  /// Toggle hide state with haptic feedback
  void _toggleHidden() {
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
        ? -buttonWidth - 20 // Start from left off-screen
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
    return _isOnLeft
        ? _edgePadding
        : screenWidth - buttonWidth - _edgePadding;
  }

  void _onPanStart(DragStartDetails details) {
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
        : (currentX > screenWidth - buttonWidth + _hideThreshold || velocity > 800);

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
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    // 📱 RESPONSIVE SIZING: Usa FAB compatto (solo icona) su schermi piccoli
    final isCompact = screenWidth < _compactScreenThreshold;
    final buttonWidth = isCompact ? _compactButtonSize : _buttonWidth;

    // When hidden, show only the tab handle
    if (_isHidden) {
      return _buildHiddenTab(context, colorScheme);
    }

    _targetX = _getTargetX(screenWidth, isCompact);

    // Calculate display position based on state
    double displayX;
    if (_isAnimatingToHide) {
      // Animate to off-screen position
      displayX = _isOnLeft
          ? -buttonWidth - 20 // Slide left off screen
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
          bottom: _bottomPadding,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (details) => _onPanEnd(details, screenWidth, isCompact),
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
        );
      },
    );
  }

  /// Build the hidden tab - simple, no animation needed
  Widget _buildHiddenTab(BuildContext context, ColorScheme colorScheme) {
    final isLeftSide = _isOnLeft;

    return Positioned(
      bottom: _bottomPadding,
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
  static String _userKey(String key) => userCacheKeys.userScopedKey('fab_position_$key');

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
  const _ExpandableExerciseMenu({
    required this.onSingleExercise,
    this.onShowHistory,
    this.onHide,
    this.additionalOptions,
  });

  final VoidCallback onSingleExercise;
  final VoidCallback? onShowHistory;
  final VoidCallback? onHide;
  final List<DraggableActionOption>? additionalOptions;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSingleExercise,
    VoidCallback? onShowHistory,
    VoidCallback? onHide,
    List<DraggableActionOption>? additionalOptions,
  }) {
    final safeMax = ModalService.safeMaxChildSize(context, preferredMax: 0.9);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: safeMax,
        snap: true,
        snapSizes: [0.45, safeMax],
        builder: (context, scrollController) => _ExpandableExerciseMenu(
          onSingleExercise: onSingleExercise,
          onShowHistory: onShowHistory,
          onHide: onHide,
          additionalOptions: additionalOptions,
        ),
      ),
    );
  }

  @override
  State<_ExpandableExerciseMenu> createState() => _ExpandableExerciseMenuState();
}

class _ExpandableExerciseMenuState extends State<_ExpandableExerciseMenu> {
  // ✅ FIX: Rimossa variabile _advancedExpanded (dropdown rimosso)

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    AppIcons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.addExercise,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Opzione 1: Esercizio Singolo (PRIMARIA)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.add,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(context.l10n.addSingleExercise),
              subtitle: Text(context.l10n.addSingleExerciseHint),
              trailing: Icon(AppIcons.chevronRight),
              onTap: () {
                Navigator.of(context).pop();
                widget.onSingleExercise();
              },
            ),

            // ✅ FIX: Rimosso dropdown "Set Avanzati"
            // Mostra direttamente le opzioni individuali (Superset, DropSet, Rest-Pause)

            // Additional options (se presenti) - ora include Set Avanzati direttamente
            if (widget.additionalOptions != null) ...[
              const Divider(height: 1),
              ...widget.additionalOptions!.map((option) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (option.color ?? Theme.of(context).colorScheme.secondary).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      option.icon,
                      color: option.color ?? Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  title: Text(option.label),
                  trailing: Icon(AppIcons.chevronRight),
                  onTap: () {
                    Navigator.of(context).pop();
                    option.onTap();
                  },
                );
              }),
            ],

            // ✅ FIX: Rimosso "Storico" e "Nascondi pulsante"
            // Menu deve mostrare solo: Singolo, Superset, DropSet, Rest-Pause

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ✅ FIX: Rimosso metodo _buildAdvancedOption (dropdown rimosso)
}
