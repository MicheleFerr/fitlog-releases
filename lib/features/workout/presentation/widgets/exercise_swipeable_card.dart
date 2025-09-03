import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class ExerciseSwipeableCard extends ConsumerStatefulWidget {
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

  const ExerciseSwipeableCard({
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
  });

  @override
  ConsumerState<ExerciseSwipeableCard> createState() => _ExerciseSwipeableCardState();
}

class _ExerciseSwipeableCardState extends ConsumerState<ExerciseSwipeableCard> 
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Auto-hide swipe hint
  late AnimationController _hintController;
  late Animation<double> _hintOpacityAnimation;
  bool _showSwipeHint = false;
  
  double _dragExtent = 0;
  bool _isDragging = false;
  bool _isActionsRevealed = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.09, 0), // Ridotto a 9% per eliminare completamente lo spazio nero
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    // Setup hint animation
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _hintOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeIn,
    ));
    
    // Show hint for first item after delay
    if (widget.index == 0) {
      _showSwipeHint = true;
      _hintController.forward();
      
      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showSwipeHint) {
          _hintController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showSwipeHint = false;
              });
            }
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _hintController.dispose();
    super.dispose();
  }
  
  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    setState(() {});
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      
      // Limita il drag extent (ora positivo per swipe da sinistra a destra)
      if (_dragExtent < 0) {
        _dragExtent = 0;
      } else if (_dragExtent > 75) {
        _dragExtent = 75; // Ulteriormente ridotto per allinearsi con le nuove dimensioni
      }
      
      // Haptic feedback quando raggiunge i threshold
      if (_dragExtent > 40 && !_isActionsRevealed) { // Ridotto per attivazione più veloce
        HapticFeedback.lightImpact();
        _isActionsRevealed = true;
      } else if (_dragExtent < 40 && _isActionsRevealed) {
        HapticFeedback.selectionClick();
        _isActionsRevealed = false;
      }
    });
  }
  
  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    
    if (velocity > 300 || _dragExtent > 40) { // Allineati con i nuovi threshold
      // Swipe veloce a destra o drag sufficiente - mostra azioni
      _controller.forward();
      _isActionsRevealed = true;
      HapticFeedback.mediumImpact();
    } else if (velocity < -300 || _dragExtent < 20) {
      // Swipe veloce a sinistra o drag insufficiente - nascondi azioni
      _controller.reverse();
      _isActionsRevealed = false;
    } else {
      // Decidi in base alla posizione
      if (_dragExtent > 50) {
        _controller.forward();
        _isActionsRevealed = true;
      } else {
        _controller.reverse();
        _isActionsRevealed = false;
      }
    }
    
    setState(() {
      _dragExtent = 0;
    });
  }
  
  void _closeActions() {
    _controller.reverse();
    _isActionsRevealed = false;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: _isActionsRevealed ? _closeActions : widget.onTap,
      child: Stack(
        children: [
          // Background con azioni verticali
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 70, // Ridotto ulteriormente per allinearsi con lo swipe ridotto
              margin: const EdgeInsets.only(bottom: 8, right: 2), // Margine destro minimo
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Skip action - priorità alta, prima delle altre
                  if (widget.onSkip != null && !widget.exercise.isCompleted && !widget.exercise.isSkipped)
                    _buildVerticalAction(
                      icon: Icons.skip_next_rounded,
                      label: l10n.skip,
                      color: Colors.orange,
                      onTap: () {
                        _closeActions();
                        _showSkipDialog();
                      },
                    ),
                  
                  // Replace action
                  if (widget.onReplace != null)
                    _buildVerticalAction(
                      icon: Icons.swap_horiz_rounded,
                      label: l10n.replace,
                      color: theme.colorScheme.secondary,
                      onTap: () {
                        _closeActions();
                        widget.onReplace!();
                      },
                    ),
                  
                  // Edit action
                  if (widget.onEdit != null)
                    _buildVerticalAction(
                      icon: Icons.edit_rounded,
                      label: l10n.edit,
                      color: theme.colorScheme.primary,
                      onTap: () {
                        _closeActions();
                        widget.onEdit!();
                      },
                    ),
                  
                  // Delete action
                  if (widget.onDelete != null)
                    _buildVerticalAction(
                      icon: Icons.delete_rounded,
                      label: l10n.delete,
                      color: theme.colorScheme.error,
                      onTap: () {
                        _closeActions();
                        _showDeleteConfirmation();
                      },
                    ),
                ],
              ),
            ),
          ),
          
          // Foreground card
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double translateX = _isDragging 
                  ? _dragExtent 
                  : _slideAnimation.value.dx * MediaQuery.of(context).size.width;
              
              return Transform.translate(
                offset: Offset(translateX, 0),
                child: Transform.scale(
                  scale: _isDragging 
                      ? 1.0 - (_dragExtent.abs() / 1000)
                      : _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: widget.child,
              ),
            ),
          ),
          
          // Swipe hint overlay (solo per il primo esercizio)
          if (widget.index == 0 && !_isActionsRevealed && !_isDragging)
            Positioned(
              left: 8,
              top: 8,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_right_rounded,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.swipeForActions,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildVerticalAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExercise),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.confirmDeleteExercise(widget.exercise.name)),
            const SizedBox(height: 8),
            Text(
              l10n.thisActionCannotBeUndone,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
              Navigator.of(context).pop();
              widget.onDelete?.call();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.exerciseDeleted),
                  backgroundColor: theme.colorScheme.tertiary,
                  action: SnackBarAction(
                    label: l10n.undo,
                    textColor: theme.colorScheme.onTertiary,
                    onPressed: () {
                      // TODO: Implementare undo
                    },
                  ),
                ),
              );
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
  
  void _showSkipDialog() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.skip_next_rounded,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.skipExercise,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.exercise.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Skip reasons
            _buildSkipReason(
              icon: Icons.fitness_center,
              title: l10n.equipmentBusy,
              subtitle: l10n.equipmentBusyDesc,
              onTap: () => _skipExercise('equipment_busy'),
            ),
            
            _buildSkipReason(
              icon: Icons.battery_alert,
              title: l10n.tooTired,
              subtitle: l10n.tooTiredDesc,
              onTap: () => _skipExercise('too_tired'),
            ),
            
            _buildSkipReason(
              icon: Icons.schedule,
              title: l10n.noTime,
              subtitle: l10n.noTimeDesc,
              onTap: () => _skipExercise('no_time'),
            ),
            
            _buildSkipReason(
              icon: Icons.healing,
              title: l10n.minorDiscomfort,
              subtitle: l10n.minorDiscomfortDesc,
              onTap: () => _skipExercise('minor_discomfort'),
            ),
            
            _buildSkipReason(
              icon: Icons.more_horiz,
              title: l10n.otherReason,
              subtitle: l10n.otherReasonDesc,
              onTap: () => _skipExercise('other'),
            ),
            
            // Cancel button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkipReason({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.orange,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
  
  void _skipExercise(String reason) {
    Navigator.of(context).pop();
    widget.onSkip?.call(reason);
    
    // Show confirmation snackbar
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.skip_next_rounded,
              color: theme.colorScheme.onTertiary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.exerciseSkipped(widget.exercise.name)),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: l10n.undo,
          textColor: theme.colorScheme.onTertiary,
          onPressed: () {
            // TODO: Implementare undo skip
          },
        ),
      ),
    );
  }
}