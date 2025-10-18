/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE REPOSITORY PROVIDER - DI for flexible routine repository
///
/// Provides:
/// - Singleton instance of FirebaseFlexibleRoutineRepository
/// - Dependency injection for testing
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/data/repositories/firebase_flexible_routine_repository.dart';
import 'package:gymbro_flutter_new/features/routine/domain/repositories/flexible_routine_repository.dart';

/// Provider for FlexibleRoutineRepository instance
final flexibleRoutineRepositoryProvider =
    Provider<FlexibleRoutineRepository>((ref) {
  return FirebaseFlexibleRoutineRepository();
});
