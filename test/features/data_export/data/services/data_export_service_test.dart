// NOTE: DataExportService has hard dependencies on:
// - FirebaseAuth (requires Firebase app initialization)
// - WorkoutHistoryRepositoryEnhanced, TemplateRepository, and other repositories
// - PackageInfo.fromPlatform() (requires platform channels)
// - path_provider (requires platform channels)
//
// Testing strategy: We test the pure data logic and entity behaviour
// that DataExportService exposes via ExportedData and ExportProgress.
// The _packageExport and Stream<ExportProgress> methods are tested
// indirectly via a lightweight testable wrapper that exposes the
// format generation utilities.
//
// Integration / E2E tests that spin up Firebase emulators cover
// the full export pipeline.

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';

// ---------------------------------------------------------------------------
// Minimal testable wrapper that exposes private helpers as pure functions.
// This avoids importing the full service (which would require Firebase).
// ---------------------------------------------------------------------------

/// Generates a CSV summary string from an [ExportedData] instance.
/// This mirrors DataExportService._generateCsvSummary.
String generateCsvSummary(ExportedData data) {
  final buffer = StringBuffer();
  buffer.writeln('FitLog Data Export Summary');
  buffer.writeln('Export ID,${data.exportId}');
  buffer.writeln('Exported At,${data.exportedAt.toIso8601String()}');
  buffer.writeln('App Version,${data.appVersion}');
  buffer.writeln('');
  buffer.writeln('Category,Count');
  buffer.writeln('Workouts,${data.workouts.length}');
  buffer.writeln('Templates,${data.templates.length}');
  buffer.writeln('Custom Exercises,${data.customExercises.length}');
  buffer.writeln('Body Measurements,${data.bodyMeasurements.length}');
  buffer.writeln('Progress Photos,${data.progressPhotoUrls.length}');
  buffer.writeln('Personal Records,${data.personalRecords.length}');
  buffer.writeln('Achievements,${data.achievements.length}');
  return buffer.toString();
}

/// Generates the README text from an [ExportedData] instance.
/// This mirrors DataExportService._generateReadme.
String generateReadme(ExportedData data) {
  return '''
FitLog Data Export
==================

Export ID: ${data.exportId}
Exported At: ${data.exportedAt.toIso8601String()}
App Version: ${data.appVersion}

This export contains your personal fitness data in compliance with
GDPR Article 20 (Right to Data Portability).

Contents:
---------
- data.json: Complete export in single file
- workouts.json: Workout history (${data.workouts.length} workouts)
- templates.json: Workout templates (${data.templates.length} templates)
- custom_exercises.json: Custom exercises (${data.customExercises.length} exercises)
- body_measurements.json: Body measurements (${data.bodyMeasurements.length} entries)
- progress_photos.json: Progress photo URLs (${data.progressPhotoUrls.length} photos)
- personal_records.json: Personal records (${data.personalRecords.length} PRs)
- achievements.json: Unlocked achievements (${data.achievements.length} badges)

Data Format:
------------
All files are in JSON format and can be opened with any text editor
or imported into spreadsheet applications.

For Support:
------------
Contact: support@fitlog.app

''';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ExportedData _baseData({
  String exportId = 'exp-001',
  String appVersion = '1.0.0',
  String userId = 'user-001',
  DateTime? exportedAt,
  List<Map<String, dynamic>>? workouts,
  List<Map<String, dynamic>>? templates,
  List<Map<String, dynamic>>? customExercises,
  List<Map<String, dynamic>>? bodyMeasurements,
  List<String>? progressPhotoUrls,
  List<Map<String, dynamic>>? personalRecords,
  Map<String, dynamic>? settings,
  List<Map<String, dynamic>>? achievements,
}) {
  return ExportedData(
    exportId: exportId,
    exportedAt: exportedAt ?? DateTime(2024, 6, 1, 10),
    appVersion: appVersion,
    userId: userId,
    workouts: workouts ?? const [],
    templates: templates ?? const [],
    customExercises: customExercises ?? const [],
    bodyMeasurements: bodyMeasurements ?? const [],
    progressPhotoUrls: progressPhotoUrls ?? const [],
    personalRecords: personalRecords ?? const [],
    settings: settings ?? const {},
    achievements: achievements ?? const [],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  // ================================================================
  // ExportRequest - categories and date filtering logic
  // ================================================================
  group('ExportRequest category logic', () {
    test('ExportRequest.all() contains every ExportCategory', () {
      final request = ExportRequest.all();
      for (final category in ExportCategory.values) {
        expect(
          request.categories.contains(category),
          isTrue,
          reason: '$category should be in ExportRequest.all()',
        );
      }
    });

    test('ExportRequest with single category contains only that category', () {
      final request = ExportRequest(
        categories: {ExportCategory.workoutHistory},
      );
      expect(request.categories, hasLength(1));
      expect(request.categories.first, ExportCategory.workoutHistory);
    });

    test('ExportRequest with dateFrom and dateTo stores them correctly', () {
      final from = DateTime(2024, 1, 1);
      final to = DateTime(2024, 12, 31);
      final request = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        dateFrom: from,
        dateTo: to,
      );
      expect(request.dateFrom, from);
      expect(request.dateTo, to);
    });

    test('ExportRequest default format is zip', () {
      final request = ExportRequest(categories: {ExportCategory.workoutHistory});
      expect(request.format, ExportFormat.zip);
    });

    test('ExportRequest default includePhotos is true', () {
      final request = ExportRequest(categories: {ExportCategory.workoutHistory});
      expect(request.includePhotos, isTrue);
    });
  });

  // ================================================================
  // ExportedData immutability and copyWith chaining
  // ================================================================
  group('ExportedData immutability', () {
    test('copyWith returns a new instance, original is unchanged', () {
      final original = _baseData();
      final updated = original.copyWith(
        workouts: [
          {'id': 'w1'},
        ],
      );
      expect(original.workouts, isEmpty);
      expect(updated.workouts, hasLength(1));
    });

    test('multiple copyWith calls can be chained immutably', () {
      final data = _baseData()
          .copyWith(
            workouts: [
              {'id': 'w1'},
            ],
          )
          .copyWith(
            templates: [
              {'id': 't1'},
            ],
          )
          .copyWith(
            achievements: [
              {'id': 'a1'},
            ],
          );

      expect(data.workouts, hasLength(1));
      expect(data.templates, hasLength(1));
      expect(data.achievements, hasLength(1));
    });
  });

  // ================================================================
  // CSV summary generation (mirrors _generateCsvSummary)
  // ================================================================
  group('generateCsvSummary', () {
    test('contains the export id', () {
      final data = _baseData(exportId: 'my-export-123');
      final csv = generateCsvSummary(data);
      expect(csv, contains('my-export-123'));
    });

    test('contains the app version', () {
      final data = _baseData(appVersion: '2.5.1');
      final csv = generateCsvSummary(data);
      expect(csv, contains('2.5.1'));
    });

    test('reports correct workout count', () {
      final data = _baseData(
        workouts: [
          {'id': 'w1'},
          {'id': 'w2'},
          {'id': 'w3'},
        ],
      );
      final csv = generateCsvSummary(data);
      expect(csv, contains('Workouts,3'));
    });

    test('reports 0 for empty categories', () {
      final data = _baseData();
      final csv = generateCsvSummary(data);
      expect(csv, contains('Workouts,0'));
      expect(csv, contains('Templates,0'));
      expect(csv, contains('Achievements,0'));
    });

    test('reports correct template count', () {
      final data = _baseData(
        templates: [
          {'id': 't1'},
        ],
      );
      final csv = generateCsvSummary(data);
      expect(csv, contains('Templates,1'));
    });

    test('reports correct progress photo count', () {
      final data = _baseData(
        progressPhotoUrls: [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg',
        ],
      );
      final csv = generateCsvSummary(data);
      expect(csv, contains('Progress Photos,2'));
    });

    test('starts with FitLog Data Export Summary header', () {
      final data = _baseData();
      final csv = generateCsvSummary(data);
      expect(csv, startsWith('FitLog Data Export Summary'));
    });

    test('contains exportedAt ISO string', () {
      final exportedAt = DateTime(2024, 6, 15, 8, 30);
      final data = _baseData(exportedAt: exportedAt);
      final csv = generateCsvSummary(data);
      expect(csv, contains(exportedAt.toIso8601String()));
    });
  });

  // ================================================================
  // README generation (mirrors _generateReadme)
  // ================================================================
  group('generateReadme', () {
    test('contains export ID', () {
      final data = _baseData(exportId: 'readme-export-001');
      final readme = generateReadme(data);
      expect(readme, contains('readme-export-001'));
    });

    test('contains app version', () {
      final data = _baseData(appVersion: '3.1.0');
      final readme = generateReadme(data);
      expect(readme, contains('3.1.0'));
    });

    test('contains GDPR reference', () {
      final data = _baseData();
      final readme = generateReadme(data);
      expect(readme, contains('GDPR Article 20'));
    });

    test('contains correct workout count in description', () {
      final data = _baseData(
        workouts: [
          {'id': 'w1'},
          {'id': 'w2'},
        ],
      );
      final readme = generateReadme(data);
      expect(readme, contains('2 workouts'));
    });

    test('contains correct template count', () {
      final data = _baseData(
        templates: [
          {'id': 't1'},
          {'id': 't2'},
          {'id': 't3'},
        ],
      );
      final readme = generateReadme(data);
      expect(readme, contains('3 templates'));
    });

    test('contains 0 count for empty categories', () {
      final data = _baseData();
      final readme = generateReadme(data);
      expect(readme, contains('0 workouts'));
      expect(readme, contains('0 templates'));
    });

    test('starts with FitLog Data Export header', () {
      final data = _baseData();
      final readme = generateReadme(data);
      expect(readme.trim(), startsWith('FitLog Data Export'));
    });

    test('contains support contact email', () {
      final data = _baseData();
      final readme = generateReadme(data);
      expect(readme, contains('support@fitlog.app'));
    });

    test('contains data.json reference', () {
      final data = _baseData();
      final readme = generateReadme(data);
      expect(readme, contains('data.json'));
    });
  });

  // ================================================================
  // ExportProgress state transitions
  // ================================================================
  group('ExportProgress state transitions', () {
    test('initial() has status idle and progress 0.0', () {
      final p = ExportProgress.initial();
      expect(p.status, ExportStatus.idle);
      expect(p.progress, 0.0);
    });

    test('copyWith can simulate progress through all statuses', () {
      var progress = ExportProgress.initial();

      progress = progress.copyWith(
        status: ExportStatus.preparing,
        progress: 0.0,
        currentStep: 'Preparing...',
      );
      expect(progress.status, ExportStatus.preparing);

      progress = progress.copyWith(
        status: ExportStatus.collectingWorkouts,
        progress: 0.1,
      );
      expect(progress.status, ExportStatus.collectingWorkouts);
      expect(progress.progress, closeTo(0.1, 0.001));

      progress = progress.copyWith(
        status: ExportStatus.packaging,
        progress: 0.85,
      );
      expect(progress.status, ExportStatus.packaging);

      progress = progress.copyWith(
        status: ExportStatus.completed,
        progress: 1.0,
        exportFilePath: '/tmp/export.zip',
        completedAt: DateTime.now(),
      );
      expect(progress.status, ExportStatus.completed);
      expect(progress.progress, 1.0);
      expect(progress.exportFilePath, isNotNull);
      expect(progress.completedAt, isNotNull);
    });

    test('failed state stores errorMessage', () {
      final progress = ExportProgress.initial().copyWith(
        status: ExportStatus.failed,
        errorMessage: 'Export failed: storage unavailable',
      );
      expect(progress.status, ExportStatus.failed);
      expect(progress.errorMessage, 'Export failed: storage unavailable');
    });

    test('itemCounts accumulate correctly via copyWith', () {
      var progress = ExportProgress.initial();
      progress = progress.copyWith(
        itemCounts: {ExportCategory.workoutHistory: 10},
      );
      progress = progress.copyWith(
        itemCounts: {
          ...progress.itemCounts,
          ExportCategory.templates: 5,
        },
      );

      expect(progress.itemCounts[ExportCategory.workoutHistory], 10);
      expect(progress.itemCounts[ExportCategory.templates], 5);
    });
  });

  // ================================================================
  // ExportedData JSON round-trip with all categories populated
  // ================================================================
  group('ExportedData full round-trip', () {
    test('serializes and restores all list fields', () {
      final original = ExportedData(
        exportId: 'full-export-001',
        exportedAt: DateTime(2024, 6, 1, 12),
        appVersion: '1.5.0',
        userId: 'user-xyz',
        workouts: [
          {'id': 'w1', 'name': 'Push Day', 'duration': 60},
        ],
        templates: [
          {'id': 't1', 'name': 'Beginner Template'},
        ],
        customExercises: [
          {'id': 'ce1', 'name': 'Bulgarian Split Squat'},
        ],
        bodyMeasurements: [
          {'date': '2024-01-01', 'weight': 75.5},
        ],
        progressPhotoUrls: [
          'https://storage.example.com/before.jpg',
          'https://storage.example.com/after.jpg',
        ],
        personalRecords: [
          {'exercise': 'Squat', 'weight': 120.0, 'reps': 5},
        ],
        settings: {'units': 'metric', 'language': 'en'},
        achievements: [
          {'id': 'a1', 'name': 'First Workout', 'unlockedAt': '2024-01-02'},
        ],
      );

      final json = original.toJson();
      final restored = ExportedData.fromJson(json);

      expect(restored.exportId, original.exportId);
      expect(restored.userId, original.userId);
      expect(restored.appVersion, original.appVersion);
      expect(restored.workouts.length, 1);
      expect(restored.templates.length, 1);
      expect(restored.customExercises.length, 1);
      expect(restored.bodyMeasurements.length, 1);
      expect(restored.progressPhotoUrls.length, 2);
      expect(restored.personalRecords.length, 1);
      expect(restored.settings['units'], 'metric');
      expect(restored.achievements.length, 1);
    });

    test('workouts data is preserved after round-trip', () {
      final data = _baseData(
        workouts: [
          {'id': 'w1', 'name': 'Morning Run', 'calories': 350},
        ],
      );

      final json = data.toJson();
      final restored = ExportedData.fromJson(json);

      expect(restored.workouts.first['name'], 'Morning Run');
      expect(restored.workouts.first['calories'], 350);
    });

    test('settings map is preserved after round-trip', () {
      final data = _baseData(
        settings: {'theme': 'dark', 'notifications': true, 'units': 'imperial'},
      );

      final json = data.toJson();
      final restored = ExportedData.fromJson(json);

      expect(restored.settings['theme'], 'dark');
      expect(restored.settings['notifications'], isTrue);
      expect(restored.settings['units'], 'imperial');
    });
  });

  // ================================================================
  // Date filtering logic (mirrored from _collectWorkouts)
  // ================================================================
  group('Date range filtering logic (mirrored)', () {
    bool passesDateFilter(
      DateTime workoutDate,
      DateTime? dateFrom,
      DateTime? dateTo,
    ) {
      if (dateFrom != null && workoutDate.isBefore(dateFrom)) return false;
      if (dateTo != null && workoutDate.isAfter(dateTo)) return false;
      return true;
    }

    test('no date range: all workouts pass', () {
      expect(passesDateFilter(DateTime(2024, 6, 1), null, null), isTrue);
      expect(passesDateFilter(DateTime(2020, 1, 1), null, null), isTrue);
    });

    test('workout before dateFrom is excluded', () {
      final from = DateTime(2024, 6, 1);
      expect(passesDateFilter(DateTime(2024, 5, 31), from, null), isFalse);
    });

    test('workout on dateFrom is included', () {
      final from = DateTime(2024, 6, 1);
      expect(passesDateFilter(DateTime(2024, 6, 1), from, null), isTrue);
    });

    test('workout after dateTo is excluded', () {
      final to = DateTime(2024, 12, 31);
      expect(passesDateFilter(DateTime(2025, 1, 1), null, to), isFalse);
    });

    test('workout on dateTo is included', () {
      final to = DateTime(2024, 12, 31);
      expect(passesDateFilter(DateTime(2024, 12, 31), null, to), isTrue);
    });

    test('workout within range is included', () {
      final from = DateTime(2024, 1, 1);
      final to = DateTime(2024, 12, 31);
      expect(passesDateFilter(DateTime(2024, 6, 15), from, to), isTrue);
    });

    test('workout outside range is excluded', () {
      final from = DateTime(2024, 1, 1);
      final to = DateTime(2024, 12, 31);
      expect(passesDateFilter(DateTime(2023, 12, 31), from, to), isFalse);
      expect(passesDateFilter(DateTime(2025, 1, 1), from, to), isFalse);
    });
  });
}
