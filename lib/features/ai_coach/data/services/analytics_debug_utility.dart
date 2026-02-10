/// Analytics Debug Utility
///
/// Utility per verificare i dati analytics e diagnosticare
/// problemi con l'AI Coach.
///
/// **Usage**:
/// ```dart
/// // In debug screen or console
/// await AnalyticsDebugUtility.debugExerciseAnalytics(
///   analyticsRepo: ref.read(analyticsRepositoryProvider),
///   userId: user.uid,
///   exerciseQuery: 'panca',
/// );
/// ```
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/analytics_repository.dart';

/// Debug utility for analytics data inspection
class AnalyticsDebugUtility {
  AnalyticsDebugUtility._();

  /// Debug exercise analytics data
  ///
  /// Prints detailed information about exercise history,
  /// sessions, and calculated 1RM values.
  ///
  /// [analyticsRepo] - The analytics repository
  /// [userId] - User ID to query
  /// [exerciseQuery] - Exercise name to search (case-insensitive)
  static Future<String> debugExerciseAnalytics({
    required AnalyticsRepository analyticsRepo,
    required String userId,
    required String exerciseQuery,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('=' * 60);
    buffer.writeln('🔍 ANALYTICS DEBUG - Exercise: "$exerciseQuery"');
    buffer.writeln('   User ID: $userId');
    buffer.writeln('=' * 60);

    try {
      // 1. Search for exercises matching query
      final searchResult = await analyticsRepo.searchExercises(
        userId: userId,
        query: exerciseQuery,
      );

      await searchResult.fold(
        (failure) async {
          buffer.writeln('❌ Search failed: ${failure.message}');
        },
        (matches) async {
          buffer.writeln('\n📋 Found ${matches.length} matching exercises:');

          if (matches.isEmpty) {
            buffer.writeln('   ⚠️ No exercises found matching "$exerciseQuery"');
            buffer.writeln('\n   Possible causes:');
            buffer.writeln('   1. Analytics collection is empty');
            buffer.writeln('   2. Exercise name is different in database');
            buffer.writeln('   3. Workout was not saved correctly');
            return;
          }

          // 2. For each match, show detailed info
          for (final history in matches) {
            buffer.writeln('\n${"─" * 50}');
            buffer.writeln('📊 Exercise: "${history.exerciseName}"');
            buffer.writeln('   ID: ${history.exerciseId}');
            buffer.writeln('   Muscle Group: ${history.muscleGroup}');
            buffer.writeln('   Total Sessions: ${history.sessions.length}');
            buffer.writeln('   Personal Record (all-time 1RM): ${history.personalRecord.toStringAsFixed(1)} kg');

            // 3. Show all sessions
            if (history.sessions.isEmpty) {
              buffer.writeln('   ⚠️ No sessions recorded!');
            } else {
              buffer.writeln('\n   📅 Sessions (newest first):');

              final sortedSessions = [...history.sessions]
                ..sort((a, b) => b.date.compareTo(a.date));

              for (var i = 0; i < sortedSessions.length && i < 10; i++) {
                final session = sortedSessions[i];
                final daysAgo = DateTime.now().difference(session.date).inDays;

                buffer.writeln('   ┌─ Session ${i + 1}: ${_formatDate(session.date)} ($daysAgo days ago)');
                buffer.writeln('   │  Sets: ${session.sets.length}');
                buffer.writeln('   │  Max Weight: ${session.maxWeight.toStringAsFixed(1)} kg');
                buffer.writeln('   │  Total Volume: ${session.totalVolume.toStringAsFixed(0)} kg');
                buffer.writeln('   │  Highest Est. 1RM: ${session.highestEstimated1RM.toStringAsFixed(1)} kg');

                // Show individual sets
                for (var j = 0; j < session.sets.length; j++) {
                  final set = session.sets[j];
                  final est1RM = set.estimatedOneRM;
                  buffer.writeln('   │    Set ${j + 1}: ${set.weight.toStringAsFixed(1)}kg x ${set.reps} reps → Est. 1RM: ${est1RM.toStringAsFixed(1)} kg');
                }
                buffer.writeln('   └─');
              }

              if (sortedSessions.length > 10) {
                buffer.writeln('   ... and ${sortedSessions.length - 10} more sessions');
              }
            }

            // 4. Test timeframe filtering (last 12 weeks)
            buffer.writeln('\n   🕐 Timeframe Filter Test (last 12 weeks):');
            final endDate = DateTime.now();
            final startDate = endDate.subtract(const Duration(days: 84));
            final filteredSessions = history.getSessionsByTimeframe(startDate, endDate);
            buffer.writeln('   Filtered sessions: ${filteredSessions.length}');

            if (filteredSessions.isEmpty && history.sessions.isNotEmpty) {
              buffer.writeln('   ⚠️ WARNING: Sessions exist but filter returns empty!');
              buffer.writeln('   Filter range: ${_formatDate(startDate)} → ${_formatDate(endDate)}');

              // Check why filtering fails
              for (final session in history.sessions) {
                final isAfterStart = session.date.isAfter(startDate);
                final isBeforeEnd = session.date.isBefore(endDate);
                buffer.writeln('   Session ${_formatDate(session.date)}: '
                    'isAfter(start)=$isAfterStart, isBefore(end)=$isBeforeEnd');
              }
            }
          }
        },
      );

      // 5. List all exercises in analytics collection
      buffer.writeln('\n${"=" * 60}');
      buffer.writeln('📚 ALL EXERCISES IN ANALYTICS COLLECTION:');

      final allExercisesStream = analyticsRepo.getExerciseHistory(userId);
      await allExercisesStream.first.then((result) {
        result.fold(
          (failure) {
            buffer.writeln('   ❌ Failed to fetch: ${failure.message}');
          },
          (allExercises) {
            if (allExercises.isEmpty) {
              buffer.writeln('   ⚠️ Analytics collection is EMPTY!');
              buffer.writeln('   This means no workouts have been synced to analytics.');
            } else {
              buffer.writeln('   Total exercises: ${allExercises.length}');
              for (final ex in allExercises.take(20)) {
                buffer.writeln('   • "${ex.exerciseName}" - ${ex.sessions.length} sessions');
              }
              if (allExercises.length > 20) {
                buffer.writeln('   ... and ${allExercises.length - 20} more');
              }
            }
          },
        );
      }).timeout(const Duration(seconds: 10));

    } catch (e, st) {
      buffer.writeln('\n❌ Debug failed with exception:');
      buffer.writeln('   Error: $e');
      buffer.writeln('   Stack: $st');
    }

    buffer.writeln('\n${"=" * 60}');

    final output = buffer.toString();

    // Print to debug console
    if (kDebugMode) {
      debugPrint(output);
    }

    return output;
  }

  /// Format date as YYYY-MM-DD HH:mm
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Validate 1RM calculation
  ///
  /// Tests the Epley formula with given weight and reps
  static String validate1RMCalculation({
    required double weight,
    required int reps,
  }) {
    // Epley formula: 1RM = (weight × reps / 37.5) + weight
    final estimated1RM = reps == 1
        ? weight
        : (weight * reps / 37.5) + weight;

    return '''
🧮 1RM CALCULATION VALIDATION
   Weight: ${weight.toStringAsFixed(1)} kg
   Reps: $reps
   ─────────────────────────
   Formula: 1RM = (weight × reps / 37.5) + weight
   Calculation: (${weight.toStringAsFixed(1)} × $reps / 37.5) + ${weight.toStringAsFixed(1)}
              = ${(weight * reps / 37.5).toStringAsFixed(2)} + ${weight.toStringAsFixed(1)}
              = ${estimated1RM.toStringAsFixed(1)} kg
   ─────────────────────────
   ESTIMATED 1RM: ${estimated1RM.toStringAsFixed(1)} kg
''';
  }

  /// Quick check for AI Coach data availability
  static Future<Map<String, dynamic>> quickCheck({
    required AnalyticsRepository analyticsRepo,
    required String userId,
  }) async {
    final result = <String, dynamic>{
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'analyticsAvailable': false,
      'exerciseCount': 0,
      'exercises': <String>[],
      'errors': <String>[],
    };

    try {
      final stream = analyticsRepo.getExerciseHistory(userId);
      await stream.first.then((either) {
        either.fold(
          (failure) {
            result['errors'] = ['Failed to fetch: ${failure.message}'];
          },
          (exercises) {
            result['analyticsAvailable'] = exercises.isNotEmpty;
            result['exerciseCount'] = exercises.length;
            result['exercises'] = exercises
                .map((e) => '${e.exerciseName} (${e.sessions.length} sessions)')
                .toList();
          },
        );
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      result['errors'] = ['Exception: $e'];
    }

    if (kDebugMode) {
      debugPrint('🔍 Analytics Quick Check:');
      debugPrint(const JsonEncoder.withIndent('  ').convert(result));
    }

    return result;
  }
}
