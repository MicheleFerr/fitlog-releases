/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// Recovery Insights Riverpod Provider - state management for recovery insights
///
/// **Provides**:
/// - RecoveryInsightsRepository instance (with Firebase + userId)
/// - Tier statuses (all 3 tiers)
/// - Individual tier status by tier type
/// - Readiness Score (Basic tier)
/// - Muscle Recovery Data (Intermediate tier)
/// - Overtraining Risk (Advanced tier)
///
/// **Cache Strategy**:
/// - Readiness Score: 4 hour TTL
/// - Muscle Recovery: 2 hour TTL
/// - Overtraining Risk: 1 hour TTL
///
/// **Usage**:
/// ```dart
/// // Watch all tier statuses
/// final tierStatuses = ref.watch(tierStatusesProvider);
///
/// // Watch specific tier
/// final basicTier = ref.watch(tierStatusProvider(RecoveryTier.basic));
///
/// // Watch readiness score
/// final readinessScore = ref.watch(readinessScoreProvider);
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/repositories/recovery_insights_repository_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/recovery_insights_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/readiness_score.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/muscle_recovery_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/overtraining_risk.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

/// Provider for RecoveryInsightsRepository instance
///
/// **Dependencies**:
/// - FirebaseFirestore.instance (singleton)
/// - AuthService.currentUser.uid (from authServiceProvider)
///
/// **Auto-dispose**: Yes (recreates when dependencies change)
final recoveryInsightsRepositoryProvider =
    Provider.autoDispose<RecoveryInsightsRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.uid ?? '';

  return RecoveryInsightsRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    userId: userId,
  );
});

/// Provider for all tier statuses (Basic, Intermediate, Advanced)
///
/// **Returns**: List<RecoveryTierStatus> with unlock status for each tier
///
/// **Data Flow**:
/// 1. Fetch completed workouts from Firestore
/// 2. Calculate days since account creation
/// 3. Evaluate unlock status for each tier
/// 4. Return tier statuses list
///
/// **Refresh Strategy**: Auto-dispose (refetches on rebuild)
///
/// **Error Handling**: Throws Exception with failure message
final tierStatusesProvider =
    FutureProvider.autoDispose<List<RecoveryTierStatus>>((ref) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.getTierStatuses();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (statuses) => statuses,
  );
});

/// Provider for specific tier status
///
/// **Parameters**:
/// - `tier`: Which tier to fetch (Basic/Intermediate/Advanced)
///
/// **Returns**: RecoveryTierStatus for specified tier
///
/// **Use Case**: Display single tier progress in detail screen
///
/// **Example**:
/// ```dart
/// final basicTier = ref.watch(tierStatusProvider(RecoveryTier.basic));
/// ```
final tierStatusProvider = FutureProvider.autoDispose
    .family<RecoveryTierStatus, RecoveryTier>((ref, tier) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.getTierStatus(tier);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (status) => status,
  );
});

/// Provider for readiness score (Basic tier)
///
/// **Returns**: ReadinessScore with 0-100 score and category
///
/// **Data Flow**:
/// 1. Check cache (4 hour TTL)
/// 2. If stale: recalculate from workout history
/// 3. Store in cache with timestamp
///
/// **Cache Duration**: 4 hours (readiness changes slowly)
///
/// **Unlock Requirement**: Basic tier (6 workouts, 14 days)
///
/// **Example**:
/// ```dart
/// final readiness = ref.watch(readinessScoreProvider);
/// readiness.when(
///   data: (score) => Text('${score.score}/100'),
///   loading: () => LoadingIndicator(),
///   error: (err, _) => ErrorWidget(err),
/// );
/// ```
final readinessScoreProvider =
    FutureProvider.autoDispose<ReadinessScore>((ref) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.getReadinessScore();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (score) => score,
  );
});

/// Provider for muscle recovery data (Intermediate tier)
///
/// **Returns**: MuscleRecoveryData with per-muscle recovery status
///
/// **Data Flow**:
/// 1. Check cache (2 hour TTL)
/// 2. If stale: recalculate from workout volume history
/// 3. Store in cache
///
/// **Cache Duration**: 2 hours (muscle recovery changes faster)
///
/// **Unlock Requirement**: Intermediate tier (12 workouts, 28 days)
///
/// **Muscle Groups Tracked**:
/// - Chest, Back, Shoulders
/// - Biceps, Triceps
/// - Legs, Core
///
/// **Example**:
/// ```dart
/// final muscleRecovery = ref.watch(muscleRecoveryProvider);
/// muscleRecovery.when(
///   data: (data) => MuscleRecoveryWidget(data: data),
///   loading: () => LoadingIndicator(),
///   error: (err, _) => Text('Locked - Complete 12 workouts'),
/// );
/// ```
final muscleRecoveryProvider =
    FutureProvider.autoDispose<MuscleRecoveryData>((ref) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.getMuscleRecoveryData();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

/// Provider for overtraining risk (Advanced tier)
///
/// **Returns**: OvertrainingRisk with TSB + HRV metrics
///
/// **Data Flow**:
/// 1. Fetch HRV baseline from cache (if exists)
/// 2. Calculate TSB from workout history
/// 3. Calculate HRV deviation from recent readings
/// 4. Determine risk level
/// 5. Cache assessment
///
/// **Cache Duration**: 1 hour (overtraining risk changes quickly)
///
/// **Unlock Requirement**: Advanced tier (20 workouts, 42 days)
///
/// **Risk Levels**:
/// - Low: TSB > -10, HRV normal
/// - Moderate: TSB -10 to -20, HRV slightly low
/// - High: TSB -20 to -30, HRV low
/// - Very High: TSB < -30, HRV very low
///
/// **Example**:
/// ```dart
/// final overtrainingRisk = ref.watch(overtrainingRiskProvider);
/// overtrainingRisk.when(
///   data: (risk) => OvertrainingRiskWidget(risk: risk),
///   loading: () => LoadingIndicator(),
///   error: (err, _) => Text('Locked - Complete 20 workouts'),
/// );
/// ```
final overtrainingRiskProvider =
    FutureProvider.autoDispose<OvertrainingRisk>((ref) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.getOvertrainingRisk();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (risk) => risk,
  );
});

/// Provider for HRV baseline data (Advanced tier only)
///
/// **Returns**: HrvBaselineData? (null if not calculated yet)
///
/// **Data Flow**:
/// 1. Fetch baseline from Hive cache
/// 2. Check if baseline needs update (7+ days old)
/// 3. Return baseline with metadata
///
/// **Baseline Calculation Requirements**:
/// - Minimum: 20 days of HRV data
/// - Recommended: 28+ days for accuracy
///
/// **Update Strategy**: Weekly (baseline adapts slowly)
///
/// **Example**:
/// ```dart
/// final hrvBaseline = ref.watch(hrvBaselineProvider);
/// hrvBaseline.when(
///   data: (baseline) {
///     if (baseline == null) return Text('Collecting baseline data...');
///     return Text('Baseline: ${baseline.baseline.toStringAsFixed(1)} ms');
///   },
///   loading: () => LoadingIndicator(),
///   error: (err, _) => ErrorWidget(err),
/// );
/// ```
final hrvBaselineProvider =
    FutureProvider.autoDispose<HrvBaselineData?>((ref) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.getHrvBaseline();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (baseline) => baseline,
  );
});

/// Provider to check if cache is valid for specific tier
///
/// **Parameters**:
/// - `tier`: Which tier cache to check
///
/// **Returns**: bool (true if cache exists and not expired)
///
/// **Use Case**: Determine if we need to show "refreshing" indicator
///
/// **Example**:
/// ```dart
/// final isValid = ref.watch(cacheValidProvider(RecoveryTier.basic));
/// if (!isValid) {
///   // Show "Refreshing data..." indicator
/// }
/// ```
final cacheValidProvider =
    FutureProvider.autoDispose.family<bool, RecoveryTier>((ref, tier) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  return repository.isCacheValid(tier);
});

/// Provider to clear all recovery insights cache
///
/// **Use Case**: Force refresh after workout completion
///
/// **Side Effects**:
/// - Clears all Hive caches (readiness, muscle recovery, overtraining)
/// - Next read will recalculate from Firestore data
///
/// **Example**:
/// ```dart
/// // After workout completion:
/// await ref.read(clearCacheProvider.future);
/// ref.invalidate(tierStatusesProvider); // Trigger refetch
/// ```
final clearCacheProvider = FutureProvider.autoDispose<void>((ref) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.clearCache();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

/// Provider to clear specific tier cache
///
/// **Parameters**:
/// - `tier`: Which tier cache to clear
///
/// **Use Case**: Selective cache invalidation (e.g., only clear Basic tier)
///
/// **Example**:
/// ```dart
/// await ref.read(clearTierCacheProvider(RecoveryTier.basic).future);
/// ref.invalidate(readinessScoreProvider);
/// ```
final clearTierCacheProvider =
    FutureProvider.autoDispose.family<void, RecoveryTier>((ref, tier) async {
  final repository = ref.watch(recoveryInsightsRepositoryProvider);
  final result = await repository.clearTierCache(tier);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});
