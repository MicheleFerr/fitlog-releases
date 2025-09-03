import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../providers/workout_provider.dart';
import '../providers/exercise_optimization_provider.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';

/// 🎯 TIER-1 PREMIUM GESTURES & ANIMATIONS
/// Advanced interaction patterns for professional fitness app

// ============================================================================
// SWIPEABLE EXERCISE CARD - Multi-directional swipe actions
// ============================================================================

class SwipeableExerciseCard extends ConsumerStatefulWidget {
  final String exerciseId;
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  
  const SwipeableExerciseCard({
    super.key,
    required this.exerciseId,
    required this.child,
    this.onDelete,
    this.onDuplicate,
    this.onComplete,
    this.onEdit,
  });
  
  @override
  ConsumerState<SwipeableExerciseCard> createState() => _SwipeableExerciseCardState();
}

class _SwipeableExerciseCardState extends ConsumerState<SwipeableExerciseCard>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  
  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  
  // Gesture tracking
  double _dragExtent = 0;
  SwipeDirection? _swipeDirection;
  bool _isAnimating = false;
  
  // Haptic feedback timing
  bool _hapticTriggered = false;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.fastOutSlowIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.5, 1.0),
    ));
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }
  
  void _handleDragStart(DragStartDetails details) {
    if (_isAnimating) return;
    
    _scaleController.forward();
    _hapticTriggered = false;
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      
      // Determine swipe direction
      if (_dragExtent.abs() > 20) {
        if (_dragExtent > 0) {
          _swipeDirection = SwipeDirection.right;
        } else {
          _swipeDirection = SwipeDirection.left;
        }
      }
      
      // Haptic feedback at threshold
      if (_dragExtent.abs() > 100 && !_hapticTriggered) {
        HapticFeedback.lightImpact();
        _hapticTriggered = true;
      }
    });
  }
  
  void _handleDragEnd(DragEndDetails details) {
    if (_isAnimating) return;
    
    final velocity = details.primaryVelocity ?? 0;
    final threshold = MediaQuery.of(context).size.width * 0.3;
    
    // Check if swipe passes threshold
    if (_dragExtent.abs() > threshold || velocity.abs() > 500) {
      _executeSwipeAction();
    } else {
      _resetPosition();
    }
  }
  
  void _executeSwipeAction() {
    setState(() => _isAnimating = true);
    
    switch (_swipeDirection) {
      case SwipeDirection.left:
        // Delete action
        HapticFeedback.mediumImpact();
        _slideController.forward().then((_) {
          widget.onDelete?.call();
          _resetAfterAction();
        });
        break;
        
      case SwipeDirection.right:
        // Complete/Duplicate action
        HapticFeedback.mediumImpact();
        _rotateController.forward().then((_) {
          widget.onComplete?.call();
          _resetAfterAction();
        });
        break;
        
      default:
        _resetPosition();
    }
  }
  
  void _resetPosition() {
    setState(() {
      _dragExtent = 0;
      _swipeDirection = null;
    });
    _scaleController.reverse();
  }
  
  void _resetAfterAction() {
    _slideController.reverse();
    _rotateController.reverse();
    _scaleController.reverse();
    setState(() {
      _dragExtent = 0;
      _swipeDirection = null;
      _isAnimating = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _slideController,
          _scaleController,
          _rotateController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Stack(
                    children: [
                      // Background actions
                      if (_swipeDirection != null)
                        _SwipeBackground(
                          direction: _swipeDirection!,
                          extent: _dragExtent.abs(),
                        ),
                      
                      // Main content
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum SwipeDirection { left, right }

class _SwipeBackground extends StatelessWidget {
  final SwipeDirection direction;
  final double extent;
  
  const _SwipeBackground({
    required this.direction,
    required this.extent,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = (extent / 200).clamp(0.0, 1.0);
    
    return Positioned.fill(
      child: Container(
        alignment: direction == SwipeDirection.left
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: direction == SwipeDirection.left
              ? theme.colorScheme.error.withOpacity(opacity)
              : theme.colorScheme.primary.withOpacity(opacity),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          direction == SwipeDirection.left
              ? Icons.delete_outline
              : Icons.check_circle_outline,
          color: theme.colorScheme.onError,
          size: 28,
        ),
      ),
    );
  }
}

// ============================================================================
// DRAGGABLE REORDERABLE LIST - Smooth drag and drop
// ============================================================================

class PremiumReorderableWorkout extends ConsumerStatefulWidget {
  final List<String> exerciseIds;
  final Function(int, int) onReorder;
  
  const PremiumReorderableWorkout({
    super.key,
    required this.exerciseIds,
    required this.onReorder,
  });
  
  @override
  ConsumerState<PremiumReorderableWorkout> createState() => _PremiumReorderableWorkoutState();
}

class _PremiumReorderableWorkoutState extends ConsumerState<PremiumReorderableWorkout>
    with TickerProviderStateMixin {
  
  String? _draggedItemId;
  int? _draggedIndex;
  int? _targetIndex;
  
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 4,
      end: 16,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _elevationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: widget.exerciseIds.length,
      onReorder: (oldIndex, newIndex) {
        HapticFeedback.mediumImpact();
        widget.onReorder(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double scale = 1 + (animValue * 0.05);
            final double elevation = 4 + (animValue * 12);
            
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(16),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final exerciseId = widget.exerciseIds[index];
        
        return _DraggableExerciseItem(
          key: ValueKey(exerciseId),
          exerciseId: exerciseId,
          index: index,
        );
      },
    );
  }
}

class _DraggableExerciseItem extends ConsumerWidget {
  final String exerciseId;
  final int index;
  
  const _DraggableExerciseItem({
    super.key,
    required this.exerciseId,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            child: Icon(
              Icons.drag_indicator,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          // Exercise content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Text('Exercise ${index + 1}'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK ACTION MENU - Context-aware floating actions
// ============================================================================

class QuickActionMenu extends ConsumerStatefulWidget {
  final String exerciseId;
  final Widget child;
  
  const QuickActionMenu({
    super.key,
    required this.exerciseId,
    required this.child,
  });
  
  @override
  ConsumerState<QuickActionMenu> createState() => _QuickActionMenuState();
}

class _QuickActionMenuState extends ConsumerState<QuickActionMenu>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isMenuOpen = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleMenu() {
    HapticFeedback.lightImpact();
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final batchOps = ref.read(batchOperationsProvider);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main content
        GestureDetector(
          onLongPress: _toggleMenu,
          child: widget.child,
        ),
        
        // Quick action buttons
        if (_isMenuOpen) ...[
          // Overlay to close menu
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // Action buttons
          Positioned(
            top: -50,
            right: 16,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuickActionButton(
                        icon: Icons.done_all,
                        color: theme.colorScheme.primary,
                        onTap: () {
                          batchOps.completeAllSets(widget.exerciseId);
                          _toggleMenu();
                        },
                        tooltip: 'Complete all',
                      ),
                      const SizedBox(width: 8),
                      _QuickActionButton(
                        icon: Icons.content_copy,
                        color: theme.colorScheme.secondary,
                        onTap: () {
                          batchOps.copySetsFromHistory(widget.exerciseId);
                          _toggleMenu();
                        },
                        tooltip: 'Copy from last',
                      ),
                      const SizedBox(width: 8),
                      _QuickActionButton(
                        icon: Icons.trending_up,
                        color: theme.colorScheme.tertiary,
                        onTap: () {
                          batchOps.applyProgressiveOverload(widget.exerciseId);
                          _toggleMenu();
                        },
                        tooltip: 'Progressive overload',
                      ),
                      const SizedBox(width: 8),
                      _QuickActionButton(
                        icon: Icons.clear_all,
                        color: theme.colorScheme.error,
                        onTap: () {
                          batchOps.clearAllSets(widget.exerciseId);
                          _toggleMenu();
                        },
                        tooltip: 'Clear all',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  
  const _QuickActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}