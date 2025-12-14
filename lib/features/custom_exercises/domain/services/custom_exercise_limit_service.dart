/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/custom_exercises/domain/services
/// 🎯 Feature: Custom Exercise Limit Management
/// 🔧 Type: Service (Business Logic)
///
/// Manages free tier limits (5 permanent exercises) and ad-unlock flow.
/// - Free users: 5 permanent + unlimited temporary (7-day via ads)
/// - Premium users: unlimited permanent
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
class CustomExerciseLimitService {
  CustomExerciseLimitService({
    required CustomExerciseRepository repository,
    required bool Function() isPremiumUser,
  })  : _repository = repository,
        _isPremiumUser = isPremiumUser;

  final CustomExerciseRepository _repository;
  final bool Function() _isPremiumUser;

  /// Maximum permanent exercises for free tier
  static const int freeLimit = 5;

  /// Days a temporary unlock lasts after watching ad
  static const int tempUnlockDays = 7;

  /// Check if user is premium
  bool get isPremium => _isPremiumUser();

  /// Check if user can create a new permanent exercise
  ///
  /// Returns true if:
  /// - User is premium (unlimited)
  /// - User has not reached free tier limit (< 5 permanent)
  Future<bool> canCreatePermanent() async {
    // Premium users have unlimited
    if (isPremium) return true;

    // Free users: check permanent count
    final permanentCount = await getPermanentCount();
    return permanentCount < freeLimit;
  }

  /// Check if user needs to watch ad for next exercise
  ///
  /// Returns true if:
  /// - User is NOT premium
  /// - User has reached free tier limit (>= 5 permanent)
  Future<bool> requiresAdForNext() async {
    // Premium users never need ads
    if (isPremium) return false;

    // Free users: check if limit reached
    final permanentCount = await getPermanentCount();
    return permanentCount >= freeLimit;
  }

  /// Get remaining permanent slots for free tier
  ///
  /// Returns:
  /// - 999 for premium users (unlimited)
  /// - 0-5 for free users based on current usage
  Future<int> getRemainingPermanentSlots() async {
    // Premium users have unlimited
    if (isPremium) return 999;

    // Free users: calculate remaining
    final permanentCount = await getPermanentCount();
    final remaining = freeLimit - permanentCount;
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
    if (isPremium) {
      status = LimitStatus.unlimited;
    } else if (permanentCount < freeLimit) {
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
  /// - Premium users: always permanent (unlockedUntil = null)
  /// - Free users with slots: permanent (unlockedUntil = null)
  /// - Free users without slots: temporary 7-day unlock
  ///
  /// Returns exercise with correct unlockedUntil field
  Future<CustomExercise> prepareExerciseForSave(CustomExercise exercise) async {
    // Premium users always get permanent
    if (isPremium) {
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
  /// Has free slots available (< 5 permanent)
  available,

  /// Limit reached, needs ad (>= 5 permanent)
  requiresAd,

  /// Premium user, unlimited
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

  /// Remaining permanent slots (0-5 for free, 999 for premium)
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
