/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/providers
/// 🎯 Feature: exercise_database
/// 🔧 Type: provider
///
/// Riverpod provider for PatchManagerService
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/patch_manager_service.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// Provider for PatchManagerService (singleton)
///
/// Provides access to the patch management service for:
/// - Submitting patches to local Hive storage
/// - Syncing with Firestore patches
/// - Getting local patch count (for badge UI)
final patchManagerServiceProvider = FutureProvider.autoDispose<PatchManagerService>((ref) async {
  final boxManager = ref.watch(hiveBoxManagerProvider);
  final exercisesBox = await boxManager.openBox<Map>(HiveBoxNames.exercises);

  return PatchManagerService(hiveBox: exercisesBox);
});
