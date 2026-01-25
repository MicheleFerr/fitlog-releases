/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/custom_exercises/domain/services
/// 🎯 Feature: Custom Exercise Limit Management
/// 🔧 Type: Service (Business Logic)
///
/// Manages tier-based limits and ad-unlock flow for custom single exercises.
/// - Tier-based limits: Starter (3), Bronze (5), Silver (7), Gold (10), Platinum (999)
/// - Premium/Pro users: unlimited (999) regardless of XP tier
/// - Ad-unlock flow: temporary 7-day unlocks when tier limit reached
library;

import 'package:gymbro_flutter_new/features/custom_exercises/domain/entities/custom_exercise.dart';
import 'package:gymbro_flutter_new/features/custom_exercises/domain/repositories/custom_exercise_repository.dart';

/// Custom Exercise Limit Service
///
/// Handles business logic for:
/// - Checking if user can create permanent exercises
/// - Managing ad-unlock flow (7-day temporary unlocks)
/// - Converting temporary to permanent slots
/// - Tracking expired exercises needing renewal
///
/// ✅ FIXED: Uses consolidated tier limits (UserTier + AccountTier)
/// Instead of boolean isPremium, receives maxCustomSingleExercises from tierEntitlementsProvider
class CustomExerciseLimitService {
  CustomExerciseLimitService({
    required CustomExerciseRepository repository,
    required int maxCustomSingleExercises,
  })  : _repository = repository,
        _maxCustomSingleExercises = maxCustomSingleExercises;

  final CustomExerciseRepository _repository;
  final int _maxCustomSingleExercises;

  /// Days a temporary unlock lasts after watching ad
  static const int tempUnlockDays = 7;

  /// Check if user has unlimited exercises (999 = unlimited)
  bool get hasUnlimitedExercises => _maxCustomSingleExercises >= 999;

  /// Maximum custom exercises for this user (from consolidated tier entitlements)
  int get maxExercises => _maxCustomSingleExercises;

  /// Check if user can create a new permanent exercise
  ///
  /// Returns true if:
  /// - User has unlimited (999)
  /// - User has not reached tier limit
  Future<bool> canCreatePermanent() async {
    // Unlimited users (999) always can create
    if (hasUnlimitedExercises) return true;

    // Check against consolidated tier limit
    final permanentCount = await getPermanentCount();
    return permanentCount < maxExercises;
  }

  /// Check if user needs to watch ad for next exercise
  ///
  /// Returns true if:
  /// - User is NOT unlimited
  /// - User has reached tier limit
  Future<bool> requiresAdForNext() async {
    // Unlimited users never need ads
    if (hasUnlimitedExercises) return false;

    // Check if tier limit reached
    final permanentCount = await getPermanentCount();
    return permanentCount >= maxExercises;
  }

  /// Get remaining permanent slots based on tier
  ///
  /// Returns:
  /// - 999 for unlimited users
  /// - 0-maxExercises for limited users based on current usage
  Future<int> getRemainingPermanentSlots() async {
    // Unlimited users
    if (hasUnlimitedExercises) return 999;

    // Calculate remaining against tier limit
    final permanentCount = await getPermanentCount();
    final remaining = maxExercises - permanentCount;
    return remaining < 0 ? 0 : remaining;
  }

  /// Get current count of permanent exercises
  ///
  /// Permanent exercises have unlockedUntil == null
  Future<int> getPermanentCount() async {
    final result = await _repository.getPermanentCount();
    return result.fold(
      (failure) => 0, // On error, return 0 (fail-safe)
      (count) => count,
    );
  }

  /// Get current count of temporary (ad-unlocked) exercises
  ///
  /// Temporary exercises have unlockedUntil != null
  Future<int> getTemporaryCount() async {
    final result = await _repository.getAll();
    return result.fold(
      (failure) => 0, // On error, return 0 (fail-safe)
      (allExercises) => allExercises.where((e) => e.unlockedUntil != null).length,
    );
  }

  /// Get comprehensive limit check result for UI display
  Future<LimitCheckResult> checkLimits() async {
    final permanentCount = await getPermanentCount();
    final expired = await getExpiredExercises();
    final remaining = await getRemainingPermanentSlots();

    LimitStatus status;
    if (hasUnlimitedExercises) {
      status = LimitStatus.unlimited;
    } else if (permanentCount < maxExercises) {
      status = LimitStatus.available;
    } else {
      status = LimitStatus.requiresAd;
    }

    return LimitCheckResult(
      status: status,
      remainingSlots: remaining,
      permanentCount: permanentCount,
      expiredCount: expired.length,
    );
  }

  /// Prepare exercise for save with appropriate unlock status
  ///
  /// Business logic:
  /// - Unlimited users: always permanent (unlockedUntil = null)
  /// - Users with slots: permanent (unlockedUntil = null)
  /// - Users without slots: temporary 7-day unlock
  ///
  /// Returns exercise with correct unlockedUntil field
  Future<CustomExercise> prepareExerciseForSave(CustomExercise exercise) async {
    // Unlimited users always get permanent
    if (hasUnlimitedExercises) {
      // Note: copyWith doesn't support nullable fields properly
      // We need to return a new instance
      return CustomExercise(
        id: exercise.id,
        nome: exercise.nome,
        baseExerciseId: exercise.baseExerciseId,
        focus: exercise.focus,
        muscoliSecondari: exercise.muscoliSecondari,
        tipoEsercizio: exercise.tipoEsercizio,
        patternMovimento: exercise.patternMovimento,
        attrezzatura: exercise.attrezzatura,
        createdAt: exercise.createdAt,
        unlockedUntil: null, // Permanent
        isModifiedFromBase: exercise.isModifiedFromBase,
        userId: exercise.userId,
      );
    }

    // Free users: check available slots
    final hasSlots = await canCreatePermanent();

    if (hasSlots) {
      // User has free slots available - make permanent
      return CustomExercise(
        id: exercise.id,
        nome: exercise.nome,
        baseExerciseId: exercise.baseExerciseId,
        focus: exercise.focus,
        muscoliSecondari: exercise.muscoliSecondari,
        tipoEsercizio: exercise.tipoEsercizio,
        patternMovimento: exercise.patternMovimento,
        attrezzatura: exercise.attrezzatura,
        createdAt: exercise.createdAt,
        unlockedUntil: null, // Permanent
        isModifiedFromBase: exercise.isModifiedFromBase,
        userId: exercise.userId,
      );
    } else {
      // User needs temporary unlock (ad-unlocked)
      final expirationDate = DateTime.now().add(
        const Duration(days: tempUnlockDays),
      );

      return CustomExercise(
        id: exercise.id,
        nome: exercise.nome,
        baseExerciseId: exercise.baseExerciseId,
        focus: exercise.focus,
        muscoliSecondari: exercise.muscoliSecondari,
        tipoEsercizio: exercise.tipoEsercizio,
        patternMovimento: exercise.patternMovimento,
        attrezzatura: exercise.attrezzatura,
        createdAt: exercise.createdAt,
        unlockedUntil: expirationDate, // Temporary 7-day unlock
        isModifiedFromBase: exercise.isModifiedFromBase,
        userId: exercise.userId,
      );
    }
  }

  /// Handle ad completion - extend or convert to permanent
  ///
  /// Business logic:
  /// - If user now has free slots (deleted permanent): convert to permanent
  /// - Otherwise: extend temporary unlock by 7 days
  Future<void> onAdWatched(String exerciseId) async {
    final result = await _repository.getById(exerciseId);

    final exercise = result.fold(
      (failure) => throw Exception('Failed to get exercise: $failure'),
      (ex) => ex,
    );

    if (exercise == null) {
      throw Exception('Exercise not found: $exerciseId');
    }

    // Check if user now has free slots
    final hasSlots = await canCreatePermanent();

    CustomExercise updated;
    if (hasSlots) {
      // Convert to permanent
      updated = CustomExercise(
        id: exercise.id,
        nome: exercise.nome,
        baseExerciseId: exercise.baseExerciseId,
        focus: exercise.focus,
        muscoliSecondari: exercise.muscoliSecondari,
        tipoEsercizio: exercise.tipoEsercizio,
        patternMovimento: exercise.patternMovimento,
        attrezzatura: exercise.attrezzatura,
        createdAt: exercise.createdAt,
        unlockedUntil: null, // Make permanent
        isModifiedFromBase: exercise.isModifiedFromBase,
        userId: exercise.userId,
      );
    } else {
      // Extend temporary unlock
      final newExpiration = DateTime.now().add(
        const Duration(days: tempUnlockDays),
      );

      updated = CustomExercise(
        id: exercise.id,
        nome: exercise.nome,
        baseExerciseId: exercise.baseExerciseId,
        focus: exercise.focus,
        muscoliSecondari: exercise.muscoliSecondari,
        tipoEsercizio: exercise.tipoEsercizio,
        patternMovimento: exercise.patternMovimento,
        attrezzatura: exercise.attrezzatura,
        createdAt: exercise.createdAt,
        unlockedUntil: newExpiration,
        isModifiedFromBase: exercise.isModifiedFromBase,
        userId: exercise.userId,
      );
    }

    final updateResult = await _repository.update(updated);
    updateResult.fold(
      (failure) => throw Exception('Failed to update exercise: $failure'),
      (_) => null,
    );
  }

  /// Get all expired exercises that need renewal
  ///
  /// Returns exercises where:
  /// - unlockedUntil != null (temporary)
  /// - unlockedUntil < now (expired)
  Future<List<CustomExercise>> getExpiredExercises() async {
    final result = await _repository.getAll();
    final now = DateTime.now();

    return result.fold(
      (failure) => [], // On error, return empty list (fail-safe)
      (allExercises) {
        return allExercises.where((exercise) {
          // Must have expiration date (temporary)
          if (exercise.unlockedUntil == null) return false;

          // Check if expired
          return exercise.unlockedUntil!.isBefore(now);
        }).toList();
      },
    );
  }

  /// Get all active exercises (not expired)
  ///
  /// Returns exercises where:
  /// - unlockedUntil == null (permanent), OR
  /// - unlockedUntil > now (still valid temporary)
  Future<List<CustomExercise>> getActiveExercises() async {
    final result = await _repository.getActive();

    return result.fold(
      (failure) => [], // On error, return empty list (fail-safe)
      (activeExercises) => activeExercises,
    );
  }

  /// Delete expired temporary exercises
  ///
  /// Useful for cleanup - removes exercises that:
  /// - Have been expired for > X days
  /// - User hasn't renewed
  Future<void> cleanupExpiredExercises({
    int daysAfterExpiration = 30,
  }) async {
    final expired = await getExpiredExercises();
    final cutoffDate = DateTime.now().subtract(
      Duration(days: daysAfterExpiration),
    );

    for (final exercise in expired) {
      if (exercise.unlockedUntil != null &&
          exercise.unlockedUntil!.isBefore(cutoffDate)) {
        await _repository.delete(exercise.id);
      }
    }
  }
}

/// Limit status for UI display
enum LimitStatus {
  /// Has free slots available (< tier limit)
  available,

  /// Limit reached, needs ad (>= tier limit)
  requiresAd,

  /// Premium/Pro user or Platinum tier, unlimited (999)
  unlimited,
}

/// Limit check result for UI display
class LimitCheckResult {
  const LimitCheckResult({
    required this.status,
    required this.remainingSlots,
    required this.permanentCount,
    required this.expiredCount,
  });

  /// Current limit status
  final LimitStatus status;

  /// Remaining permanent slots (0-tier_limit, 999 for unlimited)
  final int remainingSlots;

  /// Current count of permanent exercises
  final int permanentCount;

  /// Count of expired exercises needing renewal
  final int expiredCount;

  /// Can user create a permanent exercise?
  bool get canCreatePermanent =>
      status == LimitStatus.available || status == LimitStatus.unlimited;

  /// Does user need to watch ad?
  bool get requiresAd => status == LimitStatus.requiresAd;

  /// Is user premium?
  bool get isPremium => status == LimitStatus.unlimited;

  @override
  String toString() {
    return 'LimitCheckResult('
        'status: $status, '
        'remaining: $remainingSlots, '
        'permanent: $permanentCount, '
        'expired: $expiredCount)';
  }
}
