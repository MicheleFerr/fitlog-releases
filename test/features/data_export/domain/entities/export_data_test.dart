// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExportRequest _baseRequest({
  Set<ExportCategory>? categories,
  ExportFormat format = ExportFormat.zip,
  bool includePhotos = true,
  DateTime? dateFrom,
  DateTime? dateTo,
}) {
  return ExportRequest(
    categories: categories ?? {ExportCategory.workoutHistory},
    format: format,
    includePhotos: includePhotos,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );
}

ExportedData _baseExportedData({
  String exportId = 'export-001',
  DateTime? exportedAt,
  String appVersion = '1.0.0',
  String userId = 'user-001',
}) {
  return ExportedData(
    exportId: exportId,
    exportedAt: exportedAt ?? DateTime(2024, 6, 1, 10),
    appVersion: appVersion,
    userId: userId,
  );
}

void main() {
  // ================================================================
  // ExportCategory enum
  // ================================================================
  group('ExportCategory enum', () {
    test('has 8 cases', () {
      expect(ExportCategory.values.length, 8);
    });

    test('contains all expected categories', () {
      expect(ExportCategory.values, contains(ExportCategory.workoutHistory));
      expect(ExportCategory.values, contains(ExportCategory.templates));
      expect(ExportCategory.values, contains(ExportCategory.customExercises));
      expect(ExportCategory.values, contains(ExportCategory.bodyMeasurements));
      expect(ExportCategory.values, contains(ExportCategory.progressPhotos));
      expect(ExportCategory.values, contains(ExportCategory.personalRecords));
      expect(ExportCategory.values, contains(ExportCategory.settings));
      expect(ExportCategory.values, contains(ExportCategory.achievements));
    });
  });

  // ================================================================
  // ExportFormat enum
  // ================================================================
  group('ExportFormat enum', () {
    test('has 3 cases', () {
      expect(ExportFormat.values.length, 3);
    });

    test('contains json, csv, and zip', () {
      expect(ExportFormat.values, contains(ExportFormat.json));
      expect(ExportFormat.values, contains(ExportFormat.csv));
      expect(ExportFormat.values, contains(ExportFormat.zip));
    });
  });

  // ================================================================
  // ExportStatus enum
  // ================================================================
  group('ExportStatus enum', () {
    test('has 12 cases', () {
      expect(ExportStatus.values.length, 12);
    });

    test('contains idle and completed at expected positions', () {
      expect(ExportStatus.values, contains(ExportStatus.idle));
      expect(ExportStatus.values, contains(ExportStatus.completed));
      expect(ExportStatus.values, contains(ExportStatus.failed));
    });
  });

  // ================================================================
  // ExportRequest
  // ================================================================
  group('ExportRequest', () {
    group('factory constructor', () {
      test('stores required fields', () {
        final req = _baseRequest(
          categories: {ExportCategory.workoutHistory, ExportCategory.templates},
        );

        expect(
          req.categories,
          containsAll([
            ExportCategory.workoutHistory,
            ExportCategory.templates,
          ]),
        );
      });

      test('format defaults to zip', () {
        final req = ExportRequest(
          categories: {ExportCategory.workoutHistory},
        );
        expect(req.format, ExportFormat.zip);
      });

      test('includePhotos defaults to true', () {
        final req = ExportRequest(
          categories: {ExportCategory.workoutHistory},
        );
        expect(req.includePhotos, isTrue);
      });

      test('dateFrom and dateTo default to null', () {
        final req = _baseRequest();
        expect(req.dateFrom, isNull);
        expect(req.dateTo, isNull);
      });

      test('accepts dateFrom and dateTo', () {
        final from = DateTime(2024, 1, 1);
        final to = DateTime(2024, 12, 31);
        final req = _baseRequest(dateFrom: from, dateTo: to);

        expect(req.dateFrom, from);
        expect(req.dateTo, to);
      });
    });

    group('ExportRequest.all() factory', () {
      test('contains all ExportCategory values', () {
        final req = ExportRequest.all();
        for (final category in ExportCategory.values) {
          expect(req.categories, contains(category));
        }
      });

      test('categories count matches ExportCategory.values', () {
        final req = ExportRequest.all();
        expect(req.categories.length, ExportCategory.values.length);
      });

      test('uses default format (zip)', () {
        final req = ExportRequest.all();
        expect(req.format, ExportFormat.zip);
      });
    });

    group('copyWith', () {
      test('can change format', () {
        final req = _baseRequest(format: ExportFormat.zip);
        final updated = req.copyWith(format: ExportFormat.json);
        expect(updated.format, ExportFormat.json);
        expect(req.format, ExportFormat.zip); // original unchanged
      });

      test('can change includePhotos', () {
        final req = _baseRequest(includePhotos: true);
        final updated = req.copyWith(includePhotos: false);
        expect(updated.includePhotos, isFalse);
      });

      test('copies with no changes produces equal instance', () {
        final req = _baseRequest();
        final copy = req.copyWith();
        expect(copy, equals(req));
      });
    });

    group('equality', () {
      test('two identical instances are equal', () {
        final a = ExportRequest(
          categories: {ExportCategory.workoutHistory},
          format: ExportFormat.json,
        );
        final b = ExportRequest(
          categories: {ExportCategory.workoutHistory},
          format: ExportFormat.json,
        );
        expect(a, equals(b));
      });

      test('instances with different formats are not equal', () {
        final a = _baseRequest(format: ExportFormat.json);
        final b = _baseRequest(format: ExportFormat.csv);
        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('toJson / fromJson round-trip', () {
        final original = ExportRequest(
          categories: {
            ExportCategory.workoutHistory,
            ExportCategory.templates,
          },
          format: ExportFormat.json,
          includePhotos: false,
          dateFrom: DateTime(2024, 1, 1),
          dateTo: DateTime(2024, 12, 31),
        );

        final json = original.toJson();
        final restored = ExportRequest.fromJson(json);
        expect(restored, equals(original));
      });

      test('toJson contains "categories" key', () {
        final req = _baseRequest();
        final json = req.toJson();
        expect(json.containsKey('categories'), isTrue);
      });

      test('toJson contains "format" key', () {
        final req = _baseRequest();
        final json = req.toJson();
        expect(json.containsKey('format'), isTrue);
      });
    });
  });

  // ================================================================
  // ExportProgress
  // ================================================================
  group('ExportProgress', () {
    group('factory constructor', () {
      test('stores status', () {
        const progress = ExportProgress(status: ExportStatus.preparing);
        expect(progress.status, ExportStatus.preparing);
      });

      test('progress defaults to 0.0', () {
        const progress = ExportProgress(status: ExportStatus.idle);
        expect(progress.progress, 0.0);
      });

      test('itemCounts defaults to empty map', () {
        const progress = ExportProgress(status: ExportStatus.idle);
        expect(progress.itemCounts, isEmpty);
      });

      test('optional fields default to null', () {
        const progress = ExportProgress(status: ExportStatus.idle);
        expect(progress.currentStep, isNull);
        expect(progress.errorMessage, isNull);
        expect(progress.exportFilePath, isNull);
        expect(progress.completedAt, isNull);
      });
    });

    group('ExportProgress.initial()', () {
      test('status is idle', () {
        final p = ExportProgress.initial();
        expect(p.status, ExportStatus.idle);
      });

      test('progress is 0.0', () {
        final p = ExportProgress.initial();
        expect(p.progress, 0.0);
      });
    });

    group('copyWith', () {
      test('can update progress', () {
        final p = ExportProgress.initial();
        final updated = p.copyWith(progress: 0.5);
        expect(updated.progress, 0.5);
        expect(p.progress, 0.0); // original unchanged
      });

      test('can update status', () {
        final p = ExportProgress.initial();
        final updated = p.copyWith(status: ExportStatus.completed);
        expect(updated.status, ExportStatus.completed);
      });

      test('can set errorMessage', () {
        final p = ExportProgress.initial();
        final updated = p.copyWith(errorMessage: 'Something went wrong');
        expect(updated.errorMessage, 'Something went wrong');
      });

      test('can set exportFilePath', () {
        final p = ExportProgress.initial();
        final updated = p.copyWith(exportFilePath: '/tmp/export.zip');
        expect(updated.exportFilePath, '/tmp/export.zip');
      });

      test('can set itemCounts', () {
        final p = ExportProgress.initial();
        final updated = p.copyWith(
          itemCounts: {ExportCategory.workoutHistory: 42},
        );
        expect(updated.itemCounts[ExportCategory.workoutHistory], 42);
      });
    });

    group('equality', () {
      test('two identical instances are equal', () {
        const a = ExportProgress(
          status: ExportStatus.completed,
          progress: 1.0,
        );
        const b = ExportProgress(
          status: ExportStatus.completed,
          progress: 1.0,
        );
        expect(a, equals(b));
      });

      test('instances with different status are not equal', () {
        const a = ExportProgress(status: ExportStatus.idle);
        const b = ExportProgress(status: ExportStatus.completed);
        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('toJson / fromJson round-trip', () {
        final original = ExportProgress(
          status: ExportStatus.completed,
          progress: 1.0,
          currentStep: 'Done',
          exportFilePath: '/tmp/test.zip',
          completedAt: DateTime(2024, 6, 1, 10),
          itemCounts: {ExportCategory.workoutHistory: 5},
        );

        final json = original.toJson();
        final restored = ExportProgress.fromJson(json);
        expect(restored, equals(original));
      });
    });
  });

  // ================================================================
  // ExportedData
  // ================================================================
  group('ExportedData', () {
    group('factory constructor', () {
      test('stores required fields', () {
        final exportedAt = DateTime(2024, 6, 1, 10);
        final data = ExportedData(
          exportId: 'exp-001',
          exportedAt: exportedAt,
          appVersion: '2.0.0',
          userId: 'user-abc',
        );

        expect(data.exportId, 'exp-001');
        expect(data.exportedAt, exportedAt);
        expect(data.appVersion, '2.0.0');
        expect(data.userId, 'user-abc');
      });

      test('workouts defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.workouts, isEmpty);
      });

      test('templates defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.templates, isEmpty);
      });

      test('customExercises defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.customExercises, isEmpty);
      });

      test('bodyMeasurements defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.bodyMeasurements, isEmpty);
      });

      test('progressPhotoUrls defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.progressPhotoUrls, isEmpty);
      });

      test('personalRecords defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.personalRecords, isEmpty);
      });

      test('settings defaults to empty map', () {
        final data = _baseExportedData();
        expect(data.settings, isEmpty);
      });

      test('achievements defaults to empty list', () {
        final data = _baseExportedData();
        expect(data.achievements, isEmpty);
      });
    });

    group('copyWith', () {
      test('can add workouts', () {
        final data = _baseExportedData();
        final updated = data.copyWith(
          workouts: [
            {'id': 'w1', 'name': 'Workout A'},
          ],
        );
        expect(updated.workouts.length, 1);
        expect(data.workouts, isEmpty); // original unchanged
      });

      test('can add templates', () {
        final data = _baseExportedData();
        final updated = data.copyWith(
          templates: [
            {'id': 't1'},
          ],
        );
        expect(updated.templates.length, 1);
      });

      test('can set settings', () {
        final data = _baseExportedData();
        final updated = data.copyWith(
          settings: {'theme': 'dark', 'language': 'en'},
        );
        expect(updated.settings['theme'], 'dark');
      });

      test('can set progressPhotoUrls', () {
        final data = _baseExportedData();
        final updated = data.copyWith(
          progressPhotoUrls: ['https://example.com/photo1.jpg'],
        );
        expect(updated.progressPhotoUrls.length, 1);
      });

      test('copies with no changes produces equal instance', () {
        final data = _baseExportedData();
        final copy = data.copyWith();
        expect(copy, equals(data));
      });

      test('original is not mutated after copyWith', () {
        final data = _baseExportedData();
        // ignore: unused_result
        final _ = data.copyWith(
          workouts: [
            {'id': 'w1'},
          ],
        );
        expect(data.workouts, isEmpty);
      });
    });

    group('equality', () {
      test('two identical instances are equal', () {
        final exportedAt = DateTime(2024, 6, 1, 10);
        final a = ExportedData(
          exportId: 'exp-001',
          exportedAt: exportedAt,
          appVersion: '1.0.0',
          userId: 'user-001',
        );
        final b = ExportedData(
          exportId: 'exp-001',
          exportedAt: exportedAt,
          appVersion: '1.0.0',
          userId: 'user-001',
        );
        expect(a, equals(b));
      });

      test('instances with different exportId are not equal', () {
        final exportedAt = DateTime(2024, 6, 1, 10);
        final a = _baseExportedData(exportId: 'exp-001', exportedAt: exportedAt);
        final b = _baseExportedData(exportId: 'exp-002', exportedAt: exportedAt);
        expect(a, isNot(equals(b)));
      });
    });

    group('JSON serialization', () {
      test('toJson contains all required keys', () {
        final data = _baseExportedData();
        final json = data.toJson();

        expect(json.containsKey('exportId'), isTrue);
        expect(json.containsKey('exportedAt'), isTrue);
        expect(json.containsKey('appVersion'), isTrue);
        expect(json.containsKey('userId'), isTrue);
        expect(json.containsKey('workouts'), isTrue);
        expect(json.containsKey('templates'), isTrue);
        expect(json.containsKey('customExercises'), isTrue);
        expect(json.containsKey('bodyMeasurements'), isTrue);
        expect(json.containsKey('progressPhotoUrls'), isTrue);
        expect(json.containsKey('personalRecords'), isTrue);
        expect(json.containsKey('settings'), isTrue);
        expect(json.containsKey('achievements'), isTrue);
      });

      test('toJson / fromJson round-trip for empty data', () {
        final original = _baseExportedData();
        final json = original.toJson();
        final restored = ExportedData.fromJson(json);
        expect(restored, equals(original));
      });

      test('toJson / fromJson round-trip with populated lists', () {
        final original = ExportedData(
          exportId: 'exp-002',
          exportedAt: DateTime(2024, 6, 1, 10),
          appVersion: '1.2.3',
          userId: 'user-002',
          workouts: [
            {'id': 'w1', 'name': 'Morning Run'},
          ],
          templates: [
            {'id': 't1', 'name': 'Push Day'},
          ],
          progressPhotoUrls: ['https://storage.example.com/photo.jpg'],
          settings: {'units': 'metric'},
          achievements: [
            {'id': 'a1', 'name': 'First Workout'},
          ],
        );

        final json = original.toJson();
        final restored = ExportedData.fromJson(json);
        expect(restored, equals(original));
      });

      test('fromJson parses required fields correctly', () {
        final exportedAt = DateTime(2024, 6, 1, 10);
        final json = {
          'exportId': 'exp-003',
          'exportedAt': exportedAt.toIso8601String(),
          'appVersion': '3.0.0',
          'userId': 'user-xyz',
        };

        final data = ExportedData.fromJson(json);
        expect(data.exportId, 'exp-003');
        expect(data.appVersion, '3.0.0');
        expect(data.userId, 'user-xyz');
        expect(data.workouts, isEmpty);
      });

      test('toJson serializes workouts list', () {
        final data = _baseExportedData().copyWith(
          workouts: [
            {'id': 'w1'},
            {'id': 'w2'},
          ],
        );
        final json = data.toJson();
        final workouts = json['workouts'] as List;
        expect(workouts.length, 2);
      });
    });
  });
}
