import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_draft.dart';

void main() {
  group('WorkoutDraft', () {
    final testDate = DateTime(2026, 1, 15, 10, 30);
    final sampleWorkoutJson = jsonEncode({
      'name': 'Push Day',
      'exercises': [],
      'startTime': testDate.toIso8601String(),
    });

    WorkoutDraft createSubject({
      String id = 'draft_123',
      String? workoutJson,
      DateTime? lastSaved,
      String? deviceId,
      Map<String, dynamic>? metadata,
      bool isRecovered = false,
    }) {
      return WorkoutDraft(
        id: id,
        workoutJson: workoutJson ?? sampleWorkoutJson,
        lastSaved: lastSaved ?? testDate,
        deviceId: deviceId,
        metadata: metadata,
        isRecovered: isRecovered,
      );
    }

    group('constructor', () {
      test('creates with all required fields', () {
        final draft = createSubject();

        expect(draft.id, 'draft_123');
        expect(draft.workoutJson, sampleWorkoutJson);
        expect(draft.lastSaved, testDate);
      });

      test('nullable fields default to null', () {
        final draft = createSubject();

        expect(draft.deviceId, isNull);
        expect(draft.metadata, isNull);
      });

      test('isRecovered defaults to false', () {
        final draft = createSubject();
        expect(draft.isRecovered, false);
      });

      test('creates with all optional fields', () {
        final draft = createSubject(
          deviceId: 'device-abc',
          metadata: {'workoutName': 'Push Day', 'exerciseCount': 5},
          isRecovered: true,
        );

        expect(draft.deviceId, 'device-abc');
        expect(draft.metadata, isNotNull);
        expect(draft.metadata!['workoutName'], 'Push Day');
        expect(draft.metadata!['exerciseCount'], 5);
        expect(draft.isRecovered, true);
      });

      test('stores arbitrary JSON string', () {
        final jsonStr = jsonEncode({'custom': 'data', 'count': 42});
        final draft = createSubject(workoutJson: jsonStr);

        expect(draft.workoutJson, jsonStr);
        final decoded = jsonDecode(draft.workoutJson);
        expect(decoded['custom'], 'data');
        expect(decoded['count'], 42);
      });
    });

    group('isStale', () {
      test('returns false for recent draft (less than 24h)', () {
        final draft = createSubject(
          lastSaved: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(draft.isStale, false);
      });

      test('returns false for draft saved exactly now', () {
        final draft = createSubject(lastSaved: DateTime.now());

        expect(draft.isStale, false);
      });

      test('returns false for draft saved 23 hours ago', () {
        final draft = createSubject(
          lastSaved: DateTime.now().subtract(const Duration(hours: 23)),
        );

        expect(draft.isStale, false);
      });

      test('returns false for draft saved exactly 24 hours ago', () {
        // isStale uses > 24, not >=
        final draft = createSubject(
          lastSaved: DateTime.now().subtract(const Duration(hours: 24)),
        );

        expect(draft.isStale, false);
      });

      test('returns true for draft saved 25 hours ago', () {
        final draft = createSubject(
          lastSaved: DateTime.now().subtract(const Duration(hours: 25)),
        );

        expect(draft.isStale, true);
      });

      test('returns true for draft saved 48 hours ago', () {
        final draft = createSubject(
          lastSaved: DateTime.now().subtract(const Duration(hours: 48)),
        );

        expect(draft.isStale, true);
      });

      test('returns true for draft saved days ago', () {
        final draft = createSubject(
          lastSaved: DateTime.now().subtract(const Duration(days: 7)),
        );

        expect(draft.isStale, true);
      });
    });

    group('copyWith', () {
      test('copies with new workoutJson', () {
        final original = createSubject();
        final newJson = jsonEncode({'name': 'Leg Day'});
        final copy = original.copyWith(workoutJson: newJson);

        expect(copy.workoutJson, newJson);
        expect(copy.id, original.id);
        expect(copy.lastSaved, original.lastSaved);
        expect(copy.deviceId, original.deviceId);
        expect(copy.metadata, original.metadata);
        expect(copy.isRecovered, original.isRecovered);
      });

      test('copies with new lastSaved', () {
        final original = createSubject();
        final newDate = DateTime(2026, 3, 1);
        final copy = original.copyWith(lastSaved: newDate);

        expect(copy.lastSaved, newDate);
        expect(copy.workoutJson, original.workoutJson);
      });

      test('copies with new isRecovered', () {
        final original = createSubject(isRecovered: false);
        final copy = original.copyWith(isRecovered: true);

        expect(copy.isRecovered, true);
        expect(copy.id, original.id);
      });

      test('preserves id when copying', () {
        final original = createSubject(id: 'draft_specific');
        final copy = original.copyWith(workoutJson: '{}');

        expect(copy.id, 'draft_specific');
      });

      test('preserves deviceId when copying', () {
        final original = createSubject(deviceId: 'device-xyz');
        final copy = original.copyWith(isRecovered: true);

        expect(copy.deviceId, 'device-xyz');
      });

      test('preserves metadata when copying', () {
        final original = createSubject(
          metadata: {'key': 'value'},
        );
        final copy = original.copyWith(isRecovered: true);

        expect(copy.metadata, {'key': 'value'});
      });

      test('returns instance with same values when no args', () {
        final original = createSubject(
          deviceId: 'dev-1',
          metadata: {'k': 'v'},
          isRecovered: true,
        );
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.workoutJson, original.workoutJson);
        expect(copy.lastSaved, original.lastSaved);
        expect(copy.deviceId, original.deviceId);
        expect(copy.metadata, original.metadata);
        expect(copy.isRecovered, original.isRecovered);
      });
    });

    group('toWorkout', () {
      test('throws on invalid JSON', () {
        final draft = createSubject(workoutJson: 'not-json');

        expect(() => draft.toWorkout(), throwsA(isA<FormatException>()));
      });
    });

    group('metadata', () {
      test('can store complex metadata', () {
        final draft = createSubject(
          metadata: {
            'workoutName': 'Push Day',
            'exerciseCount': 5,
            'startTime': '2026-01-15T10:30:00.000',
            'nested': {'level': 2},
          },
        );

        expect(draft.metadata!['workoutName'], 'Push Day');
        expect(draft.metadata!['exerciseCount'], 5);
        expect(draft.metadata!['nested'], isA<Map>());
      });

      test('null metadata is valid', () {
        final draft = createSubject(metadata: null);
        expect(draft.metadata, isNull);
      });

      test('empty metadata is valid', () {
        final draft = createSubject(metadata: {});
        expect(draft.metadata, isEmpty);
      });
    });
  });
}
