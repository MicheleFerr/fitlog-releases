/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation
/// 🎯 Feature: routine
/// 🔧 Type: provider
///
/// ROUTINE REMINDER SERVICE PROVIDER - DI for skip tracking and recovery
///
/// Provides:
/// - Singleton instance of RoutineReminderService
/// - Access to skip day tracking and recovery workflows
///
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/application/services/routine_reminder_service.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_repository_provider.dart';

/// Provider for RoutineReminderService instance
final routineReminderServiceProvider = Provider<RoutineReminderService>((ref) {
  final repository = ref.read(flexibleRoutineRepositoryProvider);
  return RoutineReminderService(repository: repository);
});
