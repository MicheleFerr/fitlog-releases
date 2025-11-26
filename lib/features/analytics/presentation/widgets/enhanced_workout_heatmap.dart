import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Enhanced Heatmap calendar with zoom controls and detailed exercise view
class EnhancedWorkoutHeatmap extends ConsumerStatefulWidget {
  
  const EnhancedWorkoutHeatmap({
    super.key,
    required this.workoutData,
    this.onDayTap,
    this.startDate,
    this.weeksToShow = 52,
  });
  final Map<DateTime, WorkoutDayData> workoutData;
  final Function(DateTime, WorkoutDayData?)? onDayTap;
  final DateTime? startDate;
  final int weeksToShow;

  @override
  ConsumerState<EnhancedWorkoutHeatmap> createState() => _EnhancedWorkoutHeatmapState();
}

class _EnhancedWorkoutHeatmapState extends ConsumerState<EnhancedWorkoutHeatmap> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  DateTime? _selectedDate;
  
  // Scroll state
  final ScrollController _scrollController = ScrollController();
  double _cellSize = 14;
  
  static const double _minCellSize = 10;
  static const double _maxCellSize = 30;
  static const double _defaultCellSize = 14;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
    
    // Scroll to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToToday() {
    if (_scrollController.hasClients) {
      final todayPosition = _cellSize * (widget.weeksToShow - 4);
      _scrollController.animateTo(
        todayPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _zoomIn() {
    setState(() {
      _cellSize = (_cellSize + 2).clamp(_minCellSize, _maxCellSize);
    });
    HapticFeedback.lightImpact();
  }

  void _zoomOut() {
    setState(() {
      _cellSize = (_cellSize - 2).clamp(_minCellSize, _maxCellSize);
    });
    HapticFeedback.lightImpact();
  }

  void _resetZoom() {
    setState(() {
      _cellSize = _defaultCellSize;
    });
    HapticFeedback.lightImpact();
    _scrollToToday();
  }

  void _showWorkoutDetails(DateTime date, WorkoutDayData? data) {
    if (data == null || data.exercises.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutDetailsSheet(
        date: date,
        workoutData: data,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endDate = widget.startDate ?? DateTime.now();
    final startDate = endDate.subtract(Duration(days: widget.weeksToShow * 7));
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        _buildHeader(theme, l10n),
        const SizedBox(height: 16),
        
        // Zoom controls
        _buildZoomControls(theme, l10n),
        const SizedBox(height: 12),
        
        // Month labels
        _buildMonthLabels(startDate, endDate, theme),
        const SizedBox(height: 8),
        
        // Heatmap grid with day labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day of week labels
            _buildDayLabels(theme),
            const SizedBox(width: 8),
            
            // Heatmap grid
            Expanded(
              child: GestureDetector(
                onScaleUpdate: (details) {
                  // Pinch to zoom
                  setState(() {
                    _cellSize = (_cellSize * details.scale)
                        .clamp(_minCellSize, _maxCellSize);
                  });
                  HapticFeedback.lightImpact();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildHeatmapGrid(startDate, endDate, theme, l10n);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Legend
        const SizedBox(height: 16),
        _buildLegend(theme, l10n),
        
        // Selected day details
        if (_selectedDate != null)
          _buildSelectedDayDetails(theme, l10n),
      ],
    );
  }

  Widget _buildZoomControls(ThemeData theme, AppLocalizations l10n) {
    final isZoomedIn = _cellSize >= _maxCellSize - 1;
    final isZoomedOut = _cellSize <= _minCellSize + 1;
    final isDefault = (_cellSize - _defaultCellSize).abs() < 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Zoom out button
        IconButton(
          onPressed: isZoomedOut ? null : _zoomOut,
          icon: const SemanticIcon(
  icon: AppIcons.removeCircleOutline,
  semanticLabel: 'Remove circle outline',
),
          tooltip: l10n.zoomOut,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(width: 8),
        
        // Reset zoom button
        TextButton.icon(
          onPressed: isDefault ? null : _resetZoom,
          icon: const SemanticIcon(
  icon: AppIcons.centerFocusStrong,
  semanticLabel: 'Center focus strong',
  size: AppIconSize.small,
),
          label: Text(l10n.resetZoom),
          style: TextButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(width: 8),
        
        // Zoom in button
        IconButton(
          onPressed: isZoomedIn ? null : _zoomIn,
          icon: const SemanticIcon(
  icon: AppIcons.addCircleOutline,
  semanticLabel: 'Add circle outline',
),
          tooltip: l10n.zoomIn,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    final totalWorkouts = widget.workoutData.length;
    final currentStreak = _calculateCurrentStreak();
    final longestStreak = _calculateLongestStreak();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          icon: AppIcons.workout,
          value: totalWorkouts.toString(),
          label: l10n.totalWorkouts,
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        _buildStatCard(
          icon: AppIcons.streak,
          value: currentStreak.toString(),
          label: l10n.currentStreak,
          color: context.colors.secondary,
          theme: theme,
        ),
        _buildStatCard(
          icon: AppIcons.achievement,
          value: longestStreak.toString(),
          label: l10n.longestStreak,
          color: context.colors.warning,
          theme: theme,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthLabels(DateTime startDate, DateTime endDate, ThemeData theme) {
    final months = <MonthLabel>[];
    DateTime current = startDate;
    int weekIndex = 0;
    
    while (current.isBefore(endDate)) {
      if (months.isEmpty || current.month != months.last.month) {
        months.add(MonthLabel(
          month: current.month,
          year: current.year,
          weekIndex: weekIndex,
        ));
      }
      current = current.add(const Duration(days: 7));
      weekIndex++;
    }
    
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          const SizedBox(width: 40), // Space for day labels
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: months.map((monthLabel) {
                  return Container(
                    width: _cellSize * 4.3, // Approximate month width
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      DateFormat('MMM').format(DateTime(monthLabel.year, monthLabel.month)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayLabels(ThemeData theme) {
    final days = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    
    return Column(
      children: days.asMap().entries.map((entry) {
        final isWeekend = entry.key >= 5;
        return Container(
          height: _cellSize + 2,
          width: 32,
          alignment: Alignment.centerRight,
          child: Text(
            entry.value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(
                alpha: isWeekend ? 0.4 : 0.6,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildHeatmapGrid(DateTime startDate, DateTime endDate, ThemeData theme, AppLocalizations l10n) {
    final weeks = <List<DateTime?>>[];
    DateTime current = startDate;
    
    // Adjust to start from Monday
    while (current.weekday != DateTime.monday) {
      current = current.subtract(const Duration(days: 1));
    }
    
    // Build weeks
    while (current.isBefore(endDate.add(const Duration(days: 7)))) {
      final week = <DateTime?>[];
      for (int i = 0; i < 7; i++) {
        if (current.isAfter(endDate)) {
          week.add(null);
        } else {
          week.add(DateTime(current.year, current.month, current.day));
        }
        current = current.add(const Duration(days: 1));
      }
      weeks.add(week);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.asMap().entries.map((weekEntry) {
        final weekIndex = weekEntry.key;
        final week = weekEntry.value;
        
        return Column(
          children: week.asMap().entries.map((dayEntry) {
            final dayIndex = dayEntry.key;
            final date = dayEntry.value;
            
            if (date == null) {
              return SizedBox(
                width: _cellSize,
                height: _cellSize,
              );
            }
            
            final workoutData = widget.workoutData[date];
            final isSelected = _selectedDate?.year == date.year &&
                _selectedDate?.month == date.month &&
                _selectedDate?.day == date.day;
            final isToday = _isToday(date);
            
            // Animation delay based on position
            final delay = (weekIndex * 7 + dayIndex) * 10;
            
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + delay),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  HapticFeedback.lightImpact();
                  _showWorkoutDetails(date, workoutData);
                  widget.onDayTap?.call(date, workoutData);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _cellSize,
                  height: _cellSize,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getColorForWorkoutData(workoutData, theme).withValues(
                      alpha: _animation.value,
                    ),
                    borderRadius: BorderRadius.circular(_cellSize / 4),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                              ? theme.colorScheme.outline
                              : Colors.transparent,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: _cellSize > 20 && workoutData != null
                      ? Center(
                          child: Text(
                            workoutData.exercises.length.toString(),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: _cellSize / 2.5,
                              color: context.colors.surface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
  
  Widget _buildLegend(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.less,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        ...WorkoutIntensityLevel.values.map((level) {
          return Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getColorForLevel(level, theme),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          l10n.more,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildSelectedDayDetails(ThemeData theme, AppLocalizations l10n) {
    final workoutData = widget.workoutData[_selectedDate];
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showWorkoutDetails(_selectedDate!, workoutData),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorForWorkoutData(workoutData, theme),
                borderRadius: BorderRadius.circular(8),
              ),
              child: workoutData != null
                  ? Center(
                      child: Icon(
                        AppIcons.workout,
                        color: context.colors.surface,
                        size: 20,
                      ),
                    )
                  : Icon(
                      AppIcons.hotel,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'it').format(_selectedDate!),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (workoutData != null) ...[
                    Text(
                      l10n.exerciseCount(workoutData.exercises.length),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (workoutData.totalMinutes > 0)
                      Text(
                        l10n.durationMinutes(workoutData.totalMinutes),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ] else
                    Text(
                      l10n.restDay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getColorForWorkoutData(WorkoutDayData? data, ThemeData theme) {
    if (data == null || data.exercises.isEmpty) {
      return theme.colorScheme.surfaceContainerHighest;
    }
    
    final exerciseCount = data.exercises.length;
    WorkoutIntensityLevel level;
    
    if (exerciseCount == 0) {
      level = WorkoutIntensityLevel.none;
    } else if (exerciseCount <= 3) {
      level = WorkoutIntensityLevel.light;
    } else if (exerciseCount <= 5) {
      level = WorkoutIntensityLevel.moderate;
    } else if (exerciseCount <= 8) {
      level = WorkoutIntensityLevel.intense;
    } else {
      level = WorkoutIntensityLevel.extreme;
    }
    
    return _getColorForLevel(level, theme);
  }
  
  Color _getColorForLevel(WorkoutIntensityLevel level, ThemeData theme) {
    // Use theme success color for intensity levels with opacity variations
    final successBase = context.colors.success;

    switch (level) {
      case WorkoutIntensityLevel.none:
        return theme.colorScheme.surfaceContainerHighest;
      case WorkoutIntensityLevel.light:
        return successBase.withValues(alpha: 0.3);
      case WorkoutIntensityLevel.moderate:
        return successBase.withValues(alpha: 0.5);
      case WorkoutIntensityLevel.intense:
        return successBase.withValues(alpha: 0.75);
      case WorkoutIntensityLevel.extreme:
        return successBase;
    }
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  int _calculateCurrentStreak() {
    final sortedDates = widget.workoutData.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if worked out today or yesterday
    bool hasRecentWorkout = false;
    for (final date in sortedDates.reversed) {
      if (_isSameDay(date, today) || _isSameDay(date, yesterday)) {
        hasRecentWorkout = true;
        break;
      }
    }
    
    if (!hasRecentWorkout) return 0;
    
    int streak = 0;
    DateTime expectedDate = today;
    
    for (final date in sortedDates.reversed) {
      if (_isSameDay(date, expectedDate) || 
          _isSameDay(date, expectedDate.subtract(const Duration(days: 1)))) {
        streak++;
        expectedDate = date.subtract(const Duration(days: 1));
      } else if (date.isBefore(expectedDate.subtract(const Duration(days: 1)))) {
        break;
      }
    }
    
    return streak;
  }
  
  int _calculateLongestStreak() {
    final sortedDates = widget.workoutData.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;
    
    int maxStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final daysDiff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (daysDiff == 1) {
        currentStreak++;
        maxStreak = math.max(maxStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }
    
    return maxStreak;
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Data model for a workout day
class WorkoutDayData {
  
  WorkoutDayData({
    required this.exercises,
    this.totalMinutes = 0,
    this.notes,
  });
  final List<ExerciseData> exercises;
  final int totalMinutes;
  final String? notes;
}

/// Data model for an exercise
class ExerciseData {
  
  ExerciseData({
    required this.name,
    required this.sets,
    this.notes,
  });
  final String name;
  final List<SetData> sets;
  final String? notes;
}

/// Data model for a set
class SetData {
  
  SetData({
    this.reps,
    this.weight,
    this.duration,
    this.effort,
    this.isWarmup = false,
    this.isDropSet = false,
    this.isRestPause = false,
  });
  final int? reps;
  final double? weight;
  final int? duration; // in seconds for timed exercises
  final int? effort; // 1-10 scale
  final bool isWarmup;
  final bool isDropSet;
  final bool isRestPause;
}

/// Intensity levels for the heatmap
enum WorkoutIntensityLevel {
  none,
  light,
  moderate,
  intense,
  extreme,
}

/// Month label for the calendar
class MonthLabel {
  
  const MonthLabel({
    required this.month,
    required this.year,
    required this.weekIndex,
  });
  final int month;
  final int year;
  final int weekIndex;
}

/// Bottom sheet for workout details
class WorkoutDetailsSheet extends StatefulWidget {
  
  const WorkoutDetailsSheet({
    super.key,
    required this.date,
    required this.workoutData,
  });
  final DateTime date;
  final WorkoutDayData workoutData;
  
  @override
  State<WorkoutDetailsSheet> createState() => _WorkoutDetailsSheetState();
}

class _WorkoutDetailsSheetState extends State<WorkoutDetailsSheet> {
  final Map<int, bool> _expandedExercises = {};
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.calendar,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, d MMMM yyyy', 'it').format(widget.date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      avatar: SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onPrimaryContainer,
),
                      label: Text(l10n.exerciseCount(widget.workoutData.exercises.length)),
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                    if (widget.workoutData.totalMinutes > 0) ...[
                      const SizedBox(width: 8),
                      Chip(
                        avatar: SemanticIcon(
  icon: AppIcons.timer,
  semanticLabel: 'Timer',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSecondaryContainer,
),
                        label: Text(l10n.durationMinutes(widget.workoutData.totalMinutes)),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Exercise list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.workoutData.exercises.length,
              itemBuilder: (context, index) {
                final exercise = widget.workoutData.exercises[index];
                final isExpanded = _expandedExercises[index] ?? false;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          l10n.setsCount(exercise.sets.length),
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedExercises[index] = !isExpanded;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _expandedExercises[index] = !isExpanded;
                          });
                        },
                      ),
                      
                      // Expanded set details
                      if (isExpanded)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Set headers
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      l10n.sets,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n.weightLabel,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n.repsLabel,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n.effortLabel,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Set rows
                              ...exercise.sets.asMap().entries.map((entry) {
                                final setIndex = entry.key;
                                final set = entry.value;
                                // Treat effort=0 as warmup (when RPE is 0)
                                final isWarmupSet = set.isWarmup || (set.effort != null && set.effort == 0);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isWarmupSet
                                                ? context.colors.warning.withValues(alpha: 0.2)
                                                : theme.colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isWarmupSet ? 'W' : '${setIndex + 1}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isWarmupSet ? context.colors.warning : null,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          set.weight != null
                                              ? '${set.weight} kg'
                                              : '-',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          set.reps != null
                                              ? '${set.reps}'
                                              : set.duration != null
                                                  ? '${set.duration}s'
                                                  : '-',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (set.effort != null)
                                              _buildEffortIndicator(set.effort!, theme),
                                            if (set.isDropSet)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4),
                                                child: SemanticIcon(
  icon: AppIcons.arrowDownward,
  semanticLabel: 'Arrow downward',
  size: AppIconSize.tiny,
  color: context.colors.secondary,
),
                                              ),
                                            if (set.isRestPause)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4),
                                                child: SemanticIcon(
  icon: AppIcons.pause,
  semanticLabel: 'Pause',
  size: AppIconSize.tiny,
  color: context.colors.primary,
),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (exercise.notes != null) ...[
                                const Divider(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SemanticIcon(
  icon: AppIcons.note,
  semanticLabel: 'Note',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurface.withValues(alpha: 0.6,
),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        exercise.notes!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEffortIndicator(int effort, ThemeData theme) {
    final color = effort <= 3
        ? context.colors.success
        : effort <= 6
            ? context.colors.warning
            : effort <= 8
                ? context.colors.secondary
                : context.colors.error;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$effort',
        style: context.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
