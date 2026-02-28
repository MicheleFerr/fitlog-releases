import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';

void main() {
  final now = DateTime(2026, 2, 15, 10, 0);

  group('GymEquipmentProfile', () {
    group('constructor', () {
      test('creates instance with all fields', () {
        final profile = GymEquipmentProfile(
          id: 'test-id',
          name: 'Home Gym',
          defaultBarbellWeight: 15.0,
          availablePlates: [20, 10, 5],
          isDefault: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(profile.id, 'test-id');
        expect(profile.name, 'Home Gym');
        expect(profile.defaultBarbellWeight, 15.0);
        expect(profile.availablePlates, [20, 10, 5]);
        expect(profile.isDefault, isFalse);
        expect(profile.createdAt, now);
        expect(profile.updatedAt, now);
      });

      test('defaults for defaultBarbellWeight and availablePlates', () {
        final profile = GymEquipmentProfile(
          id: 'id',
          name: 'Test',
          createdAt: now,
          updatedAt: now,
        );

        expect(profile.defaultBarbellWeight, 20.0);
        expect(profile.availablePlates, [25, 20, 15, 10, 5, 2.5, 1.25]);
        expect(profile.isDefault, isFalse);
      });
    });

    group('create factory', () {
      test('generates UUID for id', () {
        final profile = GymEquipmentProfile.create(name: 'My Gym');

        expect(profile.id, isNotEmpty);
        expect(profile.id.length, greaterThan(10));
        expect(profile.name, 'My Gym');
      });

      test('uses default barbell weight when not specified', () {
        final profile = GymEquipmentProfile.create(name: 'Test');
        expect(profile.defaultBarbellWeight, 20.0);
      });

      test('uses custom barbell weight', () {
        final profile = GymEquipmentProfile.create(
          name: 'Test',
          defaultBarbellWeight: 15.0,
        );
        expect(profile.defaultBarbellWeight, 15.0);
      });

      test('uses default plates when not specified', () {
        final profile = GymEquipmentProfile.create(name: 'Test');
        expect(profile.availablePlates, [25, 20, 15, 10, 5, 2.5, 1.25]);
      });

      test('uses custom plates', () {
        final profile = GymEquipmentProfile.create(
          name: 'Test',
          availablePlates: [20, 10, 5],
        );
        expect(profile.availablePlates, [20, 10, 5]);
      });

      test('sets isDefault from parameter', () {
        final profile = GymEquipmentProfile.create(
          name: 'Default',
          isDefault: true,
        );
        expect(profile.isDefault, isTrue);
      });

      test('isDefault defaults to false', () {
        final profile = GymEquipmentProfile.create(name: 'Test');
        expect(profile.isDefault, isFalse);
      });

      test('sets createdAt and updatedAt to now', () {
        final before = DateTime.now();
        final profile = GymEquipmentProfile.create(name: 'Test');
        final after = DateTime.now();

        expect(profile.createdAt.isAfter(before) || profile.createdAt.isAtSameMomentAs(before), isTrue);
        expect(profile.createdAt.isBefore(after) || profile.createdAt.isAtSameMomentAs(after), isTrue);
        expect(profile.updatedAt, profile.createdAt);
      });

      test('generates unique IDs for different instances', () {
        final a = GymEquipmentProfile.create(name: 'Gym A');
        final b = GymEquipmentProfile.create(name: 'Gym B');

        expect(a.id, isNot(equals(b.id)));
      });
    });

    group('createDefault factory', () {
      test('uses fixed id default_profile', () {
        final profile = GymEquipmentProfile.createDefault();
        expect(profile.id, 'default_profile');
      });

      test('uses name Default', () {
        final profile = GymEquipmentProfile.createDefault();
        expect(profile.name, 'Default');
      });

      test('sets isDefault to true', () {
        final profile = GymEquipmentProfile.createDefault();
        expect(profile.isDefault, isTrue);
      });

      test('uses barbell weight 20.0', () {
        final profile = GymEquipmentProfile.createDefault();
        expect(profile.defaultBarbellWeight, 20.0);
      });

      test('uses standard plates when not specified', () {
        final profile = GymEquipmentProfile.createDefault();
        expect(profile.availablePlates, [25, 20, 15, 10, 5, 2.5, 1.25]);
      });

      test('accepts custom plates', () {
        final profile = GymEquipmentProfile.createDefault(
          availablePlates: [20, 10, 5],
        );
        expect(profile.availablePlates, [20, 10, 5]);
      });
    });

    group('copyWith', () {
      late GymEquipmentProfile original;

      setUp(() {
        original = GymEquipmentProfile(
          id: 'original-id',
          name: 'Original',
          defaultBarbellWeight: 20.0,
          availablePlates: [25, 20, 15, 10, 5],
          isDefault: false,
          createdAt: now,
          updatedAt: now,
        );
      });

      test('copies with new name', () {
        final copied = original.copyWith(name: 'Renamed');

        expect(copied.name, 'Renamed');
        expect(copied.id, original.id);
        expect(copied.defaultBarbellWeight, original.defaultBarbellWeight);
      });

      test('copies with new barbell weight', () {
        final copied = original.copyWith(defaultBarbellWeight: 15.0);
        expect(copied.defaultBarbellWeight, 15.0);
      });

      test('clearBarbellWeight sets weight to null', () {
        final copied = original.copyWith(clearBarbellWeight: true);
        expect(copied.defaultBarbellWeight, isNull);
      });

      test('clearBarbellWeight overrides defaultBarbellWeight param', () {
        final copied = original.copyWith(
          defaultBarbellWeight: 25.0,
          clearBarbellWeight: true,
        );
        expect(copied.defaultBarbellWeight, isNull);
      });

      test('copies with new plates', () {
        final copied = original.copyWith(availablePlates: [10, 5, 2.5]);
        expect(copied.availablePlates, [10, 5, 2.5]);
      });

      test('copies with new isDefault', () {
        final copied = original.copyWith(isDefault: true);
        expect(copied.isDefault, isTrue);
      });

      test('preserves id', () {
        final copied = original.copyWith(name: 'New Name');
        expect(copied.id, 'original-id');
      });

      test('preserves createdAt', () {
        final copied = original.copyWith(name: 'New Name');
        expect(copied.createdAt, now);
      });

      test('updates updatedAt', () {
        final copied = original.copyWith(name: 'New Name');
        expect(copied.updatedAt.isAfter(now) || copied.updatedAt.isAtSameMomentAs(now), isTrue);
      });

      test('preserves all unmodified fields', () {
        final copied = original.copyWith(isDefault: true);

        expect(copied.name, 'Original');
        expect(copied.defaultBarbellWeight, 20.0);
        expect(copied.availablePlates, [25, 20, 15, 10, 5]);
      });
    });

    group('equality', () {
      test('equal when id matches regardless of other fields', () {
        final a = GymEquipmentProfile(
          id: 'same-id',
          name: 'Gym A',
          defaultBarbellWeight: 20.0,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        final b = GymEquipmentProfile(
          id: 'same-id',
          name: 'Gym B',
          defaultBarbellWeight: 15.0,
          availablePlates: [10, 5],
          isDefault: true,
          createdAt: DateTime(2026, 2, 2),
          updatedAt: DateTime(2026, 2, 2),
        );

        expect(a, equals(b));
      });

      test('not equal when id differs', () {
        final a = GymEquipmentProfile(
          id: 'id-1',
          name: 'Same Name',
          createdAt: now,
          updatedAt: now,
        );
        final b = GymEquipmentProfile(
          id: 'id-2',
          name: 'Same Name',
          createdAt: now,
          updatedAt: now,
        );

        expect(a, isNot(equals(b)));
      });

      test('identical instance is equal', () {
        final profile = GymEquipmentProfile(
          id: 'id',
          name: 'Test',
          createdAt: now,
          updatedAt: now,
        );
        expect(profile, equals(profile));
      });

      test('not equal to non-GymEquipmentProfile', () {
        final profile = GymEquipmentProfile(
          id: 'id',
          name: 'Test',
          createdAt: now,
          updatedAt: now,
        );
        expect(profile == 'not a profile', isFalse);
      });
    });

    group('hashCode', () {
      test('same for profiles with same id', () {
        final a = GymEquipmentProfile(
          id: 'same-id',
          name: 'A',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
        final b = GymEquipmentProfile(
          id: 'same-id',
          name: 'B',
          createdAt: DateTime(2026, 2, 2),
          updatedAt: DateTime(2026, 2, 2),
        );

        expect(a.hashCode, equals(b.hashCode));
      });

      test('can be used in Set', () {
        final a = GymEquipmentProfile(
          id: 'id-1',
          name: 'A',
          createdAt: now,
          updatedAt: now,
        );
        final b = GymEquipmentProfile(
          id: 'id-1',
          name: 'B',
          createdAt: now,
          updatedAt: now,
        );
        final c = GymEquipmentProfile(
          id: 'id-2',
          name: 'C',
          createdAt: now,
          updatedAt: now,
        );

        final set = {a, b, c};
        expect(set.length, 2);
      });
    });

    group('toString', () {
      test('includes relevant info', () {
        final profile = GymEquipmentProfile(
          id: 'test-id',
          name: 'Home Gym',
          defaultBarbellWeight: 20.0,
          availablePlates: [25, 20, 15],
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        );

        final str = profile.toString();

        expect(str, contains('GymEquipmentProfile'));
        expect(str, contains('test-id'));
        expect(str, contains('Home Gym'));
        expect(str, contains('20.0'));
        expect(str, contains('3'));
        expect(str, contains('true'));
      });
    });

    group('static constants', () {
      test('standardPlates has correct values', () {
        expect(
          GymEquipmentProfile.standardPlates,
          [25, 20, 15, 10, 5, 2.5, 1.25],
        );
      });

      test('allPlates includes 0.5', () {
        expect(
          GymEquipmentProfile.allPlates,
          [25, 20, 15, 10, 5, 2.5, 1.25, 0.5],
        );
      });

      test('allPlates is superset of standardPlates', () {
        for (final plate in GymEquipmentProfile.standardPlates) {
          expect(GymEquipmentProfile.allPlates, contains(plate));
        }
      });

      test('commonBarbells has expected entries', () {
        expect(GymEquipmentProfile.commonBarbells, hasLength(4));
      });

      test('commonBarbells includes 20kg option', () {
        final option = GymEquipmentProfile.commonBarbells
            .firstWhere((o) => o.label == '20kg');
        expect(option.weight, 20.0);
      });

      test('commonBarbells includes 15kg option', () {
        final option = GymEquipmentProfile.commonBarbells
            .firstWhere((o) => o.label == '15kg');
        expect(option.weight, 15.0);
      });

      test('commonBarbells includes No barbell option with null weight', () {
        final option = GymEquipmentProfile.commonBarbells
            .firstWhere((o) => o.label == 'No');
        expect(option.weight, isNull);
      });

      test('commonBarbells includes EZ bar option', () {
        final option = GymEquipmentProfile.commonBarbells
            .firstWhere((o) => o.label == 'EZ 7.5');
        expect(option.weight, 7.5);
      });
    });
  });

  group('BarbellOption', () {
    test('creates with label and weight', () {
      const option = BarbellOption(label: '20kg', weight: 20.0);
      expect(option.label, '20kg');
      expect(option.weight, 20.0);
    });

    test('weight can be null (no barbell)', () {
      const option = BarbellOption(label: 'No barbell', weight: null);
      expect(option.label, 'No barbell');
      expect(option.weight, isNull);
    });

    test('supports decimal weights', () {
      const option = BarbellOption(label: 'EZ 7.5kg', weight: 7.5);
      expect(option.weight, 7.5);
    });
  });
}
