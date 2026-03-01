/// WorkoutPreset models unit tests.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/models/workout_preset.dart';

void main() {
  group('RepRangePreset', () {
    test('constructor with required fields', () {
      const preset = RepRangePreset(
        id: 'strength',
        labelKey: 'repPreset.strength.label',
        reps: 5,
        descriptionKey: 'repPreset.strength.description',
        iconName: 'fitness_center',
        colorHex: '#E53935',
      );
      expect(preset.id, 'strength');
      expect(preset.labelKey, 'repPreset.strength.label');
      expect(preset.reps, 5);
      expect(preset.minReps, isNull);
      expect(preset.maxReps, isNull);
      expect(preset.order, 0);
    });

    test('constructor with optional fields', () {
      const preset = RepRangePreset(
        id: 'hypertrophy',
        labelKey: 'label',
        reps: 10,
        minReps: 8,
        maxReps: 12,
        descriptionKey: 'desc',
        iconName: 'bolt',
        colorHex: '#FF5722',
        order: 2,
      );
      expect(preset.minReps, 8);
      expect(preset.maxReps, 12);
      expect(preset.order, 2);
    });

    test('hasRepRange true when min and max differ', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        minReps: 8,
        maxReps: 12,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      expect(preset.hasRepRange, true);
    });

    test('hasRepRange false when no range', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      expect(preset.hasRepRange, false);
    });

    test('hasRepRange false when min equals max', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        minReps: 10,
        maxReps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      expect(preset.hasRepRange, false);
    });

    test('color parses valid hex', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#E53935',
      );
      expect(preset.color, const Color(0xFFE53935));
    });

    test('color fallback on invalid hex', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: 'invalid',
      );
      // Should fallback to Material Blue 500
      expect(preset.color, const Color(0xFF2196F3));
    });

    test('color handles hex without #', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: 'FF5722',
      );
      expect(preset.color, const Color(0xFFFF5722));
    });

    test('icon returns mapped IconData', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'fitness_center',
        colorHex: '#000000',
      );
      expect(preset.icon, isA<IconData>());
    });

    test('icon fallback for unknown name', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'unknown_icon',
        colorHex: '#000000',
      );
      expect(preset.icon, isA<IconData>());
    });

    test('fromJson', () {
      final json = {
        'id': 'strength',
        'labelKey': 'repPreset.strength.label',
        'reps': 5,
        'minReps': 3,
        'maxReps': 6,
        'descriptionKey': 'repPreset.strength.description',
        'iconName': 'fitness_center',
        'colorHex': '#E53935',
        'order': 1,
      };
      final preset = RepRangePreset.fromJson(json);
      expect(preset.id, 'strength');
      expect(preset.reps, 5);
      expect(preset.minReps, 3);
      expect(preset.maxReps, 6);
      expect(preset.order, 1);
    });

    test('fromJson with defaults', () {
      final json = {
        'id': 'test',
        'labelKey': 'l',
        'reps': 10,
        'descriptionKey': 'd',
        'iconName': 'bolt',
        'colorHex': '#000000',
      };
      final preset = RepRangePreset.fromJson(json);
      expect(preset.minReps, isNull);
      expect(preset.maxReps, isNull);
      expect(preset.order, 0);
    });

    test('toJson', () {
      const preset = RepRangePreset(
        id: 'strength',
        labelKey: 'label',
        reps: 5,
        minReps: 3,
        maxReps: 6,
        descriptionKey: 'desc',
        iconName: 'fitness_center',
        colorHex: '#E53935',
        order: 1,
      );
      final json = preset.toJson();
      expect(json['id'], 'strength');
      expect(json['reps'], 5);
      expect(json['minReps'], 3);
      expect(json['maxReps'], 6);
      expect(json['order'], 1);
    });

    test('toJson omits null minReps/maxReps', () {
      const preset = RepRangePreset(
        id: 'test',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      final json = preset.toJson();
      expect(json.containsKey('minReps'), false);
      expect(json.containsKey('maxReps'), false);
    });

    test('equality', () {
      const a = RepRangePreset(
        id: 'strength',
        labelKey: 'l',
        reps: 5,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      const b = RepRangePreset(
        id: 'strength',
        labelKey: 'l',
        reps: 5,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      const c = RepRangePreset(
        id: 'hypertrophy',
        labelKey: 'l',
        reps: 10,
        descriptionKey: 'd',
        iconName: 'bolt',
        colorHex: '#000000',
      );
      expect(a == b, true);
      expect(a == c, false);
      expect(a.hashCode, b.hashCode);
    });

    test('all icon names resolve', () {
      const iconNames = [
        'fitness_center',
        'bolt',
        'trending_up',
        'bubble_chart',
        'timer',
        'all_inclusive',
        'speed',
        'flash_on',
        'schedule',
        'access_time',
        'hourglass_empty',
        'timer_off',
        'repeat',
      ];
      for (final name in iconNames) {
        final preset = RepRangePreset(
          id: 'test',
          labelKey: 'l',
          reps: 10,
          descriptionKey: 'd',
          iconName: name,
          colorHex: '#000000',
        );
        expect(preset.icon, isA<IconData>(),
            reason: 'Icon "$name" should resolve');
      }
    });
  });

  group('SetCountPreset', () {
    test('constructor', () {
      const preset = SetCountPreset(id: 'sets_3', sets: 3);
      expect(preset.id, 'sets_3');
      expect(preset.sets, 3);
      expect(preset.order, 0);
    });

    test('constructor with order', () {
      const preset = SetCountPreset(id: 'sets_5', sets: 5, order: 2);
      expect(preset.order, 2);
    });

    test('fromJson', () {
      final json = {'id': 'sets_4', 'sets': 4, 'order': 3};
      final preset = SetCountPreset.fromJson(json);
      expect(preset.id, 'sets_4');
      expect(preset.sets, 4);
      expect(preset.order, 3);
    });

    test('fromJson default order', () {
      final json = {'id': 'sets_3', 'sets': 3};
      final preset = SetCountPreset.fromJson(json);
      expect(preset.order, 0);
    });

    test('toJson', () {
      const preset = SetCountPreset(id: 'sets_3', sets: 3, order: 1);
      final json = preset.toJson();
      expect(json['id'], 'sets_3');
      expect(json['sets'], 3);
      expect(json['order'], 1);
    });

    test('equality', () {
      const a = SetCountPreset(id: 'sets_3', sets: 3);
      const b = SetCountPreset(id: 'sets_3', sets: 3);
      const c = SetCountPreset(id: 'sets_5', sets: 5);
      expect(a == b, true);
      expect(a == c, false);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('RestTimePreset', () {
    test('constructor', () {
      const preset = RestTimePreset(
        id: 'rest_60',
        labelKey: 'restPreset.oneMinute',
        seconds: 60,
        iconName: 'speed',
      );
      expect(preset.id, 'rest_60');
      expect(preset.labelKey, 'restPreset.oneMinute');
      expect(preset.seconds, 60);
      expect(preset.iconName, 'speed');
      expect(preset.order, 0);
    });

    test('constructor with null seconds (no timer)', () {
      const preset = RestTimePreset(
        id: 'rest_none',
        labelKey: 'restPreset.none',
        seconds: null,
        iconName: 'timer_off',
      );
      expect(preset.seconds, isNull);
    });

    test('fromJson', () {
      final json = {
        'id': 'rest_90',
        'labelKey': 'restPreset.ninetySeconds',
        'seconds': 90,
        'iconName': 'timer',
        'order': 2,
      };
      final preset = RestTimePreset.fromJson(json);
      expect(preset.id, 'rest_90');
      expect(preset.seconds, 90);
      expect(preset.order, 2);
    });

    test('fromJson with null seconds', () {
      final json = {
        'id': 'rest_none',
        'labelKey': 'restPreset.none',
        'seconds': null,
        'iconName': 'timer_off',
      };
      final preset = RestTimePreset.fromJson(json);
      expect(preset.seconds, isNull);
    });

    test('fromJson default order', () {
      final json = {
        'id': 'rest_60',
        'labelKey': 'l',
        'seconds': 60,
        'iconName': 'timer',
      };
      final preset = RestTimePreset.fromJson(json);
      expect(preset.order, 0);
    });

    test('toJson', () {
      const preset = RestTimePreset(
        id: 'rest_60',
        labelKey: 'restPreset.oneMinute',
        seconds: 60,
        iconName: 'speed',
        order: 1,
      );
      final json = preset.toJson();
      expect(json['id'], 'rest_60');
      expect(json['labelKey'], 'restPreset.oneMinute');
      expect(json['seconds'], 60);
      expect(json['iconName'], 'speed');
      expect(json['order'], 1);
    });

    test('icon returns mapped IconData', () {
      const preset = RestTimePreset(
        id: 'test',
        labelKey: 'l',
        seconds: 60,
        iconName: 'speed',
      );
      expect(preset.icon, isA<IconData>());
    });

    test('icon fallback for unknown name', () {
      const preset = RestTimePreset(
        id: 'test',
        labelKey: 'l',
        seconds: 60,
        iconName: 'unknown_icon',
      );
      expect(preset.icon, isA<IconData>());
    });

    test('equality', () {
      const a = RestTimePreset(
        id: 'rest_60',
        labelKey: 'l',
        seconds: 60,
        iconName: 'speed',
      );
      const b = RestTimePreset(
        id: 'rest_60',
        labelKey: 'l',
        seconds: 60,
        iconName: 'speed',
      );
      const c = RestTimePreset(
        id: 'rest_90',
        labelKey: 'l',
        seconds: 90,
        iconName: 'speed',
      );
      expect(a == b, true);
      expect(a == c, false);
      expect(a.hashCode, b.hashCode);
    });
  });
}
