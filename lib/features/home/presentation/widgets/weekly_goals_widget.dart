import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/home_widget_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class WeeklyGoalsWidget extends ConsumerWidget {
  
  const WeeklyGoalsWidget({
    super.key,
    required this.size,
  });
  final WidgetSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (size) {
      case WidgetSize.small:
        return _buildCompactView(context, ref);
      case WidgetSize.medium:
        return _buildStandardView(context, ref);
      case WidgetSize.large:
        return _buildExpandedView(context, ref);
    }
  }

  Widget _buildCompactView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.colorScheme.primary.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: FutureBuilder<int>(
          future: _getWeeklyWorkoutCount(userId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            const goal = 4;
            final progress = (count / goal).clamp(0.0, 1.0);
            
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppIcons.flag,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Obiettivo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$count',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: count >= goal ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ' / $goal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count >= goal ? 'Obiettivo raggiunto! 🎉' :
                    count == 0 ? 'Inizia il tuo primo workout' :
                    'Ancora ${goal - count} workout',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: count >= goal ? theme.colorScheme.primary :
                             theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStandardView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.06),
              theme.colorScheme.primary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: FutureBuilder<Map<String, bool>>(
          future: _getWeeklyWorkouts(userId),
          builder: (context, snapshot) {
            final workoutDays = snapshot.data ?? {};
            final count = workoutDays.values.where((v) => v).length;
            const goal = 4;
            
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppIcons.flag,
                          color: theme.colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Obiettivo Settimanale',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$count / $goal workout',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (count >= goal)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '✓ Completato',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Week days
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['L', 'M', 'M', 'G', 'V', 'S', 'D'].asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final isToday = index == DateTime.now().weekday - 1;
                      final hasWorkout = workoutDays[day] ?? false;
                      
                      return Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: hasWorkout
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: isToday ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ) : null,
                            ),
                            child: Center(
                              child: hasWorkout
                                  ? Icon(
                                      AppIcons.check,
                                      color: theme.colorScheme.onPrimary,
                                      size: 18,
                                    )
                                  : Text(
                                      day,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isToday)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  // Progress bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progresso',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '${(count / goal * 100).toInt()}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: count / goal,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.04),
              theme.colorScheme.primary.withValues(alpha: 0.01),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      AppIcons.trackChanges,
                      color: theme.colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Obiettivi & Suggerimenti',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Piano settimanale personalizzato',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Weekly overview with suggestions
              FutureBuilder<Map<String, bool>>(
                future: _getWeeklyWorkouts(userId),
                builder: (context, snapshot) {
                  final workoutDays = snapshot.data ?? {};
                  final count = workoutDays.values.where((v) => v).length;
                  const goal = 4;
                  
                  return Column(
                    children: [
                      // Stats cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              icon: AppIcons.workout,
                              label: 'Completati',
                              value: '$count',
                              color: context.colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              icon: AppIcons.flag,
                              label: 'Obiettivo',
                              value: '$goal',
                              color: context.colors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGoalCard(
                              context,
                              icon: AppIcons.calendar,
                              label: 'Giorni rimasti',
                              value: '${7 - DateTime.now().weekday}',
                              color: context.colors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Suggestions
                      if (count < goal) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    AppIcons.tip,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Suggerimento',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getSuggestion(count, goal - count),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colors.success.withValues(alpha: 0.1),
                                context.colors.success.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.colors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.achievement,
                                color: context.colors.success,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Obiettivo Raggiunto!',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: context.colors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Ottimo lavoro questa settimana!',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Accedi per vedere i tuoi obiettivi',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ MIGRATED: Reads from 'workouts' collection instead of exerciseActivities
  Future<int> _getWeeklyWorkoutCount(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    if (kDebugMode) {
      debugPrint('📊 [WeeklyGoals] Fetching workout count from workouts collection');
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .get();

    // Count unique days from completed workouts
    final Set<String> uniqueDays = {};
    for (final doc in query.docs) {
      final data = doc.data();
      final timestamp = data['completedAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        uniqueDays.add('${date.year}-${date.month}-${date.day}');
      }
    }

    if (kDebugMode) {
      debugPrint('  ✅ Found ${uniqueDays.length} unique workout days this week');
    }

    return uniqueDays.length;
  }

  /// ✅ MIGRATED: Reads from 'workouts' collection instead of exerciseActivities
  Future<Map<String, bool>> _getWeeklyWorkouts(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    if (kDebugMode) {
      debugPrint('📊 [WeeklyGoals] Fetching weekly workout map from workouts collection');
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .get();

    final Map<String, bool> workoutDays = {
      'L': false, 'M': false, 'M': false, 'G': false,
      'V': false, 'S': false, 'D': false,
    };

    for (final doc in query.docs) {
      final data = doc.data();
      final timestamp = data['completedAt'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dayIndex = date.weekday - 1;
        final dayNames = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
        if (dayIndex >= 0 && dayIndex < 7) {
          workoutDays[dayNames[dayIndex]] = true;
        }
      }
    }

    if (kDebugMode) {
      final completedDays = workoutDays.values.where((v) => v).length;
      debugPrint('  ✅ Found workouts on $completedDays days this week');
    }

    return workoutDays;
  }

  String _getSuggestion(int completed, int remaining) {
    if (completed == 0) {
      return 'Inizia oggi il tuo primo workout della settimana! Un buon inizio è metà dell\'opera.';
    } else if (remaining == 1) {
      return 'Ancora un workout per raggiungere il tuo obiettivo! Puoi farcela!';
    } else if (remaining == 2) {
      return 'Ottimo progresso! Programma i prossimi $remaining workout nei giorni rimanenti.';
    } else {
      return 'Continua con costanza! Ti mancano $remaining workout per completare l\'obiettivo settimanale.';
    }
  }
}