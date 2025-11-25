/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: test/features/routine/domain/entities
/// 🎯 Feature: flexible_routine
/// 🔧 Type: unit test
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE ENTITY UNIT TESTS - v2.0
///
/// Tests:
/// - Entity creation with all 12 fields
/// - Freezed copyWith method
/// - Freezed equality comparison
/// - JSON serialization/deserialization
/// - Edge cases (empty sets, boundary values)
/// - Immutability guarantees
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';

void main() {
  group('FlexibleRoutine Entity', () {
    // Sample data
    final now = DateTime(2025, 1, 15, 10, 30);

    final sampleRoutine = FlexibleRoutine(
      id: 'routine-123',
      userId: 'user-456',
      name: 'PPL 6-Day Split',
      description: 'Push Pull Legs routine for hypertrophy',
      presetType: RoutinePreset.ppl6Day,
      trainingDays: const {1, 2, 3, 4, 5, 6}, // Mon-Sat (Set)
      workoutSchedule: const {
        1: 'template-push',
        2: 'template-pull',
        3: 'template-legs',
        4: 'template-push',
        5: 'template-pull',
        6: 'template-legs',
      },
      isActive: true,
      completedDays: const {'2025-01-10', '2025-01-12', '2025-01-14'},
      totalWorkouts: 24,
      createdAt: now,
      updatedAt: now,
    );

    group('Entity Creation', () {
      test('creates entity with all required fields', () {
        expect(sampleRoutine.id, 'routine-123');
        expect(sampleRoutine.userId, 'user-456');
        expect(sampleRoutine.name, 'PPL 6-Day Split');
        expect(sampleRoutine.description, 'Push Pull Legs routine for hypertrophy');
        expect(sampleRoutine.presetType, RoutinePreset.ppl6Day);
        expect(sampleRoutine.trainingDays, {1, 2, 3, 4, 5, 6});
        expect(sampleRoutine.workoutSchedule, {
          1: 'template-push',
          2: 'template-pull',
          3: 'template-legs',
          4: 'template-push',
          5: 'template-pull',
          6: 'template-legs',
        });
        expect(sampleRoutine.isActive, true);
        expect(sampleRoutine.completedDays, {'2025-01-10', '2025-01-12', '2025-01-14'});
        expect(sampleRoutine.totalWorkouts, 24);
        expect(sampleRoutine.createdAt, now);
        expect(sampleRoutine.updatedAt, now);
      });

      test('creates entity with minimal fields (using defaults)', () {
        final minimalRoutine = FlexibleRoutine(
          id: 'routine-min',
          userId: 'user-123',
          name: 'Custom Routine',
          presetType: RoutinePreset.custom,
          trainingDays: const {1, 3, 5},
          workoutSchedule: const {},
          createdAt: now,
          updatedAt: now,
        );

        expect(minimalRoutine.id, 'routine-min');
        expect(minimalRoutine.description, ''); // Default empty string
        expect(minimalRoutine.workoutSchedule, isEmpty);
        expect(minimalRoutine.isActive, true); // Default true
        expect(minimalRoutine.completedDays, isEmpty); // Default empty set
        expect(minimalRoutine.totalWorkouts, 0); // Default 0
      });

      test('creates entity with empty training days', () {
        final emptyDaysRoutine = FlexibleRoutine(
          id: 'routine-empty',
          userId: 'user-123',
          name: 'Empty Routine',
          presetType: RoutinePreset.custom,
          trainingDays: const {}, // Empty set
          workoutSchedule: const {},
          createdAt: now,
          updatedAt: now,
        );

        expect(emptyDaysRoutine.trainingDays, isEmpty);
      });
    });

    group('Freezed Equality', () {
      test('identical instances are equal', () {
        final routine1 = sampleRoutine;
        final routine2 = sampleRoutine;

        expect(routine1, equals(routine2));
        expect(routine1.hashCode, equals(routine2.hashCode));
      });

      test('instances with same values are equal', () {
        final routine1 = FlexibleRoutine(
          id: 'routine-123',
          userId: 'user-456',
          name: 'PPL 6-Day Split',
          presetType: RoutinePreset.ppl6Day,
          trainingDays: const {1, 2, 3, 4, 5, 6},
          workoutSchedule: const {
            1: 'template-push',
            2: 'template-pull',
          },
          completedDays: const {'2025-01-10'},
          createdAt: now,
          updatedAt: now,
        );

        final routine2 = FlexibleRoutine(
          id: 'routine-123',
          userId: 'user-456',
          name: 'PPL 6-Day Split',
          presetType: RoutinePreset.ppl6Day,
          trainingDays: const {1, 2, 3, 4, 5, 6},
          workoutSchedule: const {
            1: 'template-push',
            2: 'template-pull',
          },
          completedDays: const {'2025-01-10'},
          createdAt: now,
          updatedAt: now,
        );

        expect(routine1, equals(routine2));
        expect(routine1.hashCode, equals(routine2.hashCode));
      });

      test('instances with different values are not equal', () {
        final routine1 = sampleRoutine;
        final routine2 = sampleRoutine.copyWith(name: 'Different Name');

        expect(routine1, isNot(equals(routine2)));
        expect(routine1.hashCode, isNot(equals(routine2.hashCode)));
      });
    });

    group('Freezed CopyWith', () {
      test('copyWith creates new instance with updated field', () {
        final updated = sampleRoutine.copyWith(name: 'Updated Name');

        expect(updated.name, 'Updated Name');
        expect(updated.id, sampleRoutine.id); // Other fields unchanged
        expect(updated.userId, sampleRoutine.userId);
        expect(updated.presetType, sampleRoutine.presetType);
      });

      test('copyWith with isActive toggles activation state', () {
        final deactivated = sampleRoutine.copyWith(isActive: false);

        expect(deactivated.isActive, false);
        expect(sampleRoutine.isActive, true); // Original unchanged
      });

      test('copyWith with multiple fields updates all', () {
        final updated = sampleRoutine.copyWith(
          name: 'New Name',
          totalWorkouts: 50,
          description: 'New description',
          updatedAt: now.add(const Duration(days: 1)),
        );

        expect(updated.name, 'New Name');
        expect(updated.totalWorkouts, 50);
        expect(updated.description, 'New description');
        expect(updated.updatedAt, now.add(const Duration(days: 1)));
      });

      test('copyWith with empty trainingDays clears set', () {
        final emptyDays = sampleRoutine.copyWith(trainingDays: const {});

        expect(emptyDays.trainingDays, isEmpty);
        expect(sampleRoutine.trainingDays, isNotEmpty); // Original unchanged
      });

      test('copyWith with empty workoutSchedule clears map', () {
        final emptySchedule = sampleRoutine.copyWith(workoutSchedule: const {});

        expect(emptySchedule.workoutSchedule, isEmpty);
        expect(sampleRoutine.workoutSchedule, isNotEmpty); // Original unchanged
      });

      test('copyWith with empty completedDays clears set', () {
        final emptyCompleted = sampleRoutine.copyWith(completedDays: const {});

        expect(emptyCompleted.completedDays, isEmpty);
        expect(sampleRoutine.completedDays, isNotEmpty); // Original unchanged
      });
    });

    group('JSON Serialization', () {
      test('toJson converts entity to JSON map', () {
        final json = sampleRoutine.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], 'routine-123');
        expect(json['userId'], 'user-456');
        expect(json['name'], 'PPL 6-Day Split');
        expect(json['description'], 'Push Pull Legs routine for hypertrophy');
        expect(json['presetType'], 'ppl_6_day');
        expect(json['trainingDays'], isA<List>());
        expect(json['workoutSchedule'], isA<Map>());
        expect(json['isActive'], true);
        expect(json['completedDays'], isA<List>());
        expect(json['totalWorkouts'], 24);
        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
      });

      test('fromJson creates entity from JSON map', () {
        final json = {
          'id': 'routine-json',
          'userId': 'user-json',
          'name': 'JSON Routine',
          'description': 'Test routine',
          'presetType': 'upper_lower_4_day',
          'trainingDays': [1, 2, 4, 5],
          'workoutSchedule': {
            '1': 'template-upper',
            '2': 'template-lower',
            '4': 'template-upper',
            '5': 'template-lower',
          },
          'isActive': false,
          'completedDays': ['2025-01-10', '2025-01-12'],
          'totalWorkouts': 10,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final routine = FlexibleRoutine.fromJson(json);

        expect(routine.id, 'routine-json');
        expect(routine.userId, 'user-json');
        expect(routine.name, 'JSON Routine');
        expect(routine.description, 'Test routine');
        expect(routine.presetType, RoutinePreset.upperLower4Day);
        expect(routine.trainingDays, {1, 2, 4, 5});
        expect(routine.workoutSchedule, {
          1: 'template-upper',
          2: 'template-lower',
          4: 'template-upper',
          5: 'template-lower',
        });
        expect(routine.isActive, false);
        expect(routine.completedDays, {'2025-01-10', '2025-01-12'});
        expect(routine.totalWorkouts, 10);
      });

      test('round-trip serialization preserves data', () {
        final json = sampleRoutine.toJson();
        final deserialized = FlexibleRoutine.fromJson(json);

        expect(deserialized.id, sampleRoutine.id);
        expect(deserialized.userId, sampleRoutine.userId);
        expect(deserialized.name, sampleRoutine.name);
        expect(deserialized.description, sampleRoutine.description);
        expect(deserialized.presetType, sampleRoutine.presetType);
        expect(deserialized.trainingDays, sampleRoutine.trainingDays);
        expect(deserialized.workoutSchedule, sampleRoutine.workoutSchedule);
        expect(deserialized.isActive, sampleRoutine.isActive);
        expect(deserialized.completedDays, sampleRoutine.completedDays);
        expect(deserialized.totalWorkouts, sampleRoutine.totalWorkouts);
        expect(deserialized.createdAt.toIso8601String(), sampleRoutine.createdAt.toIso8601String());
        expect(deserialized.updatedAt.toIso8601String(), sampleRoutine.updatedAt.toIso8601String());
      });
    });

    group('Edge Cases', () {
      test('handles all preset types', () {
        for (final preset in RoutinePreset.values) {
          final routine = FlexibleRoutine(
            id: 'routine-${preset.name}',
            userId: 'user-123',
            name: 'Test ${preset.displayName}',
            presetType: preset,
            trainingDays: preset.defaultTrainingDays,
            workoutSchedule: const {},
            createdAt: now,
            updatedAt: now,
          );

          expect(routine.presetType, preset);
          expect(routine.trainingDays, preset.defaultTrainingDays);
        }
      });

      test('handles large workout counts', () {
        final largeCountRoutine = sampleRoutine.copyWith(
          totalWorkouts: 999999,
        );

        expect(largeCountRoutine.totalWorkouts, 999999);
      });

      test('handles zero workout counts', () {
        final zeroCountRoutine = sampleRoutine.copyWith(
          totalWorkouts: 0,
        );

        expect(zeroCountRoutine.totalWorkouts, 0);
      });

      test('handles workoutSchedule with all 7 days', () {
        final fullWeekSchedule = sampleRoutine.copyWith(
          trainingDays: const {1, 2, 3, 4, 5, 6, 7},
          workoutSchedule: const {
            1: 'template-1',
            2: 'template-2',
            3: 'template-3',
            4: 'template-4',
            5: 'template-5',
            6: 'template-6',
            7: 'template-7',
          },
        );

        expect(fullWeekSchedule.trainingDays, {1, 2, 3, 4, 5, 6, 7});
        expect(fullWeekSchedule.workoutSchedule.length, 7);
      });

      test('handles many completed days', () {
        final manyCompletedDays = sampleRoutine.copyWith(
          completedDays: {
            '2025-01-01',
            '2025-01-02',
            '2025-01-03',
            '2025-01-05',
            '2025-01-06',
            '2025-01-08',
            '2025-01-09',
            '2025-01-10',
          },
        );

        expect(manyCompletedDays.completedDays.length, 8);
      });
    });

    group('Immutability', () {
      test('entity is immutable after creation', () {
        final routine = sampleRoutine;
        final originalName = routine.name;
        final originalTotalWorkouts = routine.totalWorkouts;

        // Attempt to modify via copyWith
        final modified = routine.copyWith(
          name: 'Modified Name',
          totalWorkouts: 100,
        );

        // Original unchanged
        expect(routine.name, originalName);
        expect(routine.totalWorkouts, originalTotalWorkouts);

        // New instance has changes
        expect(modified.name, 'Modified Name');
        expect(modified.totalWorkouts, 100);
      });
    });
  });
}
