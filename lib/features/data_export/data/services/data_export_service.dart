/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/services
/// 🎯 Feature: data_export
/// 🔧 Type: service
/// 📱 Platform: Universal
///
/// GDPR Article 20 - Right to Data Portability
/// Collects and exports all user data in portable format
library;

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';
import 'package:gymbro_flutter_new/features/history/data/repositories/workout_history_repository_enhanced.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/repositories/progress_photo_repository.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/pr_celebration_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';

/// Service for exporting user data (GDPR Art. 20)
class DataExportService {
  DataExportService({
    required WorkoutHistoryRepositoryEnhanced workoutRepository,
    required TemplateRepository templateRepository,
    required CustomExerciseRepository customExerciseRepository,
    required MeasurementRepository measurementRepository,
    required ProgressPhotoRepository photoRepository,
    required PRCelebrationRepository prRepository,
    FirebaseAuth? auth,
  })  : _workoutRepository = workoutRepository,
        _templateRepository = templateRepository,
        _customExerciseRepository = customExerciseRepository,
        _measurementRepository = measurementRepository,
        _photoRepository = photoRepository,
        _prRepository = prRepository,
        _auth = auth ?? FirebaseAuth.instance;

  final WorkoutHistoryRepositoryEnhanced _workoutRepository;
  final TemplateRepository _templateRepository;
  final CustomExerciseRepository _customExerciseRepository;
  final MeasurementRepository _measurementRepository;
  final ProgressPhotoRepository _photoRepository;
  final PRCelebrationRepository _prRepository;
  final FirebaseAuth _auth;

  /// Export all user data based on request
  ///
  /// Returns the path to the exported ZIP file
  Stream<ExportProgress> exportData(ExportRequest request) async* {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      yield const ExportProgress(
        status: ExportStatus.failed,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    try {
      yield const ExportProgress(
        status: ExportStatus.preparing,
        progress: 0.0,
        currentStep: 'Preparing export...',
      );

      final exportId = const Uuid().v4();
      final packageInfo = await PackageInfo.fromPlatform();
      final itemCounts = <ExportCategory, int>{};

      // Collect data from each category
      final data = ExportedData(
        exportId: exportId,
        exportedAt: DateTime.now(),
        appVersion: packageInfo.version,
        userId: userId,
      );

      var updatedData = data;
      var progress = 0.1;
      final categoryCount = request.categories.length;
      final progressPerCategory = 0.7 / categoryCount;

      // Collect workouts
      if (request.categories.contains(ExportCategory.workoutHistory)) {
        yield ExportProgress(
          status: ExportStatus.collectingWorkouts,
          progress: progress,
          currentStep: 'Collecting workout history...',
          itemCounts: itemCounts,
        );

        final workouts = await _collectWorkouts(userId, request);
        updatedData = updatedData.copyWith(workouts: workouts);
        itemCounts[ExportCategory.workoutHistory] = workouts.length;
        progress += progressPerCategory;
      }

      // Collect templates
      if (request.categories.contains(ExportCategory.templates)) {
        yield ExportProgress(
          status: ExportStatus.collectingTemplates,
          progress: progress,
          currentStep: 'Collecting templates...',
          itemCounts: itemCounts,
        );

        final templates = await _collectTemplates();
        updatedData = updatedData.copyWith(templates: templates);
        itemCounts[ExportCategory.templates] = templates.length;
        progress += progressPerCategory;
      }

      // Collect custom exercises
      if (request.categories.contains(ExportCategory.customExercises)) {
        yield ExportProgress(
          status: ExportStatus.collectingExercises,
          progress: progress,
          currentStep: 'Collecting custom exercises...',
          itemCounts: itemCounts,
        );

        final exercises = await _collectCustomExercises();
        updatedData = updatedData.copyWith(customExercises: exercises);
        itemCounts[ExportCategory.customExercises] = exercises.length;
        progress += progressPerCategory;
      }

      // Collect body measurements
      if (request.categories.contains(ExportCategory.bodyMeasurements)) {
        yield ExportProgress(
          status: ExportStatus.collectingMeasurements,
          progress: progress,
          currentStep: 'Collecting body measurements...',
          itemCounts: itemCounts,
        );

        final measurements = await _collectMeasurements(userId);
        updatedData = updatedData.copyWith(bodyMeasurements: measurements);
        itemCounts[ExportCategory.bodyMeasurements] = measurements.length;
        progress += progressPerCategory;
      }

      // Collect progress photos (URLs only for now)
      if (request.categories.contains(ExportCategory.progressPhotos)) {
        yield ExportProgress(
          status: ExportStatus.collectingPhotos,
          progress: progress,
          currentStep: 'Collecting progress photos...',
          itemCounts: itemCounts,
        );

        final photoUrls = await _collectPhotoUrls(userId);
        updatedData = updatedData.copyWith(progressPhotoUrls: photoUrls);
        itemCounts[ExportCategory.progressPhotos] = photoUrls.length;
        progress += progressPerCategory;
      }

      // Collect personal records
      if (request.categories.contains(ExportCategory.personalRecords)) {
        yield ExportProgress(
          status: ExportStatus.collectingRecords,
          progress: progress,
          currentStep: 'Collecting personal records...',
          itemCounts: itemCounts,
        );

        final prs = await _collectPersonalRecords(userId);
        updatedData = updatedData.copyWith(personalRecords: prs);
        itemCounts[ExportCategory.personalRecords] = prs.length;
        progress += progressPerCategory;
      }

      // Collect settings
      if (request.categories.contains(ExportCategory.settings)) {
        yield ExportProgress(
          status: ExportStatus.collectingSettings,
          progress: progress,
          currentStep: 'Collecting settings...',
          itemCounts: itemCounts,
        );

        final settings = await _collectSettings();
        updatedData = updatedData.copyWith(settings: settings);
        itemCounts[ExportCategory.settings] = 1;
        progress += progressPerCategory;
      }

      // Package the export
      yield ExportProgress(
        status: ExportStatus.packaging,
        progress: 0.85,
        currentStep: 'Creating export file...',
        itemCounts: itemCounts,
      );

      final filePath = await _packageExport(updatedData, request.format);

      yield ExportProgress(
        status: ExportStatus.completed,
        progress: 1.0,
        currentStep: 'Export completed!',
        exportFilePath: filePath,
        completedAt: DateTime.now(),
        itemCounts: itemCounts,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ Export failed: $e');
        debugPrint('$stack');
      }
      yield ExportProgress(
        status: ExportStatus.failed,
        errorMessage: 'Export failed: ${e.toString()}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _collectWorkouts(
    String userId,
    ExportRequest request,
  ) async {
    try {
      final workouts = await _workoutRepository.getWorkouts();
      return workouts.fold(
        (failure) => <Map<String, dynamic>>[],
        (list) => list
            .where((w) {
              if (request.dateFrom != null &&
                  w.startedAt.isBefore(request.dateFrom!)) {
                return false;
              }
              if (request.dateTo != null &&
                  w.startedAt.isAfter(request.dateTo!)) {
                return false;
              }
              return true;
            })
            .map((w) => w.toMap())
            .toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting workouts: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _collectTemplates() async {
    try {
      final templates = await _templateRepository.getUserTemplates();
      return templates.map((t) => t.toJson()).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting templates: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _collectCustomExercises() async {
    try {
      final result = await _customExerciseRepository.getAll();
      return result.fold(
        (failure) => <Map<String, dynamic>>[],
        (exercises) => exercises.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting custom exercises: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _collectMeasurements(String userId) async {
    try {
      final result = await _measurementRepository.getMeasurements(userId);
      return result.fold(
        (failure) => <Map<String, dynamic>>[],
        (measurements) => measurements.map((m) => m.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting measurements: $e');
      return [];
    }
  }

  Future<List<String>> _collectPhotoUrls(String userId) async {
    try {
      final result = await _photoRepository.getPhotos(userId: userId);
      return result.fold(
        (failure) => <String>[],
        (photos) => photos.map((p) => p.photoUrl).toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting photos: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _collectPersonalRecords(
      String userId) async {
    try {
      final result = await _prRepository.getRecentCelebrations(userId, limit: 10000);
      return result.fold(
        (failure) => <Map<String, dynamic>>[],
        (prs) => prs.map((pr) => pr.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting PRs: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _collectSettings() async {
    try {
      // Export privacy consents
      final consents = await PrivacyManager.getGrantedConsents();
      final consentTimestamp = await PrivacyManager.getConsentTimestamp();

      return {
        'privacy_consents': consents.map((c) => c.name).toList(),
        'consent_timestamp': consentTimestamp?.toIso8601String(),
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error collecting settings: $e');
      return {};
    }
  }

  Future<String> _packageExport(
    ExportedData data,
    ExportFormat format,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final fileName = 'fitlog_export_$timestamp';

    switch (format) {
      case ExportFormat.json:
        final jsonFile = File('${exportDir.path}/$fileName.json');
        final jsonContent =
            const JsonEncoder.withIndent('  ').convert(data.toJson());
        await jsonFile.writeAsString(jsonContent);
        return jsonFile.path;

      case ExportFormat.csv:
        // For CSV, we create a simple summary file
        final csvFile = File('${exportDir.path}/$fileName.csv');
        final csvContent = _generateCsvSummary(data);
        await csvFile.writeAsString(csvContent);
        return csvFile.path;

      case ExportFormat.zip:
        return await _createZipExport(data, exportDir.path, fileName);
    }
  }

  Future<String> _createZipExport(
    ExportedData data,
    String exportDirPath,
    String fileName,
  ) async {
    final archive = Archive();

    // Add main data JSON
    final mainJson =
        const JsonEncoder.withIndent('  ').convert(data.toJson());
    archive.addFile(ArchiveFile(
      'data.json',
      mainJson.length,
      utf8.encode(mainJson),
    ));

    // Add separate files for each category
    if (data.workouts.isNotEmpty) {
      final workoutsJson =
          const JsonEncoder.withIndent('  ').convert(data.workouts);
      archive.addFile(ArchiveFile(
        'workouts.json',
        workoutsJson.length,
        utf8.encode(workoutsJson),
      ));
    }

    if (data.templates.isNotEmpty) {
      final templatesJson =
          const JsonEncoder.withIndent('  ').convert(data.templates);
      archive.addFile(ArchiveFile(
        'templates.json',
        templatesJson.length,
        utf8.encode(templatesJson),
      ));
    }

    if (data.customExercises.isNotEmpty) {
      final exercisesJson =
          const JsonEncoder.withIndent('  ').convert(data.customExercises);
      archive.addFile(ArchiveFile(
        'custom_exercises.json',
        exercisesJson.length,
        utf8.encode(exercisesJson),
      ));
    }

    if (data.bodyMeasurements.isNotEmpty) {
      final measurementsJson =
          const JsonEncoder.withIndent('  ').convert(data.bodyMeasurements);
      archive.addFile(ArchiveFile(
        'body_measurements.json',
        measurementsJson.length,
        utf8.encode(measurementsJson),
      ));
    }

    if (data.progressPhotoUrls.isNotEmpty) {
      final photosJson =
          const JsonEncoder.withIndent('  ').convert(data.progressPhotoUrls);
      archive.addFile(ArchiveFile(
        'progress_photos.json',
        photosJson.length,
        utf8.encode(photosJson),
      ));
    }

    if (data.personalRecords.isNotEmpty) {
      final prsJson =
          const JsonEncoder.withIndent('  ').convert(data.personalRecords);
      archive.addFile(ArchiveFile(
        'personal_records.json',
        prsJson.length,
        utf8.encode(prsJson),
      ));
    }

    // Add README
    final readme = _generateReadme(data);
    archive.addFile(ArchiveFile(
      'README.txt',
      readme.length,
      utf8.encode(readme),
    ));

    // Create ZIP file
    final zipEncoder = ZipEncoder();
    final zipData = zipEncoder.encode(archive);
    if (zipData.isEmpty) {
      throw Exception('Failed to create ZIP archive');
    }

    final zipFile = File('$exportDirPath/$fileName.zip');
    await zipFile.writeAsBytes(zipData);
    return zipFile.path;
  }

  String _generateCsvSummary(ExportedData data) {
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

    return buffer.toString();
  }

  String _generateReadme(ExportedData data) {
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

Data Format:
------------
All files are in JSON format and can be opened with any text editor
or imported into spreadsheet applications.

For Support:
------------
Contact: support@fitlog.app

''';
  }
}
