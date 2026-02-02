import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/fitness_profile_local_datasource.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/user_goals_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Service for completing initial onboarding and persisting collected data.
///
/// Integrates with:
/// - [FitnessProfileLocalDataSource] for questionnaire persistence
/// - [UserGoalsNotifier] for workout frequency
/// - [AppConfig] for completion flag
class InitialOnboardingCompletionService {
  InitialOnboardingCompletionService(this._ref);

  final Ref _ref;

  /// Complete onboarding and save all data
  ///
  /// Returns true if successful, throws on error
  Future<bool> complete(InitialOnboardingData data) async {
    try {
      // Get current user ID
      final userAsync = _ref.read(firebaseUserProvider);
      final userId = userAsync.valueOrNull?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🚀 Completing initial onboarding for user: $userId');

      // 1. Save fitness questionnaire
      await _saveFitnessQuestionnaire(data, userId);

      // 2. Save user goals (workouts per week)
      await _saveUserGoals(data);

      // 3. Apply experience-based defaults (persona-driven)
      await _applyExperienceBasedDefaults(data);

      // 4. Mark onboarding as completed
      await _markOnboardingCompleted();

      // 5. Sync to Firestore in background (non-blocking)
      unawaited(_syncToFirestore(data, userId));

      debugPrint('✅ Initial onboarding completed successfully');
      return true;
    } catch (e, stack) {
      debugPrint('❌ Error completing onboarding: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Save fitness questionnaire to local storage
  Future<void> _saveFitnessQuestionnaire(
    InitialOnboardingData data,
    String userId,
  ) async {
    final boxManager = _ref.read(hiveBoxManagerProvider);
    final datasource = FitnessProfileLocalDataSource(boxManager);

    final questionnaire = data.toQuestionnaire();
    await datasource.saveFitnessQuestionnaire(questionnaire, userId);

    debugPrint('💾 Saved fitness questionnaire');
  }

  /// Save user goals (workouts per week)
  Future<void> _saveUserGoals(InitialOnboardingData data) async {
    final goalsNotifier = _ref.read(userGoalsProvider.notifier);
    await goalsNotifier.setWorkoutsPerWeek(data.workoutsPerWeek);

    debugPrint('💾 Saved user goals: ${data.workoutsPerWeek} workouts/week');
  }

  /// 🌱 PERSONA-DRIVEN: Apply defaults based on experience level
  ///
  /// For beginners (Marco persona):
  /// - Exercise notes ON (promemoria su come fare esercizi)
  /// - Quick icons ON (accesso rapido a info)
  /// - RPE OFF (troppo complesso)
  /// - Plate calculator ON (non deve calcolare)
  Future<void> _applyExperienceBasedDefaults(InitialOnboardingData data) async {
    final appConfigNotifier = _ref.read(appConfigProvider.notifier);

    if (data.experience == ExperienceLevelUI.beginner) {
      await appConfigNotifier.applyBeginnerDefaults();
      debugPrint('🌱 Applied beginner defaults for experience level');
    } else {
      debugPrint(
        '📊 Experience level: ${data.experience.name} - using standard defaults',
      );
    }
  }

  /// Mark onboarding as completed in AppConfig
  Future<void> _markOnboardingCompleted() async {
    final appConfigNotifier = _ref.read(appConfigProvider.notifier);
    await appConfigNotifier.setInitialOnboardingCompleted(true);

    debugPrint('✅ Marked initial onboarding as completed');
  }

  /// Sync data to Firestore in background
  ///
  /// This is non-blocking and failures don't affect the user experience
  Future<void> _syncToFirestore(
    InitialOnboardingData data,
    String userId,
  ) async {
    try {
      // TODO: Implement Firestore sync when needed
      // For now, data is only stored locally
      debugPrint('☁️ Firestore sync placeholder (not implemented)');
    } catch (e) {
      // Log but don't throw - sync failures shouldn't block onboarding
      debugPrint('⚠️ Firestore sync failed (non-blocking): $e');
    }
  }
}

/// Provider for InitialOnboardingCompletionService
final initialOnboardingCompletionServiceProvider =
    Provider<InitialOnboardingCompletionService>((ref) {
      return InitialOnboardingCompletionService(ref);
    });
