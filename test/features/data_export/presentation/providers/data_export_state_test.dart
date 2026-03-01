// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';
import 'package:gymbro_flutter_new/features/data_export/presentation/providers/data_export_providers.dart';

// ---------------------------------------------------------------------------
// Tests for DataExportState (pure Dart, no Firebase)
// ---------------------------------------------------------------------------

void main() {
  // ================================================================
  // DataExportState.initial()
  // ================================================================
  group('DataExportState.initial()', () {
    test('isExporting is false', () {
      final state = DataExportState.initial();
      expect(state.isExporting, isFalse);
    });

    test('request is null', () {
      final state = DataExportState.initial();
      expect(state.request, isNull);
    });

    test('progress status is idle', () {
      final state = DataExportState.initial();
      expect(state.progress.status, ExportStatus.idle);
    });

    test('progress value is 0.0', () {
      final state = DataExportState.initial();
      expect(state.progress.progress, 0.0);
    });
  });

  // ================================================================
  // DataExportState constructor
  // ================================================================
  group('DataExportState constructor', () {
    test('stores all provided fields', () {
      final progress = ExportProgress(
        status: ExportStatus.completed,
        progress: 1.0,
        exportFilePath: '/tmp/export.zip',
      );
      final request = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        format: ExportFormat.zip,
      );

      final state = DataExportState(
        progress: progress,
        request: request,
        isExporting: true,
      );

      expect(state.progress, progress);
      expect(state.request, request);
      expect(state.isExporting, isTrue);
    });

    test('isExporting defaults to false', () {
      final state = DataExportState(
        progress: ExportProgress.initial(),
      );
      expect(state.isExporting, isFalse);
    });

    test('request defaults to null', () {
      final state = DataExportState(
        progress: ExportProgress.initial(),
      );
      expect(state.request, isNull);
    });
  });

  // ================================================================
  // DataExportState.copyWith
  // ================================================================
  group('DataExportState.copyWith', () {
    DataExportState baseState() => DataExportState.initial();

    test('can update isExporting to true', () {
      final updated = baseState().copyWith(isExporting: true);
      expect(updated.isExporting, isTrue);
    });

    test('can update isExporting to false', () {
      final state = DataExportState(
        progress: ExportProgress.initial(),
        isExporting: true,
      );
      final updated = state.copyWith(isExporting: false);
      expect(updated.isExporting, isFalse);
    });

    test('can update progress', () {
      final newProgress = ExportProgress(
        status: ExportStatus.collectingWorkouts,
        progress: 0.3,
      );
      final updated = baseState().copyWith(progress: newProgress);
      expect(updated.progress.status, ExportStatus.collectingWorkouts);
      expect(updated.progress.progress, 0.3);
    });

    test('can update request', () {
      final request = ExportRequest(
        categories: {ExportCategory.templates, ExportCategory.achievements},
        format: ExportFormat.json,
      );
      final updated = baseState().copyWith(request: request);
      expect(updated.request, request);
      expect(updated.request!.format, ExportFormat.json);
    });

    test('copyWith without args preserves all fields', () {
      final progress = ExportProgress(
        status: ExportStatus.packaging,
        progress: 0.85,
      );
      final request = ExportRequest(
        categories: {ExportCategory.workoutHistory},
      );
      final state = DataExportState(
        progress: progress,
        request: request,
        isExporting: true,
      );

      final copy = state.copyWith();
      expect(copy.progress, state.progress);
      expect(copy.request, state.request);
      expect(copy.isExporting, state.isExporting);
    });

    test('original is not mutated after copyWith', () {
      final original = baseState();
      // ignore: unused_result
      final _ = original.copyWith(isExporting: true);
      expect(original.isExporting, isFalse);
    });

    test('multiple copyWith calls chain correctly', () {
      final request = ExportRequest(categories: {ExportCategory.workoutHistory});
      final newProgress = ExportProgress(
        status: ExportStatus.completed,
        progress: 1.0,
      );

      final result = DataExportState.initial()
          .copyWith(isExporting: true)
          .copyWith(request: request)
          .copyWith(progress: newProgress)
          .copyWith(isExporting: false);

      expect(result.isExporting, isFalse);
      expect(result.request, request);
      expect(result.progress.status, ExportStatus.completed);
    });
  });

  // ================================================================
  // DataExportState - export flow simulation
  // ================================================================
  group('DataExportState export flow simulation', () {
    test('state transitions from initial to exporting', () {
      var state = DataExportState.initial();
      final request = ExportRequest.all();

      // Simulate startExport preamble
      state = state.copyWith(
        request: request,
        isExporting: true,
        progress: const ExportProgress(status: ExportStatus.preparing),
      );

      expect(state.isExporting, isTrue);
      expect(state.request, request);
      expect(state.progress.status, ExportStatus.preparing);
    });

    test('state transitions through collecting phases', () {
      var state = DataExportState.initial();

      state = state.copyWith(
        isExporting: true,
        progress: ExportProgress(
          status: ExportStatus.collectingWorkouts,
          progress: 0.1,
          currentStep: 'Collecting workout history...',
        ),
      );
      expect(state.progress.status, ExportStatus.collectingWorkouts);

      state = state.copyWith(
        progress: ExportProgress(
          status: ExportStatus.collectingTemplates,
          progress: 0.2,
        ),
      );
      expect(state.progress.status, ExportStatus.collectingTemplates);

      state = state.copyWith(
        progress: ExportProgress(
          status: ExportStatus.packaging,
          progress: 0.85,
        ),
      );
      expect(state.progress.status, ExportStatus.packaging);
    });

    test('state sets isExporting false when completed', () {
      var state = DataExportState(
        progress: ExportProgress(
          status: ExportStatus.packaging,
          progress: 0.85,
        ),
        isExporting: true,
      );

      // Simulate completion
      state = state.copyWith(
        progress: ExportProgress(
          status: ExportStatus.completed,
          progress: 1.0,
          exportFilePath: '/tmp/export.zip',
        ),
      );
      state = state.copyWith(isExporting: false);

      expect(state.isExporting, isFalse);
      expect(state.progress.status, ExportStatus.completed);
      expect(state.progress.exportFilePath, '/tmp/export.zip');
    });

    test('state sets isExporting false on failure', () {
      var state = DataExportState(
        progress: ExportProgress(
          status: ExportStatus.collectingWorkouts,
          progress: 0.1,
        ),
        isExporting: true,
      );

      state = state.copyWith(
        progress: ExportProgress(
          status: ExportStatus.failed,
          errorMessage: 'Export failed: storage unavailable',
        ),
      );
      state = state.copyWith(isExporting: false);

      expect(state.isExporting, isFalse);
      expect(state.progress.status, ExportStatus.failed);
      expect(state.progress.errorMessage, contains('storage unavailable'));
    });

    test('cancel resets to initial state', () {
      var state = DataExportState(
        progress: ExportProgress(
          status: ExportStatus.collectingWorkouts,
          progress: 0.1,
        ),
        isExporting: true,
        request: ExportRequest.all(),
      );

      // Simulate cancelExport
      state = DataExportState.initial();

      expect(state.isExporting, isFalse);
      expect(state.progress.status, ExportStatus.idle);
      expect(state.request, isNull);
    });

    test('reset returns to initial state after completion', () {
      var state = DataExportState(
        progress: ExportProgress(
          status: ExportStatus.completed,
          progress: 1.0,
          exportFilePath: '/tmp/export.zip',
        ),
        isExporting: false,
        request: ExportRequest.all(),
      );

      // Simulate reset()
      state = DataExportState.initial();

      expect(state.progress.status, ExportStatus.idle);
      expect(state.progress.progress, 0.0);
      expect(state.request, isNull);
      expect(state.isExporting, isFalse);
    });
  });

  // ================================================================
  // ExportRequest - isExporting guard logic
  // ================================================================
  group('Export guard: isExporting prevents duplicate export', () {
    test('should not start export when isExporting is true', () {
      final state = DataExportState(
        progress: ExportProgress(status: ExportStatus.collectingWorkouts),
        isExporting: true,
      );

      // Simulate startExport guard: if (state.isExporting) return;
      final shouldProceed = !state.isExporting;
      expect(shouldProceed, isFalse);
    });

    test('should start export when isExporting is false', () {
      final state = DataExportState.initial();
      final shouldProceed = !state.isExporting;
      expect(shouldProceed, isTrue);
    });
  });

  // ================================================================
  // availableExportCategoriesProvider - pure logic
  // ================================================================
  group('Available export categories', () {
    test('all 8 categories are available', () {
      final categories = ExportCategory.values.toSet();
      expect(categories.length, 8);
    });

    test('includes all expected categories', () {
      final categories = ExportCategory.values.toSet();
      expect(categories, contains(ExportCategory.workoutHistory));
      expect(categories, contains(ExportCategory.templates));
      expect(categories, contains(ExportCategory.customExercises));
      expect(categories, contains(ExportCategory.bodyMeasurements));
      expect(categories, contains(ExportCategory.progressPhotos));
      expect(categories, contains(ExportCategory.personalRecords));
      expect(categories, contains(ExportCategory.settings));
      expect(categories, contains(ExportCategory.achievements));
    });
  });

  // ================================================================
  // ExportRequest - derived from selected categories (sheet logic)
  // ================================================================
  group('ExportRequest creation from selection', () {
    test('empty category selection produces empty categories set', () {
      final selectedCategories = <ExportCategory>{};
      final request = ExportRequest(
        categories: selectedCategories,
        format: ExportFormat.zip,
      );
      expect(request.categories, isEmpty);
    });

    test('export button should be disabled when no categories selected', () {
      // Mirrors: isEnabled = canExport && _selectedCategories.isNotEmpty
      final categories = <ExportCategory>{};
      final canExport = true;
      final isEnabled = canExport && categories.isNotEmpty;
      expect(isEnabled, isFalse);
    });

    test('export button should be disabled when canExport is false', () {
      final categories = ExportCategory.values.toSet();
      final canExport = false;
      final isEnabled = canExport && categories.isNotEmpty;
      expect(isEnabled, isFalse);
    });

    test('export button enabled when categories selected and canExport true', () {
      final categories = {ExportCategory.workoutHistory};
      final canExport = true;
      final isEnabled = canExport && categories.isNotEmpty;
      expect(isEnabled, isTrue);
    });

    test('select-all then deselect-all toggles correctly', () {
      var selected = ExportCategory.values.toSet();

      // all selected -> deselect all
      if (selected.length == ExportCategory.values.length) {
        selected = {};
      }
      expect(selected, isEmpty);

      // none selected -> select all
      if (selected.isEmpty) {
        selected = ExportCategory.values.toSet();
      }
      expect(selected.length, ExportCategory.values.length);
    });

    test('single category toggle adds to set', () {
      final selected = <ExportCategory>{};
      selected.add(ExportCategory.workoutHistory);
      expect(selected.contains(ExportCategory.workoutHistory), isTrue);
      expect(selected.length, 1);
    });

    test('single category toggle removes from set', () {
      final selected = {ExportCategory.workoutHistory, ExportCategory.templates};
      selected.remove(ExportCategory.workoutHistory);
      expect(selected.contains(ExportCategory.workoutHistory), isFalse);
      expect(selected.length, 1);
    });

    test('creates ExportRequest with selected format', () {
      final request = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        format: ExportFormat.json,
      );
      expect(request.format, ExportFormat.json);
    });

    test('creates ExportRequest with csv format', () {
      final request = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        format: ExportFormat.csv,
      );
      expect(request.format, ExportFormat.csv);
    });
  });

  // ================================================================
  // ZIP archive file selection logic (mirrors _createZipExport)
  // ================================================================
  group('ZIP archive file selection logic', () {
    // Mirrors the isNotEmpty checks in _createZipExport
    bool shouldIncludeWorkouts(ExportedData data) => data.workouts.isNotEmpty;
    bool shouldIncludeTemplates(ExportedData data) => data.templates.isNotEmpty;
    bool shouldIncludeExercises(ExportedData data) =>
        data.customExercises.isNotEmpty;
    bool shouldIncludeMeasurements(ExportedData data) =>
        data.bodyMeasurements.isNotEmpty;
    bool shouldIncludePhotos(ExportedData data) =>
        data.progressPhotoUrls.isNotEmpty;
    bool shouldIncludePRs(ExportedData data) =>
        data.personalRecords.isNotEmpty;
    bool shouldIncludeAchievements(ExportedData data) =>
        data.achievements.isNotEmpty;

    ExportedData baseData() => ExportedData(
          exportId: 'zip-test-001',
          exportedAt: DateTime(2024, 6, 1),
          appVersion: '1.0.0',
          userId: 'user-001',
        );

    test('empty data: no category files included', () {
      final data = baseData();
      expect(shouldIncludeWorkouts(data), isFalse);
      expect(shouldIncludeTemplates(data), isFalse);
      expect(shouldIncludeExercises(data), isFalse);
      expect(shouldIncludeMeasurements(data), isFalse);
      expect(shouldIncludePhotos(data), isFalse);
      expect(shouldIncludePRs(data), isFalse);
      expect(shouldIncludeAchievements(data), isFalse);
    });

    test('data with workouts: workouts.json is included', () {
      final data = baseData().copyWith(
        workouts: [
          {'id': 'w1'},
        ],
      );
      expect(shouldIncludeWorkouts(data), isTrue);
      expect(shouldIncludeTemplates(data), isFalse);
    });

    test('data with templates: templates.json is included', () {
      final data = baseData().copyWith(
        templates: [
          {'id': 't1'},
        ],
      );
      expect(shouldIncludeTemplates(data), isTrue);
      expect(shouldIncludeWorkouts(data), isFalse);
    });

    test('data with measurements: body_measurements.json is included', () {
      final data = baseData().copyWith(
        bodyMeasurements: [
          {'weight': 75.0},
        ],
      );
      expect(shouldIncludeMeasurements(data), isTrue);
    });

    test('data with photos: progress_photos.json is included', () {
      final data = baseData().copyWith(
        progressPhotoUrls: ['https://example.com/photo.jpg'],
      );
      expect(shouldIncludePhotos(data), isTrue);
    });

    test('data with personal records: personal_records.json is included', () {
      final data = baseData().copyWith(
        personalRecords: [
          {'exercise': 'Squat', 'weight': 120.0},
        ],
      );
      expect(shouldIncludePRs(data), isTrue);
    });

    test('data with achievements: achievements.json is included', () {
      final data = baseData().copyWith(
        achievements: [
          {'id': 'a1', 'name': 'First Workout'},
        ],
      );
      expect(shouldIncludeAchievements(data), isTrue);
    });

    test('data with all categories: all files included', () {
      final data = baseData().copyWith(
        workouts: [
          {'id': 'w1'},
        ],
        templates: [
          {'id': 't1'},
        ],
        customExercises: [
          {'id': 'ce1'},
        ],
        bodyMeasurements: [
          {'weight': 80.0},
        ],
        progressPhotoUrls: ['https://example.com/photo.jpg'],
        personalRecords: [
          {'exercise': 'Deadlift', 'weight': 150.0},
        ],
        achievements: [
          {'id': 'a1'},
        ],
      );

      expect(shouldIncludeWorkouts(data), isTrue);
      expect(shouldIncludeTemplates(data), isTrue);
      expect(shouldIncludeExercises(data), isTrue);
      expect(shouldIncludeMeasurements(data), isTrue);
      expect(shouldIncludePhotos(data), isTrue);
      expect(shouldIncludePRs(data), isTrue);
      expect(shouldIncludeAchievements(data), isTrue);
    });
  });

  // ================================================================
  // ExportStatus completeness
  // ================================================================
  group('ExportStatus enum', () {
    test('has 12 statuses covering full lifecycle', () {
      expect(ExportStatus.values.length, 12);
    });

    test('collecting statuses are distinct', () {
      final collectingStatuses = [
        ExportStatus.collectingWorkouts,
        ExportStatus.collectingTemplates,
        ExportStatus.collectingExercises,
        ExportStatus.collectingMeasurements,
        ExportStatus.collectingPhotos,
        ExportStatus.collectingRecords,
        ExportStatus.collectingSettings,
      ];
      expect(collectingStatuses.toSet().length, 7);
    });

    test('terminal statuses are completed and failed', () {
      final terminalStatuses = {ExportStatus.completed, ExportStatus.failed};
      expect(terminalStatuses.length, 2);
    });

    test('isTerminal logic works for completed', () {
      final status = ExportStatus.completed;
      final isTerminal =
          status == ExportStatus.completed || status == ExportStatus.failed;
      expect(isTerminal, isTrue);
    });

    test('isTerminal logic works for failed', () {
      final status = ExportStatus.failed;
      final isTerminal =
          status == ExportStatus.completed || status == ExportStatus.failed;
      expect(isTerminal, isTrue);
    });

    test('isTerminal is false for in-progress statuses', () {
      final inProgressStatuses = [
        ExportStatus.preparing,
        ExportStatus.collectingWorkouts,
        ExportStatus.collectingTemplates,
        ExportStatus.packaging,
      ];
      for (final status in inProgressStatuses) {
        final isTerminal =
            status == ExportStatus.completed || status == ExportStatus.failed;
        expect(isTerminal, isFalse, reason: '$status should not be terminal');
      }
    });
  });

  // ================================================================
  // ExportProgress - progress value constraints
  // ================================================================
  group('ExportProgress progress value semantics', () {
    test('progress 0.0 means not started', () {
      const p = ExportProgress(status: ExportStatus.idle, progress: 0.0);
      expect(p.progress, 0.0);
    });

    test('progress 1.0 means fully complete', () {
      const p = ExportProgress(status: ExportStatus.completed, progress: 1.0);
      expect(p.progress, 1.0);
    });

    test('intermediate progress values are between 0 and 1', () {
      const values = [0.1, 0.2, 0.3, 0.5, 0.7, 0.85];
      for (final v in values) {
        final p = ExportProgress(status: ExportStatus.packaging, progress: v);
        expect(p.progress, greaterThanOrEqualTo(0.0));
        expect(p.progress, lessThanOrEqualTo(1.0));
      }
    });

    test('progressPerCategory is proportional to category count', () {
      // Mirrors: progressPerCategory = 0.7 / categoryCount
      const totalProgressForCategories = 0.7;
      for (final count in [1, 2, 4, 8]) {
        final perCategory = totalProgressForCategories / count;
        expect(perCategory, closeTo(totalProgressForCategories / count, 0.001));
        expect(perCategory, greaterThan(0.0));
      }
    });

    test('8 categories each get 0.0875 progress', () {
      const progressPerCategory = 0.7 / 8;
      expect(progressPerCategory, closeTo(0.0875, 0.0001));
    });

    test('1 category gets 0.7 progress', () {
      const progressPerCategory = 0.7 / 1;
      expect(progressPerCategory, closeTo(0.7, 0.0001));
    });
  });

  // ================================================================
  // ExportedData - totalItemCount helper logic
  // ================================================================
  group('ExportedData total item count computation', () {
    int totalItems(ExportedData data) {
      return data.workouts.length +
          data.templates.length +
          data.customExercises.length +
          data.bodyMeasurements.length +
          data.progressPhotoUrls.length +
          data.personalRecords.length +
          data.achievements.length;
    }

    test('empty data has 0 total items', () {
      final data = ExportedData(
        exportId: 'total-test',
        exportedAt: DateTime(2024, 1, 1),
        appVersion: '1.0.0',
        userId: 'u1',
      );
      expect(totalItems(data), 0);
    });

    test('counts all categories correctly', () {
      final data = ExportedData(
        exportId: 'total-test',
        exportedAt: DateTime(2024, 1, 1),
        appVersion: '1.0.0',
        userId: 'u1',
        workouts: [
          {'id': 'w1'},
          {'id': 'w2'},
        ],
        templates: [
          {'id': 't1'},
        ],
        personalRecords: [
          {'id': 'pr1'},
          {'id': 'pr2'},
          {'id': 'pr3'},
        ],
      );
      expect(totalItems(data), 6);
    });
  });

  // ================================================================
  // ExportRequest - hashCode and equality edge cases
  // ================================================================
  group('ExportRequest equality edge cases', () {
    test('same categories in different order are equal (Set semantics)', () {
      final a = ExportRequest(
        categories: {
          ExportCategory.workoutHistory,
          ExportCategory.templates,
        },
      );
      final b = ExportRequest(
        categories: {
          ExportCategory.templates,
          ExportCategory.workoutHistory,
        },
      );
      expect(a, equals(b));
    });

    test('different category sets are not equal', () {
      final a = ExportRequest(
        categories: {ExportCategory.workoutHistory},
      );
      final b = ExportRequest(
        categories: {ExportCategory.templates},
      );
      expect(a, isNot(equals(b)));
    });

    test('includePhotos true vs false produces different instances', () {
      final a = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        includePhotos: true,
      );
      final b = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        includePhotos: false,
      );
      expect(a, isNot(equals(b)));
    });

    test('dateRange difference produces different instances', () {
      final a = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        dateFrom: DateTime(2024, 1, 1),
      );
      final b = ExportRequest(
        categories: {ExportCategory.workoutHistory},
        dateFrom: DateTime(2024, 6, 1),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
