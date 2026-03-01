// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/warmup_suggestion.dart';

void main() {
  // ================================================================
  // WarmupType enum
  // ================================================================
  group('WarmupType enum', () {
    test('has 2 values', () {
      expect(WarmupType.values.length, 2);
    });

    test('contains mobility and activation', () {
      expect(WarmupType.values, contains(WarmupType.mobility));
      expect(WarmupType.values, contains(WarmupType.activation));
    });
  });

  // ================================================================
  // WarmupSuggestion factory constructor
  // ================================================================
  group('WarmupSuggestion factory constructor', () {
    test('stores all required fields', () {
      const ws = WarmupSuggestion(
        exerciseId: 'hip_circle',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );

      expect(ws.exerciseId, 'hip_circle');
      expect(ws.exerciseName, 'Hip Circle');
      expect(ws.sets, 2);
      expect(ws.reps, 10);
      expect(ws.type, WarmupType.mobility);
    });

    test('activation type is stored correctly', () {
      const ws = WarmupSuggestion(
        exerciseId: 'glute_bridge',
        exerciseName: 'Glute Bridge',
        sets: 3,
        reps: 15,
        type: WarmupType.activation,
      );
      expect(ws.type, WarmupType.activation);
    });
  });

  // ================================================================
  // WarmupSuggestion copyWith
  // ================================================================
  group('WarmupSuggestion copyWith', () {
    const base = WarmupSuggestion(
      exerciseId: 'ws_base',
      exerciseName: 'Base Exercise',
      sets: 2,
      reps: 10,
      type: WarmupType.mobility,
    );

    test('can change sets', () {
      final updated = base.copyWith(sets: 3);
      expect(updated.sets, 3);
      expect(base.sets, 2); // original unchanged
    });

    test('can change reps', () {
      final updated = base.copyWith(reps: 15);
      expect(updated.reps, 15);
      expect(base.reps, 10);
    });

    test('can change type', () {
      final updated = base.copyWith(type: WarmupType.activation);
      expect(updated.type, WarmupType.activation);
    });

    test('can change exerciseName', () {
      final updated = base.copyWith(exerciseName: 'New Name');
      expect(updated.exerciseName, 'New Name');
    });

    test('copyWith no args preserves all fields', () {
      final copy = base.copyWith();
      expect(copy, equals(base));
    });

    test('original is not mutated', () {
      // ignore: unused_result
      final _ = base.copyWith(sets: 99);
      expect(base.sets, 2);
    });
  });

  // ================================================================
  // WarmupSuggestion equality
  // ================================================================
  group('WarmupSuggestion equality', () {
    test('two identical instances are equal', () {
      const a = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );
      const b = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );
      expect(a, equals(b));
    });

    test('different exerciseId produces not-equal', () {
      const a = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );
      const b = WarmupSuggestion(
        exerciseId: 'ws2',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );
      expect(a, isNot(equals(b)));
    });

    test('different sets produces not-equal', () {
      const a = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );
      const b = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 3,
        reps: 10,
        type: WarmupType.mobility,
      );
      expect(a, isNot(equals(b)));
    });

    test('different type produces not-equal', () {
      const a = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.mobility,
      );
      const b = WarmupSuggestion(
        exerciseId: 'ws1',
        exerciseName: 'Hip Circle',
        sets: 2,
        reps: 10,
        type: WarmupType.activation,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ================================================================
  // WarmupSuggestion JSON serialization
  // ================================================================
  group('WarmupSuggestion JSON serialization', () {
    const ws = WarmupSuggestion(
      exerciseId: 'hip_circle',
      exerciseName: 'Hip Circle',
      sets: 2,
      reps: 10,
      type: WarmupType.mobility,
    );

    test('toJson contains all keys', () {
      final json = ws.toJson();
      expect(json.containsKey('exerciseId'), isTrue);
      expect(json.containsKey('exerciseName'), isTrue);
      expect(json.containsKey('sets'), isTrue);
      expect(json.containsKey('reps'), isTrue);
      expect(json.containsKey('type'), isTrue);
    });

    test('toJson / fromJson round-trip for mobility', () {
      final json = ws.toJson();
      final restored = WarmupSuggestion.fromJson(json);
      expect(restored, equals(ws));
    });

    test('toJson / fromJson round-trip for activation', () {
      const activation = WarmupSuggestion(
        exerciseId: 'glute_bridge',
        exerciseName: 'Glute Bridge',
        sets: 3,
        reps: 15,
        type: WarmupType.activation,
      );
      final json = activation.toJson();
      final restored = WarmupSuggestion.fromJson(json);
      expect(restored, equals(activation));
    });

    test('fromJson parses exerciseId correctly', () {
      final json = {
        'exerciseId': 'cat_cow',
        'exerciseName': 'Cat Cow',
        'sets': 1,
        'reps': 8,
        'type': 'mobility',
      };
      final ws2 = WarmupSuggestion.fromJson(json);
      expect(ws2.exerciseId, 'cat_cow');
    });

    test('fromJson parses type correctly', () {
      final json = {
        'exerciseId': 'fire_hydrant',
        'exerciseName': 'Fire Hydrant',
        'sets': 2,
        'reps': 12,
        'type': 'activation',
      };
      final ws2 = WarmupSuggestion.fromJson(json);
      expect(ws2.type, WarmupType.activation);
    });
  });
}
