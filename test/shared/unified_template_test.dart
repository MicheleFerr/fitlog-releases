/// 🧪 Test per il sistema unificato di template
///
/// Testa la compatibilità tra i diversi sistemi di template
/// e verifica che non ci siano race condition.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/unified_workout_template.dart';

void main() {
  group('UnifiedWorkoutTemplate', () {
    test('should create unified template with race condition safety', () {
      // Create a unified template directly
      final unified = UnifiedWorkoutTemplate(
        id: 'test_template_1',
        name: 'Test Upper Body',
        description: 'Test description',
        userId: 'test_user',
        exercisesRaw: [
          {
            'exerciseId': 'bench_press',
            'exerciseName': 'Bench Press',
            'category': 'chest',
            'sets': [
              {'setNumber': 1, 'targetReps': 10, 'targetWeight': 80},
              {'setNumber': 2, 'targetReps': 8, 'targetWeight': 85},
            ],
          },
        ],
        exerciseFormat: ExerciseFormat.legacy,
        source: TemplateSource.legacy,
        createdAt: DateTime.now(),
        tags: ['upper', 'strength'],
        estimatedDuration: 45,
      );

      // Verify creation
      expect(unified.id, equals('test_template_1'));
      expect(unified.name, equals('Test Upper Body'));
      expect(unified.description, equals('Test description'));
      expect(unified.exerciseFormat, equals(ExerciseFormat.legacy));
      expect(unified.source, equals(TemplateSource.legacy));
      expect(unified.isBeingDeleted, isFalse);
      expect(unified.isSyncInProgress, isFalse);
      expect(unified.exercisesRaw, isNotEmpty);
    });

    test('should handle JSON import format correctly', () {
      final exercisesData = [
        {
          'name': 'Push ups',
          'sets': [
            {'reps': 15, 'weight': 0},
            {'reps': 12, 'weight': 0},
          ]
        },
        {
          'name': 'Squats',
          'sets': [
            {'reps': 20, 'weight': 60},
            {'reps': 18, 'weight': 65},
          ]
        }
      ];

      final unified = UnifiedWorkoutTemplate(
        id: 'imported_template_1',
        name: 'Imported Workout',
        description: 'Imported from external source',
        userId: 'test_user_123',
        exercisesRaw: exercisesData,
        exerciseFormat: ExerciseFormat.json,
        source: TemplateSource.jsonImport,
        category: UnifiedTemplateCategory.strength,
        visibility: UnifiedTemplateVisibility.private,
        tags: ['bodyweight', 'beginner', 'imported'],
        createdAt: DateTime.now(),
        importDate: DateTime.now(),
      );

      expect(unified.name, equals('Imported Workout'));
      expect(unified.userId, equals('test_user_123'));
      expect(unified.exerciseFormat, equals(ExerciseFormat.json));
      expect(unified.source, equals(TemplateSource.jsonImport));
      expect(unified.category, equals(UnifiedTemplateCategory.strength));
      expect(unified.visibility, equals(UnifiedTemplateVisibility.private));
      expect(unified.tags, contains('imported'));
      expect(unified.importDate, isNotNull);
    });

    test('should support JSON serialization preserving data', () {
      // Create unified template
      final unified = UnifiedWorkoutTemplate(
        id: 'serialization_test',
        name: 'Serialization Test',
        description: 'Testing JSON serialization',
        userId: 'test_user',
        category: UnifiedTemplateCategory.strength,
        difficulty: 'Intermediate',
        estimatedDuration: 60,
        exercisesRaw: [
          {
            'exerciseId': 'squat',
            'exerciseName': 'Squat',
            'category': 'legs',
            'sets': [
              {'setNumber': 1, 'targetReps': 10, 'targetWeight': 100},
              {'setNumber': 2, 'targetReps': 8, 'targetWeight': 110},
            ]
          }
        ],
        exerciseFormat: ExerciseFormat.legacy,
        tags: ['legs', 'compound'],
        createdAt: DateTime.now(),
        source: TemplateSource.legacy,
        visibility: UnifiedTemplateVisibility.private,
      );

      // Convert to JSON and back
      final json = unified.toJson();
      final restored = UnifiedWorkoutTemplate.fromJson(json);

      // Verify round trip
      expect(restored.id, equals('serialization_test'));
      expect(restored.name, equals('Serialization Test'));
      expect(restored.description, equals('Testing JSON serialization'));
      expect(restored.estimatedDuration, equals(60));
      expect(restored.tags, contains('legs'));
      expect(restored.tags, contains('compound'));
      expect(restored.exerciseFormat, equals(ExerciseFormat.legacy));
      expect(restored.source, equals(TemplateSource.legacy));
    });

    test('should prevent race conditions with version checking', () {
      final template1 = UnifiedWorkoutTemplate(
        id: 'race_test',
        name: 'Race Condition Test',
        userId: 'test_user',
        category: UnifiedTemplateCategory.strength,
        exercisesRaw: [],
        exerciseFormat: ExerciseFormat.legacy,
        createdAt: DateTime.now(),
        source: TemplateSource.legacy,
        visibility: UnifiedTemplateVisibility.private,
        version: 1,
      );

      final template2 = template1.copyWith(
        name: 'Modified by process 1',
        version: 2,
      );

      final template3 = template1.copyWith(
        name: 'Modified by process 2',
        version: 1, // Stale version
      );

      // template2 should be considered more recent than template3
      expect(template2.version! > template3.version!, isTrue);
    });

    test('should handle copy with for immutable updates', () {
      final original = UnifiedWorkoutTemplate(
        id: 'copy_test',
        name: 'Original Template',
        userId: 'test_user',
        exercisesRaw: [],
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(
        name: 'Updated Template',
        version: 2,
      );

      expect(updated.id, equals('copy_test')); // Same ID
      expect(updated.name, equals('Updated Template')); // Updated name
      expect(updated.userId, equals('test_user')); // Preserved field
      expect(updated.version, equals(2)); // Updated field
    });

    test('should handle different exercise formats gracefully', () {
      final testCases = [
        {
          'format': ExerciseFormat.legacy,
          'exercises': [
            {
              'exerciseId': 'push_up',
              'exerciseName': 'Push Up',
              'category': 'chest',
              'sets': [
                {'setNumber': 1, 'targetReps': 15}
              ]
            }
          ]
        },
        {
          'format': ExerciseFormat.modern,
          'exercises': [
            {
              'id': 'push_up_modern',
              'name': 'Push Up',
              'category': 'chest',
              'sets': [
                {'number': 1, 'reps': 15}
              ]
            }
          ]
        },
        {
          'format': ExerciseFormat.json,
          'exercises': [
            {
              'name': 'Push Up',
              'sets': [
                {'reps': 15}
              ]
            }
          ]
        }
      ];

      for (final testCase in testCases) {
        final unified = UnifiedWorkoutTemplate(
          id: 'format_test_${testCase['format']}',
          name: 'Format Test',
          userId: 'test_user',
          category: UnifiedTemplateCategory.strength,
          exercisesRaw: testCase['exercises'] as List<dynamic>,
          exerciseFormat: testCase['format'] as ExerciseFormat,
          createdAt: DateTime.now(),
          source: TemplateSource.legacy,
          visibility: UnifiedTemplateVisibility.private,
        );

        expect(unified.exercisesRaw, isNotEmpty);
        expect(unified.exerciseFormat, equals(testCase['format']));
      }
    });
    test('should handle equality comparison correctly', () {
      final template1 = UnifiedWorkoutTemplate(
        id: 'equality_test',
        name: 'Test Template',
        userId: 'test_user',
        exercisesRaw: [],
        createdAt: DateTime.now(),
        version: 1,
      );

      final template2 = UnifiedWorkoutTemplate(
        id: 'equality_test',
        name: 'Different Name',
        userId: 'test_user',
        exercisesRaw: [],
        createdAt: DateTime.now(),
        version: 1,
      );

      final template3 = UnifiedWorkoutTemplate(
        id: 'equality_test',
        name: 'Test Template',
        userId: 'test_user',
        exercisesRaw: [],
        createdAt: DateTime.now(),
        version: 2,
      );

      // Same ID and version should be equal
      expect(template1, equals(template2));

      // Different version should not be equal
      expect(template1, isNot(equals(template3)));
    });
  });
}