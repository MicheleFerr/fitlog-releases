import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Heatmap calendario stile GitHub contributions per visualizzare
/// l'intensità e frequenza degli allenamenti
class WorkoutHeatmapCalendar extends ConsumerStatefulWidget {
  
  const WorkoutHeatmapCalendar({
    super.key,
    required this.workoutData,
    this.onDayTap,
    this.startDate,
    this.weeksToShow = 52,
  });
  final Map<DateTime, WorkoutIntensity> workoutData;
  final Function(DateTime, WorkoutIntensity?)? onDayTap;
  final DateTime? startDate;
  final int weeksToShow;

  @override
  ConsumerState<WorkoutHeatmapCalendar> createState() => _WorkoutHeatmapCalendarState();
}

class _WorkoutHeatmapCalendarState extends ConsumerState<WorkoutHeatmapCalendar> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  DateTime? _selectedDate;
  
  // Scroll state
  final ScrollController _scrollController = ScrollController();
  bool _isZoomed = false;
  double _cellSize = 14;
  
  static const double _minCellSize = 10;
  static const double _maxCellSize = 24;
  
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
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endDate = widget.startDate ?? DateTime.now();
    final startDate = endDate.subtract(Duration(days: widget.weeksToShow * 7));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        _buildHeader(theme),
        const SizedBox(height: 16),
        
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
                    _isZoomed = _cellSize > 14;
                  });
                  HapticFeedback.lightImpact();
                },
                // ⚡ OPTIMIZATION: RepaintBoundary isolates heatmap repaints
                // The grid has many animated cells - isolate from parent
                child: RepaintBoundary(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return _buildHeatmapGrid(startDate, endDate, theme);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Legend
        const SizedBox(height: 16),
        _buildLegend(theme),
        
        // Selected day details
        if (_selectedDate != null)
          _buildSelectedDayDetails(theme),
      ],
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    final totalWorkouts = widget.workoutData.length;
    final currentStreak = _calculateCurrentStreak();
    final longestStreak = _calculateLongestStreak();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          icon: AppIcons.workout,
          value: totalWorkouts.toString(),
          label: 'Allenamenti',
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        _buildStatCard(
          icon: AppIcons.streak,
          value: currentStreak.toString(),
          label: 'Streak attuale',
          color: context.colors.secondary,
          theme: theme,
        ),
        _buildStatCard(
          icon: AppIcons.achievement,
          value: longestStreak.toString(),
          label: 'Record',
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
  
  Widget _buildHeatmapGrid(DateTime startDate, DateTime endDate, ThemeData theme) {
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
            
            final intensity = widget.workoutData[date];
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
                  widget.onDayTap?.call(date, intensity);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _cellSize,
                  height: _cellSize,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _getColorForIntensity(intensity, theme).withValues(
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
                  child: _isZoomed && intensity != null
                      ? Center(
                          child: Text(
                            intensity.workoutCount.toString(),
                            style: TextStyle(
                              fontSize: _cellSize / 2,
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
  
  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Meno',
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
          'Più',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildSelectedDayDetails(ThemeData theme) {
    final intensity = widget.workoutData[_selectedDate];
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getColorForIntensity(intensity, theme),
              borderRadius: BorderRadius.circular(8),
            ),
            child: intensity != null
                ? Center(
                    child: Text(
                      intensity.workoutCount.toString(),
                      style: TextStyle(
                        color: context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Icon(
                    AppIcons.close,
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
                if (intensity != null) ...[
                  Text(
                    '${intensity.workoutCount} allenament${intensity.workoutCount > 1 ? 'i' : 'o'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (intensity.totalMinutes > 0)
                    Text(
                      'Durata totale: ${intensity.totalMinutes} minuti',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                ] else
                  Text(
                    'Giorno di riposo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const SemanticIcon(
  icon: AppIcons.addCircleOutline,
  semanticLabel: 'Add circle outline',
),
            onPressed: () {
              // Navigate to add workout for this date
            },
          ),
        ],
      ),
    );
  }
  
  Color _getColorForIntensity(WorkoutIntensity? intensity, ThemeData theme) {
    if (intensity == null) {
      return theme.colorScheme.surfaceContainerHighest;
    }
    
    return _getColorForLevel(intensity.level, theme);
  }
  
  Color _getColorForLevel(WorkoutIntensityLevel level, ThemeData theme) {
    final successColor = context.colors.success;
    switch (level) {
      case WorkoutIntensityLevel.none:
        return theme.colorScheme.surfaceContainerHighest;
      case WorkoutIntensityLevel.light:
        return successColor.withValues(alpha: 0.3);
      case WorkoutIntensityLevel.moderate:
        return successColor.withValues(alpha: 0.5);
      case WorkoutIntensityLevel.intense:
        return successColor.withValues(alpha: 0.7);
      case WorkoutIntensityLevel.extreme:
        return successColor.withValues(alpha: 1.0);
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

class WorkoutIntensity {
  
  WorkoutIntensity({
    required this.workoutCount,
    this.totalMinutes = 0,
  }) : level = _calculateLevel(workoutCount);
  final int workoutCount;
  final int totalMinutes;
  final WorkoutIntensityLevel level;
  
  static WorkoutIntensityLevel _calculateLevel(int count) {
    if (count == 0) return WorkoutIntensityLevel.none;
    if (count == 1) return WorkoutIntensityLevel.light;
    if (count == 2) return WorkoutIntensityLevel.moderate;
    if (count == 3) return WorkoutIntensityLevel.intense;
    return WorkoutIntensityLevel.extreme;
  }
}

enum WorkoutIntensityLevel {
  none,
  light,
  moderate,
  intense,
  extreme,
}

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
