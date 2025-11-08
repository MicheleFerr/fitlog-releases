/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Provider per gestione pubblicazione versioni database esercizi
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/exercise_publish_service.dart';

/// Provider per ExercisePublishService
final exercisePublishServiceProvider = Provider<ExercisePublishService>((ref) {
  return ExercisePublishService();
});

/// Provider per metadata versione corrente
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically cancels Firestore listener when widget is disposed
final versionMetadataProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final service = ref.watch(exercisePublishServiceProvider);
  return service.watchVersionMetadata();
});

/// Provider per versione corrente (string)
/// Restituisce '1.0.0' come default per prima pubblicazione
final currentVersionProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(exercisePublishServiceProvider);
  return service.getCurrentVersion();
});
