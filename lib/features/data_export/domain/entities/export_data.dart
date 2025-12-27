/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: data_export
/// 🔧 Type: entity
/// 📱 Platform: Universal
///
/// GDPR Article 20 - Right to Data Portability
/// User can request all their data in a portable format
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_data.freezed.dart';
part 'export_data.g.dart';

/// Export data categories that can be included
enum ExportCategory {
  workoutHistory,
  templates,
  customExercises,
  bodyMeasurements,
  progressPhotos,
  personalRecords,
  settings,
  achievements,
}

/// Export format options
enum ExportFormat {
  json,
  csv,
  zip,
}

/// Status of the export process
enum ExportStatus {
  idle,
  preparing,
  collectingWorkouts,
  collectingTemplates,
  collectingExercises,
  collectingMeasurements,
  collectingPhotos,
  collectingRecords,
  collectingSettings,
  packaging,
  completed,
  failed,
}

/// Export request configuration
@freezed
abstract class ExportRequest with _$ExportRequest {
  const factory ExportRequest({
    required Set<ExportCategory> categories,
    @Default(ExportFormat.zip) ExportFormat format,
    @Default(true) bool includePhotos,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) = _ExportRequest;

  factory ExportRequest.fromJson(Map<String, dynamic> json) =>
      _$ExportRequestFromJson(json);

  /// Default request with all categories
  factory ExportRequest.all() => ExportRequest(
        categories: ExportCategory.values.toSet(),
      );
}

/// Export progress state
@freezed
abstract class ExportProgress with _$ExportProgress {
  const factory ExportProgress({
    required ExportStatus status,
    @Default(0.0) double progress,
    String? currentStep,
    String? errorMessage,
    String? exportFilePath,
    DateTime? completedAt,
    @Default({}) Map<ExportCategory, int> itemCounts,
  }) = _ExportProgress;

  factory ExportProgress.fromJson(Map<String, dynamic> json) =>
      _$ExportProgressFromJson(json);

  factory ExportProgress.initial() => const ExportProgress(
        status: ExportStatus.idle,
      );
}

/// Exported data container
@freezed
abstract class ExportedData with _$ExportedData {
  const factory ExportedData({
    required String exportId,
    required DateTime exportedAt,
    required String appVersion,
    required String userId,
    @Default([]) List<Map<String, dynamic>> workouts,
    @Default([]) List<Map<String, dynamic>> templates,
    @Default([]) List<Map<String, dynamic>> customExercises,
    @Default([]) List<Map<String, dynamic>> bodyMeasurements,
    @Default([]) List<String> progressPhotoUrls,
    @Default([]) List<Map<String, dynamic>> personalRecords,
    @Default({}) Map<String, dynamic> settings,
    @Default([]) List<Map<String, dynamic>> achievements,
  }) = _ExportedData;

  factory ExportedData.fromJson(Map<String, dynamic> json) =>
      _$ExportedDataFromJson(json);
}
