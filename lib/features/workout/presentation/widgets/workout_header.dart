import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/header_rest_timer.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class WorkoutHeader extends StatefulWidget {
  const WorkoutHeader({super.key, required this.workout});
  final Workout workout;

  @override
  State<WorkoutHeader> createState() => _WorkoutHeaderState();
}

class _WorkoutHeaderState extends State<WorkoutHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _minimizeTimer;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start minimize timer
    _startMinimizeTimer();
  }

  @override
  void dispose() {
    _minimizeTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startMinimizeTimer() {
    _minimizeTimer?.cancel();
    _minimizeTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_isMinimized) {
        _minimize();
      }
    });
  }

  void _minimize() {
    setState(() {
      _isMinimized = true;
    });
    _animationController.forward();
  }

  void _expand() {
    setState(() {
      _isMinimized = false;
    });
    _animationController.reverse();
    _startMinimizeTimer(); // Restart timer after expanding
  }

  void _toggleMinimized() {
    if (_isMinimized) {
      _expand();
    } else {
      _minimize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _toggleMinimized,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(_isMinimized ? 12 : 20),
          child: _isMinimized ? _buildMinimizedView() : _buildExpandedView(),
        ),
      ),
    );
  }

  Widget _buildExpandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Workout name and status
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workout.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(context),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Rest Timer integrato nell'header
            const HeaderRestTimer(compact: false),
            const SizedBox(width: 12),
            if (widget.workout.duration != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDuration(widget.workout.duration!),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Progress and stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Exercises',
                '${widget.workout.completedExercises}/${widget.workout.exercises.length}',
                AppIcons.workout,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Sets',
                '${widget.workout.completedSets}/${widget.workout.totalSets}',
                AppIcons.formatListNumbered,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Progress',
                '${(widget.workout.progressPercentage * 100).round()}%',
                AppIcons.trendUp,
                Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Workout Progress',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message:
                      '💡 Set Gestures:\n• Tap = Complete\n• Double-tap = Quick Edit\n• Long press = Full Edit',
                  child: SemanticIcon(
                    icon: AppIcons.help,
                    semanticLabel: 'Help',
                    size: AppIconSize.tiny,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.workout.progressPercentage,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.workout.progressPercentage < 0.3
                    ? Theme.of(context).colorScheme.error
                    : widget.workout.progressPercentage < 0.7
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.tertiary,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimizedView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Compact stats in one row
          Row(
            children: [
              // Exercises stat
              _buildCompactStat(
                'Exercises',
                '${widget.workout.completedExercises}/${widget.workout.exercises.length}',
                AppIcons.workout,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              // Sets stat
              _buildCompactStat(
                'Sets',
                '${widget.workout.completedSets}/${widget.workout.totalSets}',
                AppIcons.formatListNumbered,
                Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              // Volume stat
              _buildCompactStat(
                'Volume',
                '${_calculateTotalVolume().toInt()}kg',
                AppIcons.barChart,
                Theme.of(context).colorScheme.tertiary,
              ),
              const Spacer(),
              // Rest Timer compatto
              const HeaderRestTimer(compact: true),
              const SizedBox(width: 12),
              // Expand indicator
              SemanticIcon(
                icon: AppIcons.expandMore,
                semanticLabel: 'Expand',
                size: AppIconSize.small,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar (maintained)
          LinearProgressIndicator(
            value: widget.workout.progressPercentage,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.workout.progressPercentage < 0.3
                  ? Theme.of(context).colorScheme.error
                  : widget.workout.progressPercentage < 0.7
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiary,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (widget.workout.status) {
      case WorkoutStatus.planned:
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).colorScheme.onSurface;
        icon = AppIcons.schedule;
        text = 'Planned';
        break;
      case WorkoutStatus.inProgress:
        backgroundColor = Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.primary;
        icon = AppIcons.play;
        text = 'In Progress';
        break;
      case WorkoutStatus.completed:
        backgroundColor = Theme.of(
          context,
        ).colorScheme.tertiary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.tertiary;
        icon = AppIcons.complete;
        text = 'Completed';
        break;
      case WorkoutStatus.paused:
        backgroundColor = Theme.of(
          context,
        ).colorScheme.secondary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.secondary;
        icon = AppIcons.pause;
        text = 'Paused';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        // Rimosso border per eliminare effetto rumore visivo
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  double _calculateTotalVolume() {
    double totalVolume = 0.0;

    for (final exercise in widget.workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted && set.weight != null && set.reps != null) {
          totalVolume += set.weight! * set.reps!;
        }
      }
    }

    return totalVolume;
  }
}
