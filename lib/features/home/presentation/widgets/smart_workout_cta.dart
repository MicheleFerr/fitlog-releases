import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Smart workout CTA button that pre-loads workouts from active routines
class SmartWorkoutCTA extends ConsumerWidget {
  const SmartWorkoutCTA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final routineAsync = ref.watch(safeActiveRoutineProvider);

    return routineAsync.when(
      loading: () => _buildLoadingState(context, theme),
      error: (_, __) => _buildDisabledState(
        context,
        theme,
        context.l10n.smartWorkoutCTAErrorLoading,
      ),
      data: (routine) {
        // Guard 1: Check if routine exists and has uncompleted workout
        if (routine == null || !routine.hasUncompletedWorkout()) {
          return _buildDisabledState(
            context,
            theme,
            context.l10n.smartWorkoutCTARestDay,
          );
        }

        // Guard 2: Get next uncompleted workout
        final nextWorkout = routine.getNextUncompletedWorkout();
        if (nextWorkout == null || nextWorkout.templateId == null) {
          return _buildDisabledState(
            context,
            theme,
            context.l10n.smartWorkoutCTAIncompleteRoutine,
          );
        }

        // ✅ Ready to show active CTA
        return _buildActiveState(
          context,
          ref,
          theme,
          nextWorkout.templateId!,
        );
      },
    );
  }

  // Loading state - skeleton
  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const LoadingIndicator(),
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
              context.l10n.smartWorkoutCTARestDayHint,
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
        context.l10n.smartWorkoutCTAErrorTemplate,
      ),
      data: (templates) {
        // Find the template
        final template = templates.where((t) => t.id == templateId).firstOrNull;
        if (template == null) {
          return _buildDisabledState(
            context,
            theme,
            context.l10n.smartWorkoutCTATemplateNotFound,
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
              onTap: () async {
                await HapticFeedback.lightImpact();
                await _onSmartCTATap(context, ref, template.id, template.name);
              },
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
                          size: AppIconSize.small,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.smartWorkoutCTAStart,
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
                      context.l10n.smartWorkoutCTASuggestedToday(template.estimatedDuration),
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
    final routineAsync = ref.read(safeActiveRoutineProvider);
    if (routineAsync is! AsyncData) {
      return;
    }

    final routine = routineAsync.value;

    // Guard 2: Routine null check
    if (routine == null || !routine.hasUncompletedWorkout()) {
      return;
    }

    // Guard 3: getNextUncompletedWorkout() null check
    final nextWorkoutFresh = routine.getNextUncompletedWorkout();
    if (nextWorkoutFresh == null || nextWorkoutFresh.templateId == null) {
      return;
    }

    // Fetch template to get exercises
    final templatesAsync = ref.read(customWorkoutTemplatesProvider);
    if (templatesAsync is! AsyncData) {
      return;
    }

    final templates = templatesAsync.value ?? [];
    final template = templates.where((t) => t.id == templateId).firstOrNull;
    if (template == null) {
      return;
    }

    // ✅ Analytics tracking BEFORE starting workout
    await WorkoutAnalytics.trackEvent(
      'smart_cta_tapped',
      properties: {
        'sessionId': sessionId,
        'templateName': templateName,
        'templateId': templateId,
        'exerciseCount': template.exercises.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // ✅ Start workout from template (same as DayDetailSheet)
    // This creates an active workout, not a preloaded one
    ref.read(currentWorkoutProvider.notifier).startFromTemplate(template);

    // ✅ Navigate directly to workout screen (no extra needed)
    if (context.mounted) {
      context.goNamed('workout');
    }
  }
}

String generateSessionId() => const Uuid().v4();
