/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository_interface
///
/// Recovery Insights Repository Interface
///
/// **Purpose**: Abstract repository for recovery insights data persistence
///
/// **Responsibilities**:
/// - Fetch tier unlock statuses (Basic, Intermediate, Advanced)
/// - Cache HRV baseline data
/// - Store/retrieve muscle recovery metrics
/// - Persist overtraining risk assessments
/// - Track tier unlock timestamps
///
/// **Data Sources**:
/// - Hive (local cache): Tier unlock states, HRV baseline
/// - Firestore (cloud sync): Recovery metrics history
/// - HealthKit/Health Connect: Real-time HRV readings
///
/// **Implementation**: See `RecoveryInsightsRepositoryImpl` in data layer
library;

import 'package:fpdart/fpdart.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/muscle_recovery_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/overtraining_risk.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/readiness_score.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/evaluate_advanced_tier_unlock.dart';

/// Repository interface for recovery insights data
///
/// **Usage (in use cases)**:
/// ```dart
/// class GetCurrentRecoveryInsights {
///   final RecoveryInsightsRepository repository;
///
///   Future<Either<Failure, ReadinessScore>> call() async {
///     return repository.getReadinessScore();
///   }
/// }
/// ```
abstract class RecoveryInsightsRepository {
  // ========================================================================
  // Tier Status Management
  // ========================================================================

  /// Get current status for all three tiers
  ///
  /// **Returns**: List of [RecoveryTierStatus] (Basic, Intermediate, Advanced)
  ///
  /// **Data Flow**:
  /// 1. Check Hive cache for last status
  /// 2. Fetch workout count from Firestore
  /// 3. Calculate days since account creation
  /// 4. Determine unlock status for each tier
  /// 5. Update cache if changed
  Future<Either<Failure, List<RecoveryTierStatus>>> getTierStatuses();

  /// Get status for specific tier
  ///
  /// **Parameters**:
  /// - `tier`: Which tier to check (basic/intermediate/advanced)
  ///
  /// **Use Case**: Display single tier progress in dashboard widget
  Future<Either<Failure, RecoveryTierStatus>> getTierStatus(
    RecoveryTier tier,
  );

  /// Mark tier as unlocked (called when requirements met)
  ///
  /// **Side Effects**:
  /// - Updates Hive cache with unlock timestamp
  /// - Syncs unlock event to Firestore
  /// - Triggers analytics event (tier_unlocked)
  Future<Either<Failure, void>> unlockTier(RecoveryTier tier);

  // ========================================================================
  // Basic Tier - Readiness Score
  // ========================================================================

  /// Get current readiness score (Basic tier)
  ///
  /// **Returns**: [ReadinessScore] with 0-100 score and category
  ///
  /// **Data Flow**:
  /// 1. Check cache (valid for 4 hours)
  /// 2. If stale: recalculate from workout history
  /// 3. Store in cache with timestamp
  ///
  /// **Cache Duration**: 4 hours
  Future<Either<Failure, ReadinessScore>> getReadinessScore();

  /// Get historical readiness scores (last 30 days)
  ///
  /// **Use Case**: Display readiness trend chart in analytics screen
  ///
  /// **Returns**: Map of date → ReadinessScore
  Future<Either<Failure, Map<DateTime, ReadinessScore>>>
      getReadinessHistory({
    int days = 30,
  });

  /// Cache readiness score (called after calculation)
  ///
  /// **Parameters**:
  /// - `score`: Calculated ReadinessScore to cache
  ///
  /// **Cache Strategy**: Hive local + Firestore sync
  Future<Either<Failure, void>> cacheReadinessScore(ReadinessScore score);

  // ========================================================================
  // Intermediate Tier - Muscle Recovery
  // ========================================================================

  /// Get current muscle recovery data (Intermediate tier)
  ///
  /// **Returns**: [MuscleRecoveryData] with per-muscle recovery status
  ///
  /// **Data Flow**:
  /// 1. Check cache (valid for 2 hours)
  /// 2. If stale: recalculate from workout history
  /// 3. Store in cache
  ///
  /// **Cache Duration**: 2 hours (muscle recovery changes faster)
  Future<Either<Failure, MuscleRecoveryData>> getMuscleRecoveryData();

  /// Get muscle recovery history (last 30 days)
  ///
  /// **Use Case**: Display per-muscle recovery trends
  ///
  /// **Returns**: Map of date → MuscleRecoveryData
  Future<Either<Failure, Map<DateTime, MuscleRecoveryData>>>
      getMuscleRecoveryHistory({
    int days = 30,
  });

  /// Cache muscle recovery data
  ///
  /// **Parameters**:
  /// - `data`: Calculated MuscleRecoveryData to cache
  Future<Either<Failure, void>> cacheMuscleRecoveryData(
    MuscleRecoveryData data,
  );

  // ========================================================================
  // Advanced Tier - Overtraining Risk & HRV
  // ========================================================================

  /// Get current overtraining risk assessment (Advanced tier)
  ///
  /// **Returns**: [OvertrainingRisk] with TSB + HRV metrics
  ///
  /// **Data Flow**:
  /// 1. Fetch HRV baseline from cache (if exists)
  /// 2. Calculate TSB from workout history
  /// 3. Calculate HRV deviation from recent readings
  /// 4. Determine risk level
  /// 5. Cache assessment
  ///
  /// **Cache Duration**: 1 hour (overtraining risk changes quickly)
  Future<Either<Failure, OvertrainingRisk>> getOvertrainingRisk();

  /// Get overtraining risk history (last 30 days)
  ///
  /// **Use Case**: Display TSB trend chart in analytics
  Future<Either<Failure, Map<DateTime, OvertrainingRisk>>>
      getOvertrainingRiskHistory({
    int days = 30,
  });

  /// Store HRV baseline (calculated from 20+ days of data)
  ///
  /// **Parameters**:
  /// - `baseline`: Personal HRV baseline (ms)
  /// - `calculatedFrom`: Number of days used for baseline
  ///
  /// **Storage**: Hive local (long-term cache)
  ///
  /// **Update Frequency**: Weekly (baseline adapts slowly)
  Future<Either<Failure, void>> storeHrvBaseline({
    required double baseline,
    required int calculatedFrom,
  });

  /// Get stored HRV baseline
  ///
  /// **Returns**: Baseline HRV (ms) and calculation metadata
  ///
  /// **Returns null if**:
  /// - No baseline calculated yet
  /// - Baseline too old (>30 days)
  Future<Either<Failure, HrvBaselineData?>> getHrvBaseline();

  /// Store HRV reading (from HealthKit/Health Connect)
  ///
  /// **Parameters**:
  /// - `reading`: HRV reading from wearable device
  ///
  /// **Storage**: Firestore (synced across devices)
  Future<Either<Failure, void>> storeHrvReading(HrvReading reading);

  /// Get HRV readings for time range
  ///
  /// **Parameters**:
  /// - `days`: Number of days to fetch (default: 28 for baseline calc)
  ///
  /// **Returns**: List of HRV readings sorted by timestamp
  Future<Either<Failure, List<HrvReading>>> getHrvReadings({
    int days = 28,
  });

  // ========================================================================
  // Cache Management
  // ========================================================================

  /// Clear all cached recovery insights
  ///
  /// **Use Case**: Force refresh after workout completion
  Future<Either<Failure, void>> clearCache();

  /// Clear specific tier cache
  ///
  /// **Parameters**:
  /// - `tier`: Which tier cache to clear
  Future<Either<Failure, void>> clearTierCache(RecoveryTier tier);

  /// Check if cache is valid for tier
  ///
  /// **Returns**: True if cache exists and not expired
  Future<bool> isCacheValid(RecoveryTier tier);
}

/// HRV baseline metadata
///
/// **Structure**:
/// ```dart
/// HrvBaselineData(
///   baseline: 65.5,          // Personal baseline (ms)
///   calculatedFrom: 28,      // Days of data used
///   calculatedAt: DateTime.now(),
///   lastReading: 63.2,       // Most recent HRV
/// )
/// ```
class HrvBaselineData {
  const HrvBaselineData({
    required this.baseline,
    required this.calculatedFrom,
    required this.calculatedAt,
    this.lastReading,
  });

  /// Personal HRV baseline (ms)
  ///
  /// **Typical Range**: 40-90 ms (highly individual)
  final double baseline;

  /// Number of days used for baseline calculation
  ///
  /// **Minimum**: 20 days
  /// **Recommended**: 28+ days for accuracy
  final int calculatedFrom;

  /// When baseline was calculated
  ///
  /// **Update Strategy**: Recalculate weekly
  final DateTime calculatedAt;

  /// Most recent HRV reading (ms)
  ///
  /// **Use**: Quick deviation check without full recalculation
  final double? lastReading;

  /// Check if baseline needs update
  ///
  /// **Update Threshold**: 7+ days since last calculation
  bool get needsUpdate =>
      DateTime.now().difference(calculatedAt).inDays >= 7;

  /// Calculate current deviation from baseline
  ///
  /// **Formula**: ((Current - Baseline) / Baseline) × 100
  ///
  /// **Interpretation**:
  /// - Positive deviation: HRV above baseline (good recovery)
  /// - Negative deviation: HRV below baseline (fatigue)
  double? getDeviation(double? currentHrv) {
    if (currentHrv == null || baseline == 0) return null;
    return ((currentHrv - baseline) / baseline) * 100;
  }
}
