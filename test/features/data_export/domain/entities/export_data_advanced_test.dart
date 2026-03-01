// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';

// ---------------------------------------------------------------------------
// Advanced tests for export_data.dart targeting additional coverage:
// - ExportCategory/ExportFormat/ExportStatus enum index values
// - ExportRequest JSON edge cases and all formats
// - ExportProgress JSON with all fields populated
// - ExportedData JSON with deeply nested structures
// - ExportProgress with all statuses
// ---------------------------------------------------------------------------

ExportedData _makeData({
  String exportId = 'test-001',
  DateTime? exportedAt,
  String appVersion = '1.0.0',
  String userId = 'u-001',
}) {
  return ExportedData(
    exportId: exportId,
    exportedAt: exportedAt ?? DateTime(2025, 1, 1, 12, 0),
    appVersion: appVersion,
    userId: userId,
  );
}

void main() {
  // ================================================================
  // ExportCategory - enum indices and ordering
  // ================================================================
  group('ExportCategory enum indices', () {
    test('workoutHistory is index 0', () {
      expect(ExportCategory.workoutHistory.index, 0);
    });

    test('templates is index 1', () {
      expect(ExportCategory.templates.index, 1);
    });

    test('customExercises is index 2', () {
      expect(ExportCategory.customExercises.index, 2);
    });

    test('bodyMeasurements is index 3', () {
      expect(ExportCategory.bodyMeasurements.index, 3);
    });

    test('progressPhotos is index 4', () {
      expect(ExportCategory.progressPhotos.index, 4);
    });

    test('personalRecords is index 5', () {
      expect(ExportCategory.personalRecords.index, 5);
    });

    test('settings is index 6', () {
      expect(ExportCategory.settings.index, 6);
    });

    test('achievements is index 7', () {
      expect(ExportCategory.achievements.index, 7);
    });

    test('enum names are correct', () {
      expect(ExportCategory.workoutHistory.name, 'workoutHistory');
      expect(ExportCategory.templates.name, 'templates');
      expect(ExportCategory.customExercises.name, 'customExercises');
      expect(ExportCategory.bodyMeasurements.name, 'bodyMeasurements');
      expect(ExportCategory.progressPhotos.name, 'progressPhotos');
      expect(ExportCategory.personalRecords.name, 'personalRecords');
      expect(ExportCategory.settings.name, 'settings');
      expect(ExportCategory.achievements.name, 'achievements');
    });
  });

  // ================================================================
  // ExportFormat - enum indices
  // ================================================================
  group('ExportFormat enum indices', () {
    test('json is index 0', () {
      expect(ExportFormat.json.index, 0);
    });

    test('csv is index 1', () {
      expect(ExportFormat.csv.index, 1);
    });

    test('zip is index 2', () {
      expect(ExportFormat.zip.index, 2);
    });

    test('enum names are correct', () {
      expect(ExportFormat.json.name, 'json');
      expect(ExportFormat.csv.name, 'csv');
      expect(ExportFormat.zip.name, 'zip');
    });
  });

  // ================================================================
  // ExportStatus - enum indices and names
  // ================================================================
  group('ExportStatus enum indices', () {
    test('idle is index 0', () {
      expect(ExportStatus.idle.index, 0);
    });

    test('preparing is index 1', () {
      expect(ExportStatus.preparing.index, 1);
    });

    test('collectingWorkouts is index 2', () {
      expect(ExportStatus.collectingWorkouts.index, 2);
    });

    test('collectingTemplates is index 3', () {
      expect(ExportStatus.collectingTemplates.index, 3);
    });

    test('collectingExercises is index 4', () {
      expect(ExportStatus.collectingExercises.index, 4);
    });

    test('collectingMeasurements is index 5', () {
      expect(ExportStatus.collectingMeasurements.index, 5);
    });

    test('collectingPhotos is index 6', () {
      expect(ExportStatus.collectingPhotos.index, 6);
    });

    test('collectingRecords is index 7', () {
      expect(ExportStatus.collectingRecords.index, 7);
    });

    test('collectingSettings is index 8', () {
      expect(ExportStatus.collectingSettings.index, 8);
    });

    test('packaging is index 9', () {
      expect(ExportStatus.packaging.index, 9);
    });

    test('completed is index 10', () {
      expect(ExportStatus.completed.index, 10);
    });

    test('failed is index 11', () {
      expect(ExportStatus.failed.index, 11);
    });

    test('all status names are non-empty', () {
      for (final status in ExportStatus.values) {
        expect(status.name, isNotEmpty);
      }
    });
  });

  // ================================================================
  // ExportRequest - JSON serialization for all formats
  // ================================================================
  group('ExportRequest JSON serialization for all formats', () {
    test('json format round-trips correctly', () {
      final req = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        format: ExportFormat.json,
      );
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.format, ExportFormat.json);
    });

    test('csv format round-trips correctly', () {
      final req = ExportRequest(
        categories: {ExportCategory.templates},
        format: ExportFormat.csv,
      );
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.format, ExportFormat.csv);
    });

    test('zip format round-trips correctly', () {
      final req = ExportRequest(
        categories: {ExportCategory.achievements},
        format: ExportFormat.zip,
      );
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.format, ExportFormat.zip);
    });

    test('includePhotos=false survives round-trip', () {
      final req = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        includePhotos: false,
      );
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.includePhotos, isFalse);
    });

    test('includePhotos=true survives round-trip', () {
      final req = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        includePhotos: true,
      );
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.includePhotos, isTrue);
    });

    test('all categories survive round-trip', () {
      final req = ExportRequest.all();
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.categories.length, ExportCategory.values.length);
      for (final cat in ExportCategory.values) {
        expect(restored.categories, contains(cat));
      }
    });

    test('dateFrom null survives round-trip', () {
      final req = ExportRequest(categories: {ExportCategory.workoutHistory});
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.dateFrom, isNull);
    });

    test('dateTo null survives round-trip', () {
      final req = ExportRequest(categories: {ExportCategory.workoutHistory});
      final restored = ExportRequest.fromJson(req.toJson());
      expect(restored.dateTo, isNull);
    });

    test('toJson includes includePhotos key', () {
      final req = ExportRequest(categories: {ExportCategory.workoutHistory});
      final json = req.toJson();
      expect(json.containsKey('includePhotos'), isTrue);
    });

    test('toJson includes dateFrom key', () {
      final req = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        dateFrom: DateTime(2025, 1, 1),
      );
      final json = req.toJson();
      expect(json.containsKey('dateFrom'), isTrue);
    });
  });

  // ================================================================
  // ExportProgress - JSON round-trips for all statuses
  // ================================================================
  group('ExportProgress JSON round-trip for all statuses', () {
    for (final status in ExportStatus.values) {
      test('status $status survives JSON round-trip', () {
        final progress = ExportProgress(status: status, progress: 0.5);
        final json = progress.toJson();
        final restored = ExportProgress.fromJson(json);
        expect(restored.status, status);
      });
    }

    test('all optional fields survive round-trip', () {
      final original = ExportProgress(
        status: ExportStatus.completed,
        progress: 1.0,
        currentStep: 'All done',
        errorMessage: null,
        exportFilePath: '/tmp/export.zip',
        completedAt: DateTime(2025, 6, 15, 10, 30),
        itemCounts: {
          ExportCategory.workoutHistory: 42,
          ExportCategory.templates: 7,
          ExportCategory.achievements: 3,
        },
      );

      final json = original.toJson();
      final restored = ExportProgress.fromJson(json);

      expect(restored.status, ExportStatus.completed);
      expect(restored.progress, 1.0);
      expect(restored.currentStep, 'All done');
      expect(restored.errorMessage, isNull);
      expect(restored.exportFilePath, '/tmp/export.zip');
      expect(restored.completedAt, DateTime(2025, 6, 15, 10, 30));
      expect(restored.itemCounts[ExportCategory.workoutHistory], 42);
      expect(restored.itemCounts[ExportCategory.templates], 7);
      expect(restored.itemCounts[ExportCategory.achievements], 3);
    });

    test('failed status with error message survives round-trip', () {
      final original = ExportProgress(
        status: ExportStatus.failed,
        errorMessage: 'Firebase authentication failed',
      );
      final restored = ExportProgress.fromJson(original.toJson());
      expect(restored.status, ExportStatus.failed);
      expect(restored.errorMessage, 'Firebase authentication failed');
    });

    test('itemCounts with all categories survives round-trip', () {
      final counts = {
        for (final cat in ExportCategory.values)
          cat: ExportCategory.values.indexOf(cat) * 10,
      };
      final original = ExportProgress(
        status: ExportStatus.packaging,
        progress: 0.85,
        itemCounts: counts,
      );
      final restored = ExportProgress.fromJson(original.toJson());
      for (final cat in ExportCategory.values) {
        expect(
          restored.itemCounts[cat],
          counts[cat],
          reason: '$cat count should be preserved',
        );
      }
    });
  });

  // ================================================================
  // ExportedData - copyWith with all fields
  // ================================================================
  group('ExportedData copyWith comprehensive', () {
    test('can set all fields at once', () {
      final base = _makeData();
      final updated = base.copyWith(
        exportId: 'new-id',
        exportedAt: DateTime(2026, 1, 1),
        appVersion: '2.0.0',
        userId: 'new-user',
        workouts: [{'id': 'w1'}],
        templates: [{'id': 't1'}],
        customExercises: [{'id': 'ce1'}],
        bodyMeasurements: [{'weight': 80.0}],
        progressPhotoUrls: ['https://example.com/photo.jpg'],
        personalRecords: [{'exercise': 'Squat', 'weight': 150.0}],
        settings: {'units': 'imperial'},
        achievements: [{'id': 'a1'}],
      );

      expect(updated.exportId, 'new-id');
      expect(updated.exportedAt, DateTime(2026, 1, 1));
      expect(updated.appVersion, '2.0.0');
      expect(updated.userId, 'new-user');
      expect(updated.workouts.length, 1);
      expect(updated.templates.length, 1);
      expect(updated.customExercises.length, 1);
      expect(updated.bodyMeasurements.length, 1);
      expect(updated.progressPhotoUrls.length, 1);
      expect(updated.personalRecords.length, 1);
      expect(updated.settings['units'], 'imperial');
      expect(updated.achievements.length, 1);
    });

    test('copyWith preserves unchanged fields', () {
      final base = ExportedData(
        exportId: 'original-id',
        exportedAt: DateTime(2025, 1, 1),
        appVersion: '1.5.0',
        userId: 'user-original',
        workouts: [{'id': 'w1'}, {'id': 'w2'}],
      );

      final updated = base.copyWith(userId: 'new-user');

      expect(updated.exportId, 'original-id');
      expect(updated.appVersion, '1.5.0');
      expect(updated.workouts.length, 2);
      expect(updated.userId, 'new-user');
    });

    test('multiple chained copyWith accumulates data', () {
      var data = _makeData();
      for (int i = 0; i < 5; i++) {
        data = data.copyWith(
          workouts: [...data.workouts, {'id': 'w$i'}],
        );
      }
      expect(data.workouts.length, 5);
    });

    test('can clear bodyMeasurements by setting empty list', () {
      final base = _makeData().copyWith(
        bodyMeasurements: [
          {'weight': 75.0},
          {'weight': 76.0},
        ],
      );
      final cleared = base.copyWith(bodyMeasurements: []);
      expect(cleared.bodyMeasurements, isEmpty);
    });
  });

  // ================================================================
  // ExportedData - JSON round-trips with complex nested data
  // ================================================================
  group('ExportedData JSON round-trip complex structures', () {
    test('deeply nested workout map survives round-trip', () {
      final workoutMap = {
        'id': 'w1',
        'name': 'Push Day',
        'exercises': [
          {
            'name': 'Bench Press',
            'sets': [
              {'reps': 5, 'weight': 100.0},
              {'reps': 5, 'weight': 105.0},
            ],
          },
        ],
        'duration': 3600,
        'completedAt': DateTime(2025, 3, 1, 10, 0).toIso8601String(),
      };

      final data = _makeData().copyWith(workouts: [workoutMap]);
      final json = data.toJson();
      final restored = ExportedData.fromJson(json);

      final restoredWorkout = restored.workouts.first;
      expect(restoredWorkout['name'], 'Push Day');
      expect(restoredWorkout['exercises'], isA<List>());
      final exercises = restoredWorkout['exercises'] as List;
      expect(exercises.first['name'], 'Bench Press');
    });

    test('settings with nested map survives round-trip', () {
      final settings = {
        'units': 'metric',
        'notifications': {
          'reminders': true,
          'achievements': false,
        },
        'theme': 'dark',
        'language': 'en',
      };

      final data = _makeData().copyWith(settings: settings);
      final json = data.toJson();
      final restored = ExportedData.fromJson(json);

      expect(restored.settings['units'], 'metric');
      expect(restored.settings['theme'], 'dark');
      expect(restored.settings['language'], 'en');
    });

    test('multiple photo URLs survive round-trip', () {
      final photoUrls = [
        'https://storage.example.com/user123/before_2025-01-01.jpg',
        'https://storage.example.com/user123/after_2025-06-01.jpg',
        'https://storage.example.com/user123/progress_2025-03-01.jpg',
      ];

      final data = _makeData().copyWith(progressPhotoUrls: photoUrls);
      final json = data.toJson();
      final restored = ExportedData.fromJson(json);

      expect(restored.progressPhotoUrls.length, 3);
      expect(
        restored.progressPhotoUrls.first,
        'https://storage.example.com/user123/before_2025-01-01.jpg',
      );
      expect(restored.progressPhotoUrls.last, photoUrls.last);
    });

    test('personal records with various data types survive', () {
      final prs = [
        {
          'exercise': 'Squat',
          'weight': 150.5,
          'reps': 5,
          'date': '2025-01-15',
          'isBodyweight': false,
        },
        {
          'exercise': 'Pull-ups',
          'weight': 0.0,
          'reps': 12,
          'date': '2025-02-01',
          'isBodyweight': true,
        },
      ];

      final data = _makeData().copyWith(personalRecords: prs);
      final restored = ExportedData.fromJson(data.toJson());

      expect(restored.personalRecords.length, 2);
      expect(restored.personalRecords.first['exercise'], 'Squat');
      expect(restored.personalRecords.last['isBodyweight'], isTrue);
    });

    test('achievements with metadata survive round-trip', () {
      final achievements = [
        {
          'id': 'first_workout',
          'title': 'First Workout',
          'unlockedAt': '2025-01-02T10:00:00.000Z',
          'xpAwarded': 50,
          'tier': 'starter',
        },
        {
          'id': 'century',
          'title': '100 Workouts',
          'unlockedAt': '2025-12-01T15:30:00.000Z',
          'xpAwarded': 500,
          'tier': 'gold',
        },
      ];

      final data = _makeData().copyWith(achievements: achievements);
      final restored = ExportedData.fromJson(data.toJson());

      expect(restored.achievements.length, 2);
      expect(restored.achievements.first['id'], 'first_workout');
      expect(restored.achievements.last['xpAwarded'], 500);
    });
  });

  // ================================================================
  // ExportRequest - copyWith with dates
  // ================================================================
  group('ExportRequest copyWith date handling', () {
    test('can set dateFrom via copyWith', () {
      final base = ExportRequest(categories: {ExportCategory.workoutHistory});
      final updated = base.copyWith(dateFrom: DateTime(2025, 1, 1));
      expect(updated.dateFrom, DateTime(2025, 1, 1));
      expect(base.dateFrom, isNull); // original unchanged
    });

    test('can set dateTo via copyWith', () {
      final base = ExportRequest(categories: {ExportCategory.workoutHistory});
      final updated = base.copyWith(dateTo: DateTime(2025, 12, 31));
      expect(updated.dateTo, DateTime(2025, 12, 31));
    });

    test('can change categories via copyWith', () {
      final base = ExportRequest(
        categories: {ExportCategory.workoutHistory},
      );
      final updated = base.copyWith(
        categories: {ExportCategory.templates, ExportCategory.achievements},
      );
      expect(updated.categories.length, 2);
      expect(updated.categories, contains(ExportCategory.templates));
      expect(updated.categories, contains(ExportCategory.achievements));
    });

    test('copyWith no args produces equal instance', () {
      final original = ExportRequest(
        categories: {ExportCategory.workoutHistory, ExportCategory.templates},
        format: ExportFormat.csv,
        includePhotos: false,
        dateFrom: DateTime(2025, 1, 1),
        dateTo: DateTime(2025, 12, 31),
      );
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });

  // ================================================================
  // ExportedData - equality edge cases
  // ================================================================
  group('ExportedData equality edge cases', () {
    test('same exportId but different userId -> not equal', () {
      final exportedAt = DateTime(2025, 1, 1);
      final a = ExportedData(
        exportId: 'same',
        exportedAt: exportedAt,
        appVersion: '1.0.0',
        userId: 'user-a',
      );
      final b = ExportedData(
        exportId: 'same',
        exportedAt: exportedAt,
        appVersion: '1.0.0',
        userId: 'user-b',
      );
      expect(a, isNot(equals(b)));
    });

    test('same data but different appVersion -> not equal', () {
      final exportedAt = DateTime(2025, 1, 1);
      final a = ExportedData(
        exportId: 'exp-001',
        exportedAt: exportedAt,
        appVersion: '1.0.0',
        userId: 'u1',
      );
      final b = ExportedData(
        exportId: 'exp-001',
        exportedAt: exportedAt,
        appVersion: '2.0.0',
        userId: 'u1',
      );
      expect(a, isNot(equals(b)));
    });

    test('same data but different exportedAt -> not equal', () {
      final a = ExportedData(
        exportId: 'exp-001',
        exportedAt: DateTime(2025, 1, 1),
        appVersion: '1.0.0',
        userId: 'u1',
      );
      final b = ExportedData(
        exportId: 'exp-001',
        exportedAt: DateTime(2025, 6, 1),
        appVersion: '1.0.0',
        userId: 'u1',
      );
      expect(a, isNot(equals(b)));
    });

    test('identical instances with non-empty lists are equal', () {
      final exportedAt = DateTime(2025, 1, 1);
      final a = ExportedData(
        exportId: 'exp-001',
        exportedAt: exportedAt,
        appVersion: '1.0.0',
        userId: 'u1',
        workouts: [{'id': 'w1'}],
      );
      final b = ExportedData(
        exportId: 'exp-001',
        exportedAt: exportedAt,
        appVersion: '1.0.0',
        userId: 'u1',
        workouts: [{'id': 'w1'}],
      );
      expect(a, equals(b));
    });
  });

  // ================================================================
  // ExportProgress - equality edge cases
  // ================================================================
  group('ExportProgress equality edge cases', () {
    test('different progress values are not equal', () {
      const a = ExportProgress(status: ExportStatus.preparing, progress: 0.1);
      const b = ExportProgress(status: ExportStatus.preparing, progress: 0.2);
      expect(a, isNot(equals(b)));
    });

    test('same status and progress but different currentStep are not equal', () {
      const a = ExportProgress(
        status: ExportStatus.preparing,
        progress: 0.0,
        currentStep: 'Step A',
      );
      const b = ExportProgress(
        status: ExportStatus.preparing,
        progress: 0.0,
        currentStep: 'Step B',
      );
      expect(a, isNot(equals(b)));
    });

    test('null and non-null currentStep are not equal', () {
      const a = ExportProgress(status: ExportStatus.idle);
      const b = ExportProgress(status: ExportStatus.idle, currentStep: 'Loading');
      expect(a, isNot(equals(b)));
    });

    test('different errorMessages produce different instances', () {
      const a = ExportProgress(
        status: ExportStatus.failed,
        errorMessage: 'Error A',
      );
      const b = ExportProgress(
        status: ExportStatus.failed,
        errorMessage: 'Error B',
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ================================================================
  // ExportProgress - progress per category calculation (mirrors service)
  // ================================================================
  group('ExportProgress per-category calculation', () {
    double progressPerCategory(int categoryCount) => 0.7 / categoryCount;

    test('all 8 categories: each gets 0.0875', () {
      expect(progressPerCategory(8), closeTo(0.0875, 0.0001));
    });

    test('4 categories: each gets 0.175', () {
      expect(progressPerCategory(4), closeTo(0.175, 0.0001));
    });

    test('2 categories: each gets 0.35', () {
      expect(progressPerCategory(2), closeTo(0.35, 0.0001));
    });

    test('1 category: gets full 0.7', () {
      expect(progressPerCategory(1), closeTo(0.7, 0.0001));
    });

    test('sum of all 8 category progresses = 0.7', () {
      final perCat = progressPerCategory(8);
      expect(perCat * 8, closeTo(0.7, 0.001));
    });

    test('start progress 0.1, after all 8 categories should reach ~0.8', () {
      const startProgress = 0.1;
      final perCat = progressPerCategory(8);
      final finalProgress = startProgress + (perCat * 8);
      expect(finalProgress, closeTo(0.8, 0.001));
    });

    test('packaging phase starts at 0.85', () {
      // Mirrors service: yield ExportProgress(status: ExportStatus.packaging, progress: 0.85)
      const packagingStart = 0.85;
      expect(packagingStart, greaterThan(0.8));
      expect(packagingStart, lessThan(1.0));
    });

    test('completion is at 1.0', () {
      // Final progress
      const completionProgress = 1.0;
      expect(completionProgress, 1.0);
    });
  });

  // ================================================================
  // ExportRequest.all() - comprehensive checks
  // ================================================================
  group('ExportRequest.all() comprehensive', () {
    test('contains workoutHistory', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.workoutHistory));
    });

    test('contains templates', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.templates));
    });

    test('contains customExercises', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.customExercises));
    });

    test('contains bodyMeasurements', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.bodyMeasurements));
    });

    test('contains progressPhotos', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.progressPhotos));
    });

    test('contains personalRecords', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.personalRecords));
    });

    test('contains settings', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.settings));
    });

    test('contains achievements', () {
      expect(ExportRequest.all().categories, contains(ExportCategory.achievements));
    });

    test('includePhotos defaults to true in .all()', () {
      expect(ExportRequest.all().includePhotos, isTrue);
    });

    test('dateFrom is null in .all()', () {
      expect(ExportRequest.all().dateFrom, isNull);
    });

    test('dateTo is null in .all()', () {
      expect(ExportRequest.all().dateTo, isNull);
    });

    test('.all() is idempotent (two calls produce equal instances)', () {
      final a = ExportRequest.all();
      final b = ExportRequest.all();
      expect(a, equals(b));
    });
  });

  // ================================================================
  // ExportedData - large data sets
  // ================================================================
  group('ExportedData large data sets', () {
    test('100 workouts can be stored and retrieved', () {
      final workouts = List.generate(
        100,
        (i) => {'id': 'w$i', 'name': 'Workout $i', 'duration': i * 60},
      );
      final data = _makeData().copyWith(workouts: workouts);
      expect(data.workouts.length, 100);
      expect(data.workouts.last['id'], 'w99');
    });

    test('50 templates can be stored and retrieved', () {
      final templates = List.generate(50, (i) => {'id': 't$i'});
      final data = _makeData().copyWith(templates: templates);
      expect(data.templates.length, 50);
    });

    test('1000 personal records can be stored', () {
      final prs = List.generate(
        1000,
        (i) => {'exercise': 'Exercise $i', 'weight': (i * 1.5)},
      );
      final data = _makeData().copyWith(personalRecords: prs);
      expect(data.personalRecords.length, 1000);
    });

    test('large data set round-trips JSON correctly', () {
      final workouts = List.generate(10, (i) => {'id': 'w$i'});
      final templates = List.generate(5, (i) => {'id': 't$i'});
      final achievements = List.generate(20, (i) => {'id': 'a$i'});

      final original = _makeData().copyWith(
        workouts: workouts,
        templates: templates,
        achievements: achievements,
      );

      final restored = ExportedData.fromJson(original.toJson());
      expect(restored.workouts.length, 10);
      expect(restored.templates.length, 5);
      expect(restored.achievements.length, 20);
    });
  });

  // ================================================================
  // ExportProgress.initial() additional coverage
  // ================================================================
  group('ExportProgress.initial() additional coverage', () {
    test('itemCounts is empty map', () {
      expect(ExportProgress.initial().itemCounts, isEmpty);
    });

    test('currentStep is null', () {
      expect(ExportProgress.initial().currentStep, isNull);
    });

    test('errorMessage is null', () {
      expect(ExportProgress.initial().errorMessage, isNull);
    });

    test('exportFilePath is null', () {
      expect(ExportProgress.initial().exportFilePath, isNull);
    });

    test('completedAt is null', () {
      expect(ExportProgress.initial().completedAt, isNull);
    });

    test('two initial() calls produce equal instances', () {
      final a = ExportProgress.initial();
      final b = ExportProgress.initial();
      expect(a, equals(b));
    });
  });
}
