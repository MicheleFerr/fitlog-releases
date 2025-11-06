import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Smart workout CTA button that pre-loads workouts from active routines
class SmartWorkoutCTA extends ConsumerWidget {
  const SmartWorkoutCTA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final routineAsync = ref.watch(activeFlexibleRoutineProvider);

    return routineAsync.when(
      loading: () => _buildLoadingState(context, theme),
      error: (_, __) => _buildDisabledState(
        context,
        theme,
        'Errore caricamento',
      ),
      data: (routine) {
        // Guard 1: Check if routine exists and has today scheduled
        if (routine == null || !routine.hasProgrammedWorkoutToday()) {
          return _buildDisabledState(
            context,
            theme,
            'Giorno di Riposo 🌟',
          );
        }

        // Guard 2: Get today's workout
        final todayWorkout = routine.getTodayWorkout();
        if (todayWorkout == null || todayWorkout.templateId == null) {
          return _buildDisabledState(
            context,
            theme,
            'Routine incompleta',
          );
        }

        // ✅ Ready to show active CTA
        return _buildActiveState(
          context,
          ref,
          theme,
          todayWorkout.templateId!,
        );
      },
    );
  }

  // Loading state - skeleton
  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }

  // Disabled state - rest day or no routine
  Widget _buildDisabledState(
    BuildContext context,
    ThemeData theme,
    String label,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa il pulsante "+ Sessione Libera" per un allenamento libero',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active state - ready to pre-load
  Widget _buildActiveState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String templateId,
  ) {
    // Watch templates to get the name
    final templatesAsync = ref.watch(customWorkoutTemplatesProvider);

    return templatesAsync.when(
      loading: () => _buildLoadingState(context, theme),
      error: (_, __) => _buildDisabledState(
        context,
        theme,
        'Errore caricamento template',
      ),
      data: (templates) {
        // Find the template
        final template = templates.where((t) => t.id == templateId).firstOrNull;
        if (template == null) {
          return _buildDisabledState(
            context,
            theme,
            'Template non trovato',
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onSmartCTATap(context, ref, template.id, template.name),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AppIcons.rocket,
                          color: theme.colorScheme.onPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'INIZIA ALLENAMENTO',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suggerito per oggi • ~${template.estimatedDuration} min',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSmartCTATap(
    BuildContext context,
    WidgetRef ref,
    String templateId,
    String templateName,
  ) async {
    // Generate session ID for analytics correlation
    final sessionId = generateSessionId();

    // Guard 1: Check AsyncValue state
    final routineAsync = ref.read(activeFlexibleRoutineProvider);
    if (routineAsync is! AsyncData) {
      if (context.mounted) {
        // Fallback: Navigate to workout with template ID
        context.goNamed('workout', queryParameters: {'templateId': templateId});
      }
      return;
    }

    final routine = routineAsync.value;

    // Guard 2: Routine null check
    if (routine == null || !routine.hasProgrammedWorkoutToday()) {
      if (context.mounted) {
        context.goNamed('workout', queryParameters: {'templateId': templateId});
      }
      return;
    }

    // Guard 3: getTodayWorkout() null check
    final todayWorkoutFresh = routine.getTodayWorkout();
    if (todayWorkoutFresh == null || todayWorkoutFresh.templateId == null) {
      if (context.mounted) {
        context.goNamed('workout', queryParameters: {'templateId': templateId});
      }
      return;
    }

    // Analytics: CTA tapped
    // Note: WorkoutAnalytics import removed - analytics will be tracked in workout screen
    // await WorkoutAnalytics.trackEvent(
    //   'smart_cta_tapped',
    //   properties: {
    //     'sessionId': sessionId,
    //     'templateName': templateName,
    //     'timestamp': DateTime.now().toIso8601String(),
    //   },
    // );

    // Navigate to workout screen with template ID and session ID
    // The workout screen will handle loading the template and creating the workout
    if (context.mounted) {
      context.goNamed(
        'workout',
        queryParameters: {
          'templateId': templateId,
          'sessionId': sessionId,
          'fromSmartCTA': 'true',
        },
      );
    }
  }
}

String generateSessionId() => const Uuid().v4();
