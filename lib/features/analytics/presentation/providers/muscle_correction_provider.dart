/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// MuscleCorrectionProvider - Riverpod providers for muscle correction feature
///
/// **Purpose**: Provide access to muscle correction repository
///
/// **Providers**:
/// - muscleCorrectionRepositoryProvider: Repository instance
/// - localCorrectionsProvider: Stream of local corrections
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/muscle_correction_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/muscle_correction_repository.dart';

/// Provider for MuscleCorrectionRepository instance
///
/// **Dependencies**:
/// - HiveBoxManager (singleton)
/// - FirebaseFirestore (singleton)
final muscleCorrectionRepositoryProvider =
    Provider<MuscleCorrectionRepository>((ref) {
  return MuscleCorrectionRepositoryImpl(
    hiveBoxManager: HiveBoxManager(),
    firestore: FirebaseFirestore.instance,
  );
});

/// Provider for watching local corrections
///
/// **Returns**: FutureProvider with list of local corrections
///
/// **Updates**: When corrections are saved/deleted locally
final localCorrectionsProvider = FutureProvider<List<MuscleCorrection>>((ref) async {
  final repository = ref.watch(muscleCorrectionRepositoryProvider);

  final result = await repository.getLocalCorrections();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (corrections) => corrections,
  );
});

/// Provider for watching feedback status of a specific correction
///
/// **Parameters**: correctionId (Firestore document ID)
///
/// **Returns**: StreamProvider with FeedbackStatus
final feedbackStatusProvider = StreamProvider.family<FeedbackStatus, String>(
  (ref, correctionId) {
    final repository = ref.watch(muscleCorrectionRepositoryProvider);

    return repository.watchFeedbackStatus(correctionId).map((either) {
      return either.fold(
        (failure) => throw Exception(failure.message),
        (status) => status,
      );
    });
  },
);
