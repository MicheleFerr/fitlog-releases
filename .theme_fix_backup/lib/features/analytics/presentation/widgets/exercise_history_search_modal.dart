import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class ExerciseHistorySearchModal extends StatefulWidget {

  const ExerciseHistorySearchModal({
    super.key,
    required this.activities,
    this.onExerciseSelected,
  });
  final List<ExerciseActivity> activities;
  final Function(String exerciseName)? onExerciseSelected;

  static Future<void> show(
    BuildContext context,
    List<ExerciseActivity> activities, {
    Function(String exerciseName)? onExerciseSelected,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseHistorySearchModal(
        activities: activities,
        onExerciseSelected: onExerciseSelected,
      ),
    );
  }

  @override
  State<ExerciseHistorySearchModal> createState() => _ExerciseHistorySearchModalState();
}

class _ExerciseHistorySearchModalState extends State<ExerciseHistorySearchModal> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedExercise;
  
  // Cached data
  late List<String> _allExercises;
  late Map<String, List<ExerciseActivity>> _exerciseActivities;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  void _initializeData() {
    // Group activities by exercise name
    _exerciseActivities = {};
    for (final activity in widget.activities) {
      if (!_exerciseActivities.containsKey(activity.exerciseName)) {
        _exerciseActivities[activity.exerciseName] = [];
      }
      _exerciseActivities[activity.exerciseName]!.add(activity);
    }
    
    // Sort activities by date for each exercise
    _exerciseActivities.forEach((key, value) {
      value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
    
    // Get unique exercise names
    _allExercises = _exerciseActivities.keys.toList()..sort();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<String> get _filteredExercises {
    if (_searchQuery.isEmpty) return _allExercises;
    
    final query = _searchQuery.toLowerCase();
    return _allExercises.where((exercise) => 
      exercise.toLowerCase().contains(query)
    ).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header with search
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.search,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Storico Esercizi',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        if (_selectedExercise != null && 
                            !_filteredExercises.contains(_selectedExercise)) {
                          _selectedExercise = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cerca un esercizio...',
                      prefixIcon: const SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const SemanticIcon(
  icon: AppIcons.clear,
  semanticLabel: 'Clear',
),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainer,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _selectedExercise != null
                  ? _buildExerciseDetails(theme, scrollController)
                  : _buildExerciseList(theme, scrollController),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExerciseList(ThemeData theme, ScrollController scrollController) {
    final exercises = _filteredExercises;
    
    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
  icon: AppIcons.searchOff,
  semanticLabel: 'Search off',
  size: AppIconSize.medium,
  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5,
),
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun esercizio trovato',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exerciseName = exercises[index];
        final activities = _exerciseActivities[exerciseName]!;
        final lastActivity = activities.first;
        final totalVolume = activities.fold(0.0, (sum, activity) {
          return sum + activity.sets.fold(0.0, (setSum, set) {
            final weight = double.tryParse(set.weight) ?? 0.0;
            final reps = int.tryParse(set.reps) ?? 0;
            return setSum + (weight * reps);
          });
        });
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedExercise = exerciseName;
              });
              if (widget.onExerciseSelected != null) {
                widget.onExerciseSelected!(exerciseName);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getExerciseIcon(exerciseName),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SemanticIcon(
  icon: AppIcons.calendar,
  semanticLabel: 'Calendar',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant,
),
                            const SizedBox(width: 4),
                            Text(
                              '${activities.length} sessioni',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SemanticIcon(
  icon: AppIcons.clock,
  semanticLabel: 'Clock',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant,
),
                            const SizedBox(width: 4),
                            Text(
                              _getRelativeTime(lastActivity.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Volume totale: ${(totalVolume / 1000).toStringAsFixed(1)}k kg',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    AppIcons.chevronRight,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildExerciseDetails(ThemeData theme, ScrollController scrollController) {
    final activities = _exerciseActivities[_selectedExercise]!;
    
    return Column(
      children: [
        // Back button and title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedExercise = null;
                  });
                },
                icon: const SemanticIcon(
  icon: AppIcons.back,
  semanticLabel: 'Back',
),
              ),
              Expanded(
                child: Text(
                  _selectedExercise!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Stats summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildStatsSummary(theme, activities),
        ),
        const SizedBox(height: 16),
        
        // Progress chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildProgressChart(theme, activities),
        ),
        const SizedBox(height: 16),
        
        // History list
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityCard(theme, activity, index == 0);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsSummary(ThemeData theme, List<ExerciseActivity> activities) {
    // Calculate stats
    double maxWeight = 0;
    int totalSets = 0;
    int totalReps = 0;
    double totalVolume = 0;
    
    for (final activity in activities) {
      totalSets += activity.sets.length;
      for (final set in activity.sets) {
        final weight = double.tryParse(set.weight) ?? 0.0;
        final reps = int.tryParse(set.reps) ?? 0;
        maxWeight = weight > maxWeight ? weight : maxWeight;
        totalReps += reps;
        totalVolume += weight * reps;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Max Weight',
            '${maxWeight.toStringAsFixed(1)} kg',
            AppIcons.workout,
            theme.colorScheme.primary,
            theme,
          ),
          _buildStatItem(
            'Total Sets',
            totalSets.toString(),
            AppIcons.formatListNumbered,
            context.colors.secondary,
            theme,
          ),
          _buildStatItem(
            'Total Reps',
            totalReps.toString(),
            AppIcons.repeat,
            context.colors.success,
            theme,
          ),
          _buildStatItem(
            'Total Volume',
            '${(totalVolume / 1000).toStringAsFixed(1)}k',
            AppIcons.barChart,
            context.colors.primary,
            theme,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressChart(ThemeData theme, List<ExerciseActivity> activities) {
    // Prepare data for chart
    final List<FlSpot> volumeSpots = [];
    final List<FlSpot> maxWeightSpots = [];
    
    // Group by date and calculate daily metrics
    final Map<DateTime, List<ExerciseActivity>> dailyActivities = {};
    for (final activity in activities) {
      final date = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );
      if (!dailyActivities.containsKey(date)) {
        dailyActivities[date] = [];
      }
      dailyActivities[date]!.add(activity);
    }
    
    // Sort dates
    final dates = dailyActivities.keys.toList()..sort();
    
    // Calculate spots
    for (int i = 0; i < dates.length && i < 30; i++) {
      final date = dates[dates.length - 1 - i];
      final dayActivities = dailyActivities[date]!;
      
      double dayVolume = 0;
      double dayMaxWeight = 0;
      
      for (final activity in dayActivities) {
        for (final set in activity.sets) {
          final weight = double.tryParse(set.weight) ?? 0.0;
          final reps = int.tryParse(set.reps) ?? 0;
          dayVolume += weight * reps;
          dayMaxWeight = weight > dayMaxWeight ? weight : dayMaxWeight;
        }
      }
      
      volumeSpots.add(FlSpot(i.toDouble(), dayVolume));
      maxWeightSpots.add(FlSpot(i.toDouble(), dayMaxWeight));
    }
    
    if (volumeSpots.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: volumeSpots.reversed.toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityCard(ThemeData theme, ExerciseActivity activity, bool isLatest) {
    final totalVolume = activity.sets.fold(0.0, (sum, set) {
      final weight = double.tryParse(set.weight) ?? 0.0;
      final reps = int.tryParse(set.reps) ?? 0;
      return sum + (weight * reps);
    });
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isLatest 
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLatest) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'LATEST',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    DateFormat('EEEE, d MMMM yyyy', 'it').format(activity.createdAt),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _getRelativeTime(activity.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Sets details
            ...activity.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              final weight = double.tryParse(set.weight) ?? 0.0;
              final reps = int.tryParse(set.reps) ?? 0;
              final volume = weight * reps;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant,
),
                          const SizedBox(width: 4),
                          Text(
                            '${weight.toStringAsFixed(1)} kg',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 12),
                          SemanticIcon(
  icon: AppIcons.repeat,
  semanticLabel: 'Repeat',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant,
),
                          const SizedBox(width: 4),
                          Text(
                            '$reps reps',
                            style: theme.textTheme.bodyMedium,
                          ),
                          ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getEffortColor(set.effort).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'RPE ${set.effort}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getEffortColor(set.effort),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        ],
                      ),
                    ),
                    Text(
                      '${volume.toStringAsFixed(0)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${activity.sets.length} sets',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Volume: ${(totalVolume / 1000).toStringAsFixed(1)}k kg',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getExerciseIcon(String exerciseName) {
    final name = exerciseName.toLowerCase();
    if (name.contains('squat') || name.contains('leg')) return AppIcons.airlineSeatReclineNormal;
    if (name.contains('bench') || name.contains('chest')) return AppIcons.airlineSeatFlat;
    if (name.contains('deadlift') || name.contains('stacco')) return AppIcons.fitnessCenter;
    if (name.contains('curl') || name.contains('bicep')) return AppIcons.sportsGymnastics;
    if (name.contains('shoulder') || name.contains('spalle')) return AppIcons.accessibilityNew;
    if (name.contains('back') || name.contains('dorso')) return AppIcons.rowing;
    return AppIcons.fitnessCenter;
  }
  
  Color _getEffortColor(int effort) {
    if (effort >= 9) return context.colors.error;
    if (effort >= 7) return context.colors.secondary;
    if (effort >= 5) return context.colors.warning;
    return context.colors.success;
  }
  
  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return '$weeks ${weeks == 1 ? "settimana" : "settimane"} fa';
    } else {
      final months = (difference.inDays / 30).round();
      return '$months ${months == 1 ? "mese" : "mesi"} fa';
    }
  }
}
