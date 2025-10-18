import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/intelligent_workout_suggestion_provider.dart';

/// Smart workout CTA button that suggests workouts based on user's patterns
class SmartWorkoutCTA extends ConsumerWidget {
  const SmartWorkoutCTA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final templates = ref.watch(customWorkoutTemplatesProvider);
    final intelligentSuggestion = ref.watch(intelligentWorkoutSuggestionProvider);

    // Get suggested workout info - use intelligent suggestion if available, otherwise fallback
    final workoutInfo = intelligentSuggestion.when(
      data: (suggestion) {
        if (suggestion != null && suggestion.confidence > 0.5) {
          // Use intelligent suggestion with localization
          final localizedSuggestion = suggestion.localizeWith(l10n);
          return WorkoutInfo(
            title: '${l10n.startWorkout}: ${localizedSuggestion.templateName}',
            reason: localizedSuggestion.reason,
            pattern: localizedSuggestion.patternDescription,
            confidence: localizedSuggestion.confidence,
          );
        } else {
          // Fallback to simple day-based logic
          return _getSuggestedWorkout(templates, l10n);
        }
      },
      loading: () => _getSuggestedWorkout(templates, l10n),
      error: (_, __) => _getSuggestedWorkout(templates, l10n),
    );

    // Determine duration based on user's historical data
    final suggestedDuration = _getEstimatedDuration(templates);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.goNamed('workout'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.startWorkoutQuick,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workoutInfo.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        workoutInfo.reason,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (workoutInfo.pattern != null && workoutInfo.pattern!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🔄 ${workoutInfo.pattern}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        '~$suggestedDuration min',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gets suggested workout based on user's history and patterns
  WorkoutInfo _getSuggestedWorkout(AsyncValue templates, AppLocalizations l10n) {
    return templates.when(
      data: (templateList) {
        if (templateList.isEmpty) {
          return WorkoutInfo(
            title: l10n.startWorkout,
            reason: l10n.suggestedForToday,
          );
        }

        // Simple logic: suggest based on day of week or rotation
        final today = DateTime.now().weekday;
        
        // Try to find a suitable template based on day
        if (today == DateTime.monday || today == DateTime.thursday) {
          final pushTemplates = templateList.where((t) => 
            t.name.toLowerCase().contains('push') ||
            t.name.toLowerCase().contains('spinta') ||
            t.name.toLowerCase().contains('petto')
          );
          
          if (pushTemplates.isNotEmpty) {
            final pushTemplate = pushTemplates.first;
            return WorkoutInfo(
              title: '${l10n.startWorkout} ${pushTemplate.name}',
              reason: l10n.suggestedForToday,
            );
          }
        } else if (today == DateTime.tuesday || today == DateTime.friday) {
          final pullTemplates = templateList.where((t) => 
            t.name.toLowerCase().contains('pull') ||
            t.name.toLowerCase().contains('tirata') ||
            t.name.toLowerCase().contains('schiena')
          );
          
          if (pullTemplates.isNotEmpty) {
            final pullTemplate = pullTemplates.first;
            return WorkoutInfo(
              title: '${l10n.startWorkout} ${pullTemplate.name}',
              reason: l10n.suggestedForToday,
            );
          }
        } else if (today == DateTime.wednesday || today == DateTime.saturday) {
          final legTemplates = templateList.where((t) => 
            t.name.toLowerCase().contains('leg') ||
            t.name.toLowerCase().contains('gambe')
          );
          
          if (legTemplates.isNotEmpty) {
            final legTemplate = legTemplates.first;
            return WorkoutInfo(
              title: '${l10n.startWorkout} ${legTemplate.name}',
              reason: l10n.suggestedForToday,
            );
          }
        }

        // Fallback to first available template
        if (templateList.isNotEmpty) {
          return WorkoutInfo(
            title: '${l10n.startWorkout} ${templateList.first.name}',
            reason: l10n.suggestedForToday,
          );
        }

        return WorkoutInfo(
          title: l10n.startWorkout,
          reason: l10n.suggestedForToday,
        );
      },
      loading: () => WorkoutInfo(
        title: l10n.startWorkout,
        reason: l10n.suggestedForToday,
      ),
      error: (_, __) => WorkoutInfo(
        title: l10n.startWorkout,
        reason: l10n.suggestedForToday,
      ),
    );
  }

  /// Estimates workout duration based on user's templates and exercises
  int _getEstimatedDuration(AsyncValue templates) {
    return templates.when(
      data: (templateList) {
        if (templateList.isEmpty) return 60;

        // Calculate average based on exercise count and complexity
        double totalExercises = 0;
        for (final template in templateList) {
          totalExercises += template.exercises.length.toDouble();
        }
        final avgExerciseCount = totalExercises / templateList.length;

        // Base calculation: ~8-10 minutes per exercise including rest
        // More realistic estimation for strength training
        final estimatedMinutes = (avgExerciseCount * 10).round();
        
        // Ensure reasonable bounds (45-90 minutes)
        if (estimatedMinutes < 45) return 60;
        if (estimatedMinutes > 90) return 80;
        
        return estimatedMinutes;
      },
      loading: () => 75, // Default to 75 min when loading
      error: (_, __) => 75, // Default to 75 min on error
    );
  }
}

/// Simple data class for workout information
class WorkoutInfo {

  WorkoutInfo({
    required this.title,
    required this.reason,
    this.pattern,
    this.confidence,
  });
  final String title;
  final String reason;
  final String? pattern;
  final double? confidence;
}
