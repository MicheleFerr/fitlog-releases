/// Coaching tool executor for AI Coach
///
/// Handles: getWeeklyCheckin, getAutoProgressionPlan, getAdherenceInsights.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/onboarding_state.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart' as h;

class CoachingExecutor {
  CoachingExecutor({
    required this.historyRepo,
    required this.workoutAnalyticsRepo,
    required this.analyticsRepo,
    this.onboardingState,
  });

  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final WorkoutAnalyticsRepository workoutAnalyticsRepo;
  final AnalyticsRepository analyticsRepo;
  final OnboardingState? onboardingState;

  DateTime _startOfWeek(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    return dayStart.subtract(Duration(days: dayStart.weekday - 1));
  }

  Future<String> getWeeklyCheckin(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final workoutsEither = await historyRepo.getWorkouts();
      final allPrs = await workoutAnalyticsRepo.getUserPRs(userId);
      final state = await h.loadOnboardingState(onboardingState);
      final weeklyTarget = (state?.weeklyWorkoutTarget ?? 3).clamp(2, 7);

      return workoutsEither.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch workouts: ${failure.message}',
          'toolName': 'getWeeklyCheckin',
        }),
        (workouts) {
          final now = DateTime.now();
          final thisWeekStart = _startOfWeek(now);
          final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

          final thisWeek = workouts
              .where((w) => w.completedAt.isAfter(thisWeekStart))
              .toList();
          final lastWeek = workouts
              .where(
                (w) =>
                    w.completedAt.isAfter(lastWeekStart) &&
                    w.completedAt.isBefore(thisWeekStart),
              )
              .toList();

          final thisWeekVolume = thisWeek.fold<double>(
            0,
            (sum, w) => sum + w.totalVolume,
          );
          final lastWeekVolume = lastWeek.fold<double>(
            0,
            (sum, w) => sum + w.totalVolume,
          );

          final volumeDeltaPercent = lastWeekVolume > 0
              ? ((thisWeekVolume - lastWeekVolume) / lastWeekVolume * 100)
              : 0.0;

          final prsThisWeek = allPrs
              .where((pr) => pr.achievedAt.isAfter(thisWeekStart))
              .length;

          final adherenceScore = ((thisWeek.length / weeklyTarget) * 100)
              .clamp(0, 130)
              .round();
          final adherenceStatus = adherenceScore >= 100
              ? 'on_track'
              : adherenceScore >= 70
              ? 'warning'
              : 'critical';

          final adjustments = <String>[
            if (thisWeek.length < weeklyTarget)
              'Manca ${weeklyTarget - thisWeek.length} sessione questa settimana: aggiungi 1 workout breve (20-35 min) entro 48 ore.',
            if (volumeDeltaPercent > 20)
              'Volume in forte aumento (${volumeDeltaPercent.toStringAsFixed(0)}%): valuta -5/-10% carico su 1 seduta per gestire la fatica.',
            if (volumeDeltaPercent < -20)
              'Volume in calo (${volumeDeltaPercent.toStringAsFixed(0)}%): reintroduci 2-4 set totali sui gruppi prioritari.',
            if (prsThisWeek == 0 && thisWeek.length >= 3)
              'Nessun PR questa settimana: usa micro-progressione (+1 rep o +2.5kg) sul tuo fondamentale principale.',
            if (prsThisWeek > 0)
              'Hai $prsThisWeek PR questa settimana: consolida il carico prima del prossimo incremento.',
          ];

          if (adjustments.isEmpty) {
            adjustments.add(
              'Settimana stabile: mantieni struttura e applica progressione graduale sul prossimo allenamento.',
            );
          }

          final motivation = adherenceScore >= 100
              ? 'Ottima aderenza: stai costruendo consistenza reale.'
              : adherenceScore >= 70
              ? 'Buona base: con una seduta in più torni pienamente in target.'
              : 'Priorità adesso: semplificare il piano, non perfezionarlo.';

          return jsonEncode({
            'period': {
              'thisWeekStart':
                  thisWeekStart.toIso8601String().substring(0, 10),
              'lastWeekStart':
                  lastWeekStart.toIso8601String().substring(0, 10),
            },
            'weeklyTarget': weeklyTarget,
            'thisWeek': {
              'workouts': thisWeek.length,
              'volume': thisWeekVolume.round(),
              'prs': prsThisWeek,
            },
            'lastWeek': {
              'workouts': lastWeek.length,
              'volume': lastWeekVolume.round(),
            },
            'volumeDeltaPercent': volumeDeltaPercent.toStringAsFixed(1),
            'adherenceScore': adherenceScore,
            'adherenceStatus': adherenceStatus,
            'adjustments': adjustments.take(3).toList(),
            'motivation': motivation,
            'suggestions': <String>[
              'Fammi il piano per i prossimi 3 giorni',
              'Adatta il prossimo workout in base al recupero',
              'Analizza la progressione del mio esercizio principale',
            ],
            'toolName': 'getWeeklyCheckin',
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getWeeklyCheckin',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getWeeklyCheckin',
      });
    }
  }

  Future<String> getAutoProgressionPlan(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final rawExerciseName = args['exerciseName'] as String?;
    if (rawExerciseName == null || rawExerciseName.trim().isEmpty) {
      return jsonEncode({
        'error': 'Missing required parameter: exerciseName',
        'toolName': 'getAutoProgressionPlan',
      });
    }

    final exerciseName = h.normalizeString(rawExerciseName);
    final repsMinRaw = args['targetRepsMin'];
    final repsMaxRaw = args['targetRepsMax'];
    final targetRepsMin = repsMinRaw is num
        ? repsMinRaw.toInt()
        : int.tryParse(repsMinRaw?.toString() ?? '6') ?? 6;
    final targetRepsMax = repsMaxRaw is num
        ? repsMaxRaw.toInt()
        : int.tryParse(repsMaxRaw?.toString() ?? '10') ?? 10;

    try {
      final historyResult = await analyticsRepo.getExerciseHistoryByName(
        userId: userId,
        exerciseName: exerciseName,
      );

      return await historyResult.fold(
        (failure) async {
          final searchResult = await analyticsRepo.searchExercises(
            userId: userId,
            query: exerciseName,
          );

          return searchResult.fold(
            (_) => jsonEncode({
              'error': 'Exercise "$exerciseName" not found in your data',
              'toolName': 'getAutoProgressionPlan',
            }),
            (matches) async {
              if (matches.isEmpty) {
                return jsonEncode({
                  'error': 'Exercise "$exerciseName" not found in your data',
                  'toolName': 'getAutoProgressionPlan',
                });
              }

              final bestMatch = matches.first;
              final retryResult = await analyticsRepo.getExerciseHistoryByName(
                userId: userId,
                exerciseName: bestMatch.exerciseName,
              );
              return retryResult.fold(
                (_) => jsonEncode({
                  'error':
                      'No progression data for "${bestMatch.exerciseName}"',
                  'toolName': 'getAutoProgressionPlan',
                }),
                (exerciseHistory) => _buildAutoProgressionPlan(
                  exerciseHistory: exerciseHistory,
                  targetRepsMin: targetRepsMin,
                  targetRepsMax: targetRepsMax,
                ),
              );
            },
          );
        },
        (exerciseHistory) => _buildAutoProgressionPlan(
          exerciseHistory: exerciseHistory,
          targetRepsMin: targetRepsMin,
          targetRepsMax: targetRepsMax,
        ),
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getAutoProgressionPlan',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getAutoProgressionPlan',
      });
    }
  }

  String _buildAutoProgressionPlan({
    required dynamic exerciseHistory,
    required int targetRepsMin,
    required int targetRepsMax,
  }) {
    final sessions = exerciseHistory.sessionsSortedByDate;
    if (sessions.length < 2) {
      return jsonEncode({
        'exerciseName': exerciseHistory.exerciseName,
        'message':
            'Dati insufficienti per autoregolazione robusta (servono almeno 2 sessioni).',
        'recommendation':
            'Completa altre sessioni mantenendo range $targetRepsMin-$targetRepsMax.',
        'toolName': 'getAutoProgressionPlan',
      });
    }

    final latest = sessions[0];
    final previous = sessions[1];
    final older = sessions.length >= 3 ? sessions[2] : null;

    final latestTopWeight = latest.maxWeight;
    final latestTopReps = latest.maxReps;
    final latest1Rm = latest.highestEstimated1RM;
    final previous1Rm = previous.highestEstimated1RM;
    final trend1Rm = latest1Rm - previous1Rm;
    final trend3Session = older != null
        ? latest1Rm - older.highestEstimated1RM
        : trend1Rm;

    final lowerMuscle = exerciseHistory.muscleGroup.toLowerCase();
    final isLowerBody =
        lowerMuscle.contains('leg') ||
        lowerMuscle.contains('gamb') ||
        lowerMuscle.contains('quad') ||
        lowerMuscle.contains('glute');
    final loadStep = isLowerBody ? 5.0 : 2.5;

    String action;
    String rationale;
    double suggestedTopWeight = latestTopWeight;
    String suggestedRepRange = '$targetRepsMin-$targetRepsMax';
    int suggestedSetsDelta = 0;
    bool suggestDeload = false;

    if (trend1Rm > 1.5 && latestTopReps >= targetRepsMax) {
      action = 'increase_load';
      suggestedTopWeight = (latestTopWeight + loadStep);
      rationale =
          'Trend positivo e rep target raggiunte: aumenta il carico in modo conservativo.';
    } else if (trend1Rm >= 0 && latestTopReps < targetRepsMax) {
      action = 'add_reps';
      rationale =
          'Carico stabile con margine reps: priorita a 1-2 ripetizioni in piu prima di aumentare peso.';
    } else if (trend3Session.abs() < 1.0) {
      action = 'plateau_adjustment';
      suggestedSetsDelta = 1;
      suggestedRepRange = '${targetRepsMin + 1}-${targetRepsMax + 2}';
      rationale =
          'Plateau su 3 sessioni: aggiungi un set tecnico o varia il range reps per sbloccare progressione.';
    } else if (trend1Rm < -3.0) {
      action = 'deload';
      suggestDeload = true;
      suggestedTopWeight = (latestTopWeight * 0.9);
      suggestedRepRange = '${targetRepsMin + 2}-${targetRepsMax + 3}';
      rationale =
          'Trend in calo marcato: consigliato mini-deload (-10%) per recuperare performance.';
    } else {
      action = 'maintain';
      rationale =
          'Progressione neutra: mantieni carico e punta a consolidare tecnica e consistenza.';
    }

    final confidence = sessions.length >= 4
        ? 'high'
        : sessions.length >= 3
        ? 'medium'
        : 'low';

    return jsonEncode({
      'exerciseName': exerciseHistory.exerciseName,
      'muscleGroup': exerciseHistory.muscleGroup,
      'recentMetrics': {
        'latestTopWeight': latestTopWeight.toStringAsFixed(1),
        'latestTopReps': latestTopReps,
        'latestEstimated1RM': latest1Rm.toStringAsFixed(1),
        'previousEstimated1RM': previous1Rm.toStringAsFixed(1),
        'trend1RM': trend1Rm.toStringAsFixed(1),
      },
      'autoProgression': {
        'action': action,
        'suggestedTopWeight': suggestedTopWeight.toStringAsFixed(1),
        'suggestedRepRange': suggestedRepRange,
        'suggestedSetsDelta': suggestedSetsDelta,
        'deload': suggestDeload,
        'confidence': confidence,
        'rationale': rationale,
      },
      'toolName': 'getAutoProgressionPlan',
    });
  }

  Future<String> getAdherenceInsights(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final workoutsEither = await historyRepo.getWorkouts();
      final state = await h.loadOnboardingState(onboardingState);
      final weeklyTarget = (state?.weeklyWorkoutTarget ?? 3).clamp(2, 7);

      return workoutsEither.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch workouts: ${failure.message}',
          'toolName': 'getAdherenceInsights',
        }),
        (workouts) {
          final now = DateTime.now();
          final last28Days = now.subtract(const Duration(days: 28));
          final recent =
              workouts.where((w) => w.completedAt.isAfter(last28Days)).toList()
                ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

          const weeksObserved = 4.0;
          final targetTotal = weeklyTarget * weeksObserved;
          final adherencePercent = ((recent.length / targetTotal) * 100)
              .clamp(0, 120)
              .round();

          int longestGapDays = 0;
          for (var i = 1; i < recent.length; i++) {
            final gap = recent[i].completedAt
                .difference(recent[i - 1].completedAt)
                .inDays;
            if (gap > longestGapDays) longestGapDays = gap;
          }

          final riskLevel = adherencePercent >= 85
              ? 'low'
              : adherencePercent >= 60
              ? 'medium'
              : 'high';

          final barrierGuess = longestGapDays >= 5
              ? 'routine_fragile'
              : (recent.length < (weeklyTarget * 2)
                    ? 'time_constraint'
                    : 'load_management');

          final actionPlan = <String>[
            if (riskLevel != 'low')
              'Riduci frizione: prepara una versione "giorno difficile" da 20-30 minuti.',
            if (barrierGuess == 'time_constraint')
              'Programma finestre fisse brevi (es. 30 min) invece di sessioni perfette.',
            if (barrierGuess == 'routine_fragile')
              'Ancora l\'allenamento a un trigger stabile (stesso orario/giorno) per 2 settimane.',
            if (riskLevel == 'low')
              'Aderenza solida: mantieni la struttura e aggiungi solo micro-progressioni.',
          ];

          final motivation = riskLevel == 'low'
              ? 'Stai costruendo un\'abitudine robusta: continua cosi.'
              : riskLevel == 'medium'
              ? 'Se semplifichi 1-2 sessioni a settimana, la continuita risale rapidamente.'
              : 'Obiettivo ora: essere costante, non perfetto. Anche sessioni brevi contano.';

          return jsonEncode({
            'periodDays': 28,
            'weeklyTarget': weeklyTarget,
            'workoutsCompleted': recent.length,
            'adherencePercent': adherencePercent,
            'longestGapDays': longestGapDays,
            'riskLevel': riskLevel,
            'likelyBarrier': barrierGuess,
            'actionPlan': actionPlan,
            'motivation': motivation,
            'suggestions': <String>[
              'Crea un workout da 20 minuti per i giorni difficili',
              'Pianifica 3 sedute realistiche per questa settimana',
              'Fammi il check settimanale',
            ],
            'toolName': 'getAdherenceInsights',
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getAdherenceInsights',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getAdherenceInsights',
      });
    }
  }
}
