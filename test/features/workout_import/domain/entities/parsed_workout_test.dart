/// Unit tests for ParsedWorkout, ParsedDay, ParsedExerciseLine, ParsedSet
///
/// Tests factory constructors, copyWith, computed properties,
/// equality, JSON serialization, and MatchLevel logic.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout_import/domain/entities/parsed_workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ParsedSet
  // ---------------------------------------------------------------------------
  group('ParsedSet', () {
    group('factory constructor', () {
      test('creates with all fields', () {
        const set = ParsedSet(
          reps: 10,
          isMaxReps: false,
          weight: 80.0,
          durationSeconds: null,
          minReps: null,
          maxReps: null,
        );

        expect(set.reps, 10);
        expect(set.isMaxReps, false);
        expect(set.weight, 80.0);
        expect(set.durationSeconds, isNull);
        expect(set.minReps, isNull);
        expect(set.maxReps, isNull);
      });

      test('defaults isMaxReps to false', () {
        const set = ParsedSet(reps: 8);
        expect(set.isMaxReps, false);
      });

      test('creates AMRAP set', () {
        const set = ParsedSet(isMaxReps: true);
        expect(set.isMaxReps, true);
        expect(set.reps, isNull);
      });

      test('creates rep-range set', () {
        const set = ParsedSet(minReps: 8, maxReps: 12);
        expect(set.minReps, 8);
        expect(set.maxReps, 12);
        expect(set.reps, isNull);
      });

      test('creates timed set', () {
        const set = ParsedSet(durationSeconds: 30);
        expect(set.durationSeconds, 30);
        expect(set.reps, isNull);
      });

      test('creates weighted set with decimal weight', () {
        const set = ParsedSet(reps: 5, weight: 102.5);
        expect(set.weight, 102.5);
      });

      test('creates set with all nulls', () {
        const set = ParsedSet();
        expect(set.reps, isNull);
        expect(set.isMaxReps, false);
        expect(set.weight, isNull);
        expect(set.durationSeconds, isNull);
        expect(set.minReps, isNull);
        expect(set.maxReps, isNull);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated reps', () {
        const original = ParsedSet(reps: 8, weight: 60.0);
        final copy = original.copyWith(reps: 12);
        expect(copy.reps, 12);
        expect(copy.weight, 60.0);
        expect(original.reps, 8);
      });

      test('returns new instance with updated weight', () {
        const original = ParsedSet(reps: 5, weight: 80.0);
        final copy = original.copyWith(weight: 90.0);
        expect(copy.weight, 90.0);
        expect(original.weight, 80.0);
      });

      test('can set isMaxReps to true via copyWith', () {
        const original = ParsedSet(reps: 10);
        final copy = original.copyWith(isMaxReps: true);
        expect(copy.isMaxReps, true);
      });

      test('does not mutate original', () {
        const original = ParsedSet(reps: 8, weight: 60.0, durationSeconds: 30);
        original.copyWith(reps: 20, weight: 100.0, durationSeconds: 60);
        expect(original.reps, 8);
        expect(original.weight, 60.0);
        expect(original.durationSeconds, 30);
      });
    });

    group('equality', () {
      test('two identical ParsedSets are equal', () {
        const a = ParsedSet(reps: 10, weight: 80.0);
        const b = ParsedSet(reps: 10, weight: 80.0);
        expect(a, equals(b));
      });

      test('different reps are not equal', () {
        const a = ParsedSet(reps: 8);
        const b = ParsedSet(reps: 10);
        expect(a, isNot(equals(b)));
      });

      test('different weights are not equal', () {
        const a = ParsedSet(reps: 8, weight: 60.0);
        const b = ParsedSet(reps: 8, weight: 70.0);
        expect(a, isNot(equals(b)));
      });

      test('isMaxReps difference breaks equality', () {
        const a = ParsedSet(isMaxReps: false);
        const b = ParsedSet(isMaxReps: true);
        expect(a, isNot(equals(b)));
      });

      test('null vs non-null reps are not equal', () {
        const a = ParsedSet(reps: 8);
        const b = ParsedSet();
        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('equal objects have equal hashCodes', () {
        const a = ParsedSet(reps: 10, weight: 80.0);
        const b = ParsedSet(reps: 10, weight: 80.0);
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('toString', () {
      test('contains all field values', () {
        const set = ParsedSet(reps: 10, weight: 80.0, isMaxReps: false);
        final str = set.toString();
        expect(str, contains('10'));
        expect(str, contains('80.0'));
        expect(str, contains('false'));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct keys', () {
        const set = ParsedSet(reps: 8, weight: 80.0, isMaxReps: false);
        final json = set.toJson();
        expect(json['reps'], 8);
        expect(json['weight'], 80.0);
        expect(json['isMaxReps'], false);
      });

      test('fromJson round-trip preserves all fields', () {
        const original = ParsedSet(
          reps: 12,
          isMaxReps: false,
          weight: 75.5,
          durationSeconds: null,
          minReps: null,
          maxReps: null,
        );
        final json = original.toJson();
        final restored = ParsedSet.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson handles AMRAP set', () {
        final json = {'reps': null, 'isMaxReps': true, 'weight': null};
        final set = ParsedSet.fromJson(json);
        expect(set.isMaxReps, true);
        expect(set.reps, isNull);
      });

      test('fromJson handles rep-range set', () {
        final json = {
          'reps': null,
          'isMaxReps': false,
          'weight': null,
          'minReps': 8,
          'maxReps': 12,
        };
        final set = ParsedSet.fromJson(json);
        expect(set.minReps, 8);
        expect(set.maxReps, 12);
      });

      test('fromJson uses default false for missing isMaxReps', () {
        final json = {'reps': 10};
        final set = ParsedSet.fromJson(json);
        expect(set.isMaxReps, false);
      });

      test('fromJson handles timed set', () {
        final json = {'durationSeconds': 45};
        final set = ParsedSet.fromJson(json);
        expect(set.durationSeconds, 45);
      });

      test('fromJson handles int weight as double', () {
        final json = {'reps': 5, 'weight': 100};
        final set = ParsedSet.fromJson(json);
        expect(set.weight, 100.0);
        expect(set.weight, isA<double>());
      });

      test('toJson then fromJson round-trip for timed set', () {
        const original = ParsedSet(durationSeconds: 60, isMaxReps: false);
        final json = original.toJson();
        final restored = ParsedSet.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ParsedExerciseLine
  // ---------------------------------------------------------------------------
  group('ParsedExerciseLine', () {
    final sampleSets = [
      const ParsedSet(reps: 8, weight: 80.0),
      const ParsedSet(reps: 10, weight: 75.0),
    ];

    group('factory constructor', () {
      test('creates with required fields only', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench Press',
          sets: sampleSets,
        );

        expect(exercise.rawName, 'Bench Press');
        expect(exercise.sets, hasLength(2));
        expect(exercise.restSeconds, isNull);
        expect(exercise.muscleGroup, isNull);
        expect(exercise.notes, isNull);
        expect(exercise.supersetGroup, isNull);
        expect(exercise.matchedExerciseId, isNull);
        expect(exercise.matchedExerciseName, isNull);
        expect(exercise.matchConfidence, isNull);
        expect(exercise.matchedCategory, isNull);
      });

      test('creates with all optional fields', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Squat',
          sets: sampleSets,
          restSeconds: 120,
          muscleGroup: 'legs',
          notes: 'Keep chest up',
          supersetGroup: 'A',
          matchedExerciseId: 'squat_001',
          matchedExerciseName: 'Back Squat',
          matchConfidence: 0.95,
          matchedCategory: ExerciseCategory.legs,
        );

        expect(exercise.restSeconds, 120);
        expect(exercise.muscleGroup, 'legs');
        expect(exercise.notes, 'Keep chest up');
        expect(exercise.supersetGroup, 'A');
        expect(exercise.matchedExerciseId, 'squat_001');
        expect(exercise.matchedExerciseName, 'Back Squat');
        expect(exercise.matchConfidence, 0.95);
        expect(exercise.matchedCategory, ExerciseCategory.legs);
      });

      test('sets list is unmodifiable', () {
        final exercise = ParsedExerciseLine(rawName: 'Push-up', sets: sampleSets);
        expect(
          () => (exercise.sets as dynamic).add(const ParsedSet(reps: 5)),
          throwsUnsupportedError,
        );
      });
    });

    group('matchLevel computed property', () {
      test('returns none when no matchedExerciseId', () {
        final exercise = ParsedExerciseLine(rawName: 'Unknown', sets: []);
        expect(exercise.matchLevel, MatchLevel.none);
      });

      test('returns none when matchConfidence is null', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: null,
        );
        expect(exercise.matchLevel, MatchLevel.none);
      });

      test('returns confident when confidence >= 0.80', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench Press',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 0.80,
        );
        expect(exercise.matchLevel, MatchLevel.confident);
      });

      test('returns confident when confidence is exactly 0.80', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench Press',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 0.80,
        );
        expect(exercise.matchLevel, MatchLevel.confident);
      });

      test('returns confident when confidence is 1.0', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench Press',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 1.0,
        );
        expect(exercise.matchLevel, MatchLevel.confident);
      });

      test('returns suggested when confidence >= 0.50 and < 0.80', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 0.65,
        );
        expect(exercise.matchLevel, MatchLevel.suggested);
      });

      test('returns suggested when confidence is exactly 0.50', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 0.50,
        );
        expect(exercise.matchLevel, MatchLevel.suggested);
      });

      test('returns none when confidence is 0.49 (below suggested threshold)', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 0.49,
        );
        expect(exercise.matchLevel, MatchLevel.none);
      });

      test('returns none when confidence is 0.0', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchedExerciseId: 'bench_001',
          matchConfidence: 0.0,
        );
        expect(exercise.matchLevel, MatchLevel.none);
      });

      test('returns none when matchedExerciseId is null but confidence is high', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchedExerciseId: null,
          matchConfidence: 0.95,
        );
        expect(exercise.matchLevel, MatchLevel.none);
      });
    });

    group('copyWith', () {
      test('updates rawName', () {
        final original = ParsedExerciseLine(rawName: 'Bench', sets: sampleSets);
        final copy = original.copyWith(rawName: 'Bench Press');
        expect(copy.rawName, 'Bench Press');
        expect(original.rawName, 'Bench');
      });

      test('updates match fields', () {
        final original = ParsedExerciseLine(rawName: 'Bench', sets: []);
        final copy = original.copyWith(
          matchedExerciseId: 'bench_001',
          matchedExerciseName: 'Panca Piana',
          matchConfidence: 0.92,
          matchedCategory: ExerciseCategory.chest,
        );
        expect(copy.matchedExerciseId, 'bench_001');
        expect(copy.matchedExerciseName, 'Panca Piana');
        expect(copy.matchConfidence, 0.92);
        expect(copy.matchedCategory, ExerciseCategory.chest);
      });

      test('updates sets list', () {
        final original = ParsedExerciseLine(rawName: 'Squat', sets: sampleSets);
        final newSets = [const ParsedSet(reps: 5, weight: 100.0)];
        final copy = original.copyWith(sets: newSets);
        expect(copy.sets, hasLength(1));
        expect(original.sets, hasLength(2));
      });

      test('does not mutate original', () {
        final original = ParsedExerciseLine(
          rawName: 'OHP',
          sets: sampleSets,
          matchedExerciseId: null,
        );
        original.copyWith(rawName: 'Overhead Press', matchedExerciseId: 'ohp_001');
        expect(original.rawName, 'OHP');
        expect(original.matchedExerciseId, isNull);
      });
    });

    group('equality', () {
      test('two identical exercises are equal', () {
        final a = ParsedExerciseLine(rawName: 'Bench', sets: sampleSets);
        final b = ParsedExerciseLine(rawName: 'Bench', sets: sampleSets);
        expect(a, equals(b));
      });

      test('different rawName breaks equality', () {
        final a = ParsedExerciseLine(rawName: 'Bench', sets: []);
        final b = ParsedExerciseLine(rawName: 'Squat', sets: []);
        expect(a, isNot(equals(b)));
      });

      test('different sets breaks equality', () {
        final a = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [const ParsedSet(reps: 8)],
        );
        final b = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [const ParsedSet(reps: 10)],
        );
        expect(a, isNot(equals(b)));
      });

      test('different matchConfidence breaks equality', () {
        final a = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchConfidence: 0.90,
        );
        final b = ParsedExerciseLine(
          rawName: 'Bench',
          sets: [],
          matchConfidence: 0.75,
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct structure', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Bench Press',
          sets: [const ParsedSet(reps: 8, weight: 80.0)],
          restSeconds: 90,
          muscleGroup: 'chest',
        );
        final json = exercise.toJson();
        expect(json['rawName'], 'Bench Press');
        expect(json['restSeconds'], 90);
        expect(json['muscleGroup'], 'chest');
        expect(json['sets'], isA<List>());
        expect((json['sets'] as List).length, 1);
      });

      test('fromJson round-trip preserves all fields', () {
        final original = ParsedExerciseLine(
          rawName: 'Deadlift',
          sets: [const ParsedSet(reps: 5, weight: 120.0)],
          restSeconds: 180,
          muscleGroup: 'back',
          notes: 'Keep neutral spine',
          supersetGroup: null,
          matchedExerciseId: 'deadlift_001',
          matchedExerciseName: 'Stacco da Terra',
          matchConfidence: 0.98,
          matchedCategory: ExerciseCategory.back,
        );
        final json = original.toJson();
        final restored = ParsedExerciseLine.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson handles minimal JSON (only required fields)', () {
        final json = {
          'rawName': 'Push-up',
          'sets': <dynamic>[],
        };
        final exercise = ParsedExerciseLine.fromJson(json);
        expect(exercise.rawName, 'Push-up');
        expect(exercise.sets, isEmpty);
        expect(exercise.restSeconds, isNull);
        expect(exercise.matchedExerciseId, isNull);
      });

      test('fromJson serializes category enum correctly', () {
        final json = {
          'rawName': 'Curl',
          'sets': <dynamic>[],
          'matchedCategory': 'arms',
        };
        final exercise = ParsedExerciseLine.fromJson(json);
        expect(exercise.matchedCategory, ExerciseCategory.arms);
      });

      test('toJson serializes category enum to string', () {
        final exercise = ParsedExerciseLine(
          rawName: 'Leg Press',
          sets: [],
          matchedCategory: ExerciseCategory.legs,
        );
        final json = exercise.toJson();
        expect(json['matchedCategory'], 'legs');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ParsedDay
  // ---------------------------------------------------------------------------
  group('ParsedDay', () {
    final sampleExercises = [
      ParsedExerciseLine(
        rawName: 'Bench Press',
        sets: [const ParsedSet(reps: 8, weight: 80.0)],
      ),
      ParsedExerciseLine(
        rawName: 'Squat',
        sets: [const ParsedSet(reps: 5, weight: 100.0)],
      ),
    ];

    group('factory constructor', () {
      test('creates with required fields', () {
        final day = ParsedDay(name: 'Day A', exercises: sampleExercises);
        expect(day.name, 'Day A');
        expect(day.exercises, hasLength(2));
      });

      test('creates with empty exercises list', () {
        final day = ParsedDay(name: 'Rest Day', exercises: []);
        expect(day.exercises, isEmpty);
      });

      test('exercises list is unmodifiable', () {
        final day = ParsedDay(name: 'Push', exercises: sampleExercises);
        expect(
          () => (day.exercises as dynamic).add(
            ParsedExerciseLine(rawName: 'OHP', sets: []),
          ),
          throwsUnsupportedError,
        );
      });
    });

    group('copyWith', () {
      test('updates name', () {
        final day = ParsedDay(name: 'Monday', exercises: sampleExercises);
        final copy = day.copyWith(name: 'Tuesday');
        expect(copy.name, 'Tuesday');
        expect(day.name, 'Monday');
      });

      test('updates exercises', () {
        final day = ParsedDay(name: 'Day A', exercises: sampleExercises);
        final newExercises = [
          ParsedExerciseLine(rawName: 'Deadlift', sets: []),
        ];
        final copy = day.copyWith(exercises: newExercises);
        expect(copy.exercises, hasLength(1));
        expect(day.exercises, hasLength(2));
      });

      test('does not mutate original', () {
        final original = ParsedDay(name: 'Day A', exercises: sampleExercises);
        original.copyWith(name: 'Day B', exercises: []);
        expect(original.name, 'Day A');
        expect(original.exercises, hasLength(2));
      });
    });

    group('equality', () {
      test('two identical days are equal', () {
        final a = ParsedDay(name: 'Push', exercises: sampleExercises);
        final b = ParsedDay(name: 'Push', exercises: sampleExercises);
        expect(a, equals(b));
      });

      test('different name breaks equality', () {
        final a = ParsedDay(name: 'Push', exercises: []);
        final b = ParsedDay(name: 'Pull', exercises: []);
        expect(a, isNot(equals(b)));
      });

      test('different exercises break equality', () {
        final a = ParsedDay(name: 'Day', exercises: sampleExercises);
        final b = ParsedDay(name: 'Day', exercises: []);
        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct structure', () {
        final day = ParsedDay(
          name: 'Push Day',
          exercises: sampleExercises,
        );
        final json = day.toJson();
        expect(json['name'], 'Push Day');
        expect(json['exercises'], isA<List>());
        expect((json['exercises'] as List).length, 2);
      });

      test('fromJson round-trip preserves all fields', () {
        final original = ParsedDay(
          name: 'Leg Day',
          exercises: [
            ParsedExerciseLine(
              rawName: 'Squat',
              sets: [const ParsedSet(reps: 5, weight: 100.0)],
            ),
          ],
        );
        final json = original.toJson();
        final restored = ParsedDay.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson handles empty exercises array', () {
        final json = {'name': 'Rest', 'exercises': <dynamic>[]};
        final day = ParsedDay.fromJson(json);
        expect(day.exercises, isEmpty);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ParsedWorkout
  // ---------------------------------------------------------------------------
  group('ParsedWorkout', () {
    final sampleDay = ParsedDay(
      name: 'Workout A',
      exercises: [
        ParsedExerciseLine(
          rawName: 'Bench Press',
          sets: [const ParsedSet(reps: 8, weight: 80.0)],
        ),
      ],
    );

    group('factory constructor', () {
      test('creates with required days list', () {
        final workout = ParsedWorkout(days: [sampleDay]);
        expect(workout.days, hasLength(1));
        expect(workout.rawText, isNull);
        expect(workout.hasMultipleDays, false);
      });

      test('hasMultipleDays defaults to false', () {
        final workout = ParsedWorkout(days: [sampleDay]);
        expect(workout.hasMultipleDays, false);
      });

      test('creates with rawText', () {
        final workout = ParsedWorkout(days: [sampleDay], rawText: 'Bench 3x8');
        expect(workout.rawText, 'Bench 3x8');
      });

      test('creates with hasMultipleDays true', () {
        final secondDay = ParsedDay(name: 'Workout B', exercises: []);
        final workout = ParsedWorkout(
          days: [sampleDay, secondDay],
          hasMultipleDays: true,
        );
        expect(workout.hasMultipleDays, true);
      });

      test('days list is unmodifiable', () {
        final workout = ParsedWorkout(days: [sampleDay]);
        expect(
          () => (workout.days as dynamic).add(sampleDay),
          throwsUnsupportedError,
        );
      });
    });

    group('copyWith', () {
      test('updates rawText', () {
        final original = ParsedWorkout(days: [sampleDay]);
        final copy = original.copyWith(rawText: 'Updated text');
        expect(copy.rawText, 'Updated text');
        expect(original.rawText, isNull);
      });

      test('updates hasMultipleDays', () {
        final original = ParsedWorkout(days: [sampleDay]);
        final copy = original.copyWith(hasMultipleDays: true);
        expect(copy.hasMultipleDays, true);
        expect(original.hasMultipleDays, false);
      });

      test('updates days list', () {
        final original = ParsedWorkout(days: [sampleDay]);
        final newDay = ParsedDay(name: 'New Day', exercises: []);
        final copy = original.copyWith(days: [sampleDay, newDay]);
        expect(copy.days, hasLength(2));
        expect(original.days, hasLength(1));
      });

      test('does not mutate original', () {
        final original = ParsedWorkout(
          days: [sampleDay],
          rawText: 'original',
          hasMultipleDays: false,
        );
        original.copyWith(
          rawText: 'modified',
          hasMultipleDays: true,
          days: [],
        );
        expect(original.rawText, 'original');
        expect(original.hasMultipleDays, false);
        expect(original.days, hasLength(1));
      });
    });

    group('equality', () {
      test('two identical workouts are equal', () {
        final a = ParsedWorkout(days: [sampleDay], rawText: 'text');
        final b = ParsedWorkout(days: [sampleDay], rawText: 'text');
        expect(a, equals(b));
      });

      test('different rawText breaks equality', () {
        final a = ParsedWorkout(days: [sampleDay], rawText: 'text A');
        final b = ParsedWorkout(days: [sampleDay], rawText: 'text B');
        expect(a, isNot(equals(b)));
      });

      test('different hasMultipleDays breaks equality', () {
        final a = ParsedWorkout(days: [sampleDay], hasMultipleDays: false);
        final b = ParsedWorkout(days: [sampleDay], hasMultipleDays: true);
        expect(a, isNot(equals(b)));
      });

      test('null rawText vs non-null breaks equality', () {
        final a = ParsedWorkout(days: [sampleDay], rawText: null);
        final b = ParsedWorkout(days: [sampleDay], rawText: 'text');
        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('equal workouts have equal hashCodes', () {
        final a = ParsedWorkout(days: [sampleDay], rawText: 'text');
        final b = ParsedWorkout(days: [sampleDay], rawText: 'text');
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('toString', () {
      test('contains class name and fields', () {
        final workout = ParsedWorkout(
          days: [sampleDay],
          rawText: 'original text',
        );
        final str = workout.toString();
        expect(str, contains('ParsedWorkout'));
        expect(str, contains('original text'));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct top-level structure', () {
        final workout = ParsedWorkout(
          days: [sampleDay],
          rawText: 'Bench 3x8',
          hasMultipleDays: false,
        );
        final json = workout.toJson();
        expect(json['days'], isA<List>());
        expect(json['rawText'], 'Bench 3x8');
        expect(json['hasMultipleDays'], false);
      });

      test('fromJson round-trip preserves all fields', () {
        final original = ParsedWorkout(
          days: [sampleDay],
          rawText: 'Push workout',
          hasMultipleDays: false,
        );
        final json = original.toJson();
        final restored = ParsedWorkout.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson handles null rawText', () {
        final json = {
          'days': [sampleDay.toJson()],
          'rawText': null,
          'hasMultipleDays': false,
        };
        final workout = ParsedWorkout.fromJson(json);
        expect(workout.rawText, isNull);
      });

      test('fromJson uses default false for missing hasMultipleDays', () {
        final json = {
          'days': [sampleDay.toJson()],
        };
        final workout = ParsedWorkout.fromJson(json);
        expect(workout.hasMultipleDays, false);
      });

      test('fromJson preserves nested exercise and set data', () {
        final original = ParsedWorkout(
          days: [
            ParsedDay(
              name: 'Day A',
              exercises: [
                ParsedExerciseLine(
                  rawName: 'Deadlift',
                  sets: [
                    const ParsedSet(reps: 5, weight: 120.0),
                    const ParsedSet(reps: 5, weight: 125.0),
                  ],
                  restSeconds: 180,
                ),
              ],
            ),
          ],
          rawText: 'Deadlift 2x5',
        );
        final json = original.toJson();
        final restored = ParsedWorkout.fromJson(json);
        expect(restored.days.first.exercises.first.sets.length, 2);
        expect(restored.days.first.exercises.first.sets.first.weight, 120.0);
      });

      test('round-trip for multi-day workout', () {
        final multiDay = ParsedWorkout(
          days: [
            ParsedDay(
              name: 'Push',
              exercises: [
                ParsedExerciseLine(
                  rawName: 'Bench Press',
                  sets: [const ParsedSet(reps: 8, weight: 80.0)],
                ),
              ],
            ),
            ParsedDay(
              name: 'Pull',
              exercises: [
                ParsedExerciseLine(
                  rawName: 'Row',
                  sets: [const ParsedSet(reps: 10, weight: 60.0)],
                ),
              ],
            ),
          ],
          hasMultipleDays: true,
        );
        final json = multiDay.toJson();
        final restored = ParsedWorkout.fromJson(json);
        expect(restored.days, hasLength(2));
        expect(restored.hasMultipleDays, true);
        expect(restored.days[0].name, 'Push');
        expect(restored.days[1].name, 'Pull');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // MatchLevel enum
  // ---------------------------------------------------------------------------
  group('MatchLevel', () {
    test('has three values', () {
      expect(MatchLevel.values, hasLength(3));
    });

    test('values are confident, suggested, none', () {
      expect(MatchLevel.values, contains(MatchLevel.confident));
      expect(MatchLevel.values, contains(MatchLevel.suggested));
      expect(MatchLevel.values, contains(MatchLevel.none));
    });
  });
}
