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
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
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
  bool _isDragging = false;
  bool _isOnLeft = false;
  bool _isHidden = false;
  bool _initialized = false;

  // Layout constants
  static const double _edgePadding = 16.0;
  static const double _hideThreshold = 60.0;
  static const double _buttonWidth = 160.0;
  static const double _bottomPadding = 16.0;

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
    setState(() {
      _isHidden = !_isHidden;
    });
    HapticFeedback.mediumImpact();
    _savePosition();
  }

  double _getTargetX(double screenWidth) {
    return _isOnLeft
        ? _edgePadding
        : screenWidth - _buttonWidth - _edgePadding;
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

  void _onPanEnd(DragEndDetails details, double screenWidth) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final currentX = _targetX + _dragOffsetX;

    // Check if dragging towards edge to hide
    final isDraggingToHide = _isOnLeft
        ? (currentX < -_hideThreshold || velocity < -800)
        : (currentX > screenWidth - _buttonWidth + _hideThreshold || velocity > 800);

    if (isDraggingToHide) {
      setState(() {
        _isDragging = false;
        _isHidden = true;
        _dragOffsetX = 0;
      });
      HapticFeedback.heavyImpact();
      _savePosition();
      return;
    }

    // Determine snap side based on position
    final centerX = screenWidth / 2;
    final shouldSnapLeft = currentX + _buttonWidth / 2 < centerX;

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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main action
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(widget.label),
              subtitle: Text(context.l10n.fabMainAction),
              onTap: () {
                Navigator.of(context).pop();
                widget.onPressed();
              },
            ),

            // History option
            if (widget.onShowHistory != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.history,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: Text(context.l10n.fabHistory),
                subtitle: Text(context.l10n.fabViewPreviousWorkouts),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onShowHistory!();
                },
              ),

            // Additional options
            if (widget.additionalOptions != null)
              ...widget.additionalOptions!.map((option) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (option.color ?? Theme.of(context).colorScheme.tertiary).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    option.icon,
                    color: option.color ?? Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                title: Text(option.label),
                onTap: () {
                  Navigator.of(context).pop();
                  option.onTap();
                },
              )),

            // Hide button option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.chevronRight,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(context.l10n.fabHideButton),
              subtitle: Text(context.l10n.fabHideDescription),
              onTap: () {
                Navigator.of(context).pop();
                _toggleHidden();
              },
            ),

            // Drag info
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.swipe,
                    semanticLabel: 'Swipe',
                    size: AppIconSize.small,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.fabDragToHide,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    // When hidden, show only the tab handle
    if (_isHidden) {
      return _buildHiddenTab(context, colorScheme);
    }

    _targetX = _getTargetX(screenWidth);

    // During drag, show at drag position; otherwise animate to target
    final displayX = _isDragging ? _targetX + _dragOffsetX : _targetX;

    return SingleMotionBuilder(
      motion: _isDragging
          ? const NoMotion() // Instant follow during drag
          : const CupertinoMotion.bouncy(), // Spring snap when released
      value: displayX,
      builder: (context, animatedX, child) {
        // Clamp position to screen bounds
        final clampedX = animatedX.clamp(
          _edgePadding,
          screenWidth - _buttonWidth - _edgePadding,
        );

        return Positioned(
          left: clampedX,
          bottom: _bottomPadding,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (details) => _onPanEnd(details, screenWidth),
            onLongPress: () => _showOptionsMenu(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: _isDragging
                    ? Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: AbsorbPointer(
                absorbing: _isDragging,
                child: PremiumActionButton(
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

  /// Build the hidden tab with spring animation
  Widget _buildHiddenTab(BuildContext context, ColorScheme colorScheme) {
    final isLeftSide = _isOnLeft;

    // Animate the tab sliding in from edge
    return SingleMotionBuilder(
      motion: const CupertinoMotion.snappy(),
      value: 0.0, // Target: fully visible
      builder: (context, slideValue, child) {
        final slideOffset = isLeftSide ? -20 * slideValue : 20 * slideValue;

        return Positioned(
          bottom: _bottomPadding,
          left: isLeftSide ? slideOffset : null,
          right: isLeftSide ? null : slideOffset,
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
      },
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
