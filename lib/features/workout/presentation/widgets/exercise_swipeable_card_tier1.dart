import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Tier-1 implementation of swipeable exercise card with iOS-quality animations
/// and performance optimizations.
class ExerciseSwipeableCardTier1 extends ConsumerStatefulWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReplace;
  final Function(String reason)? onSkip;
  final Function(Exercise) onExerciseUpdate;
  final Function(ExerciseSet) onSetUpdate;
  final Widget child;
  final bool showSwipeHint;
  final bool showDeleteButton;

  const ExerciseSwipeableCardTier1({
    super.key,
    required this.exercise,
    required this.index,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onReplace,
    this.onSkip,
    required this.onExerciseUpdate,
    required this.onSetUpdate,
    required this.child,
    this.showSwipeHint = true,
    this.showDeleteButton = true,
  });

  @override
  ConsumerState<ExerciseSwipeableCardTier1> createState() => 
      _ExerciseSwipeableCardTier1State();
}

class _ExerciseSwipeableCardTier1State 
    extends ConsumerState<ExerciseSwipeableCardTier1>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _dragController;
  late AnimationController _hintController;
  late AnimationController _actionScaleController;
  
  // Animations
  late Animation<double> _dragAnimation;
  late Animation<double> _hintAnimation;
  late Animation<double> _actionScaleAnimation;
  
  
  // Drag state
  double _dragPosition = 0;
  bool _isDragging = false;
  bool _isActionsRevealed = false;
  bool _hasShownHint = false;
  
  // Constants for tier-1 experience
  static const double _maxDragDistance = 100.0;
  static const double _actionRevealThreshold = 50.0;
  static const double _velocityThreshold = 500.0;
  static const double _elasticLimit = 120.0;
  static const Duration _animationDuration = Duration(milliseconds: 450);
  static const Duration _closeAnimationDuration = Duration(milliseconds: 600);
  static const Curve _animationCurve = Curves.easeOutCubic;
  static const Curve _closeAnimationCurve = Curves.easeInOutCubic;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startHintAnimationIfNeeded();
  }
  
  void _initializeAnimations() {
    // Main drag animation controller
    _dragController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    
    _dragAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: _animationCurve,
    ));
    
    // Hint animation controller
    _hintController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _hintAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeInOut,
    ));
    
    // Action scale animation controller
    _actionScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _actionScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionScaleController,
      curve: Curves.elasticOut,
    ));
    
    // Spring animation setup
  }
  
  void _startHintAnimationIfNeeded() {
    if (widget.showSwipeHint && widget.index == 0 && !_hasShownHint) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _hintController.forward().then((_) {
            if (mounted) {
              _hintController.reverse();
              _hasShownHint = true;
            }
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _dragController.dispose();
    _hintController.dispose();
    _actionScaleController.dispose();
    super.dispose();
  }
  
  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragController.stop();
    _hintController.stop();
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    
    setState(() {
      _dragPosition += delta;
      
      // Apply elastic resistance beyond limits
      if (_dragPosition < 0) {
        _dragPosition = 0;
      } else if (_dragPosition > _maxDragDistance) {
        // Elastic resistance formula for iOS-like feel
        final overflow = _dragPosition - _maxDragDistance;
        final resistance = 1.0 - (overflow / _elasticLimit).clamp(0.0, 0.8);
        _dragPosition = _maxDragDistance + (overflow * resistance);
      }
      
      // Haptic feedback at thresholds
      final wasRevealed = _isActionsRevealed;
      _isActionsRevealed = _dragPosition > _actionRevealThreshold;
      
      if (_isActionsRevealed != wasRevealed) {
        if (_isActionsRevealed) {
          HapticFeedback.lightImpact();
          _actionScaleController.forward();
        } else {
          HapticFeedback.selectionClick();
          _actionScaleController.reverse();
        }
      }
    });
  }
  
  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    
    // Determine target position based on velocity and position
    double targetPosition = 0;
    
    if (velocity > _velocityThreshold || 
        (_dragPosition > _actionRevealThreshold && velocity >= 0)) {
      targetPosition = _maxDragDistance;
      _isActionsRevealed = true;
      HapticFeedback.mediumImpact();
    } else {
      targetPosition = 0;
      _isActionsRevealed = false;
    }
    
    // Spring animation setup completed
    
    _animateToPosition(targetPosition);
  }
  
  void _animateToPosition(double position) {
    _dragAnimation = Tween<double>(
      begin: _dragPosition,
      end: position,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOutCubic,
    ));
    
    _dragController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragPosition = position;
        });
      }
    });
  }
  
  void _closeActions() {
    if (!_isActionsRevealed) return;
    
    HapticFeedback.lightImpact();
    _isActionsRevealed = false;
    
    // Use slower animation for closing
    _dragAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: _closeAnimationCurve,
    ));
    
    _dragController.duration = _closeAnimationDuration;
    _dragController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragPosition = 0;
        });
        // Reset duration for normal animations
        _dragController.duration = _animationDuration;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Semantics(
      label: widget.exercise.name,
      hint: _isActionsRevealed ? 'Actions available' : 'Swipe for actions',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Actions background layer with fade animation
          AnimatedOpacity(
            opacity: _isActionsRevealed ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _buildActionsLayer(theme, l10n),
          ),
          
          // Main card layer with transform
          AnimatedBuilder(
            animation: _dragController,
            builder: (context, child) {
              final animatedPosition = _dragAnimation.value;
              return Transform.translate(
                offset: Offset(_isDragging ? _dragPosition : animatedPosition, 0),
                child: GestureDetector(
                  onTap: _isActionsRevealed ? () {
                    // Close swipe when tapping on the card itself
                    _closeActions();
                  } : null,
                  child: child,
                ),
              );
            },
            child: _buildMainCard(theme),
          ),
          
          // Swipe hint overlay
          if (widget.showSwipeHint && 
              widget.index == 0 && 
              !_isActionsRevealed && 
              !_isDragging)
            _buildSwipeHint(theme, l10n),
        ],
      ),
    );
  }
  
  Widget _buildActionsLayer(ThemeData theme, AppLocalizations l10n) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _actionScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _actionScaleAnimation.value,
            alignment: Alignment.centerLeft,
            child: Container(
              width: _maxDragDistance,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                  right: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                  right: Radius.circular(8),
                ),
                child: OverflowBox(
                  maxWidth: _maxDragDistance,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: _buildActionButtons(theme, l10n),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  List<Widget> _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    final actions = <Widget>[];
    
    // Skip action (highest priority)
    if (widget.onSkip != null && 
        !widget.exercise.isCompleted && 
        !widget.exercise.isSkipped) {
      actions.add(_buildActionButton(
        icon: Icons.skip_next_rounded,
        label: l10n.skip,
        color: Colors.orange,
        onTap: () {
          _closeActions();
          _showSkipDialog();
        },
      ));
    }
    
    // Replace action
    if (widget.onReplace != null) {
      actions.add(_buildActionButton(
        icon: Icons.swap_horiz_rounded,
        label: l10n.replace,
        color: theme.colorScheme.secondary,
        onTap: () {
          _closeActions();
          widget.onReplace!();
        },
      ));
    }
    
    // Edit action
    if (widget.onEdit != null) {
      actions.add(_buildActionButton(
        icon: Icons.edit_rounded,
        label: l10n.edit,
        color: theme.colorScheme.primary,
        onTap: () {
          _closeActions();
          widget.onEdit!();
        },
      ));
    }
    
    // Delete action
    if (widget.onDelete != null) {
      actions.add(_buildActionButton(
        icon: Icons.delete_rounded,
        label: l10n.delete,
        color: theme.colorScheme.error,
        onTap: () {
          _closeActions();
          _showDeleteConfirmation();
        },
      ));
    }
    
    return actions;
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainCard(ThemeData theme) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: _isActionsRevealed ? _closeActions : widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            if (_isDragging)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: -5,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: widget.child,
        ),
      ),
    );
  }
  
  Widget _buildSwipeHint(ThemeData theme, AppLocalizations l10n) {
    return Positioned(
      left: 12,
      top: 12,
      child: AnimatedBuilder(
        animation: _hintAnimation,
        builder: (context, child) {
          return AnimatedOpacity(
            opacity: _hasShownHint ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Transform.translate(
              offset: Offset(_hintAnimation.value * 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe_right_alt_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.swipeForActions,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showDeleteConfirmation() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.deleteExercise,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.confirmDeleteExercise(widget.exercise.name),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.thisActionCannotBeUndone,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop();
              widget.onDelete?.call();
              _showDeletedSnackbar();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
  
  void _showDeletedSnackbar() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.onTertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(l10n.exerciseDeleted),
          ],
        ),
        backgroundColor: theme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
  
  void _showSkipDialog() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.1),
                          Colors.orange.withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.skip_next_rounded,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.skipExercise,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.exercise.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Skip reasons with better styling
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSkipReasonTile(
                    icon: Icons.fitness_center,
                    title: l10n.equipmentBusy,
                    subtitle: l10n.equipmentBusyDesc,
                    onTap: () => _skipExercise('equipment_busy'),
                  ),
                  _buildSkipReasonTile(
                    icon: Icons.battery_alert,
                    title: l10n.tooTired,
                    subtitle: l10n.tooTiredDesc,
                    onTap: () => _skipExercise('too_tired'),
                  ),
                  _buildSkipReasonTile(
                    icon: Icons.schedule,
                    title: l10n.noTime,
                    subtitle: l10n.noTimeDesc,
                    onTap: () => _skipExercise('no_time'),
                  ),
                  _buildSkipReasonTile(
                    icon: Icons.healing,
                    title: l10n.minorDiscomfort,
                    subtitle: l10n.minorDiscomfortDesc,
                    onTap: () => _skipExercise('minor_discomfort'),
                  ),
                  _buildSkipReasonTile(
                    icon: Icons.more_horiz,
                    title: l10n.otherReason,
                    subtitle: l10n.otherReasonDesc,
                    onTap: () => _skipExercise('other'),
                  ),
                ],
              ),
            ),
            
            // Cancel button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkipReasonTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _skipExercise(String reason) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    widget.onSkip?.call(reason);
    
    final l10n = AppLocalizations.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.exercise.name} skipped',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}