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
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/analytics/data/repositories/muscle_correction_repository_impl.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/muscle_correction_repository.dart';

/// Provider for MuscleCorrectionRepository instance
///
/// **Dependencies**:
/// - HiveBoxManagerEnhanced (singleton)
/// - FirebaseFirestore (singleton)
final muscleCorrectionRepositoryProvider = Provider<MuscleCorrectionRepository>(
  (ref) {
    ref.keepAlive(); // FIX: previene ricreazione repository con Hive+Firestore
    return MuscleCorrectionRepositoryImpl(
      hiveBoxManager: HiveBoxManagerEnhanced(),
      firestore: FirebaseFirestore.instance,
    );
  },
);

/// Provider for watching local corrections
///
/// **Returns**: FutureProvider with list of local corrections
///
/// **Updates**: When corrections are saved/deleted locally
///
/// **Note**: Uses autoDispose because this is scoped data (not global auth/config)
final localCorrectionsProvider =
    FutureProvider.autoDispose<List<MuscleCorrection>>((ref) async {
      final repository = ref.watch(muscleCorrectionRepositoryProvider);

      final result = await repository.getLocalCorrections();

      return result.fold(
        (failure) => throw failure,
        (corrections) => corrections,
      );
    });

/// Provider for watching feedback status of a specific correction
///
/// **Parameters**: correctionId (Firestore document ID)
///
/// **Returns**: StreamProvider with FeedbackStatus
final feedbackStatusProvider = StreamProvider.family<FeedbackStatus, String>((
  ref,
  correctionId,
) {
  ref.keepAlive(); // FIX: previene ricreazione stream listener
  final repository = ref.watch(muscleCorrectionRepositoryProvider);

  return repository.watchFeedbackStatus(correctionId).map((either) {
    return either.fold(
      (failure) => throw failure,
      (status) => status,
    );
  });
});
