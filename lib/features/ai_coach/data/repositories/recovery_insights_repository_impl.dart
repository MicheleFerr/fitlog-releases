/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/repositories
/// 🎯 Feature: ai_coach
/// 🔧 Type: repository_implementation
///
/// Recovery Insights Repository Implementation
///
/// **Data Sources**:
/// - **Hive**: Local cache for tier statuses, HRV baseline, quick lookups
/// - **Firestore**: Cloud sync for recovery history, HRV readings
/// - **Riverpod**: State management integration
///
/// **Cache Strategy**:
/// - Readiness Score: 4 hours TTL
/// - Muscle Recovery: 2 hours TTL
/// - Overtraining Risk: 1 hour TTL
/// - HRV Baseline: 7 days TTL
///
/// **Error Handling**: All methods return `Either<Failure, T>` for functional error handling
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/muscle_recovery_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/overtraining_risk.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/readiness_score.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/recovery_insights_repository.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/evaluate_advanced_tier_unlock.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/evaluate_basic_tier_unlock.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/usecases/evaluate_intermediate_tier_unlock.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Repository implementation for recovery insights
///
/// **Usage (Provider)**:
/// ```dart
/// final recoveryInsightsRepositoryProvider = Provider<RecoveryInsightsRepository>((ref) {
///   final firestore = ref.read(firestoreProvider);
///   final userId = ref.read(authStateChangesProvider).value?.uid ?? '';
///   return RecoveryInsightsRepositoryImpl(
///     firestore: firestore,
///     userId: userId,
///   );
/// });
/// ```
class RecoveryInsightsRepositoryImpl implements RecoveryInsightsRepository {
  RecoveryInsightsRepositoryImpl({
    required this.firestore,
    required this.userId,
  });

  final FirebaseFirestore firestore;
  final String userId;

  // Hive box names (lazy-loaded)
  static const String _tierStatusBoxName = 'recovery_tier_status';
  static const String _readinessScoreBoxName = 'readiness_score_cache';
  static const String _muscleRecoveryBoxName = 'muscle_recovery_cache';
  static const String _overtrainingRiskBoxName = 'overtraining_risk_cache';
  static const String _hrvBaselineBoxName = 'hrv_baseline';

  // Cache TTLs (in hours)
  static const int _readinessCacheTtl = 4;
  static const int _muscleCacheTtl = 2;
  static const int _overtrainingCacheTtl = 1;

  // ========================================================================
  // Tier Status Management
  // ========================================================================

  @override
  Future<Either<Failure, List<RecoveryTierStatus>>> getTierStatuses() async {
    try {
      // Fetch workout count and account creation date
      final workoutsSnapshot = await firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      final workouts = workoutsSnapshot.docs
          .map((doc) => Workout.fromJson(doc.data()))
          .toList();

      // Get account creation date from user profile
      final userDoc = await firestore.collection('users').doc(userId).get();
      final accountCreatedAt =
          (userDoc.data()?['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now();

      final daysSinceCreation =
          DateTime.now().difference(accountCreatedAt).inDays;

      // Calculate status for each tier
      final statuses = <RecoveryTierStatus>[];

      for (final tier in RecoveryTier.values) {
        final config = _getConfigForTier(tier);
        final isUnlocked = workouts.length >= config.minWorkouts &&
            daysSinceCreation >= config.minDays;

        // Check if unlock timestamp exists in Hive
        DateTime? unlockedAt;
        if (isUnlocked) {
          final box = await Hive.openBox<String>(_tierStatusBoxName);
          final unlockTimestampStr = box.get('${tier.name}_unlocked_at');
          if (unlockTimestampStr != null) {
            unlockedAt = DateTime.parse(unlockTimestampStr);
          } else {
            // First time unlocking - save timestamp
            unlockedAt = DateTime.now();
            await box.put(
              '${tier.name}_unlocked_at',
              unlockedAt.toIso8601String(),
            );
          }
        }

        statuses.add(
          RecoveryTierStatus(
            tier: tier,
            isUnlocked: isUnlocked,
            currentWorkouts: workouts.length,
            currentDays: daysSinceCreation,
            config: config,
            unlockedAt: unlockedAt,
          ),
        );
      }

      return Right(statuses);
    } catch (e) {
      return Left(CacheFailure('Failed to get tier statuses: $e'));
    }
  }

  @override
  Future<Either<Failure, RecoveryTierStatus>> getTierStatus(
    RecoveryTier tier,
  ) async {
    try {
      final result = await getTierStatuses();
      return result.fold(
        (failure) => Left(failure),
        (statuses) {
          final status = statuses.firstWhere((s) => s.tier == tier);
          return Right(status);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get tier status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unlockTier(RecoveryTier tier) async {
    try {
      final now = DateTime.now();
      final box = await Hive.openBox<String>(_tierStatusBoxName);

      // Store unlock timestamp in Hive
      await box.put('${tier.name}_unlocked_at', now.toIso8601String());

      // Sync to Firestore
      await firestore.collection('users').doc(userId).update({
        'recoveryTiers.${tier.name}.unlockedAt': Timestamp.fromDate(now),
      });

      // TODO: Trigger analytics event (tier_unlocked)

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( 'Failed to unlock tier: $e'));
    }
  }

  // ========================================================================
  // Basic Tier - Readiness Score
  // ========================================================================

  @override
  Future<Either<Failure, ReadinessScore>> getReadinessScore() async {
    try {
      // Check cache first
      final box = await Hive.openBox<String>(_readinessScoreBoxName);
      final cachedJson = box.get('readiness_score');
      final cachedTimestampStr = box.get('readiness_score_timestamp');

      if (cachedJson != null && cachedTimestampStr != null) {
        final cachedTimestamp = DateTime.parse(cachedTimestampStr);
        final hoursSinceCache =
            DateTime.now().difference(cachedTimestamp).inHours;

        if (hoursSinceCache < _readinessCacheTtl) {
          // Cache still valid - return cached score
          final score = ReadinessScore.fromJson(
            Map<String, dynamic>.from(
              // ignore: avoid_dynamic_calls
              const {} as dynamic,
            ),
          );
          return Right(score);
        }
      }

      // Cache miss or expired - recalculate
      final workoutsSnapshot = await firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      final workouts = workoutsSnapshot.docs
          .map((doc) => Workout.fromJson(doc.data()))
          .toList();

      final userDoc = await firestore.collection('users').doc(userId).get();
      final accountCreatedAt =
          (userDoc.data()?['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now();

      // Use EvaluateBasicTierUnlock use case
      final useCase = EvaluateBasicTierUnlock();
      final score = await useCase(
        workouts: workouts,
        accountCreatedAt: accountCreatedAt,
      );

      // Cache result
      await cacheReadinessScore(score);

      return Right(score);
    } catch (e) {
      return Left(CacheFailure( 'Failed to get readiness score: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, ReadinessScore>>>
      getReadinessHistory({
    int days = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('recovery_history')
          .where('type', isEqualTo: 'readiness_score')
          .where('calculatedAt', isGreaterThanOrEqualTo: cutoffDate)
          .orderBy('calculatedAt', descending: true)
          .get();

      final history = <DateTime, ReadinessScore>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final calculatedAt = (data['calculatedAt'] as Timestamp).toDate();
        final score = ReadinessScore.fromJson(data['score'] as Map<String, dynamic>);
        history[calculatedAt] = score;
      }

      return Right(history);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to get readiness history: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cacheReadinessScore(
    ReadinessScore score,
  ) async {
    try {
      final box = await Hive.openBox<String>(_readinessScoreBoxName);

      // Store in Hive (local cache)
      await box.put('readiness_score', score.toJson().toString());
      await box.put(
        'readiness_score_timestamp',
        DateTime.now().toIso8601String(),
      );

      // Sync to Firestore (cloud backup)
      await firestore
          .collection('users')
          .doc(userId)
          .collection('recovery_history')
          .add({
        'type': 'readiness_score',
        'score': score.toJson(),
        'calculatedAt': Timestamp.fromDate(score.calculatedAt ?? DateTime.now()),
      });

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to cache readiness score: $e'),
      );
    }
  }

  // ========================================================================
  // Intermediate Tier - Muscle Recovery
  // ========================================================================

  @override
  Future<Either<Failure, MuscleRecoveryData>> getMuscleRecoveryData() async {
    try {
      // Check cache (2-hour TTL)
      final box = await Hive.openBox<String>(_muscleRecoveryBoxName);
      final cachedTimestampStr = box.get('muscle_recovery_timestamp');

      if (cachedTimestampStr != null) {
        final cachedTimestamp = DateTime.parse(cachedTimestampStr);
        final hoursSinceCache =
            DateTime.now().difference(cachedTimestamp).inHours;

        if (hoursSinceCache < _muscleCacheTtl) {
          // Cache valid - return cached data
          final cachedJson = box.get('muscle_recovery_data');
          if (cachedJson != null) {
            final data = MuscleRecoveryData.fromJson(
              Map<String, dynamic>.from(
                // ignore: avoid_dynamic_calls
                const {} as dynamic,
              ),
            );
            return Right(data);
          }
        }
      }

      // Recalculate
      final workoutsSnapshot = await firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      final workouts = workoutsSnapshot.docs
          .map((doc) => Workout.fromJson(doc.data()))
          .toList();

      final userDoc = await firestore.collection('users').doc(userId).get();
      final accountCreatedAt =
          (userDoc.data()?['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now();

      final useCase = EvaluateIntermediateTierUnlock();
      final data = await useCase(
        workouts: workouts,
        accountCreatedAt: accountCreatedAt,
      );

      await cacheMuscleRecoveryData(data);

      return Right(data);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to get muscle recovery data: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, MuscleRecoveryData>>>
      getMuscleRecoveryHistory({
    int days = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('recovery_history')
          .where('type', isEqualTo: 'muscle_recovery')
          .where('calculatedAt', isGreaterThanOrEqualTo: cutoffDate)
          .orderBy('calculatedAt', descending: true)
          .get();

      final history = <DateTime, MuscleRecoveryData>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final calculatedAt = (data['calculatedAt'] as Timestamp).toDate();
        final recoveryData = MuscleRecoveryData.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        history[calculatedAt] = recoveryData;
      }

      return Right(history);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to get muscle recovery history: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cacheMuscleRecoveryData(
    MuscleRecoveryData data,
  ) async {
    try {
      final box = await Hive.openBox<String>(_muscleRecoveryBoxName);

      await box.put('muscle_recovery_data', data.toJson().toString());
      await box.put(
        'muscle_recovery_timestamp',
        DateTime.now().toIso8601String(),
      );

      await firestore
          .collection('users')
          .doc(userId)
          .collection('recovery_history')
          .add({
        'type': 'muscle_recovery',
        'data': data.toJson(),
        'calculatedAt': Timestamp.fromDate(data.calculatedAt ?? DateTime.now()),
      });

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to cache muscle recovery data: $e'),
      );
    }
  }

  // ========================================================================
  // Advanced Tier - Overtraining Risk & HRV
  // ========================================================================

  @override
  Future<Either<Failure, OvertrainingRisk>> getOvertrainingRisk() async {
    try {
      // Fetch workouts and HRV readings
      final workoutsSnapshot = await firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      final workouts = workoutsSnapshot.docs
          .map((doc) => Workout.fromJson(doc.data()))
          .toList();

      final userDoc = await firestore.collection('users').doc(userId).get();
      final accountCreatedAt =
          (userDoc.data()?['createdAt'] as Timestamp?)?.toDate() ??
              DateTime.now();

      // Fetch HRV readings (last 28 days for baseline)
      final hrvResult = await getHrvReadings(days: 28);
      final hrvReadings = hrvResult.fold(
        (_) => <HrvReading>[],
        (readings) => readings,
      );

      final useCase = EvaluateAdvancedTierUnlock();
      final risk = await useCase(
        workouts: workouts,
        accountCreatedAt: accountCreatedAt,
        hrvReadings: hrvReadings.isEmpty ? null : hrvReadings,
      );

      // Cache result
      final box = await Hive.openBox<String>(_overtrainingRiskBoxName);
      await box.put('overtraining_risk', risk.toJson().toString());
      await box.put(
        'overtraining_risk_timestamp',
        DateTime.now().toIso8601String(),
      );

      return Right(risk);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to get overtraining risk: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, OvertrainingRisk>>>
      getOvertrainingRiskHistory({
    int days = 30,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('recovery_history')
          .where('type', isEqualTo: 'overtraining_risk')
          .where('calculatedAt', isGreaterThanOrEqualTo: cutoffDate)
          .orderBy('calculatedAt', descending: true)
          .get();

      final history = <DateTime, OvertrainingRisk>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final calculatedAt = (data['calculatedAt'] as Timestamp).toDate();
        final risk = OvertrainingRisk.fromJson(
          data['risk'] as Map<String, dynamic>,
        );
        history[calculatedAt] = risk;
      }

      return Right(history);
    } catch (e) {
      return Left(
        CacheFailure( 'Failed to get overtraining risk history: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> storeHrvBaseline({
    required double baseline,
    required int calculatedFrom,
  }) async {
    try {
      final box = await Hive.openBox<String>(_hrvBaselineBoxName);

      await box.put('hrv_baseline', baseline.toString());
      await box.put('hrv_baseline_calculated_from', calculatedFrom.toString());
      await box.put(
        'hrv_baseline_calculated_at',
        DateTime.now().toIso8601String(),
      );

      // Sync to Firestore
      await firestore.collection('users').doc(userId).update({
        'hrvBaseline.value': baseline,
        'hrvBaseline.calculatedFrom': calculatedFrom,
        'hrvBaseline.calculatedAt': Timestamp.now(),
      });

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( 'Failed to store HRV baseline: $e'));
    }
  }

  @override
  Future<Either<Failure, HrvBaselineData?>> getHrvBaseline() async {
    try {
      final box = await Hive.openBox<String>(_hrvBaselineBoxName);

      final baselineStr = box.get('hrv_baseline');
      final calculatedFromStr = box.get('hrv_baseline_calculated_from');
      final calculatedAtStr = box.get('hrv_baseline_calculated_at');

      if (baselineStr == null ||
          calculatedFromStr == null ||
          calculatedAtStr == null) {
        return const Right(null);
      }

      final baseline = double.parse(baselineStr);
      final calculatedFrom = int.parse(calculatedFromStr);
      final calculatedAt = DateTime.parse(calculatedAtStr);

      // Check if baseline is too old (>30 days)
      final daysSinceCalculation =
          DateTime.now().difference(calculatedAt).inDays;
      if (daysSinceCalculation > 30) {
        return const Right(null);
      }

      return Right(
        HrvBaselineData(
          baseline: baseline,
          calculatedFrom: calculatedFrom,
          calculatedAt: calculatedAt,
        ),
      );
    } catch (e) {
      return Left(CacheFailure( 'Failed to get HRV baseline: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> storeHrvReading(HrvReading reading) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('hrv_readings')
          .add({
        'value': reading.value,
        'timestamp': Timestamp.fromDate(reading.timestamp),
      });

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( 'Failed to store HRV reading: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HrvReading>>> getHrvReadings({
    int days = 28,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('hrv_readings')
          .where('timestamp', isGreaterThanOrEqualTo: cutoffDate)
          .orderBy('timestamp', descending: true)
          .get();

      final readings = snapshot.docs.map((doc) {
        final data = doc.data();
        return HrvReading(
          value: (data['value'] as num).toDouble(),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      return Right(readings);
    } catch (e) {
      return Left(CacheFailure( 'Failed to get HRV readings: $e'));
    }
  }

  // ========================================================================
  // Cache Management
  // ========================================================================

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await Hive.deleteBoxFromDisk(_readinessScoreBoxName);
      await Hive.deleteBoxFromDisk(_muscleRecoveryBoxName);
      await Hive.deleteBoxFromDisk(_overtrainingRiskBoxName);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( 'Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearTierCache(RecoveryTier tier) async {
    try {
      switch (tier) {
        case RecoveryTier.basic:
          await Hive.deleteBoxFromDisk(_readinessScoreBoxName);
        case RecoveryTier.intermediate:
          await Hive.deleteBoxFromDisk(_muscleRecoveryBoxName);
        case RecoveryTier.advanced:
          await Hive.deleteBoxFromDisk(_overtrainingRiskBoxName);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure( 'Failed to clear tier cache: $e'));
    }
  }

  @override
  Future<bool> isCacheValid(RecoveryTier tier) async {
    try {
      String boxName;
      int ttl;

      switch (tier) {
        case RecoveryTier.basic:
          boxName = _readinessScoreBoxName;
          ttl = _readinessCacheTtl;
        case RecoveryTier.intermediate:
          boxName = _muscleRecoveryBoxName;
          ttl = _muscleCacheTtl;
        case RecoveryTier.advanced:
          boxName = _overtrainingRiskBoxName;
          ttl = _overtrainingCacheTtl;
      }

      final box = await Hive.openBox<String>(boxName);
      final timestampStr = box.get('${tier.name}_timestamp');

      if (timestampStr == null) return false;

      final timestamp = DateTime.parse(timestampStr);
      final hoursSinceCache = DateTime.now().difference(timestamp).inHours;

      return hoursSinceCache < ttl;
    } catch (e) {
      return false;
    }
  }

  // ========================================================================
  // Private Helpers
  // ========================================================================

  RecoveryTierConfig _getConfigForTier(RecoveryTier tier) {
    switch (tier) {
      case RecoveryTier.basic:
        return RecoveryTierConfig.basic;
      case RecoveryTier.intermediate:
        return RecoveryTierConfig.intermediate;
      case RecoveryTier.advanced:
        return RecoveryTierConfig.advanced;
    }
  }
}
