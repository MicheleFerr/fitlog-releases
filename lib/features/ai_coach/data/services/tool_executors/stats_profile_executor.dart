/// Stats & Profile tool executor for AI Coach
///
/// Handles: getWorkoutStats, getPersonalRecords, getStreak,
/// getWorkoutHistory, getUserProfileContext, updateUserProfilePreferences,
/// getWorkoutPreferences, updateWorkoutPreferences.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart' as h;

class StatsProfileExecutor {
  StatsProfileExecutor({
    required this.analyticsRepo,
    required this.workoutAnalyticsRepo,
    required this.streakRepo,
    required this.historyRepo,
    this.measurementRepo,
    this.onboardingState,
    this.accountTier = 'free',
    this.getWorkoutPreferences,
    this.updateWorkoutPreferences,
    this.historyDaysLimit,
  });

  final AnalyticsRepository analyticsRepo;
  final WorkoutAnalyticsRepository workoutAnalyticsRepo;
  final StreakRepository streakRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final MeasurementRepository? measurementRepo;
  final OnboardingState? onboardingState;
  final String accountTier;
  final Future<Map<String, dynamic>> Function()? getWorkoutPreferences;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic> updates)?
  updateWorkoutPreferences;
  final int? historyDaysLimit;

  Future<String> getWorkoutStats(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final stats = await workoutAnalyticsRepo.getAnalyticsStats(userId);

      return jsonEncode({
        'totalWorkouts': stats.totalWorkouts,
        'totalPRs': stats.totalPRs,
        'averageWorkoutDuration': stats.averageWorkoutDuration.toStringAsFixed(
          1,
        ),
        'averageWorkoutVolume': stats.averageWorkoutVolume.toStringAsFixed(0),
        'totalVolumeLifted': stats.totalVolumeLifted.toStringAsFixed(0),
        'trainingConsistency': stats.trainingConsistency.toStringAsFixed(1),
        'mostFrequentExercise': stats.mostFrequentExercise,
        'highestVolumeExercise': stats.highestVolumeExercise,
        'firstWorkoutDate': stats.firstWorkoutDate?.toIso8601String(),
        'lastWorkoutDate': stats.lastWorkoutDate?.toIso8601String(),
        'topExercises': Map.fromEntries(
          (stats.exerciseFrequency.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .take(10),
        ),
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getWorkoutStats',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getWorkoutStats',
      });
    }
  }

  Future<String> getPersonalRecords(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final rawExerciseName = args['exerciseName'] as String?;
    // Normalize unicode escapes (e.g., \u00b0 → °)
    final exerciseName = rawExerciseName != null
        ? h.normalizeString(rawExerciseName)
        : null;

    try {
      if (exerciseName != null) {
        // Get PRs for a specific exercise
        final exerciseResult = await analyticsRepo.getExerciseHistoryByName(
          userId: userId,
          exerciseName: exerciseName,
        );

        return await exerciseResult.fold(
          (failure) async {
            // Exercise not found -> try to get all PRs filtered by name
            final allPRs = await workoutAnalyticsRepo.getUserPRs(userId);
            final filtered = allPRs
                .where(
                  (pr) => pr.exerciseName.toLowerCase().contains(
                    exerciseName.toLowerCase(),
                  ),
                )
                .toList();

            if (filtered.isEmpty) {
              return jsonEncode({
                'error': 'No PRs found for "$exerciseName"',
                'toolName': 'getPersonalRecords',
              });
            }

            return jsonEncode({
              'exerciseName': exerciseName,
              'records': filtered.map(_prToMap).toList(),
              'count': filtered.length,
            });
          },
          (exerciseHistory) async {
            final prs = await workoutAnalyticsRepo.getExercisePRs(
              userId,
              exerciseHistory.exerciseId,
            );

            final records = prs.entries.map((entry) {
              return {
                'type': entry.key.name,
                'value': entry.value.value,
                'previousValue': entry.value.previousValue,
                'improvementPercent': entry.value.improvementPercentage,
                'achievedAt': entry.value.achievedAt.toIso8601String(),
              };
            }).toList();

            return jsonEncode({
              'exerciseName': exerciseHistory.exerciseName,
              'muscleGroup': exerciseHistory.muscleGroup,
              'records': records,
              'count': records.length,
            });
          },
        );
      } else {
        // Get all PRs
        final allPRs = await workoutAnalyticsRepo.getUserPRs(userId);

        // Sort by value descending and take top 10
        final sorted = [...allPRs]..sort((a, b) => b.value.compareTo(a.value));
        final top = sorted.take(10).toList();

        return jsonEncode({
          'records': top.map(_prToMap).toList(),
          'totalPRs': allPRs.length,
          'count': top.length,
        });
      }
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getPersonalRecords',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getPersonalRecords',
      });
    }
  }

  Map<String, dynamic> _prToMap(PersonalRecord pr) {
    return {
      'exerciseName': pr.exerciseName,
      'type': pr.type.name,
      'value': pr.value,
      'previousValue': pr.previousValue,
      'improvementPercent': pr.improvementPercentage,
      'achievedAt': pr.achievedAt.toIso8601String(),
    };
  }

  Future<String> getStreak(Map<String, dynamic> args, String userId) async {
    try {
      final streak = await streakRepo.getCurrentStreak();

      return jsonEncode({
        'currentStreak': streak.currentStreak,
        'bestStreak': streak.longestStreak,
        'totalWorkoutDays': streak.totalWorkoutDays,
        'isActive': streak.isActive,
        'lastWorkoutDate': streak.lastWorkoutDate?.toIso8601String(),
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getStreak',
      );

      return jsonEncode({'error': 'Exception: $e', 'toolName': 'getStreak'});
    }
  }

  Future<String> getWorkoutHistory(
    Map<String, dynamic> args,
    String userId,
  ) async {
    // Handle daysBack and limit as either num or String
    final daysBackRaw = args['daysBack'];
    final maxDays = historyDaysLimit ?? 999;
    final daysBack =
        (daysBackRaw is num
                ? daysBackRaw.toInt()
                : int.tryParse(daysBackRaw?.toString() ?? '7') ?? 7)
            .clamp(1, maxDays);

    final limitRaw = args['limit'];
    final limit = limitRaw is num
        ? limitRaw.toInt()
        : int.tryParse(limitRaw?.toString() ?? '5') ?? 5;

    try {
      final workoutsEither = await historyRepo.getWorkouts();

      return workoutsEither.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch workouts: ${failure.message}',
          'toolName': 'getWorkoutHistory',
        }),
        (workouts) {
          final now = DateTime.now();
          final cutoff = now.subtract(Duration(days: daysBack));

          // Filter by time range, sort newest first, apply limit
          final filtered =
              workouts.where((w) => w.completedAt.isAfter(cutoff)).toList()
                ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

          final limited = filtered.take(limit).toList();

          final history = limited.map((w) {
            // Only include exercises that have at least 1 set performed
            final completedExercises = w.exercises
                .where((e) => e.sets.isNotEmpty)
                .toList();
            return {
              'name': w.name,
              'completedAt': w.completedAt.toIso8601String(),
              'durationMinutes': w.duration.inMinutes,
              'exerciseCount': completedExercises.length,
              'exercises': completedExercises.map((e) => e.name).toList(),
              'totalVolume': w.totalVolume.toStringAsFixed(0),
              'totalSets': w.totalSets,
            };
          }).toList();

          return jsonEncode({
            'daysBack': daysBack,
            'workouts': history,
            'count': history.length,
            'totalInPeriod': filtered.length,
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getWorkoutHistory',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getWorkoutHistory',
      });
    }
  }

  Future<String> getUserProfileContext(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final state = await h.loadOnboardingState(onboardingState);
      final experience = h.experienceFromOnboarding(state);
      final goal = h.goalFromOnboarding(state);
      final weeklyTarget = state?.weeklyWorkoutTarget;

      double? latestWeightKg;
      String? latestWeightDate;
      if (measurementRepo != null) {
        final latestResult = await measurementRepo!.getLatestMeasurementsByType(
          userId,
        );
        latestResult.fold((_) {}, (latest) {
          final weight = latest[MetricType.weight];
          if (weight != null) {
            latestWeightKg = weight.value;
            latestWeightDate = weight.timestamp.toIso8601String().substring(
              0,
              10,
            );
          }
        });
      }

      final missing = <String>[
        if (experience == null) 'experienceLevel',
        if (goal == null) 'goal',
        if (weeklyTarget == null) 'weeklyTarget',
      ];

      final suggestions = missing.isNotEmpty
          ? h.profileSuggestionsForMissing(missing.first)
          : <String>[
              'Fai il mio check settimanale',
              'Adatta il piano di oggi in base al recupero',
              'Analizza la mia aderenza',
            ];

      return jsonEncode({
        'profile': {
          'experienceLevel': experience,
          'goal': goal,
          'weeklyTarget': weeklyTarget,
          'accountTier': accountTier,
          'latestWeightKg': latestWeightKg,
          'latestWeightDate': latestWeightDate,
        },
        'missingFields': missing,
        'suggestions': suggestions,
        'toolName': 'getUserProfileContext',
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getUserProfileContext',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getUserProfileContext',
      });
    }
  }

  Future<String> updateUserProfilePreferences(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final normalizedExperience = h.normalizeExperienceInput(
        args['experienceLevel']?.toString(),
      );
      final normalizedGoal = h.normalizeGoalInput(args['goal']?.toString());

      final weeklyTargetRaw = args['weeklyTarget'];
      final weeklyTarget = weeklyTargetRaw is num
          ? weeklyTargetRaw.toInt().clamp(2, 7)
          : int.tryParse(weeklyTargetRaw?.toString() ?? '');
      final clampedTarget = weeklyTarget?.clamp(2, 7);

      if (normalizedExperience == null &&
          normalizedGoal == null &&
          clampedTarget == null) {
        return jsonEncode({
          'error':
              'Nessun dato valido da aggiornare. Fornisci experienceLevel, goal o weeklyTarget.',
          'toolName': 'updateUserProfilePreferences',
        });
      }

      final current =
          await h.loadOnboardingState(onboardingState) ??
          const OnboardingState();
      final updatedStepData = Map<String, dynamic>.from(current.stepData);

      if (normalizedExperience != null) {
        updatedStepData['aiExperienceLevel'] = normalizedExperience;
      }
      if (normalizedGoal != null) {
        updatedStepData['aiGoal'] = normalizedGoal;
      }

      final onboardingGoal = normalizedGoal != null
          ? h.goalToOnboardingValue(normalizedGoal)
          : null;

      final updatedState = current.copyWith(
        userExperienceLevel: normalizedExperience != null
            ? (normalizedExperience == 'beginner' ? 'beginner' : 'expert')
            : current.userExperienceLevel,
        userGoal: onboardingGoal ?? current.userGoal,
        weeklyWorkoutTarget: clampedTarget ?? current.weeklyWorkoutTarget,
        stepData: updatedStepData,
        lastInteraction: DateTime.now(),
      );

      await h.saveOnboardingState(updatedState);

      return jsonEncode({
        'success': true,
        'message': 'Preferenze profilo aggiornate con successo.',
        'profile': {
          'experienceLevel': h.experienceFromOnboarding(updatedState),
          'goal': h.goalFromOnboarding(updatedState),
          'weeklyTarget': updatedState.weeklyWorkoutTarget,
        },
        'toolName': 'updateUserProfilePreferences',
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: updateUserProfilePreferences',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'updateUserProfilePreferences',
      });
    }
  }

  Future<String> getWorkoutPreferencesResult(
    Map<String, dynamic> args,
    String userId,
  ) async {
    if (getWorkoutPreferences == null) {
      return jsonEncode({
        'error': 'Preferenze workout non disponibili',
        'toolName': 'getWorkoutPreferences',
      });
    }

    try {
      final prefs = await getWorkoutPreferences!.call();
      final sets = (prefs['defaultExerciseSets'] as num?)?.toInt() ?? 4;
      final reps = (prefs['defaultExerciseReps'] as num?)?.toInt() ?? 8;
      final restSet = (prefs['defaultRestTime'] as num?)?.toInt() ?? 90;
      final restExercise =
          (prefs['defaultRestBetweenExercises'] as num?)?.toInt() ?? 90;

      return jsonEncode({
        'preferences': prefs,
        'message':
            'Preferenze attuali: $sets×$reps, recupero serie ${restSet}s, recupero esercizi ${restExercise}s.',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Setup preferenze allenamento',
          subtitle:
              'Attuale: $sets×$reps • Recupero serie ${restSet}s • Recupero esercizi ${restExercise}s',
          templateName: 'Workout Preferences',
          actions: [
            h.buildTemplateAction(
              label: '5×5 Forza',
              command:
                  'Imposta preferenze workout: 5 serie, 5 ripetizioni, recupero serie 180 secondi.',
              actionType: 'edit',
            ),
            h.buildTemplateAction(
              label: '4×8 Ipertrofia',
              command:
                  'Imposta preferenze workout: 4 serie, 8 ripetizioni, recupero serie 90 secondi.',
              actionType: 'edit',
              style: 'primary',
            ),
            h.buildTemplateAction(
              label: 'Apri impostazioni',
              command: '__OPEN_SETTINGS__',
              actionType: 'link',
            ),
          ],
        ),
        'toolName': 'getWorkoutPreferences',
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getWorkoutPreferences',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getWorkoutPreferences',
      });
    }
  }

  Future<String> updateWorkoutPreferencesResult(
    Map<String, dynamic> args,
    String userId,
  ) async {
    if (updateWorkoutPreferences == null || getWorkoutPreferences == null) {
      return jsonEncode({
        'success': false,
        'message':
            'Non riesco ad aggiornare automaticamente le preferenze ora. Puoi farlo dal setup rapido.',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Setup preferenze allenamento',
          subtitle:
              'Apri il setup rapido per impostare serie, ripetizioni e recuperi.',
          templateName: 'Workout Preferences',
          actions: [
            h.buildTemplateAction(
              label: 'Apri impostazioni',
              command: '__OPEN_SETTINGS__',
              actionType: 'link',
              style: 'primary',
            ),
          ],
        ),
        'toolName': 'updateWorkoutPreferences',
      });
    }

    try {
      final updates = <String, dynamic>{};
      if (args.containsKey('defaultExerciseSets')) {
        updates['defaultExerciseSets'] = h.parseBoundedInt(
          args['defaultExerciseSets'],
          defaultValue: 4,
          min: 1,
          max: 8,
        );
      }
      if (args.containsKey('defaultExerciseReps')) {
        updates['defaultExerciseReps'] = h.parseBoundedInt(
          args['defaultExerciseReps'],
          defaultValue: 8,
          min: 3,
          max: 30,
        );
      }
      if (args.containsKey('defaultRestTime')) {
        updates['defaultRestTime'] = h.parseBoundedInt(
          args['defaultRestTime'],
          defaultValue: 90,
          min: 30,
          max: 300,
        );
      }
      if (args.containsKey('defaultRestBetweenExercises')) {
        updates['defaultRestBetweenExercises'] = h.parseBoundedInt(
          args['defaultRestBetweenExercises'],
          defaultValue: 90,
          min: 30,
          max: 300,
        );
      }

      if (updates.isEmpty) {
        final prefs = await getWorkoutPreferences!.call();
        return jsonEncode({
          'error':
              'Nessuna preferenza valida da aggiornare. Specifica defaultExerciseSets/defaultExerciseReps/defaultRestTime.',
          'preferences': prefs,
          'toolName': 'updateWorkoutPreferences',
        });
      }

      final updated = await updateWorkoutPreferences!.call(updates);
      final sets = (updated['defaultExerciseSets'] as num?)?.toInt() ?? 4;
      final reps = (updated['defaultExerciseReps'] as num?)?.toInt() ?? 8;
      final restSet = (updated['defaultRestTime'] as num?)?.toInt() ?? 90;
      final restExercise =
          (updated['defaultRestBetweenExercises'] as num?)?.toInt() ?? 90;

      return jsonEncode({
        'success': true,
        'preferences': updated,
        'message':
            'Preferenze aggiornate: $sets×$reps, recupero serie ${restSet}s, recupero esercizi ${restExercise}s.',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Preferenze aggiornate',
          subtitle:
              'Nuovo setup: $sets×$reps • Recupero serie ${restSet}s • Recupero esercizi ${restExercise}s',
          templateName: 'Workout Preferences',
          actions: [
            h.buildTemplateAction(
              label: 'Rifai setup guidato',
              command:
                  'Guidami a personalizzare set, ripetizioni e recuperi passo passo.',
              actionType: 'edit',
              style: 'primary',
            ),
            h.buildTemplateAction(
              label: 'Apri impostazioni',
              command: '__OPEN_SETTINGS__',
              actionType: 'link',
            ),
          ],
        ),
        'toolName': 'updateWorkoutPreferences',
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: updateWorkoutPreferences',
      );
      Map<String, dynamic>? fallbackPrefs;
      try {
        fallbackPrefs = await getWorkoutPreferences?.call();
      } catch (_) {
        fallbackPrefs = null;
      }
      return jsonEncode({
        'success': false,
        'preferences': fallbackPrefs,
        'message':
            'Non sono riuscito a salvare da chat al primo tentativo. Apri il setup rapido per confermare serie, ripetizioni e recuperi.',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Verifica preferenze',
          subtitle:
              'Apri il setup rapido per completare il salvataggio di set/reps/recuperi.',
          templateName: 'Workout Preferences',
          actions: [
            h.buildTemplateAction(
              label: 'Apri impostazioni',
              command: '__OPEN_SETTINGS__',
              actionType: 'link',
              style: 'primary',
            ),
            h.buildTemplateAction(
              label: 'Riprova da chat',
              command:
                  'Imposta preferenze workout: 4 serie, 8 ripetizioni, recupero serie 90 secondi, recupero esercizi 90 secondi.',
              actionType: 'edit',
            ),
          ],
        ),
        'toolName': 'updateWorkoutPreferences',
      });
    }
  }
}
