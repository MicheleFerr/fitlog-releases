// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/fitness_profile_local_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/medical_clearance_questionnaire.dart';

// ---------------------------------------------------------------------------
// In-memory fake for Box<Map> — no Hive initialisation required
// ---------------------------------------------------------------------------

/// Minimal in-memory [Box<Map>] fake.
///
/// Implements only the methods used by [FitnessProfileLocalDataSource]:
/// - [get]
/// - [put]
/// - [delete]
class _FakeBox implements Box<Map> {
  _FakeBox(this.name);

  @override
  final String name;

  final Map<String, Map> _store = {};

  // Inject an error to throw from the next [put] call.
  Exception? putError;

  // ---------------------------------------------------------------------------
  // Used by data source
  // ---------------------------------------------------------------------------

  @override
  Map? get(dynamic key, {Map? defaultValue}) => _store[key as String];

  @override
  Future<void> put(dynamic key, Map value) async {
    if (putError != null) throw putError!;
    _store[key as String] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key as String);
  }

  // ---------------------------------------------------------------------------
  // Unused Box members — satisfy the interface with stubs
  // ---------------------------------------------------------------------------

  @override
  bool get isOpen => true;

  @override
  bool get lazy => false;

  @override
  Iterable<Map> get values => _store.values;

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  int get length => _store.length;

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  bool containsKey(dynamic key) => _store.containsKey(key);

  @override
  Map? getAt(int index) => _store.values.elementAt(index);

  @override
  Future<void> putAt(int index, Map value) async {
    _store[_store.keys.elementAt(index)] = value;
  }

  @override
  Future<void> deleteAt(int index) async {
    _store.remove(_store.keys.elementAt(index));
  }

  @override
  Iterable<Map> valuesBetween({dynamic startKey, dynamic endKey}) =>
      _store.values;

  @override
  Map? keyAt(int index) => null;

  @override
  Future<int> clear() async {
    _store.clear();
    return 0;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> compact() async {}

  @override
  Future<void> deleteFromDisk() async {}

  @override
  Future<void> flush() async {}

  @override
  Future<Iterable<dynamic>> deleteAll(Iterable<dynamic> keys) async {
    for (final k in keys) {
      _store.remove(k as String);
    }
    return keys;
  }

  @override
  Future<void> putAll(Map<dynamic, Map> entries) async {
    for (final entry in entries.entries) {
      _store[entry.key as String] = entry.value;
    }
  }

  @override
  Map<dynamic, Map> toMap() => Map.unmodifiable(_store);

  @override
  String get path => '/fake/$name';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fake HiveBoxManagerEnhanced
//
// Holds one [_FakeBox] per box name so the data source gets the same
// in-memory box across multiple calls to [openBox].
// ---------------------------------------------------------------------------

class _FakeHiveBoxManager implements HiveBoxManagerEnhanced {
  _FakeHiveBoxManager();

  final Map<String, _FakeBox> _boxes = {};

  // Optional: inject an open error for a given box name.
  final Map<String, Exception> openErrors = {};

  _FakeBox boxFor(String name) =>
      _boxes.putIfAbsent(name, () => _FakeBox(name));

  @override
  Future<Box<E>> openBox<E>(
    String name, {
    HiveCipher? encryptionCipher,
    int maxRetries = 3,
  }) async {
    if (openErrors.containsKey(name)) throw openErrors[name]!;
    return boxFor(name) as Box<E>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

UserFitnessQuestionnaire _minimalQuestionnaire() =>
    UserFitnessQuestionnaire(
      bodyweightKg: 80.0,
      age: 30,
      heightCm: 180.0,
      sex: BiologicalSex.male,
      experienceLevel: ExperienceLevel.intermediate,
    );

UserFitnessQuestionnaire _fullQuestionnaire() => UserFitnessQuestionnaire(
      bodyweightKg: 65.5,
      age: 25,
      heightCm: 168.0,
      sex: BiologicalSex.female,
      experienceLevel: ExperienceLevel.novice,
      monthsOfTraining: 8,
      benchPressMax: 55.0,
      squatMax: 80.0,
      deadliftMax: 90.0,
      overheadPressMax: 35.0,
      trainingGoal: TrainingGoal.hypertrophy,
      hasInjuryHistory: true,
      injuryDetails: InjuryDetails(
        injuryType: 'Shoulder impingement',
        region: InjuryRegion.shoulder,
        monthsSinceInjury: 6,
        fullyRecovered: true,
      ),
      currentPainLevel: 0,
      suggestionStyle: SuggestionStyle.conservative,
      completedAt: DateTime(2024, 6, 15),
      allowPeriodicUpdates: true,
      selfReportCalibration: SelfReportCalibration.realistic,
    );

MedicalClearanceQuestionnaire _clearClearance() =>
    MedicalClearanceQuestionnaire(
      userAcknowledgedRisks: true,
      completedAt: DateTime(2024, 6, 14),
    );

MedicalClearanceQuestionnaire _highRiskClearance() =>
    MedicalClearanceQuestionnaire(
      hasHeartCondition: true,
      hasChestPain: true,
      hasDizzinessOrFainting: true,
      isHighRiskAge: true,
      hasFamilyHistory: true,
      currentSmoker: true,
      isObese: true,
      hasDiabetes: true,
      hasHighBloodPressure: true,
      userAcknowledgedRisks: false,
      completedAt: DateTime(2024, 5, 1),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeHiveBoxManager fakeManager;
  late FitnessProfileLocalDataSource dataSource;
  const userId = 'test_user_123';

  setUp(() {
    fakeManager = _FakeHiveBoxManager();
    dataSource = FitnessProfileLocalDataSource(fakeManager);
  });

  // =========================================================================
  // saveFitnessQuestionnaire
  // =========================================================================

  group('saveFitnessQuestionnaire', () {
    test('stores data under profile_<userId> key', () async {
      final questionnaire = _minimalQuestionnaire();
      await dataSource.saveFitnessQuestionnaire(questionnaire, userId);

      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      expect(box.containsKey('profile_$userId'), isTrue);
    });

    test('persists userId field alongside questionnaire data', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);

      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      final stored = box.get('profile_$userId') as Map<String, dynamic>;
      expect(stored['userId'], equals(userId));
    });

    test('persists lastModified timestamp as ISO-8601 string', () async {
      final before = DateTime.now();
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      final after = DateTime.now();

      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      final stored = box.get('profile_$userId') as Map<String, dynamic>;
      final saved = DateTime.parse(stored['lastModified'] as String);

      expect(saved.isAfter(before.subtract(Duration(seconds: 1))), isTrue);
      expect(saved.isBefore(after.add(Duration(seconds: 1))), isTrue);
    });

    test('saves full questionnaire with all optional fields', () async {
      final questionnaire = _fullQuestionnaire();
      await dataSource.saveFitnessQuestionnaire(questionnaire, userId);

      // Round-trip: read back and verify core fields
      final result = await dataSource.getFitnessQuestionnaire(userId);
      expect(result, isNotNull);
      expect(result!.bodyweightKg, equals(65.5));
      expect(result.benchPressMax, equals(55.0));
      expect(result.hasInjuryHistory, isTrue);
    });

    test('overwrites existing entry for the same userId', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);

      final updated = _minimalQuestionnaire().copyWith(bodyweightKg: 90.0);
      await dataSource.saveFitnessQuestionnaire(updated, userId);

      final result = await dataSource.getFitnessQuestionnaire(userId);
      expect(result!.bodyweightKg, equals(90.0));
    });

    test('isolates data between different users', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), 'user_A');
      final other = _minimalQuestionnaire().copyWith(bodyweightKg: 55.0);
      await dataSource.saveFitnessQuestionnaire(other, 'user_B');

      final resultA = await dataSource.getFitnessQuestionnaire('user_A');
      final resultB = await dataSource.getFitnessQuestionnaire('user_B');

      expect(resultA!.bodyweightKg, equals(80.0));
      expect(resultB!.bodyweightKg, equals(55.0));
    });

    test('propagates box exception on write failure', () async {
      fakeManager
          .boxFor(HiveBoxNames.fitnessProfile)
          .putError = Exception('disk full');

      await expectLater(
        dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId),
        throwsException,
      );
    });
  });

  // =========================================================================
  // getFitnessQuestionnaire
  // =========================================================================

  group('getFitnessQuestionnaire', () {
    test('returns null when box is empty', () async {
      final result = await dataSource.getFitnessQuestionnaire(userId);
      expect(result, isNull);
    });

    test('returns null for unknown userId when other users exist', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      final result = await dataSource.getFitnessQuestionnaire('other_user');
      expect(result, isNull);
    });

    test('returns saved questionnaire correctly', () async {
      final questionnaire = _minimalQuestionnaire();
      await dataSource.saveFitnessQuestionnaire(questionnaire, userId);

      final result = await dataSource.getFitnessQuestionnaire(userId);
      expect(result, isNotNull);
      expect(result!.bodyweightKg, equals(questionnaire.bodyweightKg));
      expect(result.age, equals(questionnaire.age));
      expect(result.sex, equals(questionnaire.sex));
      expect(result.experienceLevel, equals(questionnaire.experienceLevel));
    });

    test('returns null and does not throw when stored data is corrupted', () async {
      // Store a map that will fail fromJson (missing required fields)
      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      await box.put(
        'profile_$userId',
        <String, dynamic>{'corrupted': true, 'garbage': 'data'},
      );

      final result = await dataSource.getFitnessQuestionnaire(userId);
      // Data source catches parse errors and returns null
      expect(result, isNull);
    });

    test('handles empty map stored in box gracefully', () async {
      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      await box.put('profile_$userId', <String, dynamic>{});

      final result = await dataSource.getFitnessQuestionnaire(userId);
      expect(result, isNull);
    });
  });

  // =========================================================================
  // saveMedicalClearance
  // =========================================================================

  group('saveMedicalClearance', () {
    test('stores data under clearance_<userId> key', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      final box = fakeManager.boxFor(HiveBoxNames.medicalClearance);
      expect(box.containsKey('clearance_$userId'), isTrue);
    });

    test('persists userId and lastModified fields', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      final box = fakeManager.boxFor(HiveBoxNames.medicalClearance);
      final stored = box.get('clearance_$userId') as Map<String, dynamic>;

      expect(stored['userId'], equals(userId));
      expect(stored.containsKey('lastModified'), isTrue);
    });

    test('saves high-risk clearance without error', () async {
      await dataSource.saveMedicalClearance(_highRiskClearance(), userId);

      final result = await dataSource.getMedicalClearance(userId);
      expect(result, isNotNull);
      expect(result!.hasHeartCondition, isTrue);
      expect(result.hasDiabetes, isTrue);
    });

    test('overwrites previous clearance for same userId', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      final updated = _clearClearance().copyWith(currentSmoker: true);
      await dataSource.saveMedicalClearance(updated, userId);

      final result = await dataSource.getMedicalClearance(userId);
      expect(result!.currentSmoker, isTrue);
    });

    test('uses a separate box from fitness questionnaire', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      final profileBox = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      final clearanceBox = fakeManager.boxFor(HiveBoxNames.medicalClearance);

      expect(profileBox.length, equals(1));
      expect(clearanceBox.length, equals(1));
    });
  });

  // =========================================================================
  // getMedicalClearance
  // =========================================================================

  group('getMedicalClearance', () {
    test('returns null when box is empty', () async {
      final result = await dataSource.getMedicalClearance(userId);
      expect(result, isNull);
    });

    test('returns saved clearance correctly', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      final result = await dataSource.getMedicalClearance(userId);
      expect(result, isNotNull);
      expect(result!.userAcknowledgedRisks, isTrue);
    });

    test('returns null when stored data causes a type cast error during parsing', () async {
      // hasHeartCondition expects bool; supplying a non-castable value causes fromJson to throw.
      final box = fakeManager.boxFor(HiveBoxNames.medicalClearance);
      await box.put(
        'clearance_$userId',
        <String, dynamic>{'hasHeartCondition': 'not-a-bool-and-not-parseable-as-bool-by-json'},
      );

      // The data source catches the cast error and returns null gracefully.
      final result = await dataSource.getMedicalClearance(userId);
      expect(result, isNull);
    });

    test('returns null for unknown userId', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);
      final result = await dataSource.getMedicalClearance('stranger');
      expect(result, isNull);
    });
  });

  // =========================================================================
  // hasFitnessProfile / hasMedicalClearance
  // =========================================================================

  group('hasFitnessProfile', () {
    test('returns false when no profile exists', () async {
      expect(await dataSource.hasFitnessProfile(userId), isFalse);
    });

    test('returns true after profile saved', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      expect(await dataSource.hasFitnessProfile(userId), isTrue);
    });

    test('returns false after profile cleared', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      await dataSource.clearFitnessProfile(userId);
      expect(await dataSource.hasFitnessProfile(userId), isFalse);
    });
  });

  group('hasMedicalClearance', () {
    test('returns false when no clearance exists', () async {
      expect(await dataSource.hasMedicalClearance(userId), isFalse);
    });

    test('returns true after clearance saved', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);
      expect(await dataSource.hasMedicalClearance(userId), isTrue);
    });

    test('returns false after clearance cleared', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);
      await dataSource.clearMedicalClearance(userId);
      expect(await dataSource.hasMedicalClearance(userId), isFalse);
    });
  });

  // =========================================================================
  // clearFitnessProfile / clearMedicalClearance / clearAllUserData
  // =========================================================================

  group('clearFitnessProfile', () {
    test('removes profile entry from box', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      await dataSource.clearFitnessProfile(userId);

      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      expect(box.containsKey('profile_$userId'), isFalse);
    });

    test('does not throw when no profile exists', () async {
      await expectLater(
        dataSource.clearFitnessProfile('nonexistent_user'),
        completes,
      );
    });

    test('only removes the target user, not others', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), 'user_A');
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), 'user_B');
      await dataSource.clearFitnessProfile('user_A');

      expect(await dataSource.hasFitnessProfile('user_A'), isFalse);
      expect(await dataSource.hasFitnessProfile('user_B'), isTrue);
    });
  });

  group('clearMedicalClearance', () {
    test('removes clearance entry from box', () async {
      await dataSource.saveMedicalClearance(_clearClearance(), userId);
      await dataSource.clearMedicalClearance(userId);

      final box = fakeManager.boxFor(HiveBoxNames.medicalClearance);
      expect(box.containsKey('clearance_$userId'), isFalse);
    });

    test('does not throw when clearance does not exist', () async {
      await expectLater(
        dataSource.clearMedicalClearance('ghost_user'),
        completes,
      );
    });
  });

  group('clearAllUserData', () {
    test('removes both profile and clearance for user', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      await dataSource.clearAllUserData(userId);

      expect(await dataSource.hasFitnessProfile(userId), isFalse);
      expect(await dataSource.hasMedicalClearance(userId), isFalse);
    });

    test('does not affect other users data', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), 'user_A');
      await dataSource.saveMedicalClearance(_clearClearance(), 'user_A');
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), 'user_B');

      await dataSource.clearAllUserData('user_A');

      expect(await dataSource.hasFitnessProfile('user_B'), isTrue);
    });

    test('completes without error when user has no data', () async {
      await expectLater(dataSource.clearAllUserData('no_data_user'), completes);
    });
  });

  // =========================================================================
  // getLastModifiedTimestamp
  // =========================================================================

  group('getLastModifiedTimestamp', () {
    test('returns null when no profile exists', () async {
      final result = await dataSource.getLastModifiedTimestamp(userId);
      expect(result, isNull);
    });

    test('returns a DateTime close to save time', () async {
      final before = DateTime.now();
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      final after = DateTime.now();

      final ts = await dataSource.getLastModifiedTimestamp(userId);
      expect(ts, isNotNull);
      expect(ts!.isAfter(before.subtract(Duration(seconds: 1))), isTrue);
      expect(ts.isBefore(after.add(Duration(seconds: 1))), isTrue);
    });

    test('returns null when stored lastModified field is absent', () async {
      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      // Store data without lastModified key
      await box.put(
        'profile_$userId',
        <String, dynamic>{'bodyweightKg': 80.0},
      );

      final result = await dataSource.getLastModifiedTimestamp(userId);
      expect(result, isNull);
    });

    test('returns null when lastModified value is not a valid ISO-8601 string', () async {
      final box = fakeManager.boxFor(HiveBoxNames.fitnessProfile);
      await box.put(
        'profile_$userId',
        <String, dynamic>{'lastModified': 'not-a-date'},
      );

      final result = await dataSource.getLastModifiedTimestamp(userId);
      expect(result, isNull);
    });

    test('reflects updated timestamp after overwrite', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      final firstTs = await dataSource.getLastModifiedTimestamp(userId);

      // Brief artificial gap using future
      await Future.delayed(Duration(milliseconds: 5));

      await dataSource.saveFitnessQuestionnaire(
        _minimalQuestionnaire().copyWith(bodyweightKg: 85.0),
        userId,
      );
      final secondTs = await dataSource.getLastModifiedTimestamp(userId);

      expect(secondTs, isNotNull);
      // Second save should be >= first (could be equal on fast machines)
      expect(
        secondTs!.millisecondsSinceEpoch >=
            firstTs!.millisecondsSinceEpoch,
        isTrue,
      );
    });
  });

  // =========================================================================
  // exportFitnessData
  // =========================================================================

  group('exportFitnessData', () {
    test('returns null when no fitness profile exists', () async {
      final result = await dataSource.exportFitnessData(userId);
      expect(result, isNull);
    });

    test('returns export map when profile exists (no clearance)', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);

      final result = await dataSource.exportFitnessData(userId);
      expect(result, isNotNull);
      expect(result!['userId'], equals(userId));
      expect(result['version'], equals('1.0.0'));
      expect(result.containsKey('exportDate'), isTrue);
      expect(result['fitnessProfile'], isNotNull);
      expect(result['medicalClearance'], isNull);
    });

    test('includes medicalClearance when both records exist', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      await dataSource.saveMedicalClearance(_clearClearance(), userId);

      final result = await dataSource.exportFitnessData(userId);
      expect(result!['medicalClearance'], isNotNull);
    });

    test('exportDate is a valid ISO-8601 string', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      final result = await dataSource.exportFitnessData(userId);

      expect(() => DateTime.parse(result!['exportDate'] as String), returnsNormally);
    });
  });

  // =========================================================================
  // importFitnessData
  // =========================================================================

  group('importFitnessData', () {
    test('imports fitness profile from exported map', () async {
      // Setup: save and export
      await dataSource.saveFitnessQuestionnaire(_fullQuestionnaire(), userId);
      await dataSource.saveMedicalClearance(_clearClearance(), userId);
      final exported = await dataSource.exportFitnessData(userId);
      expect(exported, isNotNull);

      // Clear and re-import into a fresh data source
      final newManager = _FakeHiveBoxManager();
      final importedDs = FitnessProfileLocalDataSource(newManager);
      await importedDs.importFitnessData(exported!, 'new_user');

      final profile = await importedDs.getFitnessQuestionnaire('new_user');
      expect(profile, isNotNull);
      expect(profile!.bodyweightKg, equals(65.5));
      expect(profile.benchPressMax, equals(55.0));
    });

    test('imports medical clearance when present in map', () async {
      await dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId);
      await dataSource.saveMedicalClearance(_highRiskClearance(), userId);
      final exported = await dataSource.exportFitnessData(userId);

      final newManager = _FakeHiveBoxManager();
      final importedDs = FitnessProfileLocalDataSource(newManager);
      await importedDs.importFitnessData(exported!, 'imported_user');

      final clearance = await importedDs.getMedicalClearance('imported_user');
      expect(clearance, isNotNull);
      expect(clearance!.hasHeartCondition, isTrue);
    });

    test('skips medicalClearance import when field is null', () async {
      final data = <String, dynamic>{
        'userId': userId,
        'fitnessProfile': _minimalQuestionnaire().toJson(),
        'medicalClearance': null,
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
      };

      await dataSource.importFitnessData(data, userId);

      expect(await dataSource.hasFitnessProfile(userId), isTrue);
      expect(await dataSource.hasMedicalClearance(userId), isFalse);
    });

    test('skips fitnessProfile import when field is null', () async {
      final data = <String, dynamic>{
        'userId': userId,
        'fitnessProfile': null,
        'medicalClearance': _clearClearance().toJson(),
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
      };

      await dataSource.importFitnessData(data, userId);

      // Profile should not exist, clearance should
      expect(await dataSource.hasFitnessProfile(userId), isFalse);
      expect(await dataSource.hasMedicalClearance(userId), isTrue);
    });

    test('import followed by export round-trips data without loss', () async {
      final original = _fullQuestionnaire();
      await dataSource.saveFitnessQuestionnaire(original, userId);
      final exported = await dataSource.exportFitnessData(userId);

      final newManager = _FakeHiveBoxManager();
      final reimportedDs = FitnessProfileLocalDataSource(newManager);
      await reimportedDs.importFitnessData(exported!, 'round_trip_user');

      final retrieved = await reimportedDs.getFitnessQuestionnaire('round_trip_user');
      expect(retrieved!.age, equals(original.age));
      expect(retrieved.sex, equals(original.sex));
      expect(retrieved.experienceLevel, equals(original.experienceLevel));
      expect(retrieved.squatMax, equals(original.squatMax));
    });
  });

  // =========================================================================
  // Box manager error propagation
  // =========================================================================

  group('box manager error propagation', () {
    test('saveFitnessQuestionnaire propagates openBox error', () async {
      fakeManager.openErrors[HiveBoxNames.fitnessProfile] =
          Exception('cannot open fitness_profile box');

      await expectLater(
        dataSource.saveFitnessQuestionnaire(_minimalQuestionnaire(), userId),
        throwsException,
      );
    });

    test('saveMedicalClearance propagates openBox error', () async {
      fakeManager.openErrors[HiveBoxNames.medicalClearance] =
          Exception('cannot open medical_clearance box');

      await expectLater(
        dataSource.saveMedicalClearance(_clearClearance(), userId),
        throwsException,
      );
    });

    test('getFitnessQuestionnaire propagates openBox error', () async {
      fakeManager.openErrors[HiveBoxNames.fitnessProfile] =
          Exception('disk error');

      await expectLater(
        dataSource.getFitnessQuestionnaire(userId),
        throwsException,
      );
    });

    test('clearAllUserData propagates error when fitness box fails', () async {
      fakeManager.openErrors[HiveBoxNames.fitnessProfile] =
          Exception('box unavailable');

      await expectLater(
        dataSource.clearAllUserData(userId),
        throwsException,
      );
    });
  });
}
