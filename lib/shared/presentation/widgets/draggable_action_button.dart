/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: shared
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Draggable action button con salvataggio posizione
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class DraggableActionButton extends StatefulWidget { // Opzioni aggiuntive nel menu
  
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
  final String positionKey; // Chiave unica per salvare la posizione
  final VoidCallback? onShowHistory; // Callback per mostrare lo storico
  final List<DraggableActionOption>? additionalOptions;
  
  @override
  State<DraggableActionButton> createState() => _DraggableActionButtonState();
}

class _DraggableActionButtonState extends State<DraggableActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  double _currentX = 0;
  double _dragStartX = 0;
  bool _isDragging = false;
  bool _isOnLeft = false;
  bool _isHidden = false; // PiP-style hidden state
  bool _isAnimatingIn = false; // Tracks slide-in animation

  // Soglie per snap
  static const double _edgePadding = 16.0;
  static const double _hideThreshold = 50.0; // Distanza per triggerare hide
  static const double _buttonWidth = 180.0; // Larghezza stimata del button
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadPosition();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // 🔐 User-scoped cache keys
  String get _positionKey => userCacheKeys.userScopedKey('fab_position_${widget.positionKey}');
  String get _hiddenKey => userCacheKeys.userScopedKey('fab_hidden_${widget.positionKey}');

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getString(_positionKey);
    final savedHidden = prefs.getBool(_hiddenKey) ?? false;

    setState(() {
      if (savedPosition == 'left') {
        _isOnLeft = true;
      }
      _isHidden = savedHidden;
    });
  }

  Future<void> _savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _positionKey,
      _isOnLeft ? 'left' : 'right',
    );
    await prefs.setBool(_hiddenKey, _isHidden);
  }

  /// Toggle hide state (PiP-style) with smooth animation
  void _toggleHidden() {
    if (_isHidden) {
      // Unhiding: trigger slide-in animation
      setState(() {
        _isHidden = false;
        _isAnimatingIn = true;
      });
      _animationController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _isAnimatingIn = false;
          });
        }
      });
    } else {
      // Hiding: instant transition to tab
      setState(() {
        _isHidden = true;
      });
    }
    HapticFeedback.mediumImpact();
    _savePosition();
  }
  
  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartX = details.localPosition.dx;
    });
    HapticFeedback.lightImpact();
  }
  
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentX = details.localPosition.dx - _dragStartX;
    });
  }
  
  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    const buttonWidth = 180.0; // Larghezza stimata del button
    final centerX = (screenWidth - buttonWidth) / 2;

    // Check if dragging towards edge to hide (PiP-style)
    final velocity = details.velocity.pixelsPerSecond.dx;
    final isDraggingToHide = _isOnLeft
        ? (_currentX < -_hideThreshold || velocity < -500)
        : (_currentX > _hideThreshold || velocity > 500);

    if (isDraggingToHide && !_isHidden) {
      // Hide the FAB with PiP-style tab
      setState(() {
        _isDragging = false;
        _isHidden = true;
        _currentX = 0;
      });
      HapticFeedback.heavyImpact();
      _savePosition();
      return;
    }

    // Calcola se siamo più vicini a sinistra o destra
    final absoluteX = _isOnLeft
        ? _currentX
        : (screenWidth - buttonWidth - _edgePadding) + _currentX;

    final shouldSnapLeft = absoluteX < centerX;

    setState(() {
      _isDragging = false;
      _isOnLeft = shouldSnapLeft;
      _currentX = 0;
    });

    // Haptic feedback per lo snap
    HapticFeedback.mediumImpact();

    // Salva la nuova posizione
    _savePosition();

    // Anima il ritorno alla posizione
    _animationController.forward(from: 0).then((_) {
      _animationController.reset();
    });
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
            
            // Titolo
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
            
            // Opzione principale (azione normale)
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
            
            // Opzione storico se disponibile
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
            
            // Opzioni aggiuntive se presenti
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
            
            // Hide button option (PiP-style)
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

            // Informazione drag
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
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // When hidden, show only the tab handle at the edge
    if (_isHidden) {
      return _buildHiddenTab(context, screenWidth, colorScheme);
    }

    // Calcola la posizione base (sinistra o destra)
    final double baseX = _isOnLeft
        ? _edgePadding
        : screenWidth - _buttonWidth - _edgePadding;

    // Aggiungi l'offset del drag
    double currentX = baseX + (_isDragging ? _currentX : 0);

    // Limita il movimento ai bordi dello schermo
    currentX = currentX.clamp(_edgePadding, screenWidth - _buttonWidth - _edgePadding);

    // Calculate slide-in animation offset with smooth easing
    final double slideOffset = _isAnimatingIn
        ? (_isOnLeft ? -_buttonWidth : _buttonWidth) *
            (1 - Curves.easeOutCubic.transform(_animationController.value))
        : 0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          bottom: 16,
          left: currentX + (_isAnimatingIn ? slideOffset : 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _isAnimatingIn ? _animationController.value : 1.0,
            child: AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: child,
            ),
          ),
        );
      },
      child: Stack(
          children: [
            // Button principale con gesture detector
            GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onLongPress: () {
                // Mostra menu opzioni
                _showOptionsMenu(context);
              },
              child: AbsorbPointer(
                absorbing: _isDragging, // Disabilita tap durante drag
                child: PremiumActionButton(
                  onPressed: widget.onPressed,
                  icon: widget.icon,
                  label: widget.label,
                  backgroundColor: widget.backgroundColor,
                  foregroundColor: widget.foregroundColor,
                  showShadow: !_isDragging,
                  width: 160,
                ),
              ),
            ),

            // Subtle drag indicator - only during active drag
            if (_isDragging)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }

  /// Build the PiP-style hidden tab that peeks from edge
  Widget _buildHiddenTab(
    BuildContext context,
    double screenWidth,
    ColorScheme colorScheme,
  ) {
    // Tab appears on the side where FAB was positioned
    final isLeftSide = _isOnLeft;

    return Positioned(
      bottom: 20,
      left: isLeftSide ? 0 : null,
      right: isLeftSide ? null : 0,
      child: GestureDetector(
        onTap: _toggleHidden,
        onHorizontalDragEnd: (details) {
          // Swipe from edge to show FAB
          final velocity = details.velocity.pixelsPerSecond.dx;
          if (isLeftSide && velocity > 200) {
            _toggleHidden();
          } else if (!isLeftSide && velocity < -200) {
            _toggleHidden();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Container(
            width: 20,
            height: 48,
            decoration: BoxDecoration(
              // Use surfaceContainerHighest for a subtle, non-intrusive look
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
      ),
    );
  }
}

/// Widget wrapper che gestisce il posizionamento assoluto
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
        // Il contenuto principale della schermata
        child,
        
        // Il FAB draggabile sovrapposto
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

/// Provider per gestire le preferenze di posizione globalmente
class ActionButtonPosition {
  // 🔐 User-scoped key helper
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
    // Reset FAB positions for current user
    final userPrefix = userCacheKeys.userScopedKey('fab_position_');
    final keys = prefs.getKeys().where((k) => k.startsWith(userPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
