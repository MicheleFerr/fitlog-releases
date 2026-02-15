/// AI Tool Executor Service
///
/// Executes tools called by the AI assistant.
/// Implements 10 tools for accessing user analytics data.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/workout_analytics_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/pr_tracker.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/streak/data/repositories/streak_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:uuid/uuid.dart';

/// Executes AI function calls and returns results
class AIToolExecutor {
  AIToolExecutor({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.workoutAnalyticsRepo,
    required this.streakRepo,
    this.measurementRepo,
    this.templateRepo,
    this.locale,
    ExerciseSearchService? exerciseSearchService,
  }) : exerciseSearchService = exerciseSearchService ?? ExerciseSearchService();

  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepositoryEnhanced historyRepo;
  final WorkoutAnalyticsRepository workoutAnalyticsRepo;
  final StreakRepository streakRepo;
  final MeasurementRepository? measurementRepo;
  final TemplateRepository? templateRepo;
  final ExerciseSearchService exerciseSearchService;

  /// User's locale for localized exercise names
  final Locale? locale;

  /// Normalize string from AI (handles unicode escapes like \u00b0 → °)
  ///
  /// Some AI models return unicode escape sequences as literal strings.
  /// This method converts them to their actual characters.
  String _normalizeString(String input) {
    // Pattern matches \uXXXX unicode escape sequences
    final unicodePattern = RegExp(r'\\u([0-9a-fA-F]{4})');

    return input.replaceAllMapped(unicodePattern, (match) {
      final hexCode = match.group(1)!;
      final codePoint = int.parse(hexCode, radix: 16);
      return String.fromCharCode(codePoint);
    });
  }

  /// Execute a tool by name with given arguments
  ///
  /// Returns JSON-encoded string result
  Future<String> executeTool({
    required String toolName,
    required Map<String, dynamic> arguments,
    required String userId,
  }) async {
    switch (toolName) {
      case 'get1RMHistory':
        return await _get1RMHistory(arguments, userId);
      case 'getWeeklyVolume':
        return await _getWeeklyVolume(arguments, userId);
      case 'analyzeMuscleBalance':
        return await _analyzeMuscleBalance(arguments, userId);
      case 'getRecoveryData':
        return await _getRecoveryData(arguments, userId);
      case 'suggestWorkout':
        return await _suggestWorkout(arguments, userId);
      case 'compareToStandards':
        return await _compareToStandards(arguments, userId);
      case 'getWorkoutStats':
        return await _getWorkoutStats(arguments, userId);
      case 'getPersonalRecords':
        return await _getPersonalRecords(arguments, userId);
      case 'getStreak':
        return await _getStreak(arguments, userId);
      case 'getWorkoutHistory':
        return await _getWorkoutHistory(arguments, userId);
      case 'generateTemplate':
        return await _generateTemplate(arguments, userId);
      case 'getBodyProgress':
        return await _getBodyProgress(arguments, userId);
      case 'addBodyMeasurement':
        return await _addBodyMeasurement(arguments, userId);
      case 'getUserTemplates':
        return await _getUserTemplates(arguments, userId);
      case 'getTemplateDetails':
        return await _getTemplateDetails(arguments, userId);
      case 'searchExercises':
        return await _searchExercises(arguments, userId);
      case 'getAccessoryExercises':
        return await _getAccessoryExercises(arguments, userId);
      default:
        throw Exception('Unknown tool: $toolName');
    }
  }

  // ========== Existing Tool Implementations ==========

  Future<String> _get1RMHistory(Map<String, dynamic> args, String userId) async {
    final rawExerciseName = args['exerciseName'] as String?;

    // Handle weeksBack as either num or String (robust JSON parsing)
    final weeksBackRaw = args['weeksBack'];
    final weeksBack = weeksBackRaw is num
        ? weeksBackRaw.toInt()
        : int.tryParse(weeksBackRaw?.toString() ?? '12') ?? 12;

    if (rawExerciseName == null) {
      return jsonEncode({
        'error': 'Missing exerciseName parameter',
        'toolName': 'get1RMHistory',
      });
    }

    // Normalize unicode escapes (e.g., \u00b0 → °)
    final exerciseName = _normalizeString(rawExerciseName);
    debugPrint('[AI_TOOL] Normalized exercise name: "$rawExerciseName" → "$exerciseName"');

    try {
      // Try exact match first
      final result = await analyticsRepo.getExerciseHistoryByName(
        userId: userId,
        exerciseName: exerciseName,
      );

      return result.fold(
        (failure) async {
          // Exercise not found -> try case-insensitive match first
          debugPrint('[AI_TOOL] Exercise "$exerciseName" not found, trying case-insensitive match...');
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
              // Phase 2 Optimization: Smart matching with preference for exercises with data
              // 1. Try exact case-insensitive match
              // 2. If multiple matches, prefer ones with recent sessions
              // 3. If query is partial (e.g., "panca"), find best match containing it
              final normalizedSearch = exerciseName.toLowerCase().trim();

              // Sort matches: prefer those with sessions, then by name similarity
              final sortedMatches = [...matches]..sort((a, b) {
                final aHasSessions = a.sessions.isNotEmpty;
                final bHasSessions = b.sessions.isNotEmpty;

                // Prefer exercises with sessions
                if (aHasSessions && !bHasSessions) return -1;
                if (!aHasSessions && bHasSessions) return 1;

                // Among those with sessions, prefer exact name match
                final aExact = a.exerciseName.toLowerCase().trim() == normalizedSearch;
                final bExact = b.exerciseName.toLowerCase().trim() == normalizedSearch;
                if (aExact && !bExact) return -1;
                if (!aExact && bExact) return 1;

                // Prefer exercises with more recent sessions
                if (aHasSessions && bHasSessions) {
                  final aLatest = a.sessions.map((s) => s.date).reduce((a, b) => a.isAfter(b) ? a : b);
                  final bLatest = b.sessions.map((s) => s.date).reduce((a, b) => a.isAfter(b) ? a : b);
                  return bLatest.compareTo(aLatest); // Most recent first
                }

                return 0;
              });

              // Disambiguation: if 2+ exercises match with sessions and query is NOT exact
              final matchesWithSessions = sortedMatches.where((m) => m.sessions.isNotEmpty).toList();
              if (matchesWithSessions.length >= 2) {
                final isExactMatch = matchesWithSessions.any(
                  (m) => m.exerciseName.toLowerCase().trim() == normalizedSearch,
                );
                if (!isExactMatch) {
                  debugPrint('[AI_TOOL] 🔀 Disambiguation: ${matchesWithSessions.length} matches for "$exerciseName"');
                  return jsonEncode({
                    'disambiguation': true,
                    'query': exerciseName,
                    'options': matchesWithSessions.take(5).map((m) => {
                      'name': m.exerciseName,
                      'sessions': m.sessions.length,
                    }).toList(),
                    'suggestions': matchesWithSessions.take(5).map((m) => m.exerciseName).toList(),
                  });
                }
              }

              // Take best match (with sessions and most relevant)
              final caseInsensitiveMatch = sortedMatches.firstOrNull;

              if (caseInsensitiveMatch != null && caseInsensitiveMatch.sessions.isNotEmpty) {
                debugPrint('[AI_TOOL] 📦 Found best match: "${caseInsensitiveMatch.exerciseName}" (${caseInsensitiveMatch.sessions.length} sessions)');
                // Retry with correct name
                final retryResult = await analyticsRepo.getExerciseHistoryByName(
                  userId: userId,
                  exerciseName: caseInsensitiveMatch.exerciseName,
                );

                return retryResult.fold(
                  (retryFailure) => jsonEncode({
                    'error': 'Exercise "${caseInsensitiveMatch.exerciseName}" found but data unavailable',
                    'toolName': 'get1RMHistory',
                  }),
                  (exerciseHistory) {
                    final endDate = DateTime.now();
                    final startDate = endDate.subtract(Duration(days: weeksBack * 7));
                    final filteredSessions = exerciseHistory.getSessionsByTimeframe(startDate, endDate);

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
                      'personalRecord': exerciseHistory.personalRecord.toStringAsFixed(1),
                    });
                  },
                );
              }

              // No case-insensitive match found - return suggestions
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
          // Filter sessions by timeframe
          final endDate = DateTime.now();
          final startDate = endDate.subtract(Duration(days: weeksBack * 7));

          final filteredSessions = exerciseHistory.getSessionsByTimeframe(startDate, endDate);

          // Build 1RM history from sessions
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
            'personalRecord': exerciseHistory.personalRecord.toStringAsFixed(1),
          });
        },
      );
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
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

  Future<String> _getWeeklyVolume(Map<String, dynamic> args, String userId) async {
    final muscleGroup = args['muscleGroup'] as String?;

    // Handle weeksBack as either num or String (robust JSON parsing)
    final weeksBackRaw = args['weeksBack'];
    final weeksBack = weeksBackRaw is num
        ? weeksBackRaw.toInt()
        : int.tryParse(weeksBackRaw?.toString() ?? '4') ?? 4;

    try {
      // Get all exercise history from stream
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);
      // BUG FIX #2: Add timeout to prevent indefinite blocking
      final firstResult = await exerciseHistoryStream.first.timeout(
        const Duration(seconds: 10),
      );

      return firstResult.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch exercise history: ${failure.message}',
          'toolName': 'getWeeklyVolume',
        }),
        (exercises) {
          // Filter by muscle group if specified
          final filtered = muscleGroup != null
              ? exercises.where((e) =>
                  e.muscleGroup.toLowerCase() == muscleGroup.toLowerCase()).toList()
              : exercises;

          // Aggregate volume per week
          final now = DateTime.now();
          final weeklyVolume = <Map<String, dynamic>>[];

          for (var week = 0; week < weeksBack; week++) {
            final weekEnd = now.subtract(Duration(days: week * 7));
            final weekStart = weekEnd.subtract(const Duration(days: 7));

            double totalVolume = 0;
            int totalSets = 0;

            for (final exercise in filtered) {
              final sessions = exercise.getSessionsByTimeframe(weekStart, weekEnd);
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
      await FirebaseCrashlytics.instance.recordError(
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

  Future<String> _analyzeMuscleBalance(Map<String, dynamic> args, String userId) async {
    try {
      // Get all exercise history
      final exerciseHistoryStream = analyticsRepo.getExerciseHistory(userId);
      // BUG FIX #2: Add timeout to prevent indefinite blocking
      final firstResult = await exerciseHistoryStream.first.timeout(
        const Duration(seconds: 10),
      );

      return firstResult.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch exercise history: ${failure.message}',
          'toolName': 'analyzeMuscleBalance',
        }),
        (exercises) {
          // Analyze last 4 weeks
          final now = DateTime.now();
          final fourWeeksAgo = now.subtract(const Duration(days: 28));

          final muscleVolume = <String, double>{};
          final muscleFrequency = <String, int>{};

          for (final exercise in exercises) {
            final recentSessions = exercise.getSessionsByTimeframe(fourWeeksAgo, now);
            if (recentSessions.isEmpty) continue;

            final group = exercise.muscleGroup.toLowerCase();
            double volume = 0;
            for (final session in recentSessions) {
              volume += session.totalVolume;
            }

            muscleVolume[group] = (muscleVolume[group] ?? 0) + volume;
            muscleFrequency[group] = (muscleFrequency[group] ?? 0) + recentSessions.length;
          }

          // Calculate percentage distribution
          final totalVolume = muscleVolume.values.fold<double>(0, (a, b) => a + b);
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

          // Identify imbalances
          final sorted = balance.entries.toList()
            ..sort((a, b) => (b.value['volume'] as int).compareTo(a.value['volume'] as int));

          final overTrained = sorted.isNotEmpty ? sorted.first.key : null;
          final underTrained = sorted.length > 1 ? sorted.last.key : null;

          return jsonEncode({
            'balance': balance,
            'totalVolume': totalVolume.round(),
            'overTrained': overTrained,
            'underTrained': underTrained,
            'periodDays': 28,
          });
        },
      );
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
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

  Future<String> _getRecoveryData(Map<String, dynamic> args, String userId) async {
    try {
      final workoutsEither = await historyRepo.getWorkouts();

      return workoutsEither.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch workouts: ${failure.message}',
          'toolName': 'getRecoveryData',
        }),
        (workouts) {
          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 7));

          // Count workouts in last 7 days
          final recentWorkouts = workouts.where((w) {
            return w.completedAt.isAfter(sevenDaysAgo);
          }).toList();

          // BUG FIX #6: Sort explicitly instead of assuming ordering
          int daysSinceLastWorkout = -1;
          if (workouts.isNotEmpty) {
            final sorted = [...workouts]
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
            daysSinceLastWorkout = now.difference(sorted.first.completedAt).inDays;
          }

          // BUG FIX #5: Unified recovery thresholds (>=6 red, >=4 amber, <4 green)
          String recoveryStatus;
          if (recentWorkouts.length >= 6) {
            recoveryStatus = 'red'; // Overtraining risk
          } else if (recentWorkouts.length >= 4) {
            recoveryStatus = 'amber'; // High frequency
          } else {
            recoveryStatus = 'green'; // Optimal or low
          }

          return jsonEncode({
            'workoutsLast7Days': recentWorkouts.length,
            'daysSinceLastWorkout': daysSinceLastWorkout,
            'recoveryStatus': recoveryStatus,
            'recommendation': _getRecoveryRecommendation(recentWorkouts.length, daysSinceLastWorkout),
          });
        },
      );
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getRecoveryData',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getRecoveryData',
      });
    }
  }

  String _getRecoveryRecommendation(int workoutsLast7Days, int daysSinceLastWorkout) {
    if (daysSinceLastWorkout >= 4) {
      return 'Lungo periodo di riposo - pronto per allenamento intenso';
    }
    if (workoutsLast7Days >= 6) {
      return 'Frequenza alta - considera un giorno di riposo';
    }
    if (workoutsLast7Days >= 4) {
      return 'Frequenza buona - intensità moderata consigliata';
    }
    return 'Frequenza bassa-moderata - puoi aumentare intensità';
  }

  Future<String> _suggestWorkout(Map<String, dynamic> args, String userId) async {
    try {
      // BUG FIX #4: Read and use muscleGroup and difficulty from args
      final targetMuscle = args['muscleGroup'] as String?;
      final difficulty = args['difficulty'] as String?;

      // Get muscle balance data
      final balanceJson = await _analyzeMuscleBalance({}, userId);
      final balanceData = jsonDecode(balanceJson) as Map<String, dynamic>;

      // Get recovery data
      final recoveryJson = await _getRecoveryData({}, userId);
      final recoveryData = jsonDecode(recoveryJson) as Map<String, dynamic>;

      final underTrained = balanceData['underTrained'] as String?;
      final recoveryStatus = recoveryData['recoveryStatus'] as String? ?? 'green';
      final daysSinceLastWorkout = recoveryData['daysSinceLastWorkout'] as int? ?? -1;

      // Build suggestion
      String suggestedFocus;
      String intensity;

      if (recoveryStatus == 'red') {
        suggestedFocus = 'riposo o cardio leggero';
        intensity = 'molto leggera';
      } else if (recoveryStatus == 'amber') {
        // Use user-specified target if provided, otherwise underTrained
        suggestedFocus = targetMuscle ?? underTrained ?? 'full body';
        intensity = difficulty ?? 'moderata';
      } else {
        // Use user-specified target if provided, otherwise underTrained
        suggestedFocus = targetMuscle ?? underTrained ?? 'full body';
        intensity = difficulty ?? (daysSinceLastWorkout >= 3 ? 'alta' : 'moderata-alta');
      }

      return jsonEncode({
        'suggestedMuscleGroup': suggestedFocus,
        'intensity': intensity,
        'recoveryStatus': recoveryStatus,
        'underTrainedMuscle': underTrained,
        'daysSinceLastWorkout': daysSinceLastWorkout,
        'requestedMuscleGroup': targetMuscle,
        'requestedDifficulty': difficulty,
        'balance': balanceData['balance'],
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: suggestWorkout',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'suggestWorkout',
      });
    }
  }

  Future<String> _compareToStandards(Map<String, dynamic> args, String userId) async {
    final lift = args['lift'] as String?;

    // Handle numeric parameters as either num or String (robust JSON parsing)
    final weightRaw = args['weight'];
    final weight = weightRaw is num
        ? weightRaw.toDouble()
        : double.tryParse(weightRaw?.toString() ?? '0') ?? 0;

    final bodyWeightRaw = args['bodyWeight'];
    final bodyWeight = bodyWeightRaw is num
        ? bodyWeightRaw.toDouble()
        : double.tryParse(bodyWeightRaw?.toString() ?? '75') ?? 75;

    try {
      // BUG FIX #1: Guard against division by zero
      if (bodyWeight <= 0) {
        return jsonEncode({
          'error': 'bodyWeight must be > 0',
          'toolName': 'compareToStandards',
        });
      }

      final ratio = weight / bodyWeight;
      String level;

      if (ratio < 0.5) {
        level = 'Non allenato';
      } else if (ratio < 1.0) {
        level = 'Principiante';
      } else if (ratio < 1.5) {
        level = 'Novizio';
      } else if (ratio < 2.0) {
        level = 'Intermedio';
      } else if (ratio < 2.5) {
        level = 'Avanzato';
      } else {
        level = 'Elite';
      }

      return jsonEncode({
        'lift': lift ?? 'unknown',
        'weight': weight,
        'bodyWeight': bodyWeight,
        'ratio': ratio.toStringAsFixed(2),
        'level': level,
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: compareToStandards',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'compareToStandards',
      });
    }
  }

  // ========== New Tool Implementations ==========

  Future<String> _getWorkoutStats(Map<String, dynamic> args, String userId) async {
    try {
      final stats = await workoutAnalyticsRepo.getAnalyticsStats(userId);

      return jsonEncode({
        'totalWorkouts': stats.totalWorkouts,
        'totalPRs': stats.totalPRs,
        'averageWorkoutDuration': stats.averageWorkoutDuration.toStringAsFixed(1),
        'averageWorkoutVolume': stats.averageWorkoutVolume.toStringAsFixed(0),
        'totalVolumeLifted': stats.totalVolumeLifted.toStringAsFixed(0),
        'trainingConsistency': stats.trainingConsistency.toStringAsFixed(1),
        'mostFrequentExercise': stats.mostFrequentExercise,
        'highestVolumeExercise': stats.highestVolumeExercise,
        'firstWorkoutDate': stats.firstWorkoutDate?.toIso8601String(),
        'lastWorkoutDate': stats.lastWorkoutDate?.toIso8601String(),
        'topExercises': Map.fromEntries(
          stats.exerciseFrequency.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value))
            ..take(10),
        ),
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
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

  Future<String> _getPersonalRecords(Map<String, dynamic> args, String userId) async {
    final rawExerciseName = args['exerciseName'] as String?;
    // Normalize unicode escapes (e.g., \u00b0 → °)
    final exerciseName = rawExerciseName != null ? _normalizeString(rawExerciseName) : null;

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
                .where((pr) => pr.exerciseName.toLowerCase().contains(exerciseName.toLowerCase()))
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
      await FirebaseCrashlytics.instance.recordError(
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

  Future<String> _getStreak(Map<String, dynamic> args, String userId) async {
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
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getStreak',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getStreak',
      });
    }
  }

  Future<String> _getWorkoutHistory(Map<String, dynamic> args, String userId) async {
    // Handle daysBack and limit as either num or String
    final daysBackRaw = args['daysBack'];
    final daysBack = daysBackRaw is num
        ? daysBackRaw.toInt()
        : int.tryParse(daysBackRaw?.toString() ?? '7') ?? 7;

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
          final filtered = workouts
              .where((w) => w.completedAt.isAfter(cutoff))
              .toList()
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

          final limited = filtered.take(limit).toList();

          final history = limited.map((w) {
            return {
              'name': w.name,
              'completedAt': w.completedAt.toIso8601String(),
              'durationMinutes': w.duration.inMinutes,
              'exerciseCount': w.exercises.length,
              'exercises': w.exercises.map((e) => e.name).toList(),
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
      await FirebaseCrashlytics.instance.recordError(
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

  // ========== Template Generation ==========

  Future<String> _generateTemplate(Map<String, dynamic> args, String userId) async {
    final muscleGroup = args['muscleGroup'] as String? ?? 'full_body';
    final difficulty = args['difficulty'] as String? ?? 'intermediate';

    final durationRaw = args['durationMinutes'];
    final duration = durationRaw is num
        ? durationRaw.toInt()
        : int.tryParse(durationRaw?.toString() ?? '45') ?? 45;

    final equipment = args['equipment'] as String? ?? 'all';

    try {
      // 1. Determine exercise count by difficulty
      final exerciseCount = switch (difficulty) {
        'beginner' => 3,
        'intermediate' => 5,
        'advanced' => 6,
        _ => 4,
      };

      // 2. Determine sets/reps by difficulty
      final setsPerExercise = difficulty == 'beginner' ? 3 : 4;
      final repsRange = switch (difficulty) {
        'beginner' => '10-12',
        'intermediate' => '8-12',
        'advanced' => '6-10',
        _ => '8-12',
      };

      // 3. Search exercises from database using muscle group
      // This uses the JSON 'focus' field for anatomically correct results
      final allResults = await exerciseSearchService.searchExercises(muscleGroup, locale);

      // 4. Filter by equipment if specified
      final filteredResults = _filterByEquipment(allResults, equipment);

      // 5. Select diverse exercises (avoid duplicates and similar names)
      final selectedExercises = _selectDiverseExercises(filteredResults, exerciseCount);

      final exercises = selectedExercises.map((ex) {
        return {
          'name': ex.name,
          'category': ex.category.name,
          'muscles': ex.muscleGroups.take(2).toList(),
          'sets': setsPerExercise,
          'reps': repsRange,
          'restSeconds': _getRestForDifficulty(difficulty),
        };
      }).toList();

      // 6. Calculate estimated duration
      final estimatedMinutes = exercises.length * setsPerExercise * 2; // ~2 min per set

      return jsonEncode({
        'templateName': _generateTemplateName(muscleGroup, difficulty),
        'muscleGroup': muscleGroup,
        'difficulty': difficulty,
        'requestedDuration': duration,
        'estimatedDuration': estimatedMinutes,
        'exerciseCount': exercises.length,
        'exercises': exercises,
        'equipment': equipment,
        'notes': 'Piano generato dall\'AI Coach basato su scienza dello sport',
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: generateTemplate',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'generateTemplate',
      });
    }
  }

  /// Filter exercises by equipment type
  List<ExerciseDefinitionTemplate> _filterByEquipment(List<ExerciseDefinitionTemplate> exercises, String equipment) {
    if (equipment == 'all') return exercises;

    final equipmentKeywords = switch (equipment) {
      'bodyweight' || 'home' => ['corpo libero', 'bodyweight', 'nessuna', 'body weight'],
      'dumbbell' => ['manubri', 'dumbbell', 'manubrio'],
      'barbell' => ['bilanciere', 'barbell'],
      'cables' => ['cavi', 'cable', 'pulley'],
      _ => <String>[],
    };

    if (equipmentKeywords.isEmpty) return exercises;

    return exercises.where((ex) {
      final equipmentStr = ex.equipment.join(' ').toLowerCase();
      return equipmentKeywords.any((kw) => equipmentStr.contains(kw));
    }).toList();
  }

  /// Select diverse exercises avoiding similar names
  List<ExerciseDefinitionTemplate> _selectDiverseExercises(
    List<ExerciseDefinitionTemplate> exercises,
    int count,
  ) {
    if (exercises.length <= count) return exercises;

    final selected = <ExerciseDefinitionTemplate>[];
    final usedBaseNames = <String>{};

    for (final ex in exercises) {
      if (selected.length >= count) break;

      // Extract base name (first 2 words) to detect similar exercises
      final baseName = ex.name.toLowerCase().split(' ').take(2).join(' ');

      // Skip if we already have a similar exercise
      if (usedBaseNames.any((used) =>
          used.contains(baseName) ||
          baseName.contains(used) ||
          _areSimilarNames(used, baseName))) {
        continue;
      }

      selected.add(ex);
      usedBaseNames.add(baseName);
    }

    // If we couldn't get enough diverse exercises, fill with remaining
    if (selected.length < count) {
      for (final ex in exercises) {
        if (selected.length >= count) break;
        if (!selected.contains(ex)) {
          selected.add(ex);
        }
      }
    }

    return selected;
  }

  /// Check if two base names are similar (fuzzy match)
  bool _areSimilarNames(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;

    // Check if one contains the other
    if (a.contains(b) || b.contains(a)) return true;

    // Check word overlap
    final wordsA = a.split(' ').toSet();
    final wordsB = b.split(' ').toSet();
    final overlap = wordsA.intersection(wordsB).length;

    return overlap >= 1 && (overlap / wordsA.length > 0.5 || overlap / wordsB.length > 0.5);
  }

  /// Generate a descriptive template name
  String _generateTemplateName(String muscleGroup, String difficulty) {
    final groupName = switch (muscleGroup) {
      'chest' => 'Petto',
      'back' => 'Schiena',
      'legs' => 'Gambe',
      'shoulders' => 'Spalle',
      'arms' => 'Braccia',
      'push' => 'Push',
      'pull' => 'Pull',
      'upper' => 'Upper Body',
      'lower' => 'Lower Body',
      'full_body' => 'Full Body',
      _ => muscleGroup,
    };

    final levelName = switch (difficulty) {
      'beginner' => 'Principiante',
      'intermediate' => 'Intermedio',
      'advanced' => 'Avanzato',
      _ => difficulty,
    };

    return '$groupName - $levelName';
  }

  /// Get rest time based on difficulty
  int _getRestForDifficulty(String difficulty) {
    return switch (difficulty) {
      'beginner' => 90,
      'intermediate' => 75,
      'advanced' => 60,
      _ => 75,
    };
  }

  // ========== Body Measurements ==========

  Future<String> _getBodyProgress(Map<String, dynamic> args, String userId) async {
    if (measurementRepo == null) {
      return jsonEncode({
        'error': 'Body measurements not available',
        'toolName': 'getBodyProgress',
      });
    }

    final metricTypeStr = args['metricType'] as String?;
    final weeksBackRaw = args['weeksBack'];
    final weeksBackParsed = weeksBackRaw is num
        ? weeksBackRaw.toInt()
        : int.tryParse(weeksBackRaw?.toString() ?? '12') ?? 12;
    // Ensure positive value, default to 12 if invalid
    final weeksBack = weeksBackParsed > 0 ? weeksBackParsed : 12;

    try {
      final dateFrom = DateTime.now().subtract(Duration(days: weeksBack * 7));

      // Parse metric type if provided
      MetricType? filterType;
      if (metricTypeStr != null) {
        filterType = _parseMetricType(metricTypeStr);
        if (filterType == null) {
          return jsonEncode({
            'error': 'Tipo di misura non riconosciuto: $metricTypeStr',
            'suggestedTypes': ['peso', 'grasso', 'vita', 'petto', 'bicipite', 'coscia'],
            'toolName': 'getBodyProgress',
          });
        }
      }

      // Get measurements
      final result = await measurementRepo!.getMeasurements(
        userId,
        filterByType: filterType,
        dateFrom: dateFrom,
      );

      return result.fold(
        (failure) => jsonEncode({
          'error': 'Failed to fetch measurements',
          'toolName': 'getBodyProgress',
        }),
        (measurements) {
          if (measurements.isEmpty) {
            return jsonEncode({
              'message': 'Nessuna misurazione trovata nel periodo selezionato',
              'weeksBack': weeksBack,
              'toolName': 'getBodyProgress',
            });
          }

          // Group by metric type
          final byType = <String, List<Map<String, dynamic>>>{};
          for (final m in measurements) {
            final typeName = m.metricType.name;
            byType.putIfAbsent(typeName, () => []);
            byType[typeName]!.add({
              'value': m.value,
              'unit': m.unit,
              'date': m.timestamp.toIso8601String().substring(0, 10),
            });
          }

          // Sort each type by date and calculate progress
          final progress = <String, Map<String, dynamic>>{};
          for (final entry in byType.entries) {
            final sorted = entry.value..sort((a, b) =>
                (a['date'] as String).compareTo(b['date'] as String));

            final first = sorted.first;
            final last = sorted.last;
            final change = (last['value'] as double) - (first['value'] as double);
            final changePercent = first['value'] != 0
                ? (change / (first['value'] as double) * 100)
                : 0.0;

            progress[entry.key] = {
              'firstValue': first['value'],
              'lastValue': last['value'],
              'firstDate': first['date'],
              'lastDate': last['date'],
              'change': change.toStringAsFixed(1),
              'changePercent': changePercent.toStringAsFixed(1),
              'unit': first['unit'],
              'measurementCount': sorted.length,
            };
          }

          return jsonEncode({
            'progress': progress,
            'weeksBack': weeksBack,
            'totalMeasurements': measurements.length,
            'toolName': 'getBodyProgress',
          });
        },
      );
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: getBodyProgress',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getBodyProgress',
      });
    }
  }

  Future<String> _addBodyMeasurement(Map<String, dynamic> args, String userId) async {
    if (measurementRepo == null) {
      return jsonEncode({
        'error': 'Body measurements not available',
        'toolName': 'addBodyMeasurement',
      });
    }

    final metricTypeStr = args['metricType'] as String?;
    final valueRaw = args['value'];
    // Handle Italian decimal separator (comma → dot) and parse
    final value = valueRaw is num
        ? valueRaw.toDouble()
        : double.tryParse(
            valueRaw?.toString().replaceAll(',', '.') ?? '0',
          ) ?? 0;
    final unitRaw = args['unit'] as String?;
    final notes = args['notes'] as String?;

    if (metricTypeStr == null || value == 0) {
      return jsonEncode({
        'error': 'Missing required parameters: metricType and value',
        'toolName': 'addBodyMeasurement',
      });
    }

    try {
      // Parse metric type
      final metricType = _parseMetricType(metricTypeStr);
      if (metricType == null) {
        return jsonEncode({
          'error': 'Unknown metric type: $metricTypeStr',
          'supportedTypes': ['weight', 'bodyFatPercentage', 'leanMass',
            'waistCircumference', 'chestCircumference', 'bicepLeftCircumference',
            'bicepRightCircumference', 'thighLeftCircumference', 'thighRightCircumference'],
          'toolName': 'addBodyMeasurement',
        });
      }

      // Validate range
      final (minVal, maxVal) = metricType.validRange;
      if (value < minVal || value > maxVal) {
        return jsonEncode({
          'error': 'Value out of range for ${metricType.name}',
          'validRange': {'min': minVal, 'max': maxVal},
          'providedValue': value,
          'toolName': 'addBodyMeasurement',
        });
      }

      // Get previous measurement for comparison
      final previousResult = await measurementRepo!.getLatestMeasurementsByType(userId);
      double? previousValue;
      String? previousDate;

      previousResult.fold(
        (_) {},
        (latestMap) {
          final prev = latestMap[metricType];
          if (prev != null) {
            previousValue = prev.value;
            previousDate = prev.timestamp.toIso8601String().substring(0, 10);
          }
        },
      );

      // Create new measurement
      final unit = unitRaw ?? metricType.defaultUnit;
      final measurement = Measurement(
        id: const Uuid().v4(),
        userId: userId,
        metricType: metricType,
        value: value,
        unit: unit,
        timestamp: DateTime.now(),
        source: MeasurementSource.manual,
        notes: notes,
        createdAt: DateTime.now(),
      );

      // Save measurement
      final saveResult = await measurementRepo!.addMeasurement(
        measurement,
        hasConsent: true, // AI Coach assumes user consented by asking to save
      );

      return saveResult.fold(
        (failure) => jsonEncode({
          'error': 'Failed to save measurement',
          'toolName': 'addBodyMeasurement',
        }),
        (_) {
          final response = <String, dynamic>{
            'success': true,
            'saved': {
              'metricType': metricType.name,
              'value': value,
              'unit': unit,
              'date': DateTime.now().toIso8601String().substring(0, 10),
              'notes': notes,
            },
            'toolName': 'addBodyMeasurement',
          };

          // Add comparison if previous value exists
          if (previousValue != null) {
            final change = value - previousValue!;
            response['comparison'] = {
              'previousValue': previousValue,
              'previousDate': previousDate,
              'change': change.toStringAsFixed(1),
              'direction': change > 0 ? 'increased' : (change < 0 ? 'decreased' : 'unchanged'),
            };
          }

          return jsonEncode(response);
        },
      );
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: addBodyMeasurement',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'addBodyMeasurement',
      });
    }
  }

  /// Parse metric type string to MetricType enum
  /// Supports English and Italian names, handles typos and common variations
  MetricType? _parseMetricType(String typeStr) {
    final normalized = typeStr.toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '');

    return switch (normalized) {
      // Essential metrics
      'weight' || 'peso' || 'pesokg' => MetricType.weight,
      'bodyfatpercentage' || 'bodyfat' || 'grasso' || 'grassocorporeo' ||
      'percentualegrasso' || 'bf' || 'bf%' => MetricType.bodyFatPercentage,
      'leanmass' || 'massamagra' || 'muscolo' || 'massamuscolare' => MetricType.leanMass,
      'height' || 'altezza' || 'statura' => MetricType.height,
      'bmi' || 'imc' || 'indicemassacorporea' => MetricType.bmi,
      'bmr' || 'metabolismobasale' => MetricType.bmr,

      // Circumferences - Upper body
      'neckcircumference' || 'collo' || 'girocollo' => MetricType.neckCircumference,
      'shouldercircumference' || 'spalle' || 'girospalle' => MetricType.shoulderCircumference,
      'chestcircumference' || 'petto' || 'torace' || 'giropetto' => MetricType.chestCircumference,

      // Circumferences - Core
      'waistcircumference' || 'vita' || 'girovita' => MetricType.waistCircumference,
      'abdomencircumference' || 'addome' || 'pancia' || 'giroaddome' => MetricType.abdomenCircumference,
      'hipcircumference' || 'fianchi' || 'girofianchi' || 'glutei' => MetricType.hipCircumference,

      // Circumferences - Arms (bilateral)
      'bicepleftcircumference' || 'bicipitesinistro' || 'braccisinistro' => MetricType.bicepLeftCircumference,
      'biceprightcircumference' || 'bicipitedestro' || 'bracciodestro' => MetricType.bicepRightCircumference,
      'bicep' || 'bicipite' || 'braccio' => MetricType.bicepRightCircumference, // Default to right
      'forearmleftcircumference' || 'avambracciosinistro' => MetricType.forearmLeftCircumference,
      'forearmrightcircumference' || 'avambracciodestro' => MetricType.forearmRightCircumference,
      'forearm' || 'avambraccio' => MetricType.forearmRightCircumference, // Default to right

      // Circumferences - Legs (bilateral)
      'thighleftcircumference' || 'cosciasinistra' || 'gambasinistra' => MetricType.thighLeftCircumference,
      'thighrightcircumference' || 'cosciadestra' || 'gambadestra' => MetricType.thighRightCircumference,
      'thigh' || 'coscia' || 'gamba' || 'quadricipite' => MetricType.thighRightCircumference, // Default to right
      'calfleftcircumference' || 'polpacciosinistro' => MetricType.calfLeftCircumference,
      'calfrightcircumference' || 'polpacciodestro' => MetricType.calfRightCircumference,
      'calf' || 'polpaccio' => MetricType.calfRightCircumference, // Default to right

      // Vitals
      'bodytemperature' || 'temperatura' || 'temp' => MetricType.bodyTemperature,
      'watermass' || 'acqua' || 'idratazione' || 'acquacorporea' => MetricType.waterMass,
      'bonemass' || 'massaossea' || 'ossa' => MetricType.boneMass,

      _ => null,
    };
  }

  // ========== User Templates ==========

  Future<String> _getUserTemplates(Map<String, dynamic> args, String userId) async {
    if (templateRepo == null) {
      return jsonEncode({'error': 'Template repository not available'});
    }

    try {
      final templates = await templateRepo!.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({'message': 'Nessun template salvato', 'count': 0});
      }

      final category = args['category'] as String?;

      // Filter by category if provided
      final filtered = category != null
          ? templates.where((t) =>
              t.category.name.toLowerCase() == category.toLowerCase()).toList()
          : templates;

      if (filtered.isEmpty && category != null) {
        return jsonEncode({
          'message': 'Nessun template trovato per categoria "$category"',
          'availableCategories': templates.map((t) => t.category.name).toSet().toList(),
          'count': 0,
        });
      }

      final templateList = filtered.take(10).map((t) => {
        'name': t.name,
        'category': t.category.name,
        'exerciseCount': t.exercises.length,
        'targetMuscles': t.targetMuscles.take(3).toList(),
      }).toList();

      return jsonEncode({
        'templates': templateList,
        'count': templates.length,
        'showing': templateList.length,
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'getUserTemplates failed');
      return jsonEncode({'error': '$e'});
    }
  }

  Future<String> _getTemplateDetails(Map<String, dynamic> args, String userId) async {
    if (templateRepo == null) {
      return jsonEncode({'error': 'Template repository non disponibile'});
    }

    final templateName = args['templateName'] as String?;
    if (templateName == null || templateName.isEmpty) {
      return jsonEncode({'error': 'Nome template richiesto'});
    }

    try {
      final templates = await templateRepo!.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'suggestion': 'Crea prima un template di allenamento',
        });
      }

      // Find template by name (case-insensitive, partial match)
      final searchName = templateName.toLowerCase();
      final matchingTemplate = templates.firstWhereOrNull(
        (t) => t.name.toLowerCase().contains(searchName) ||
               searchName.contains(t.name.toLowerCase()),
      );

      if (matchingTemplate == null) {
        // Return available templates for suggestion
        final availableNames = templates.map((t) => t.name).take(5).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestion': 'Prova con uno di questi nomi: ${availableNames.join(", ")}',
        });
      }

      // Build detailed exercise list
      final exerciseDetails = matchingTemplate.exercises.map((ex) {
        // Get default sets info if available
        final setsCount = ex.sets.length;
        final repsInfo = setsCount > 0
            ? ex.sets.map((s) => s.reps).whereType<int>().toList()
            : <int>[];
        final avgReps = repsInfo.isNotEmpty
            ? (repsInfo.reduce((a, b) => a + b) / repsInfo.length).round()
            : null;

        return {
          'name': ex.name,
          'category': ex.category.name,
          'sets': setsCount,
          'reps': avgReps ?? 'non configurato',
          'restSeconds': ex.restTime ?? 'non configurato',
          'notes': ex.notes,
        };
      }).toList();

      // Calculate estimated duration
      final totalSets = matchingTemplate.exercises.fold<int>(
        0,
        (sum, ex) => sum + ex.sets.length,
      );
      final estimatedMinutes = totalSets * 2; // ~2 min per set

      return jsonEncode({
        'templateName': matchingTemplate.name,
        'category': matchingTemplate.category.name,
        'difficulty': matchingTemplate.difficultyLevel ?? 'non specificato',
        'targetMuscles': matchingTemplate.targetMuscles,
        'exerciseCount': matchingTemplate.exercises.length,
        'totalSets': totalSets,
        'estimatedDuration': matchingTemplate.estimatedDurationMinutes ?? estimatedMinutes,
        'exercises': exerciseDetails,
        'description': matchingTemplate.description,
        'requiredEquipment': matchingTemplate.requiredEquipment,
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'getTemplateDetails failed',
      );
      return jsonEncode({'error': '$e'});
    }
  }

  // ========== Exercise Search ==========

  Future<String> _searchExercises(Map<String, dynamic> args, String userId) async {
    final query = args['query'] as String?;
    if (query == null || query.isEmpty) {
      return jsonEncode({'error': 'Missing query parameter'});
    }

    final limitRaw = args['limit'];
    final limit = (limitRaw is num ? limitRaw.toInt() : 10).clamp(1, 20);

    try {
      final results = await exerciseSearchService.searchExercises(query, locale);
      if (results.isEmpty) {
        return jsonEncode({'message': 'Nessun esercizio trovato per "$query"'});
      }

      final exercises = results.take(limit).map((ex) => {
        'name': ex.name,
        'muscles': ex.muscleGroups.take(3).toList(),
        'equipment': ex.equipment.isNotEmpty ? ex.equipment.first : 'Nessuna',
      }).toList();

      return jsonEncode({
        'exercises': exercises,
        'count': results.length,
        'showing': exercises.length,
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, reason: 'searchExercises failed');
      return jsonEncode({'error': '$e'});
    }
  }

  // ========== Accessory Exercises ==========

  /// Get accessory exercises that target the same muscle groups as the main exercise.
  ///
  /// This ensures anatomically correct suggestions:
  /// - Bench press (chest) → chest exercises (dips, cable crossover)
  /// - Squat (legs) → leg exercises (leg press, lunges)
  /// - NEVER suggests leg exercises for chest lifts or vice versa
  Future<String> _getAccessoryExercises(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final rawExerciseName = args['exerciseName'] as String?;
    if (rawExerciseName == null || rawExerciseName.isEmpty) {
      return jsonEncode({
        'error': 'Missing exerciseName parameter',
        'toolName': 'getAccessoryExercises',
      });
    }

    final exerciseName = _normalizeString(rawExerciseName);
    final limitRaw = args['limit'];
    final limit = (limitRaw is num ? limitRaw.toInt() : 8).clamp(1, 15);

    try {
      // 1. Search for the main exercise to get its muscle groups
      final mainResults = await exerciseSearchService.searchExercises(exerciseName, locale);

      if (mainResults.isEmpty) {
        return jsonEncode({
          'error': 'Esercizio "$exerciseName" non trovato nel database',
          'suggestion': 'Prova con un nome diverso o più specifico',
          'toolName': 'getAccessoryExercises',
        });
      }

      // Get the best matching exercise
      final mainExercise = mainResults.first;
      final targetMuscles = mainExercise.muscleGroups;

      if (targetMuscles.isEmpty) {
        return jsonEncode({
          'error': 'Muscoli target non definiti per "$exerciseName"',
          'toolName': 'getAccessoryExercises',
        });
      }

      // 2. Search for exercises with the same primary muscle group
      final primaryMuscle = targetMuscles.first;
      final accessoryResults = await exerciseSearchService.searchExercises(primaryMuscle, locale);

      if (accessoryResults.isEmpty) {
        return jsonEncode({
          'mainExercise': mainExercise.name,
          'targetMuscles': targetMuscles,
          'accessories': <Map<String, dynamic>>[],
          'message': 'Nessun esercizio accessorio trovato per $primaryMuscle',
          'toolName': 'getAccessoryExercises',
        });
      }

      // 3. Filter out the main exercise and similar variants
      final filteredResults = accessoryResults.where((ex) {
        final exNameLower = ex.name.toLowerCase();
        final mainNameLower = mainExercise.name.toLowerCase();

        // Skip the main exercise itself
        if (exNameLower == mainNameLower) return false;

        // Skip very similar names (variants of same exercise)
        if (_areSimilarNames(exNameLower, mainNameLower)) return false;

        return true;
      }).toList();

      // 4. Select diverse exercises to avoid duplicates like "Panca Dumbbell" + "Panca Barbell"
      final diverseAccessories = _selectDiverseExercises(filteredResults, limit);

      final accessories = diverseAccessories.map((ex) {
        return {
          'name': ex.name,
          'muscles': ex.muscleGroups.take(3).toList(),
          'equipment': ex.equipment.isNotEmpty ? ex.equipment.first : 'Nessuna',
        };
      }).toList();

      return jsonEncode({
        'mainExercise': mainExercise.name,
        'targetMuscles': targetMuscles,
        'primaryMuscle': primaryMuscle,
        'accessories': accessories,
        'count': accessories.length,
        'note': 'Tutti gli accessori lavorano gli stessi muscoli del principale',
        'toolName': 'getAccessoryExercises',
      });
    } catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'AI Coach tool execution failed: getAccessoryExercises',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'getAccessoryExercises',
      });
    }
  }
}
