import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/weekly_dashboard_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/enhanced_workout_heatmap.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/premium_feature_overlay.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AnalyticsInsightsTab extends ConsumerWidget {
  final List<ExerciseActivity> activities;
  final bool isPremium;
  
  const AnalyticsInsightsTab({
    super.key,
    required this.activities,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    if (!isPremium) {
      return _buildPremiumLockScreen(context, theme);
    }
    
    // Show admin badge if user is admin
    final isAdminMode = isPremium && activities.isNotEmpty;
    
    return Stack(
      children: [
        ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Weekly Dashboard
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dashboard,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Dashboard',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WeeklyDashboardWidget(
                  activities: activities,
                  isPremium: isPremium,
                  onDataSync: (data) {
                    HapticFeedback.mediumImpact();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Muscle Balance Analysis
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.balance,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Muscle Group Balance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Tier1MuscleBalanceChart(
                  muscleData: _generateMuscleData(activities),
                  onTargetChanged: (muscle, newTarget) {
                    HapticFeedback.lightImpact();
                  },
                  onMuscleGroupTap: (muscle) {
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Workout Consistency Heatmap
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_view_month,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Consistency Heatmap',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EnhancedWorkoutHeatmap(
                  workoutData: _generateWorkoutData(activities),
                  weeksToShow: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Training Recommendations
        _buildTrainingRecommendations(context, activities),
        
        const SizedBox(height: 100), // Space for bottom navigation
      ],
    ),
        // Admin indicator
        if (isAdminMode)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.9),
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
                    Icons.admin_panel_settings,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ADMIN MODE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPremiumLockScreen(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Premium Insights',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock advanced analytics and insights',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Feature list
            _buildFeatureItem(
              context,
              Icons.dashboard,
              'Weekly Performance Dashboard',
              theme,
            ),
            _buildFeatureItem(
              context,
              Icons.balance,
              'Muscle Group Balance Analysis',
              theme,
            ),
            _buildFeatureItem(
              context,
              Icons.calendar_month,
              'Workout Consistency Tracking',
              theme,
            ),
            _buildFeatureItem(
              context,
              Icons.psychology,
              'Personalized Recommendations',
              theme,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/premium'),
              icon: const Icon(Icons.star),
              label: const Text('Unlock Premium'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(BuildContext context, IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainingRecommendations(BuildContext context, List<ExerciseActivity> activities) {
    final theme = Theme.of(context);
    final recommendations = _generateRecommendations(activities);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Training Recommendations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(
              context,
              rec['type'] as String,
              rec['message'] as String,
              rec['priority'] as String,
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecommendationItem(BuildContext context, String type, String message, String priority) {
    final theme = Theme.of(context);
    
    final icon = type == 'warning' ? Icons.warning_amber_rounded
                : type == 'success' ? Icons.check_circle_outline
                : Icons.info_outline;
    
    final color = type == 'warning' ? Colors.orange
                 : type == 'success' ? Colors.green
                 : theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (priority == 'high')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'High Priority',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Map<MuscleGroup, MuscleStrengthData> _generateMuscleData(List<ExerciseActivity> activities) {
    final muscleGroups = <MuscleGroup, double>{
      MuscleGroup.chest: 0,
      MuscleGroup.back: 0,
      MuscleGroup.shoulders: 0,
      MuscleGroup.arms: 0,
      MuscleGroup.legs: 0,
      MuscleGroup.core: 0,
    };
    
    final exerciseBreakdown = <MuscleGroup, Map<String, double>>{};
    
    for (final activity in activities) {
      final muscle = _getMuscleGroupEnum(activity.exerciseName);
      final volume = _calculateVolume(activity);
      muscleGroups[muscle] = (muscleGroups[muscle] ?? 0) + volume;
      
      exerciseBreakdown[muscle] ??= {};
      exerciseBreakdown[muscle]![activity.exerciseName] = 
          (exerciseBreakdown[muscle]![activity.exerciseName] ?? 0) + volume;
    }
    
    // Normalize to percentage
    final total = muscleGroups.values.fold(0.0, (sum, value) => sum + value);
    
    return Map.fromEntries(
      muscleGroups.entries.map((e) => MapEntry(
        e.key,
        MuscleStrengthData(
          currentStrength: total > 0 ? (e.value / total * 100) : 0,
          targetStrength: 16.7,
          totalVolume: e.value,
          recommendedExercises: _getRecommendedExercises(e.key),
          exerciseBreakdown: exerciseBreakdown[e.key] ?? {},
        ),
      )),
    );
  }
  
  Map<DateTime, WorkoutDayData> _generateWorkoutData(List<ExerciseActivity> activities) {
    final data = <DateTime, List<ExerciseData>>{};
    
    for (final activity in activities) {
      final date = DateTime(
        activity.createdAt.year,
        activity.createdAt.month,
        activity.createdAt.day,
      );
      
      data[date] ??= [];
      
      final exerciseData = ExerciseData(
        name: activity.exerciseName,
        sets: activity.sets.map((set) => SetData(
          reps: int.tryParse(set.reps) ?? 0,
          weight: double.tryParse(set.weight) ?? 0,
        )).toList(),
      );
      
      data[date]!.add(exerciseData);
    }
    
    return data.map((date, exercises) => MapEntry(
      date,
      WorkoutDayData(
        exercises: exercises,
        totalMinutes: exercises.length * 5, // Estimate 5 minutes per exercise
      ),
    ));
  }
  
  List<Map<String, String>> _generateRecommendations(List<ExerciseActivity> activities) {
    final recommendations = <Map<String, String>>[];
    
    // Check workout frequency
    final daysWithWorkout = _countWorkoutDays(activities);
    if (daysWithWorkout < 3) {
      recommendations.add({
        'type': 'warning',
        'message': 'Increase workout frequency to at least 3 times per week for optimal results',
        'priority': 'high',
      });
    } else {
      recommendations.add({
        'type': 'success',
        'message': 'Great consistency! You\'re working out regularly',
        'priority': 'low',
      });
    }
    
    // Check muscle balance
    final muscleData = _generateMuscleData(activities);
    final imbalanced = muscleData.entries.where((e) => 
      (e.value.currentStrength - e.value.targetStrength).abs() > 5).toList();
    
    if (imbalanced.isNotEmpty) {
      final neglected = imbalanced.firstWhere(
        (e) => e.value.currentStrength < e.value.targetStrength,
        orElse: () => imbalanced.first,
      );
      recommendations.add({
        'type': 'info',
        'message': 'Consider adding more ${neglected.key.name} exercises for balanced development',
        'priority': 'medium',
      });
    }
    
    // Check rest days
    if (daysWithWorkout > 6) {
      recommendations.add({
        'type': 'warning',
        'message': 'Remember to include rest days for recovery',
        'priority': 'high',
      });
    }
    
    return recommendations;
  }
  
  MuscleGroup _getMuscleGroupEnum(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('chest') || lower.contains('bench') || lower.contains('fly')) {
      return MuscleGroup.chest;
    } else if (lower.contains('back') || lower.contains('row') || lower.contains('pull')) {
      return MuscleGroup.back;
    } else if (lower.contains('shoulder') || lower.contains('delt') || lower.contains('press')) {
      return MuscleGroup.shoulders;
    } else if (lower.contains('bicep') || lower.contains('tricep') || lower.contains('curl')) {
      return MuscleGroup.arms;
    } else if (lower.contains('squat') || lower.contains('leg') || lower.contains('calf')) {
      return MuscleGroup.legs;
    } else if (lower.contains('ab') || lower.contains('core') || lower.contains('plank')) {
      return MuscleGroup.core;
    }
    return MuscleGroup.chest; // Default
  }
  
  List<String> _getRecommendedExercises(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return ['Bench Press', 'Incline Press', 'Chest Flyes'];
      case MuscleGroup.back:
        return ['Pull-ups', 'Barbell Row', 'Lat Pulldown'];
      case MuscleGroup.shoulders:
        return ['Overhead Press', 'Lateral Raises', 'Face Pulls'];
      case MuscleGroup.arms:
        return ['Bicep Curls', 'Tricep Dips', 'Hammer Curls'];
      case MuscleGroup.legs:
        return ['Squats', 'Deadlifts', 'Leg Press'];
      case MuscleGroup.core:
        return ['Plank', 'Russian Twists', 'Leg Raises'];
    }
  }
  
  double _calculateVolume(ExerciseActivity activity) {
    double volume = 0;
    for (final set in activity.sets) {
      final weight = double.tryParse(set.weight) ?? 0;
      final reps = int.tryParse(set.reps) ?? 0;
      volume += weight * reps;
    }
    return volume;
  }
  
  double _calculateIntensity(ExerciseActivity activity) {
    if (activity.sets.isEmpty) return 0;
    
    final avgEffort = activity.sets.fold(0.0, (sum, set) => 
      sum + (set.effort ?? 5)) / activity.sets.length;
    
    return avgEffort / 10; // Normalize to 0-1
  }
  
  int _countWorkoutDays(List<ExerciseActivity> activities) {
    final uniqueDays = <String>{};
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    for (final activity in activities) {
      if (activity.createdAt.isAfter(thirtyDaysAgo)) {
        uniqueDays.add('${activity.createdAt.year}-${activity.createdAt.month}-${activity.createdAt.day}');
      }
    }
    
    return uniqueDays.length;
  }
}