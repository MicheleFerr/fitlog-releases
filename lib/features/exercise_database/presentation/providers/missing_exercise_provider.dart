import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/missing_exercise_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/missing_exercise_request.dart';

/// Provider for MissingExerciseService
final missingExerciseServiceProvider = Provider<MissingExerciseService>((ref) {
  return MissingExerciseService();
});

/// Provider for pending requests (admin)
final pendingRequestsProvider = StreamProvider<List<MissingExerciseRequest>>((
  ref,
) {
  final service = ref.watch(missingExerciseServiceProvider);
  return service.getPendingRequests();
});

/// Provider for all requests (admin)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final allRequestsProvider =
    StreamProvider.autoDispose<List<MissingExerciseRequest>>((ref) {
      final service = ref.watch(missingExerciseServiceProvider);
      return service.getAllRequests();
    });

/// Provider for user's requests
final userRequestsProvider = StreamProvider<List<MissingExerciseRequest>>((
  ref,
) {
  final service = ref.watch(missingExerciseServiceProvider);
  return service.getUserRequests();
});

/// Provider for request counts (admin)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final requestCountsProvider =
    FutureProvider.autoDispose<Map<RequestStatus, int>>((ref) async {
      final service = ref.watch(missingExerciseServiceProvider);
      return service.getRequestCounts();
    });

/// Provider for requests filtered by status (admin)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
final requestsByStatusProvider = StreamProvider.autoDispose
    .family<List<MissingExerciseRequest>, RequestStatus>((ref, status) {
      final service = ref.watch(missingExerciseServiceProvider);
      return service.getRequestsByStatus(status);
    });
