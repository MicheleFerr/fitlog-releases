import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_optimization_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/screen_wakelock_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// 🎯 TIER-1 WORKOUT ACTION BAR
/// Undo/Redo system with batch operations

class WorkoutActionBar extends ConsumerStatefulWidget {
  const WorkoutActionBar({super.key});
  
  @override
  ConsumerState<WorkoutActionBar> createState() => _WorkoutActionBarState();
}

class _WorkoutActionBarState extends ConsumerState<WorkoutActionBar>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    // Auto-show when actions available
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final undoRedoState = ref.watch(undoRedoProvider);
    final offlineState = ref.watch(offlineSyncProvider);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main action bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Undo button
                        _ActionButton(
                          icon: AppIcons.undo,
                          label: l10n.undo,
                          enabled: undoRedoState.canUndo,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(undoRedoProvider.notifier).undo();
                            _showActionToast(context, 'Action undone');
                          },
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Redo button
                        _ActionButton(
                          icon: AppIcons.redo,
                          label: l10n.redo,
                          enabled: undoRedoState.canRedo,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(undoRedoProvider.notifier).redo();
                            _showActionToast(context, 'Action redone');
                          },
                        ),
                        
                        const Spacer(),
                        
                        // Offline indicator
                        if (!offlineState.isOnline)
                          _OfflineIndicator(
                            pendingCount: offlineState.pendingActions.length,
                          ),
                        
                        // Screen always on toggle
                        _ScreenAlwaysOnToggle(),

                        const SizedBox(width: 8),

                        // Batch operations menu
                        _BatchOperationsMenu(),

                        // Expand/Collapse button
                        IconButton(
                          icon: AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              AppIcons.expandMore,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onPressed: () {
                            setState(() => _isExpanded = !_isExpanded);
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Expanded section with history
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _isExpanded
                      ? _ActionHistory(actions: undoRedoState.undoStack)
                      : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showActionToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: _ActionToast(
            message: message,
            onDismiss: () => overlayEntry.remove(),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

class _ActionButton extends StatelessWidget {
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: enabled
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: enabled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: enabled
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineIndicator extends StatefulWidget {
  
  const _OfflineIndicator({required this.pendingCount});
  final int pendingCount;
  
  @override
  State<_OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<_OfflineIndicator>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(
              0.5 + (_pulseController.value * 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
  icon: AppIcons.cloudOff,
  semanticLabel: 'Cloud off',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onErrorContainer,
),
              const SizedBox(width: 4),
              Text(
                '${widget.pendingCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BatchOperationsMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return PopupMenuButton<BatchOperation>(
      icon: Icon(
        AppIcons.flashOn,
        color: theme.colorScheme.primary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (operation) {
        HapticFeedback.lightImpact();
        _executeBatchOperation(context, ref, operation);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: BatchOperation.completeAll,
          child: Row(
            children: [
              const SemanticIcon(
  icon: AppIcons.doneAll,
  semanticLabel: 'Done all',
  size: AppIconSize.small,
),
              const SizedBox(width: 12),
              Text(l10n.completeAllSets),
            ],
          ),
        ),
        PopupMenuItem(
          value: BatchOperation.clearAll,
          child: Row(
            children: [
              const SemanticIcon(
  icon: AppIcons.clearAll,
  semanticLabel: 'Clear all',
  size: AppIconSize.small,
),
              const SizedBox(width: 12),
              Text(l10n.clearAllSets),
            ],
          ),
        ),
        PopupMenuItem(
          value: BatchOperation.copyFromLast,
          child: Row(
            children: [
              const SemanticIcon(
  icon: AppIcons.copy,
  semanticLabel: 'Copy',
  size: AppIconSize.small,
),
              const SizedBox(width: 12),
              Text(l10n.copyFromLastWorkout),
            ],
          ),
        ),
        PopupMenuItem(
          value: BatchOperation.progressiveOverload,
          child: Row(
            children: [
              const SemanticIcon(
  icon: AppIcons.trendUp,
  semanticLabel: 'Trend up',
  size: AppIconSize.small,
),
              const SizedBox(width: 12),
              Text(l10n.applyProgressiveOverload),
            ],
          ),
        ),
      ],
    );
  }
  
  void _executeBatchOperation(BuildContext context, WidgetRef ref, BatchOperation operation) {
    // Show confirmation dialog for destructive operations
    if (operation == BatchOperation.clearAll) {
      showDialog(
        context: context,
        builder: (context) => _ConfirmationDialog(
          title: 'Clear all sets?',
          message: 'This will reset all completed sets. You can undo this action.',
          onConfirm: () {
            // Execute operation
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      // Execute operation directly
    }
  }
}

enum BatchOperation {
  completeAll,
  clearAll,
  copyFromLast,
  progressiveOverload,
}

class _ActionHistory extends StatelessWidget {
  
  const _ActionHistory({required this.actions});
  final List<WorkoutCommand> actions;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentActions = actions.reversed.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Actions',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...recentActions.map((action) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SemanticIcon(
  icon: AppIcons.history,
  semanticLabel: 'History',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant,
),
                const SizedBox(width: 8),
                Text(
                  action.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(action.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}

class _ActionToast extends StatefulWidget {
  
  const _ActionToast({
    required this.message,
    required this.onDismiss,
  });
  final String message;
  final VoidCallback onDismiss;
  
  @override
  State<_ActionToast> createState() => _ActionToastState();
}

class _ActionToastState extends State<_ActionToast>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 1),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 0),
        weight: 10,
      ),
    ]).animate(_controller);
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
          .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 1),
        weight: 80,
      ),
    ]).animate(_controller);
    
    _controller.forward().then((_) {
      widget.onDismiss();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.onSurface.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.complete,
                    color: theme.colorScheme.onInverseSurface,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  
  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });
  final String title;
  final String message;
  final VoidCallback onConfirm;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}

class _ScreenAlwaysOnToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final wakelockState = ref.watch(screenWakelockProvider);

    return Tooltip(
      message: wakelockState.isEnabled
        ? l10n.keepScreenOn
        : l10n.keepScreenOn,
      child: Material(
        color: wakelockState.isEnabled
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(screenWakelockProvider.notifier).toggleEnabled();

            // Show feedback toast
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  wakelockState.isEnabled
                    ? 'Schermo sempre acceso disattivato'
                    : 'Schermo sempre acceso attivato',
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                wakelockState.isEnabled
                  ? AppIcons.mobileScreenShare
                  : AppIcons.mobileOff,
                key: ValueKey(wakelockState.isEnabled),
                size: 20,
                color: wakelockState.isEnabled
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
