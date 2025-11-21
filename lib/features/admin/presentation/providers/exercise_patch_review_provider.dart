/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Riverpod providers for exercise patch review
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/repositories/exercise_patch_repository.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/exercise_patch_repository_impl.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// Repository provider (singleton)
final exercisePatchRepositoryProvider = Provider<ExercisePatchRepository>((ref) {
  return ExercisePatchRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
});

/// Fetch pending patches for admin review
final exercisePatchReviewProvider =
    FutureProvider.autoDispose<List<ExercisePatch>>((ref) async {
  final repository = ref.watch(exercisePatchRepositoryProvider);

  final result = await repository.getPendingPatches();

  return result.fold(
    (failure) {
      throw Exception(failure.message);
    },
    (patches) => patches,
  );
});

/// Stream of pending patch count (for dashboard/notifications)
final pendingPatchCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repository = ref.watch(exercisePatchRepositoryProvider);

  return repository.watchPendingPatchCount().map(
        (either) => either.fold(
          (failure) {
            throw Exception(failure.message);
          },
          (count) => count,
        ),
      );
});

/// Approve patch action
final approvePatchProvider =
    Provider.autoDispose<Future<void> Function(String patchId, String? adminNote)>((ref) {
  return (String patchId, String? adminNote) async {
    final repository = ref.watch(exercisePatchRepositoryProvider);

    // Get current user ID from auth
    final currentUser = ref.watch(firebaseUserProvider).value;
    final adminUserId = currentUser?.uid ?? 'anonymous';

    final result = await repository.approvePatch(
      patchId: patchId,
      adminUserId: adminUserId,
      adminNote: adminNote,
    );

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (_) {
        // Success - refresh patch list
        ref.invalidate(exercisePatchReviewProvider);
      },
    );
  };
});

/// Reject patch action
final rejectPatchProvider = Provider.autoDispose<
    Future<void> Function(
  String patchId,
  String reason,
  String? adminNote,
)>((ref) {
  return (String patchId, String reason, String? adminNote) async {
    final repository = ref.watch(exercisePatchRepositoryProvider);

    // Get current user ID from auth
    final currentUser = ref.watch(firebaseUserProvider).value;
    final adminUserId = currentUser?.uid ?? 'anonymous';

    final result = await repository.rejectPatch(
      patchId: patchId,
      adminUserId: adminUserId,
      reason: reason,
      adminNote: adminNote,
    );

    result.fold(
      (failure) {
        throw Exception(failure.message);
      },
      (_) {
        // Success - refresh patch list
        ref.invalidate(exercisePatchReviewProvider);
      },
    );
  };
});
