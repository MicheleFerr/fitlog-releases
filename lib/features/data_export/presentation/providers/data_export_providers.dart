/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: data_export
/// 🔧 Type: provider
/// 📱 Platform: Universal
///
/// GDPR Article 20 - Right to Data Portability
/// Providers for data export functionality
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/data_export/data/services/data_export_service.dart';
import 'package:gymbro_flutter_new/features/data_export/domain/entities/export_data.dart';

// Import existing providers
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/presentation/providers/custom_exercise_providers.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/progress_photos/presentation/providers/progress_photo_providers.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';

/// Provider for DataExportService
final dataExportServiceProvider = Provider<DataExportService>((ref) {
  final workoutRepo = ref.watch(workoutHistoryRepositoryProvider);
  final templateRepo = ref.watch(templateRepositoryProvider);
  final customExerciseRepo = ref.watch(customExerciseRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);
  final photoRepo = ref.watch(progressPhotoRepositoryProvider);
  final prRepo = ref.watch(prCelebrationRepositoryProvider);
  final achievementRepo = ref.watch(achievementRepositoryProvider);

  return DataExportService(
    workoutRepository: workoutRepo,
    templateRepository: templateRepo,
    customExerciseRepository: customExerciseRepo,
    measurementRepository: measurementRepo,
    photoRepository: photoRepo,
    prRepository: prRepo,
    achievementRepository: achievementRepo,
  );
});

/// State for data export process
class DataExportState {
  const DataExportState({
    required this.progress,
    this.request,
    this.isExporting = false,
  });

  factory DataExportState.initial() =>
      DataExportState(progress: ExportProgress.initial(), isExporting: false);

  final ExportProgress progress;
  final ExportRequest? request;
  final bool isExporting;

  DataExportState copyWith({
    ExportProgress? progress,
    ExportRequest? request,
    bool? isExporting,
  }) {
    return DataExportState(
      progress: progress ?? this.progress,
      request: request ?? this.request,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

/// Notifier for data export operations
class DataExportNotifier extends Notifier<DataExportState> {
  late final DataExportService _service;

  @override
  DataExportState build() {
    _service = ref.watch(dataExportServiceProvider);
    return DataExportState.initial();
  }

  /// Start data export with given request
  Future<void> startExport(ExportRequest request) async {
    if (state.isExporting) return;

    state = state.copyWith(
      request: request,
      isExporting: true,
      progress: const ExportProgress(status: ExportStatus.preparing),
    );

    await for (final progress in _service.exportData(request)) {
      state = state.copyWith(progress: progress);

      if (progress.status == ExportStatus.completed ||
          progress.status == ExportStatus.failed) {
        state = state.copyWith(isExporting: false);
        break;
      }
    }
  }

  /// Cancel ongoing export (if possible)
  void cancelExport() {
    if (state.isExporting) {
      state = DataExportState.initial();
    }
  }

  /// Reset state after export completed
  void reset() {
    state = DataExportState.initial();
  }
}

/// Provider for data export notifier
final dataExportProvider =
    NotifierProvider<DataExportNotifier, DataExportState>(
      DataExportNotifier.new,
    );

/// Provider for checking if user can export (must be authenticated)
final canExportProvider = Provider<bool>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user != null;
});

/// Provider for available export categories
final availableExportCategoriesProvider = Provider<Set<ExportCategory>>((ref) {
  // All categories are available for export
  return ExportCategory.values.toSet();
});
