import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/services/rate_limiter.dart'
    show CooldownLimiter;
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_records_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/daily_login_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/providers/scheduling_provider.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/cloud_sync_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/firebase_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Current Firebase User Provider
final firebaseUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

// Current User Model Provider
final currentUserProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.watch(authServiceProvider);

  await for (final user in authService.authStateChanges) {
    if (user != null) {
      try {
        final userDoc = await authService.getUserDocument(user.uid);
        if (userDoc.exists) {
          yield UserModel.fromDocumentSnapshot(userDoc);
        } else {
          // User document will be created by AuthService automatically
          final newUserDoc = await authService.getUserDocument(user.uid);
          if (newUserDoc.exists) {
            yield UserModel.fromDocumentSnapshot(newUserDoc);
          } else {
            // Fallback: create basic user model
            yield UserModel(
              uid: user.uid,
              email: user.email ?? '',
              displayName:
                  user.displayName ??
                  (user.isAnonymous ? 'Guest User' : 'GymBro User'),
              photoURL: user.photoURL,
              isGuest: user.isAnonymous,
              preferences: const UserPreferences(),
              stats: const UserStats(),
            );
          }
        }
      } catch (e) {
        // Handle error by creating a basic UserModel from Firebase User
        yield UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName:
              user.displayName ??
              (user.isAnonymous ? 'Guest User' : 'GymBro User'),
          photoURL: user.photoURL,
          isGuest: user.isAnonymous,
          preferences: const UserPreferences(),
          stats: const UserStats(),
        );
      }
    } else {
      yield null;
    }
  }
});

// Auth State Provider (loading, authenticated, unauthenticated)
final authStateProvider = Provider<AuthState>((ref) {
  final asyncUser = ref.watch(firebaseUserProvider);

  return asyncUser.when(
    data: (user) =>
        user != null ? AuthState.authenticated : AuthState.unauthenticated,
    loading: () => AuthState.loading,
    error: (_, __) => AuthState.unauthenticated,
  );
});

// Auth Controller
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  AuthService get _authService => ref.watch(authServiceProvider);

  // Register with Email and Password
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign In with Email and Password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign In with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign In with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      await _authService.signInWithApple();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign In Anonymously (Guest Mode)
  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();

    try {
      await _authService.signInAnonymously();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign Out
  /// 🔧 FIX: Clear ALL local cache on logout to prevent data leakage between users
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      // 🔐 SECURITY: Clear ALL user data before sign out
      // This prevents the next user from seeing previous user's cached data
      await _clearAllUserCaches();

      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 🔐 SECURITY: Centralized cleanup of ALL user data caches
  ///
  /// Clears:
  /// 1. All Hive boxes (including unopened ones via HiveBoxManagerEnhanced)
  /// 2. Static in-memory caches (exercise, profile, rate limiter)
  /// 3. Singleton services (usage tracker, LA service, progress cache)
  /// 4. Provider-level caches (app config static cache)
  /// 5. Invalidate all user-specific Riverpod providers (XP, achievements, history, etc.)
  Future<void> _clearAllUserCaches() async {
    if (kDebugMode) {
      debugPrint('[Auth] 🔐 Starting comprehensive cache cleanup...');
    }

    // 1. Clear ALL Hive boxes (including unopened ones)
    try {
      final boxManager = ref.read(hiveBoxManagerProvider);
      await boxManager.clearAllUserData();
      if (kDebugMode) {
        debugPrint('[Auth] ✅ Cleared all Hive user data');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️ Failed to clear Hive cache: $e');
      }
    }

    // 2. Clear static in-memory caches
    try {
      // User profile cache (5-min TTL)
      ref.read(userProfileCacheProvider).clearAll();

      // Exercise replacement modal static cache
      ExerciseReplacementModal.clearStaticCache();

      // Rate limiter state (login attempts tracking)
      CooldownLimiter.resetAll();

      if (kDebugMode) {
        debugPrint(
          '[Auth] ✅ Cleared in-memory caches (profile, exercise modal, rate limiter)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️ Failed to clear in-memory caches: $e');
      }
    }

    // 3. Clear singleton services with user data
    try {
      // Exercise usage tracker (usage counts, boosts)
      await ExerciseUsageTracker().clearOnLogout();

      // Progress cache static maps (operation locks, calculations)
      ProgressCacheRepository.clearOnLogout();

      // iOS Live Activity session
      await WorkoutSessionLAService().resetOnLogout();

      if (kDebugMode) {
        debugPrint(
          '[Auth] ✅ Cleared singleton services (usage tracker, progress cache, LA service)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️ Failed to clear singleton services: $e');
      }
    }

    // 4. Clear provider-level static caches
    try {
      // AppConfig static cache (survives provider rebuilds)
      AppConfigNotifier.clearCachedConfigOnLogout();

      if (kDebugMode) {
        debugPrint('[Auth] ✅ Cleared provider static caches');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️ Failed to clear provider caches: $e');
      }
    }

    // 5. Invalidate ALL user-specific Riverpod providers
    // Forces re-fetch from Firebase on next login
    try {
      // XP & Gamification (CRITICAL - was missing, caused stale tier/XP)
      ref.invalidate(userXPProvider);
      ref.invalidate(dailyLoginProvider);

      // Achievements & PRs
      ref.invalidate(achievementNotifierProvider);
      ref.invalidate(unlockedAchievementsProvider);
      ref.invalidate(newlyDetectedPRsProvider);

      // Workout analytics & records
      ref.invalidate(workoutAnalyticsProvider);
      ref.invalidate(analyticsCacheServiceProvider);
      clearRecordsCache(); // Static in-memory exercise records cache

      // History & progress
      ref.invalidate(workoutHistoryRepositoryProvider);
      ref.invalidate(progressCacheRepositoryProvider);

      // Workout auto-save & templates
      ref.invalidate(workoutAutoSaveProvider);
      ref.invalidate(firebaseTemplateNotifierProvider);

      // Streak
      ref.invalidate(streakRepositoryProvider);

      // Scheduling
      ref.invalidate(schedulingProvider);

      // Cloud sync state
      ref.invalidate(cloudSyncProvider);

      // User profile (force re-stream on next login)
      ref.invalidate(userProfileNotifierProvider);

      if (kDebugMode) {
        debugPrint('[Auth] ✅ Invalidated all user-specific providers');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️ Failed to invalidate providers: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[Auth] 🔐 Comprehensive cache cleanup completed');
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();

    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete user account and all associated data (GDPR Art. 17)
  ///
  /// Returns true if deletion was successful, false if re-authentication is required.
  /// Throws an exception for other errors.
  Future<bool> deleteAccount() async {
    state = const AsyncValue.loading();

    try {
      // 🔐 SECURITY: Clear ALL local cache before account deletion
      await _clearAllUserCaches();

      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      // Check if re-authentication is required
      if (e.toString().contains('requires-recent-login')) {
        state = const AsyncValue.data(null);
        return false; // Signal that re-auth is needed
      }
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

enum AuthState { loading, authenticated, unauthenticated }
