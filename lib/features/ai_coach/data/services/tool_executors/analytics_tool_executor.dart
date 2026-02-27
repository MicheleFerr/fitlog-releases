/// Analytics tool executor for AI Coach
///
/// Handles: get1RMHistory, getWeeklyVolume, analyzeMuscleBalance
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart'
    as h;

class AnalyticsToolExecutor {
  const AnalyticsToolExecutor({
    required this.analyticsRepo,
    this.historyDaysLimit,
  });

  final AnalyticsRepository analyticsRepo;
  final int? historyDaysLimit;

  // ------------------------------------------------------------------
  // get1RMHistory
  // ------------------------------------------------------------------

  Future<String> get1RMHistory(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final rawExerciseName = args['exerciseName'] as String?;

    final weeksBackRaw = args['weeksBack'];
    final maxWeeks = historyDaysLimit != null ? (historyDaysLimit! ~/ 7) : 999;
    final weeksBack =
        (weeksBackRaw is num
                ? weeksBackRaw.toInt()
                : int.tryParse(weeksBackRaw?.toString() ?? '12') ?? 12)
            .clamp(1, maxWeeks);

    if (rawExerciseName == null) {
      return jsonEncode({
        'error': 'Missing exerciseName parameter',
        'toolName': 'get1RMHistory',
      });
    }

    final exerciseName = h.normalizeString(rawExerciseName);
    h.debugLog(
      '[AI_TOOL] Normalized exercise name: "$rawExerciseName" -> "$exerciseName"',
    );

    try {
      final result = await analyticsRepo.getExerciseHistoryByName(
        userId: userId,
        exerciseName: exerciseName,
      );

      return result.fold(
        (failure) async {
          h.debugLog(
            '[AI_TOOL] Exercise "$exerciseName" not found, trying case-insensitive match...',
          );
          final searchResult = await analyticsRepo.searchExercises(
            userId: userId,
            query: exerciseName,
          );

          return searchResult.fold(
            (searchFailure) => jsonEncode({
              'error': 'Exercise "$exerciseName" not found in your data',
              'toolName': 'get1RMHistory',
            }),
            (matches) async {
              final normalizedSearch = exerciseName.toLowerCase().trim();

              final sortedMatches = [...matches]
                ..sort((a, b) {
                  final aHasSessions = a.sessions.isNotEmpty;
                  final bHasSessions = b.sessions.isNotEmpty;
                  if (aHasSessions && !bHasSessions) return -1;
                  if (!aHasSessions && bHasSessions) return 1;

                  final aExact =
                      a.exerciseName.toLowerCase().trim() == normalizedSearch;
                  final bExact =
                      b.exerciseName.toLowerCase().trim() == normalizedSearch;
                  if (aExact && !bExact) return -1;
                  if (!aExact && bExact) return 1;

                  if (aHasSessions && bHasSessions) {
                    final aLatest = a.sessions
                        .map((s) => s.date)
                        .reduce((a, b) => a.isAfter(b) ? a : b);
                    final bLatest = b.sessions
                        .map((s) => s.date)
                        .reduce((a, b) => a.isAfter(b) ? a : b);
                    return bLatest.compareTo(aLatest);
                  }
                  return 0;
                });

              final matchesWithSessions = sortedMatches
                  .where((m) => m.sessions.isNotEmpty)
                  .toList();
              if (matchesWithSessions.length >= 2) {
                final isExactMatch = matchesWithSessions.any(
                  (m) =>
                      m.exerciseName.toLowerCase().trim() == normalizedSearch,
                );
                if (!isExactMatch) {
                  h.debugLog(
                    '[AI_TOOL] Disambiguation: ${matchesWithSessions.length} matches for "$exerciseName"',
                  );
                  return jsonEncode({
                    'disambiguation': true,
                    'query': exerciseName,
                    'options': matchesWithSessions
                        .take(5)
                        .map(
                          (m) => {
                            'name': m.exerciseName,
                            'sessions': m.sessions.length,
                          },
                        )
                        .toList(),
                    'suggestions': matchesWithSessions
                        .take(5)
                        .map((m) => m.exerciseName)
                        .toList(),
                  });
                }
              }

              final caseInsensitiveMatch = sortedMatches.firstOrNull;

              if (caseInsensitiveMatch != null &&
                  caseInsensitiveMatch.sessions.isNotEmpty) {
                h.debugLog(
                  '[AI_TOOL] Found best match: "${caseInsensitiveMatch.exerciseName}" (${caseInsensitiveMatch.sessions.length} sessions)',
                );
                final retryResult = await analyticsRepo
                    .getExerciseHistoryByName(
                      userId: userId,
                      exerciseName: caseInsensitiveMatch.exerciseName,
                    );

                return retryResult.fold(
                  (retryFailure) => jsonEncode({
                    'error':
                        'Exercise "${caseInsensitiveMatch.exerciseName}" found but data unavailable',
                    'toolName': 'get1RMHistory',
                  }),
                  (exerciseHistory) {
                    final endDate = DateTime.now();
                    final startDate = endDate.subtract(
                      Duration(days: weeksBack * 7),
                    );
                    final filteredSessions = exerciseHistory
                        .getSessionsByTimeframe(startDate, endDate);

                    final history = filteredSessions.map((session) {
                      return {
                        'date': session.date.toIso8601String(),
                        'estimated1RM':
                            session.highestEstimated1RM.toStringAsFixed(1),
                        'maxWeight': session.maxWeight.toStringAsFixed(1),
                        'totalVolume':
                            session.totalVolume.toStringAsFixed(0),
                      };
                    }).toList();

                    return jsonEncode({
                      'exerciseName': exerciseHistory.exerciseName,
                      'muscleGroup': exerciseHistory.muscleGroup,
                      'weeksBack': weeksBack,
                      'history': history,
                      'count': history.length,
                      'personalRecord':
                          exerciseHistory.personalRecord.toStringAsFixed(1),
                    });
                  },
                );
              }

              final suggestionNames = matches
                  .map((e) => e.exerciseName)
                  .take(5)
                  .toList();

              return jsonEncode({
                'error': 'Exercise "$exerciseName" not found in your data',
                'suggestions': suggestionNames,
                'toolName': 'get1RMHistory',
              });
            },
          );
        },
        (exerciseHistory) {
          final endDate = DateTime.now();
          final startDate = endDate.subtract(Duration(days: weeksBack * 7));

          final filteredSessions = exerciseHistory.getSessionsByTimeframe(
            startDate,
            endDate,
          );

          final history = filteredSessions.map((session) {
            return {
              'date': session.date.toIso8601String(),
              'estimated1RM': session.highestEstimated1RM.toStringAsFixed(1),
              'maxWeight': session.maxWeight.toStringAsFixed(1),
              'totalVolume': session.totalVolume.toStringAsFixed(0),
            };
          }).toList();

          return jsonEncode({
            'exerciseName': exerciseHistory.exerciseName,
            'muscleGroup': exerciseHistory.muscleGroup,
            'weeksBack': weeksBack,
            'history': history,
            'count': history.length,
            'personalRecord':
                exerciseHistory.personalRecord.toStringAsFixed(1),
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: get1RMHistory',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'get1RMHistory',
      });
    }
  }

  // ------------------------------------------------------------------
  // getWeeklyVolume
  // ------------------------------------------------------------------

  Future<String> getWeeklyVolume(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final muscleGroup = args['muscleGroup'] as String?;

    final weeksBackRaw = args['weeksBack'];
    final maxWeeks = historyDaysLimit != null ? (historyDaysLimit! ~/ 7) : 999;
    final weeksBack =
        (weeksBackRaw is num
                ? weeksBackRaw.toInt()
                : int.tryParse(weeksBackRaw?.toString() ?? '4') ?? 4)
            .clamp(1, maxWeeks);

    try {
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);
      final firstResult = await exerciseHistoryStream.first.timeout(
        const Duration(seconds: 10),
      );

      return firstResult.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch exercise history: ${failure.message}',
          'toolName': 'getWeeklyVolume',
        }),
        (exercises) {
          final filtered = muscleGroup != null
              ? exercises
                    .where(
                      (e) =>
                          e.muscleGroup.toLowerCase() ==
                          muscleGroup.toLowerCase(),
                    )
                    .toList()
              : exercises;

          final now = DateTime.now();
          final weeklyVolume = <Map<String, dynamic>>[];

          for (var week = 0; week < weeksBack; week++) {
            final weekEnd = now.subtract(Duration(days: week * 7));
            final weekStart = weekEnd.subtract(const Duration(days: 7));

            double totalVolume = 0;
            int totalSets = 0;

            for (final exercise in filtered) {
              final sessions = exercise.getSessionsByTimeframe(
                weekStart,
                weekEnd,
              );
              for (final session in sessions) {
                totalVolume += session.totalVolume;
                totalSets += session.sets.length;
              }
            }

            weeklyVolume.add({
              'week': week + 1,
              'weekStart': weekStart.toIso8601String().substring(0, 10),
              'volume': totalVolume.round(),
              'sets': totalSets,
            });
          }

          return jsonEncode({
            'muscleGroup': muscleGroup ?? 'all',
            'weeksBack': weeksBack,
            'weeklyVolume': weeklyVolume,
            'exerciseCount': filtered.length,
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getWeeklyVolume',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getWeeklyVolume',
      });
    }
  }

  // ------------------------------------------------------------------
  // analyzeMuscleBalance
  // ------------------------------------------------------------------

  Future<String> analyzeMuscleBalance(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);
      final firstResult = await exerciseHistoryStream.first.timeout(
        const Duration(seconds: 10),
      );

      return firstResult.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch exercise history: ${failure.message}',
          'toolName': 'analyzeMuscleBalance',
        }),
        (exercises) {
          final now = DateTime.now();
          final fourWeeksAgo = now.subtract(const Duration(days: 28));

          final muscleVolume = <String, double>{};
          final muscleFrequency = <String, int>{};

          for (final exercise in exercises) {
            final recentSessions = exercise.getSessionsByTimeframe(
              fourWeeksAgo,
              now,
            );
            if (recentSessions.isEmpty) continue;

            final group = h.canonicalMuscleGroup(exercise.muscleGroup);
            double volume = 0;
            for (final session in recentSessions) {
              volume += session.totalVolume;
            }

            muscleVolume[group] = (muscleVolume[group] ?? 0) + volume;
            muscleFrequency[group] =
                (muscleFrequency[group] ?? 0) + recentSessions.length;
          }

          final totalVolume = muscleVolume.values.fold<double>(
            0,
            (a, b) => a + b,
          );
          final balance = <String, Map<String, dynamic>>{};

          for (final entry in muscleVolume.entries) {
            final percentage = totalVolume > 0
                ? (entry.value / totalVolume * 100)
                : 0.0;
            balance[entry.key] = {
              'volume': entry.value.round(),
              'percentage': percentage.toStringAsFixed(1),
              'frequency': muscleFrequency[entry.key] ?? 0,
            };
          }

          var sortable = balance.entries
              .where((entry) => h.majorMuscleGroups.contains(entry.key))
              .toList();

          if (sortable.length < 2) {
            sortable = balance.entries
                .where((entry) => entry.key != 'other')
                .toList();
          }

          if (sortable.length < 2) {
            sortable = balance.entries.toList();
          }

          final sorted = sortable
            ..sort(
              (a, b) => (b.value['volume'] as int).compareTo(
                a.value['volume'] as int,
              ),
            );

          final overTrained = sorted.isNotEmpty ? sorted.first.key : null;
          final underTrained = sorted.length > 1 ? sorted.last.key : null;
          final suggestedExercises = switch (underTrained) {
            'back' => <String>[
              'Rematore bilanciere',
              'Lat machine',
              'Pulley basso',
            ],
            'chest' => <String>[
              'Panca piana',
              'Panca inclinata manubri',
              'Chest press',
            ],
            'legs' => <String>['Squat', 'Leg press', 'Romanian deadlift'],
            'shoulders' => <String>[
              'Military press',
              'Alzate laterali',
              'Face pull',
            ],
            'arms' => <String>[
              'Curl manubri',
              'Pushdown cavo',
              'French press',
            ],
            'core' => <String>[
              'Plank',
              'Crunch cavo',
              'Hanging leg raise',
            ],
            'glutes' => <String>[
              'Hip thrust',
              'Bulgarian split squat',
              'Glute bridge',
            ],
            _ => const <String>[],
          };
          final localizedBalance = <String, Map<String, dynamic>>{
            for (final entry in balance.entries)
              h.muscleGroupLabel(entry.key): entry.value,
          };

          return jsonEncode({
            'balance': balance,
            'balanceLocalized': localizedBalance,
            'totalVolume': totalVolume.round(),
            'overTrained': overTrained,
            'overTrainedLabel':
                overTrained != null ? h.muscleGroupLabel(overTrained) : null,
            'underTrained': underTrained,
            'underTrainedLabel':
                underTrained != null ? h.muscleGroupLabel(underTrained) : null,
            'suggestedExercises': suggestedExercises,
            'suggestions': suggestedExercises,
            'periodDays': 28,
          });
        },
      );
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: analyzeMuscleBalance',
      );
      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'analyzeMuscleBalance',
      });
    }
  }
}
