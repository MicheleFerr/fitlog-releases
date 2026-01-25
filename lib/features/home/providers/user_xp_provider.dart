/// Central User XP Provider
///
/// Aggregates XP from all sources:
/// - Achievement XP (unlocked achievements)
/// - Daily Login XP (consecutive login bonuses)
/// - Workout XP (completed workouts)
///
/// This is the SINGLE SOURCE OF TRUTH for user XP.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/daily_login_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/models/level_system.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

/// State class for total user XP
@immutable
class UserXPState {
  const UserXPState({
    this.achievementXP = 0,
    this.dailyLoginXP = 0,
    this.workoutXP = 0,
    this.isLoading = false,
    this.error,
  });

  /// XP from unlocked achievements
  final int achievementXP;

  /// XP from daily login bonuses
  final int dailyLoginXP;

  /// XP from completed workouts
  final int workoutXP;

  /// Loading state
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Total XP from all sources
  int get totalXP => achievementXP + dailyLoginXP + workoutXP;

  /// Current user tier based on total XP
  UserTier get currentTier => UserTier.fromXP(totalXP);

  /// Level info based on total XP
  LevelInfo get levelInfo => LevelSystem.getLevelInfo(totalXP);

  /// Progress to next tier (0.0 to 1.0)
  double get tierProgress => currentTier.progressToNext(totalXP);

  /// XP needed for next tier
  int get xpToNextTier {
    final next = currentTier.next;
    if (next == null) return 0;
    return next.minXP - totalXP;
  }

  UserXPState copyWith({
    int? achievementXP,
    int? dailyLoginXP,
    int? workoutXP,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserXPState(
      achievementXP: achievementXP ?? this.achievementXP,
      dailyLoginXP: dailyLoginXP ?? this.dailyLoginXP,
      workoutXP: workoutXP ?? this.workoutXP,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() =>
      'UserXPState(total: $totalXP, achievement: $achievementXP, dailyLogin: $dailyLoginXP, workout: $workoutXP, tier: ${currentTier.displayName})';
}

/// Central XP Notifier - Aggregates all XP sources
class UserXPNotifier extends Notifier<UserXPState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  UserXPState build() {
    // Setup listeners to XP sources
    _setupListeners();

    // Initialize asynchronously
    Future.microtask(() => _initialize());

    return const UserXPState(isLoading: true);
  }

  void _setupListeners() {
    // Listen to daily login XP changes
    ref.listen<DailyLoginState>(
      dailyLoginProvider,
      (previous, next) {
        if (state.dailyLoginXP != next.totalXpEarned) {
          state = state.copyWith(dailyLoginXP: next.totalXpEarned);
          if (kDebugMode) {
            debugPrint('📊 [UserXP] Daily login XP updated: ${next.totalXpEarned}');
          }
        }
      },
    );
  }

  Future<void> _initialize() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        state = const UserXPState();
        return;
      }

      // Load daily login XP
      final dailyLoginState = ref.read(dailyLoginProvider);
      final dailyLoginXP = dailyLoginState.totalXpEarned;

      // Load achievement XP and workout XP from Firestore
      int achievementXP = 0;
      int workoutXP = 0;
      try {
        final doc = await _firestore
            .collection('user_xp')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          achievementXP = (data?['achievementXP'] as num?)?.toInt() ?? 0;
          workoutXP = (data?['workoutXP'] as num?)?.toInt() ?? 0;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [UserXP] Failed to load XP from Firestore: $e');
        }
      }

      state = UserXPState(
        achievementXP: achievementXP,
        dailyLoginXP: dailyLoginXP,
        workoutXP: workoutXP,
        isLoading: false,
      );

      if (kDebugMode) {
        debugPrint('✅ [UserXP] Initialized: $state');
      }
    } catch (e) {
      state = UserXPState(
        isLoading: false,
        error: 'Failed to initialize XP: $e',
      );
      if (kDebugMode) {
        debugPrint('❌ [UserXP] Init failed: $e');
      }
    }
  }

  /// Add XP from a completed workout
  ///
  /// Calculates XP using LevelSystem formula and saves to Firestore.
  /// Returns the XP awarded.
  Future<int> addWorkoutXP({
    required String workoutId,
    required int durationMinutes,
    required int exerciseCount,
    required double totalVolume,
    bool isPersonalRecord = false,
    int streakDays = 0,
  }) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return 0;

      // Calculate XP using existing formula
      final xpEarned = LevelSystem.calculateWorkoutXp(
        duration: durationMinutes,
        exercises: exerciseCount,
        totalVolume: totalVolume,
        isPersonalRecord: isPersonalRecord,
        streakDays: streakDays,
      );

      // Update Firestore
      await _firestore.collection('user_xp').doc(user.uid).set({
        'workoutXP': FieldValue.increment(xpEarned),
        'lastWorkoutXP': xpEarned,
        'lastWorkoutId': workoutId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update local state
      state = state.copyWith(workoutXP: state.workoutXP + xpEarned);

      if (kDebugMode) {
        debugPrint('🎉 [UserXP] Workout XP awarded: +$xpEarned (total workout XP: ${state.workoutXP})');
        debugPrint('   Duration: ${durationMinutes}min, Exercises: $exerciseCount, Volume: ${totalVolume.toStringAsFixed(0)}kg');
        if (isPersonalRecord) debugPrint('   🏆 PR bonus included!');
        if (streakDays > 0) debugPrint('   🔥 Streak bonus: $streakDays days');
      }

      return xpEarned;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [UserXP] Failed to add workout XP: $e');
      }
      return 0;
    }
  }

  /// Add daily login XP bonus
  ///
  /// Called from daily_login_provider when user claims bonus.
  Future<int> addDailyLoginXP(int xp) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return 0;

      // Daily login XP is already tracked in SharedPreferences by daily_login_provider
      // We just update our local state to reflect it
      state = state.copyWith(dailyLoginXP: state.dailyLoginXP + xp);

      if (kDebugMode) {
        debugPrint('🎉 [UserXP] Daily login XP: +$xp (total daily XP: ${state.dailyLoginXP})');
      }

      return xp;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [UserXP] Failed to add daily login XP: $e');
      }
      return 0;
    }
  }

  /// Add achievement XP when badge is unlocked
  ///
  /// Called from achievement unlock flow when user unlocks a new badge.
  Future<int> addAchievementXP(int xp, {required String badgeName}) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return 0;

      // Update Firestore
      await _firestore.collection('user_xp').doc(user.uid).set({
        'achievementXP': FieldValue.increment(xp),
        'lastAchievementXP': xp,
        'lastAchievementName': badgeName,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update local state
      state = state.copyWith(achievementXP: state.achievementXP + xp);

      if (kDebugMode) {
        debugPrint('🏆 [UserXP] Achievement XP awarded: +$xp for "$badgeName" (total achievement XP: ${state.achievementXP})');
      }

      return xp;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [UserXP] Failed to add achievement XP: $e');
      }
      return 0;
    }
  }

  /// Force refresh XP from all sources
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _initialize();
  }
}

/// Main provider for central user XP
final userXPProvider = NotifierProvider<UserXPNotifier, UserXPState>(
  UserXPNotifier.new,
);

/// Convenience provider for total XP
final totalUserXPProvider = Provider<int>((ref) {
  return ref.watch(userXPProvider).totalXP;
});

/// Convenience provider for current tier
final userTierProvider = Provider<UserTier>((ref) {
  return ref.watch(userXPProvider).currentTier;
});

/// Convenience provider for level info
final userLevelInfoProvider = Provider<LevelInfo>((ref) {
  return ref.watch(userXPProvider).levelInfo;
});

/// Convenience provider for tier progress (0.0 to 1.0)
final userTierProgressProvider = Provider<double>((ref) {
  return ref.watch(userXPProvider).tierProgress;
});
