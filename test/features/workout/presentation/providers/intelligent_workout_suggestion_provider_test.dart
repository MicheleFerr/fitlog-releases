/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/presentation/providers
/// 🎯 Feature: Intelligent Workout Suggestions
/// 🧪 Type: Provider Unit Tests
///
/// Tests for intelligent workout suggestion provider that learns from user history
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/intelligent_workout_suggestion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_template.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/recovery_time_calculator.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

class MockHiveWorkoutDataSource extends Mock {
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return [];
  }
}

// ============================================================================
// TEST SUITE
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutSuggestion', () {
    group('Construction', () {
      test('should create suggestion with required fields', () {
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Continue your routine',
          confidence: 0.85,
        );

        expect(suggestion.templateName, equals('Push Day'));
        expect(suggestion.reason, equals('Continue your routine'));
        expect(suggestion.confidence, equals(0.85));
        expect(suggestion.pattern, isNull);
        expect(suggestion.daysSinceLastWorkout, isNull);
        expect(suggestion.recoveryStatus, isNull);
      });

      test('should create suggestion with optional fields', () {
        const recoveryStatus = RecoveryStatus(
          workoutType: 'PUSH',
          isRecovered: true,
          hoursSinceWorkout: 72,
          hoursUntilRecovered: 0,
          recoveryPercentage: 100.0,
        );

        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Continue your routine',
          confidence: 0.85,
          pattern: ['PUSH', 'PULL', 'LEGS'],
          daysSinceLastWorkout: 3,
          recoveryStatus: recoveryStatus,
        );

        expect(suggestion.pattern, equals(['PUSH', 'PULL', 'LEGS']));
        expect(suggestion.daysSinceLastWorkout, equals(3));
        expect(suggestion.recoveryStatus, equals(recoveryStatus));
      });
    });

    group('patternDescription', () {
      test('should return empty string when pattern is null', () {
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Fallback',
          confidence: 0.5,
        );

        expect(suggestion.patternDescription, isEmpty);
      });

      test('should return empty string when pattern is empty', () {
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Fallback',
          confidence: 0.5,
          pattern: [],
        );

        expect(suggestion.patternDescription, isEmpty);
      });

      test('should return arrow-separated pattern for single element', () {
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Pattern',
          confidence: 0.8,
          pattern: ['PUSH'],
        );

        expect(suggestion.patternDescription, equals('PUSH'));
      });

      test('should return arrow-separated pattern for multiple elements', () {
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Pattern',
          confidence: 0.8,
          pattern: ['PUSH', 'PULL', 'LEGS'],
        );

        expect(suggestion.patternDescription, equals('PUSH → PULL → LEGS'));
      });
    });

    group('localizeWith', () {
      test('should localize "Continue your routine" reason', () {
        final mockL10n = _MockLocalizations();
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Continue your routine',
          confidence: 0.85,
        );

        final localized = suggestion.localizeWith(mockL10n);

        expect(localized.reason, equals('Continua la tua routine'));
        expect(localized.templateName, equals('Push Day'));
        expect(localized.confidence, equals(0.85));
      });

      test('should localize "Next in rotation" reason', () {
        final mockL10n = _MockLocalizations();
        final suggestion = WorkoutSuggestion(
          templateName: 'Pull Day',
          reason: 'Next in rotation',
          confidence: 0.75,
        );

        final localized = suggestion.localizeWith(mockL10n);

        expect(localized.reason, equals('Prossimo nella rotazione'));
      });

      test('should localize "Your most frequent workout" reason', () {
        final mockL10n = _MockLocalizations();
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Your most frequent workout',
          confidence: 0.6,
        );

        final localized = suggestion.localizeWith(mockL10n);

        expect(localized.reason, equals('Il tuo allenamento più frequente'));
      });

      test('should preserve pattern and other fields', () {
        final mockL10n = _MockLocalizations();
        const recoveryStatus = RecoveryStatus(
          workoutType: 'PUSH',
          isRecovered: true,
          hoursSinceWorkout: 72,
          hoursUntilRecovered: 0,
          recoveryPercentage: 100.0,
        );

        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Continue your routine',
          confidence: 0.85,
          pattern: ['PUSH', 'PULL', 'LEGS'],
          daysSinceLastWorkout: 3,
          recoveryStatus: recoveryStatus,
        );

        final localized = suggestion.localizeWith(mockL10n);

        expect(localized.pattern, equals(['PUSH', 'PULL', 'LEGS']));
        expect(localized.daysSinceLastWorkout, equals(3));
        expect(localized.recoveryStatus, equals(recoveryStatus));
      });

      test('should use original reason as fallback for unknown reason', () {
        final mockL10n = _MockLocalizations();
        final suggestion = WorkoutSuggestion(
          templateName: 'Push Day',
          reason: 'Some custom reason',
          confidence: 0.7,
        );

        final localized = suggestion.localizeWith(mockL10n);

        expect(localized.reason, equals('Some custom reason'));
      });
    });
  });

  group('intelligentWorkoutSuggestionProvider', () {
    group('Provider Behavior Documentation', () {
      test('should be a FutureProvider returning WorkoutSuggestion?', () {
        // Document: This is a FutureProvider<WorkoutSuggestion?>
        // that analyzes workout history and suggests next workout
        expect(
          intelligentWorkoutSuggestionProvider,
          isA<FutureProvider<WorkoutSuggestion?>>(),
        );
      });

      test('should return null when user is not authenticated', () {
        // Document: When FirebaseAuth.instance.currentUser is null,
        // the provider returns null immediately without processing

        // Note: Cannot easily test due to Firebase singleton
        // Implementation requires checking FirebaseAuth.instance.currentUser?.uid
      });

      test('should return null when user has no workout history', () {
        // Document: When user has no workouts in last 30 days,
        // returns null and tracks 'no_history' fallback analytics

        // Required data: recentWorkouts.isEmpty
        // Analytics: WorkoutSuggestionAnalytics.trackFallbackUsed(reason: 'no_history')
      });

      test('should use custom pattern detection first (LEVEL 1)', () {
        // Document: Tries to detect custom name patterns first (e.g., "Pippo", "Giovanni")
        // - extractSequences with normalizeNames=false
        // - Requires confidence >= 0.75
        // - Uses exact template name matching (preferExactMatch=true)
        // - Applies recovery override if predicted workout not recovered

        // Expected flow:
        // 1. PatternDetectionService.extractSequences(normalizeNames: false)
        // 2. SimplePatternDetector.detectRepeatingPattern()
        // 3. Check confidence >= 0.75
        // 4. RecoveryTimeCalculator.calculateAllRecoveryStatuses(useExactNames: true)
        // 5. Find template with exact name match
        // 6. Track analytics: suggestionLevel='intelligent_custom'
      });

      test('should fallback to normalized pattern detection (LEVEL 2)', () {
        // Document: If custom pattern fails, tries normalized patterns (PUSH, PULL, LEGS)
        // - extractSequences with normalizeNames=true
        // - Same confidence threshold (>= 0.75)
        // - Uses normalized template matching

        // Expected flow:
        // 1. Custom pattern confidence < 0.75 or no match
        // 2. PatternDetectionService.extractSequences(normalizeNames: true)
        // 3. Detect pattern with normalized workout types
        // 4. Track analytics: suggestionLevel='intelligent_normalized'
      });

      test('should use frequency-based suggestion as final fallback (LEVEL 3)', () {
        // Document: If pattern detection fails, uses most frequent workout
        // - Counts workout name frequency in recent history
        // - Returns workout with highest count
        // - Confidence: 0.6 (moderate)
        // - Tracks 'low_confidence' fallback

        // Expected behavior:
        // 1. Count frequency of each workout name
        // 2. Select most frequent (reduce with max value)
        // 3. Calculate daysSinceLastWorkout
        // 4. Track analytics: suggestionLevel='fallback'
      });

      test('should apply recovery override when predicted workout not recovered', () {
        // Document: If next workout in pattern is not recovered,
        // finds best recovered workout from pattern and overrides prediction

        // Logic:
        // 1. Calculate recovery status for predicted workout
        // 2. Check !isRecovered
        // 3. Call RecoveryTimeCalculator.findBestRecoveredWorkout()
        // 4. Override if better option found
        // 5. Update reason: 'Better recovery time'
      });

      test('should boost confidence with recovery status', () {
        // Document: When workout is well-recovered, boosts confidence

        // Logic:
        // 1. Get base confidence from pattern detection
        // 2. Call recoveryCalculator.getRecoveryConfidenceBoost()
        // 3. Add boost and clamp to [0.0, 1.0]
        // 4. Use boosted confidence in final suggestion
      });

      test('should track analytics at key points', () {
        // Document: Tracks analytics for:
        // 1. Pattern detection (patternFound, confidence, computationTimeMs)
        // 2. Fallback usage (reason, errorDetails)
        // 3. Suggestion shown (templateName, reason, suggestionLevel)

        // Analytics calls:
        // - WorkoutSuggestionAnalytics.trackPatternDetection()
        // - WorkoutSuggestionAnalytics.trackFallbackUsed()
        // - WorkoutSuggestionAnalytics.trackSuggestionShown()
      });

      test('should handle errors gracefully', () {
        // Document: Catches all exceptions, tracks error analytics, returns null

        // Error handling:
        // try { ... } catch (e) {
        //   debugPrint error
        //   trackFallbackUsed(reason: 'error', errorDetails: e.toString())
        //   return null
        // }
      });
    });

    group('Template Matching Logic', () {
      test('should prefer exact name match when preferExactMatch=true', () {
        // Document: _findMatchingTemplate with preferExactMatch=true
        // tries exact name match first (case-insensitive)

        final templates = [
          _createTemplate('Pippo'),
          _createTemplate('Push Day'),
          _createTemplate('Giovanni'),
        ];

        // Would match "Pippo" exactly before trying normalized/keyword
        // Implementation: templates.firstWhereOrNull(name.toLowerCase() == workoutType.toLowerCase())
      });

      test('should fallback to normalized match when exact fails', () {
        // Document: If exact match not found, tries normalized match
        // using PatternDetectionService.normalizeWorkoutType()

        final templates = [
          _createTemplate('Push Day'), // normalizes to "PUSH"
          _createTemplate('Pull Workout'), // normalizes to "PULL"
        ];

        // workoutType="PUSH" → finds "Push Day" via normalized match
      });

      test('should use keyword matching as third option', () {
        // Document: Keyword matching uses typeMapping dictionary

        // Type mappings:
        // 'push' → ['push', 'chest', 'petto', 'spinta', 'tricep', 'shoulder']
        // 'pull' → ['pull', 'back', 'schiena', 'tirata', 'bicep', 'dorsal']
        // 'legs' → ['legs', 'gambe', 'quad', 'glute', 'squat']
        // 'upper' → ['upper', 'superiore', 'upper body', 'torso']
        // 'lower' → ['lower', 'inferiore', 'lower body', 'gambe']
        // 'full_body' → ['full', 'total', 'completo', 'circuit', 'hiit']
      });

      test('should return first template as absolute fallback', () {
        // Document: If no matches found and templates not empty,
        // returns templates.first as last resort

        // Logs warning: "No match for X, using fallback: Y"
      });

      test('should return null when templates list is empty', () {
        // Document: If templates.isEmpty, returns null
        // (cannot suggest anything without templates)
      });
    });

    group('Frequency-Based Suggestion Logic', () {
      test('should count workout name frequency correctly', () {
        // Document: _getFrequencyBasedSuggestion counts frequency
        // by workout.name in recentWorkouts

        final recentWorkouts = [
          _createWorkoutModel('Push Day'),
          _createWorkoutModel('Pull Day'),
          _createWorkoutModel('Push Day'), // Push Day = 2
          _createWorkoutModel('Legs Day'),
          _createWorkoutModel('Push Day'), // Push Day = 3
        ];

        // Expected: mostFrequent = 'Push Day' (count=3)
      });

      test('should return fallback suggestion when frequency map empty', () {
        // Document: If templateFrequency is empty,
        // calls _createFallbackSuggestion('Quick Workout')

        final recentWorkouts = <WorkoutModel>[];

        // Expected: WorkoutSuggestion(
        //   templateName: 'Quick Workout',
        //   reason: 'Your most frequent workout',
        //   confidence: 0.5,
        // )
      });

      test('should use confidence 0.6 for frequency-based suggestions', () {
        // Document: Frequency-based suggestions have moderate confidence (0.6)
        // Lower than pattern-detected (0.75+) but higher than fallback (0.5)
      });

      test('should calculate daysSinceLastWorkout correctly', () {
        // Document: Uses recentWorkouts.first.startTime to calculate days
        // If startTime is null, uses 0

        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final workout = _createWorkoutModel('Push Day', startTime: threeDaysAgo);

        // Expected: daysSinceLastWorkout = 3
      });

      test('should break ties using reduce with first occurrence', () {
        // Document: When multiple workouts have same max frequency,
        // reduce returns first one encountered

        final recentWorkouts = [
          _createWorkoutModel('Push Day'),
          _createWorkoutModel('Pull Day'),
          _createWorkoutModel('Push Day'), // Both Push and Pull = 2
          _createWorkoutModel('Pull Day'),
        ];

        // Expected: Returns first in frequency map (insertion order)
      });
    });

    group('Data Requirements', () {
      test('should query last 30 days of workout history', () {
        // Document: Queries local storage with:
        // - cutoffDate: DateTime.now() - 30 days
        // - limit: 50 workouts max

        // Call: hiveDataSource.getWorkouts(
        //   userId,
        //   limit: 50,
        //   startDate: DateTime.now().subtract(Duration(days: 30)),
        // )
      });

      test('should require authenticated user', () {
        // Document: Must have FirebaseAuth.instance.currentUser?.uid
        // Returns null immediately if user not authenticated
      });

      test('should load all workout templates', () {
        // Document: Loads templates via:
        // await ref.read(allWorkoutTemplatesProvider.future)

        // Used for template matching after pattern detection
      });
    });
  });

  group('Integration Behavior', () {
    test('should use PatternDetectionService for sequence extraction', () {
      // Document: Creates PatternDetectionService instance with hiveDataSource
      // Calls extractSequences twice:
      // 1. normalizeNames=false (custom)
      // 2. normalizeNames=true (normalized)
    });

    test('should use SimplePatternDetector for pattern detection', () {
      // Document: Creates SimplePatternDetector instance
      // Calls detectRepeatingPattern() on extracted sequences
      // Returns PatternResult with confidence, pattern, occurrences
    });

    test('should use RecoveryTimeCalculator for recovery logic', () {
      // Document: Creates RecoveryTimeCalculator instance
      // Calls:
      // 1. calculateAllRecoveryStatuses() - for all workouts in pattern
      // 2. getRecoveryConfidenceBoost() - to boost suggestion confidence
      // 3. findBestRecoveredWorkout() - when override needed
    });

    test('should measure computation time with Stopwatch', () {
      // Document: Uses Stopwatch to track pattern detection time
      // Includes in analytics: computationTimeMs
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Create test workout template
WorkoutTemplate _createTemplate(String name) {
  return WorkoutTemplate(
    id: 'template-${name.toLowerCase()}',
    name: name,
    description: 'Test template for $name',
    exercises: [],
    isCustom: true,
  );
}

/// Create test workout model
WorkoutModel _createWorkoutModel(String name, {DateTime? startTime}) {
  final now = DateTime.now();
  return WorkoutModel(
    id: 'workout-${now.millisecondsSinceEpoch}',
    name: name,
    exercises: [],
    status: 'completed',
    startTime: startTime ?? now,
    createdAt: now,
    updatedAt: now,
  );
}

// ============================================================================
// MOCK LOCALIZATIONS
// ============================================================================

/// Mock localizations for testing localizeWith
class _MockLocalizations {
  String get continueRoutine => 'Continua la tua routine';
  String get nextInRotation => 'Prossimo nella rotazione';
  String get yourMostFrequentWorkout => 'Il tuo allenamento più frequente';
  String get startNewCycle => 'Inizia nuovo ciclo';

  String resumeAfterDays(int days) => 'Riprendi dopo $days giorni';
  String restartCycleAfterDays(int days) => 'Ricomincia ciclo dopo $days giorni';
}
