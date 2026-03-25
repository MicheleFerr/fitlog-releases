import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/entities/initial/initial_onboarding_data.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/initial/onboarding_completion_identity_store.dart';
import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/fitness_profile_local_datasource.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/providers/user_goals_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:uuid/uuid.dart';

/// Service for completing initial onboarding and persisting collected data.
///
/// Integrates with:
/// - [FitnessProfileLocalDataSource] for questionnaire persistence
/// - [UserGoalsNotifier] for workout frequency
/// - [AppConfig] for completion flag
class InitialOnboardingCompletionService {
  InitialOnboardingCompletionService(this._ref);

  final Ref _ref;
  static const _maskedIpAddress = '0.0.0.***';
  static const _uuid = Uuid();

  /// Complete onboarding and save all data
  ///
  /// Returns true if successful, throws on error
  Future<bool> complete(InitialOnboardingData data) async {
    try {
      // Get current user ID
      final userAsync = _ref.read(firebaseUserProvider);
      final userId = userAsync.when(
        data: (user) => user?.uid,
        loading: () => null,
        error: (_, __) => null,
      );

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🚀 Completing initial onboarding for user: $userId');

      // 1. Save fitness questionnaire
      await _saveFitnessQuestionnaire(data, userId);

      // 2. Seed the main measurements store so onboarding data is visible app-wide.
      await _persistEssentialMeasurementsIfMissing(data, userId);

      // 3. Save user goals (workouts per week)
      await _saveUserGoals(data);

      // 4. Apply experience-based defaults (persona-driven)
      await _applyExperienceBasedDefaults(data);

      // 5. Mark onboarding as completed
      await _markOnboardingCompleted(userId);

      // 6. Sync to Firestore in background (non-blocking)
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

  Future<void> _persistEssentialMeasurementsIfMissing(
    InitialOnboardingData data,
    String userId,
  ) async {
    try {
      final consentRepository = _ref.read(consentRepositoryProvider);

      final createConsentResult = await consentRepository.createInitialConsent(
        userId: userId,
        ipAddress: _maskedIpAddress,
      );

      if (createConsentResult.isRight()) {
        await consentRepository.grantConsent(
          userId: userId,
          group: MetricGroup.essential,
          ipAddress: _maskedIpAddress,
        );
      } else {
        await consentRepository.grantConsent(
          userId: userId,
          group: MetricGroup.essential,
          ipAddress: _maskedIpAddress,
        );
      }

      final measurementRepository = _ref.read(measurementRepositoryProvider);
      final latestMeasurementsResult = await measurementRepository
          .getLatestMeasurementsByType(userId);
      final latestMeasurements = latestMeasurementsResult.getOrElse(
        (_) => <MetricType, Measurement>{},
      );
      final recordedAt = data.completedAt ?? DateTime.now();

      if (!latestMeasurements.containsKey(MetricType.weight)) {
        final weightMeasurement = Measurement(
          id: _uuid.v4(),
          userId: userId,
          metricType: MetricType.weight,
          value: data.bodyweightKg,
          unit: MetricType.weight.defaultUnit,
          timestamp: recordedAt,
          source: MeasurementSource.manual,
          notes: 'Saved from onboarding',
          createdAt: recordedAt,
          updatedAt: recordedAt,
        );

        await measurementRepository.addMeasurement(
          weightMeasurement,
          hasConsent: true,
        );
      }

      if (!latestMeasurements.containsKey(MetricType.height)) {
        final heightMeasurement = Measurement(
          id: _uuid.v4(),
          userId: userId,
          metricType: MetricType.height,
          value: data.heightCm,
          unit: MetricType.height.defaultUnit,
          timestamp: recordedAt,
          source: MeasurementSource.manual,
          notes: 'Saved from onboarding',
          createdAt: recordedAt,
          updatedAt: recordedAt,
        );

        await measurementRepository.addMeasurement(
          heightMeasurement,
          hasConsent: true,
        );
      }

      debugPrint('💾 Seeded essential measurements from onboarding');
    } catch (e) {
      debugPrint(
        '⚠️ Failed to seed onboarding measurements (non-blocking): $e',
      );
    }
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
  Future<void> _markOnboardingCompleted(String userId) async {
    if (kDebugMode) {
      debugPrint('🔧 [CompletionService] Marking onboarding as completed...');
    }
    final appConfigNotifier = _ref.read(appConfigProvider.notifier);
    await appConfigNotifier.setInitialOnboardingCompleted(true);
    await OnboardingCompletionIdentityStore.setCompletedUserId(userId);

    if (kDebugMode) {
      debugPrint(
        '✅ [CompletionService] Marked initial onboarding as completed',
      );
    }
  }

  /// Sync data to Firestore in background
  ///
  /// This is non-blocking and failures don't affect the user experience
  Future<void> _syncToFirestore(
    InitialOnboardingData data,
    String userId,
  ) async {
    try {
      final authService = _ref.read(authServiceProvider);
      await authService.updateUserDocument(userId, {
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
        // Clear admin reset marker once onboarding is completed again.
        'onboardingLastResetAt': FieldValue.delete(),
        'onboardingSummary': {
          'goal': data.goal.name,
          'sex': data.sex.name,
          'age': data.age,
          'heightCm': data.heightCm,
          'bodyweightKg': data.bodyweightKg,
          'experience': data.experience.name,
          'workoutsPerWeek': data.workoutsPerWeek,
          'completedAt': data.completedAt?.toIso8601String(),
        },
      });
      debugPrint('☁️ Firestore onboarding sync completed');
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
