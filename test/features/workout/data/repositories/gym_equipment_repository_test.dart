import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/gym_equipment_repository.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

// Mocks
class MockHiveBoxManagerEnhanced extends Mock
    implements HiveBoxManagerEnhanced {}

class MockBox extends Mock implements Box<GymEquipmentProfile> {}

class FakeGymEquipmentProfile extends Fake implements GymEquipmentProfile {}

void main() {
  late GymEquipmentRepository repository;
  late MockHiveBoxManagerEnhanced mockBoxManager;
  late MockBox mockBox;

  final defaultProfile = GymEquipmentProfile(
    id: 'default_profile',
    name: 'Default',
    defaultBarbellWeight: 20.0,
    availablePlates: GymEquipmentProfile.standardPlates,
    isDefault: true,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  final customProfile = GymEquipmentProfile(
    id: 'custom-1',
    name: 'Home Gym',
    defaultBarbellWeight: 15.0,
    availablePlates: [20, 10, 5, 2.5],
    isDefault: false,
    createdAt: DateTime(2024, 2, 1),
    updatedAt: DateTime(2024, 2, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeGymEquipmentProfile());
  });

  setUp(() {
    mockBoxManager = MockHiveBoxManagerEnhanced();
    mockBox = MockBox();

    when(() => mockBoxManager.openBox<GymEquipmentProfile>('gym_equipment_profiles'))
        .thenAnswer((_) async => mockBox);

    when(() => mockBox.isOpen).thenReturn(true);
    when(() => mockBox.values).thenReturn([defaultProfile]);
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async {});
    when(() => mockBox.delete(any())).thenAnswer((_) async {});
    when(() => mockBox.flush()).thenAnswer((_) async {});
    when(() => mockBox.close()).thenAnswer((_) async {});

    repository = GymEquipmentRepository(mockBoxManager);
  });

  group('GymEquipmentRepository', () {
    group('init', () {
      test('opens Hive box on first init', () async {
        await repository.init();

        verify(() => mockBoxManager
            .openBox<GymEquipmentProfile>('gym_equipment_profiles')).called(1);
      });

      test('does not reopen box on subsequent init calls', () async {
        await repository.init();
        await repository.init();

        verify(() => mockBoxManager
            .openBox<GymEquipmentProfile>('gym_equipment_profiles')).called(1);
      });

      test('creates default profile if none exists', () async {
        when(() => mockBox.values).thenReturn([]);

        await repository.init();

        verify(() => mockBox.put(any(), any())).called(1);
      });

      test('does not create default profile if profiles exist', () async {
        when(() => mockBox.values).thenReturn([defaultProfile]);

        await repository.init();

        // put is only called if needed - default already exists
        // the init opens and checks. No extra put beyond _ensureDefaultProfile
        // Actually _ensureDefaultProfile calls getAllProfiles -> init (no-op) -> box.values
        // then sees it's not empty, returns without saving
        verifyNever(() => mockBox.put(any(), any()));
      });
    });

    group('getAllProfiles', () {
      test('returns profiles sorted with default first', () async {
        when(() => mockBox.values).thenReturn([customProfile, defaultProfile]);

        final profiles = await repository.getAllProfiles();

        expect(profiles.length, 2);
        expect(profiles[0].isDefault, true);
        expect(profiles[1].isDefault, false);
      });

      test('returns empty list when box is null (init failed)', () async {
        when(() => mockBoxManager
                .openBox<GymEquipmentProfile>('gym_equipment_profiles'))
            .thenThrow(Exception('Box open failed'));

        // Force a fresh repository since init hasn't been called yet
        final repo = GymEquipmentRepository(mockBoxManager);
        final profiles = await repo.getAllProfiles();

        expect(profiles, isEmpty);
      });

      test('sorts non-default profiles alphabetically by name', () async {
        final profileA = GymEquipmentProfile(
          id: 'a',
          name: 'Alpha Gym',
          isDefault: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        final profileZ = GymEquipmentProfile(
          id: 'z',
          name: 'Zeta Gym',
          isDefault: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        when(() => mockBox.values).thenReturn([profileZ, defaultProfile, profileA]);

        final profiles = await repository.getAllProfiles();

        expect(profiles[0].name, 'Default');
        expect(profiles[1].name, 'Alpha Gym');
        expect(profiles[2].name, 'Zeta Gym');
      });
    });

    group('getProfile', () {
      test('returns profile by ID', () async {
        when(() => mockBox.get('custom-1')).thenReturn(customProfile);

        final profile = await repository.getProfile('custom-1');

        expect(profile, isNotNull);
        expect(profile!.id, 'custom-1');
        expect(profile.name, 'Home Gym');
      });

      test('returns null for non-existent ID', () async {
        when(() => mockBox.get('nonexistent')).thenReturn(null);

        final profile = await repository.getProfile('nonexistent');

        expect(profile, isNull);
      });
    });

    group('getDefaultProfile', () {
      test('returns the default profile', () async {
        when(() => mockBox.values).thenReturn([customProfile, defaultProfile]);

        final profile = await repository.getDefaultProfile();

        expect(profile, isNotNull);
        expect(profile!.isDefault, true);
        expect(profile.name, 'Default');
      });

      test('returns first profile when no default exists', () async {
        final nonDefault = GymEquipmentProfile(
          id: 'nd-1',
          name: 'Non Default',
          isDefault: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        when(() => mockBox.values).thenReturn([nonDefault]);

        final profile = await repository.getDefaultProfile();

        expect(profile, isNotNull);
        expect(profile!.name, 'Non Default');
      });

      test('returns default-created profile when list is empty', () async {
        when(() => mockBox.values).thenReturn([]);

        final profile = await repository.getDefaultProfile();

        // getAllProfiles returns empty, so orElse triggers createDefault
        expect(profile, isNotNull);
        expect(profile!.id, 'default_profile');
      });
    });

    group('saveProfile', () {
      test('saves profile to Hive box', () async {
        await repository.saveProfile(customProfile);

        verify(() => mockBox.put('custom-1', customProfile)).called(1);
        verify(() => mockBox.flush()).called(1);
      });
    });

    group('setDefaultProfile', () {
      test('sets the specified profile as default', () async {
        when(() => mockBox.values).thenReturn([defaultProfile, customProfile]);

        await repository.setDefaultProfile('custom-1');

        // Should update each profile
        verify(() => mockBox.put(any(), any())).called(2);
        verify(() => mockBox.flush()).called(1);
      });
    });

    group('deleteProfile', () {
      test('deletes non-default profile', () async {
        when(() => mockBox.get('custom-1')).thenReturn(customProfile);

        await repository.deleteProfile('custom-1');

        verify(() => mockBox.delete('custom-1')).called(1);
      });

      test('does not delete default profile', () async {
        when(() => mockBox.get('default_profile')).thenReturn(defaultProfile);

        await repository.deleteProfile('default_profile');

        verifyNever(() => mockBox.delete('default_profile'));
      });

      test('does nothing for non-existent profile', () async {
        when(() => mockBox.get('nonexistent')).thenReturn(null);

        await repository.deleteProfile('nonexistent');

        verifyNever(() => mockBox.delete(any()));
      });
    });

    group('migrateFromLegacyConfig', () {
      test('does nothing with null plates', () async {
        await repository.migrateFromLegacyConfig(null);

        verifyNever(() => mockBox.put(any(), any()));
      });

      test('does nothing with empty plates', () async {
        await repository.migrateFromLegacyConfig([]);

        verifyNever(() => mockBox.put(any(), any()));
      });

      test('does not migrate if multiple profiles exist', () async {
        when(() => mockBox.values).thenReturn([defaultProfile, customProfile]);

        await repository.migrateFromLegacyConfig([20, 10, 5]);

        // Only the init call for _ensureDefaultProfile, no extra save
        verifyNever(() => mockBox.put('default_profile', any()));
      });
    });

    group('dispose', () {
      test('closes the Hive box', () async {
        await repository.init();
        await repository.dispose();

        verify(() => mockBox.close()).called(1);
      });
    });

    group('_listEquals', () {
      // Test through migrateFromLegacyConfig behavior
      test('migrate works when default plates match standard', () async {
        when(() => mockBox.values).thenReturn([defaultProfile]);

        await repository.migrateFromLegacyConfig([20, 10, 5]);

        // Should save because default plates are standard plates
        verify(() => mockBox.put(any(), any())).called(1);
      });
    });
  });
}
