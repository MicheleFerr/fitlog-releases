import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/progress_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_coach_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/domain/entities/workout_template.dart'
    as TemplateEntity;
import 'package:flutter/foundation.dart';

export 'package:gymbro_flutter_new/features/home/domain/services/ai_coach_service.dart'
    show AIInsight;

/// Provider for AI Coach insights
/// 🔧 FIX BUG #6: Watch currentUserProvider to invalidate on logout/switch
/// Previously used sync authServiceProvider which didn't react to auth changes
final aiCoachInsightsProvider = FutureProvider.autoDispose<List<AIInsight>>((
  ref,
) async {
  // FIX: keepAlive to prevent expensive re-fetching on widget rebuilds
  ref.keepAlive();

  // Watch auth stream - provider will invalidate when user changes
  final userAsync = ref.watch(currentUserProvider);
  final currentUser = userAsync.value;

  if (currentUser?.email == null) {
    return [];
  }

  try {
    // Get workout data (activities for volume/progressive overload analysis)
    // ✅ Use HybridExerciseActivityRepository for correct workout dates
    final repository = ref.watch(hybridExerciseActivityRepositoryProvider);

    final activities = await repository.getUserActivities(
      userEmail: currentUser!.email!,
    );

    // Get completed workouts for recovery analysis
    final workoutRepo = ref.watch(workoutRepositoryProvider);
    final workoutsResult = await workoutRepo.getWorkouts(limit: 100);
    final completedWorkouts = workoutsResult.fold(
      (failure) => <dynamic>[],
      (workouts) =>
          workouts.where((w) => w.status == WorkoutStatus.completed).toList(),
    );

    // Get exercise database (case-insensitive lookup)
    final exerciseDatabase = await ref.watch(allExercisesProvider.future);
    final exerciseMap = {
      for (var e in exerciseDatabase) e.nome.toLowerCase(): e,
    };

    // Get progress stats
    final progressData = await ref.watch(progressDataProvider.future);
    final streakAsync = await ref.watch(currentStreakProvider.future);
    final frequencyAsync = await ref.watch(weeklyFrequencyProvider.future);
    final l10n = ref.watch(appLocalizationsProvider);

    // Get user templates for actionable insights (safe fallback to empty list)
    List<TemplateEntity.WorkoutTemplate> userTemplates = [];
    try {
      final templateRepository = TemplateRepository();
      final templates = await templateRepository.getUserTemplates();
      userTemplates = templates.cast<TemplateEntity.WorkoutTemplate>();
    } catch (templateError) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Could not fetch templates (non-critical): $templateError',
        );
      }
      // Continue without templates - insights will work but without action buttons
    }

    // Generate insights with exercise database, templates, and completed workouts
    return AICoachService.generateInsights(
      activities,
      progressData?.quickStats,
      streakAsync,
      frequencyAsync,
      l10n,
      exerciseMap,
      userTemplates,
      completedWorkouts: completedWorkouts,
    );
  } catch (e, stackTrace) {
    // Log error for debugging
    if (kDebugMode) {
      debugPrint('❌ AI Coach Error: $e');
    }
    if (kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
    return [];
  }
});

/// Provider for primary AI Coach advice (for the main card)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final primaryAIAdviceProvider = FutureProvider.autoDispose<String>((ref) async {
  final insights = await ref.watch(aiCoachInsightsProvider.future);
  final l10n = ref.watch(appLocalizationsProvider);

  if (insights.isEmpty) {
    return l10n.aiCoachFirstWorkout;
  }

  // Return the highest priority insight
  final topInsight = insights.first;
  return '${topInsight.title}: ${topInsight.recommendation}';
});
