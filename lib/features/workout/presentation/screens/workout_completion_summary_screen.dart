/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/screens
/// 🎯 Feature: workout
/// 🔧 Type: screen
///
/// Schermata di riepilogo mostrata dopo il completamento di un workout.
/// Visualizza statistiche chiave e conferma il salvataggio.
///
/// **STATISTICHE VISUALIZZATE**:
/// - Durata totale workout
/// - Numero esercizi completati
/// - Serie totali eseguite
/// - Volume totale (peso × reps)
/// - RPE medio (se disponibile)
///
/// **NAVIGAZIONE**:
/// - Pulsante "Done" → torna alla home
/// - Pulsante "View Details" → naviga a workout history detail
///
/// **ESEMPIO UTILIZZO**:
/// ```dart
/// // Dal workout_provider dopo save
/// context.goNamed(
///   'workout-completion-summary',
///   extra: completedWorkout,
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Screen di riepilogo workout completato
class WorkoutCompletionSummaryScreen extends ConsumerWidget {
  /// Workout completato da mostrare
  final Workout workout;

  const WorkoutCompletionSummaryScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calcola statistiche workout
    final totalExercises = workout.exercises.length;
    final totalSets = workout.exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.sets.length,
    );
    final totalVolume = workout.exercises.fold<double>(
      0.0,
      (sum, exercise) => sum + exercise.sets.fold<double>(
        0.0,
        (exerciseSum, set) {
          final weight = double.tryParse(set.weight.toString()) ?? 0.0;
          final reps = int.tryParse(set.reps.toString()) ?? 0;
          return exerciseSum + (weight * reps);
        },
      ),
    );

    // Calcola RPE medio (solo set non warmup con RPE > 0)
    final setsWithRpe = workout.exercises
        .expand((exercise) => exercise.sets)
        .where((set) => !set.isWarmup && (set.rpe ?? 0) > 0)
        .toList();
    final averageRpe = setsWithRpe.isNotEmpty
        ? setsWithRpe.fold<double>(
              0.0,
              (sum, set) => sum + (set.rpe ?? 0).toDouble(),
            ) / setsWithRpe.length
        : 0.0;

    // Formatta durata
    final duration = workout.duration ?? Duration.zero;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final durationText = hours > 0
        ? '${hours}h ${minutes}m'
        : minutes > 0
            ? '${minutes}m ${seconds}s'
            : '${seconds}s';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workoutCompleted),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎉 Success Icon
              Icon(
                Icons.check_circle,
                size: 80,
                color: context.colors.primary,
              ),
              const SizedBox(height: 24),

              // 💪 Workout Name
              Text(
                workout.name,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ✅ Completion Timestamp
              Text(
                _formatCompletionTime(context, workout.endTime ?? DateTime.now()),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 📊 Statistics Cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Durata
                      _StatCard(
                        icon: Icons.timer_outlined,
                        label: context.l10n.duration,
                        value: durationText,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: 16),

                      // Grid: Esercizi + Serie
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.fitness_center,
                              label: context.l10n.exercises,
                              value: totalExercises.toString(),
                              color: context.colors.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.repeat,
                              label: context.l10n.totalSets,
                              value: totalSets.toString(),
                              color: context.colors.tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Volume Totale
                      _StatCard(
                        icon: Icons.monitor_weight_outlined,
                        label: context.l10n.totalVolume,
                        value: '${totalVolume.toStringAsFixed(0)} kg',
                        color: const Color(0xFF4CAF50), // Verde
                      ),
                      const SizedBox(height: 16),

                      // RPE Medio (se disponibile)
                      if (averageRpe > 0)
                        _StatCard(
                          icon: Icons.speed,
                          label: context.l10n.averageRpe,
                          value: averageRpe.toStringAsFixed(1),
                          color: const Color(0xFFFF9800), // Arancione
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔘 Action Buttons
              Column(
                children: [
                  // View Details Button
                  FilledButton.icon(
                    onPressed: () {
                      // TODO: Navigate to workout history detail
                      context.pop();
                    },
                    icon: const Icon(Icons.analytics_outlined),
                    label: Text(context.l10n.viewDetails),
                  ),
                  const SizedBox(height: 12),

                  // Done Button
                  OutlinedButton(
                    onPressed: () {
                      // Torna alla home
                      context.go('/');
                    },
                    child: Text(context.l10n.done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatta timestamp completamento con localizzazione
  String _formatCompletionTime(BuildContext context, DateTime completedAt) {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inMinutes < 1) {
      return context.l10n.justNow;
    } else if (difference.inHours < 1) {
      return context.l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return context.l10n.hoursAgo(difference.inHours);
    } else {
      // Formatta data completa
      return '${completedAt.day}/${completedAt.month}/${completedAt.year} '
          '${completedAt.hour.toString().padLeft(2, '0')}:'
          '${completedAt.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Card statistica singola
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
