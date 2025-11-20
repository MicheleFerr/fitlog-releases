/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider
///
/// Provider for user's pending patch count (badge UI)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/patch_manager_provider.dart';

/// Provider per contare le patch pending dell'utente
///
/// **Usage**: Badge su "My Patches" button in home screen
/// **Updates**: Auto-refresh quando patch submittedPerfetto!
final userPatchCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final patchManager = await ref.watch(patchManagerServiceProvider.future);

  // Get count of local patches (user's pending submissions)
  final count = await patchManager.getLocalPatchCount();

  return count;
});
