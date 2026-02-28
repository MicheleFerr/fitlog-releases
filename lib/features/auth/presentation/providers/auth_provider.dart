import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/core/services/rate_limiter.dart'
    show CooldownLimiter;
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/achievement_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/exercise_records_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_usage_tracker.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/home/providers/daily_login_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/features/progress/presentation/providers/cached_progress_provider.dart';
import 'package:gymbro_flutter_new/features/scheduling/presentation/providers/scheduling_provider.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/cloud_sync_provider.dart';
import 'package:gymbro_flutter_new/features/streak/presentation/providers/streak_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/workout_session_la_service.dart';
import 'package:gymbro_flutter_new/features/workout/data/services/template_cloud_sync_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/firebase_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_auto_save_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_modal.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/services/initial/onboarding_completion_identity_store.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

// Re-export shared providers for backward compatibility.
// All existing imports of auth_provider.dart continue to work.
export 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_providers_shared.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_providers_shared.dart';

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

// authStateProvider is now defined in auth_providers_shared.dart
// and re-exported above for backward compatibility.

// Auth Controller
final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  AuthService get _authService => ref.watch(authServiceProvider);

  /// 🔧 FIX: Check if user has completed onboarding and reset local flag if not
  ///
  /// Called after successful login to ensure new users see onboarding even
  /// if another user had already completed it on this device.
  Future<void> _checkAndResetOnboardingForNewUser(String uid) async {
    try {
      final appConfig = ref.read(appConfigProvider);
      final appConfigNotifier = ref.read(appConfigProvider.notifier);
      final localCompleted = appConfig.initialOnboardingCompleted;
      final completedForUserId =
          await OnboardingCompletionIdentityStore.getCompletedUserId();

      // Get user document from Firestore
      final userDoc = await _authService.getUserDocument(uid);

      if (!userDoc.exists) {
        // New user without document - definitely needs onboarding
        if (kDebugMode) {
          debugPrint(
            '[Auth] 🆕 New user (no document) - resetting onboarding flag',
          );
        }
        await appConfigNotifier.setInitialOnboardingCompleted(false);
        await OnboardingCompletionIdentityStore.clearCompletedUserId();
        return;
      }

      // Check if user has completed onboarding
      final data = userDoc.data() as Map<String, dynamic>?;
      final hasRemoteOnboardingFlag =
          data?.containsKey('onboardingCompleted') == true;
      final hasCompletedOnboarding = data?['onboardingCompleted'] == true;

      if (!hasRemoteOnboardingFlag) {
        // Remote flag missing:
        // - preserve local completion for the same local owner
        // - reset only when completion clearly belongs to another user
        if (localCompleted &&
            completedForUserId != null &&
            completedForUserId != uid) {
          if (kDebugMode) {
            debugPrint(
              '[Auth] 🔄 onboardingCompleted missing remotely and local completion belongs to another user → reset local flag',
            );
          }
          await appConfigNotifier.setInitialOnboardingCompleted(false);
          await OnboardingCompletionIdentityStore.clearCompletedUserId();
          return;
        }

        if (kDebugMode) {
          debugPrint(
            '[Auth] ℹ️ onboardingCompleted missing in Firestore - preserving local flag: $localCompleted',
          );
        }
        return;
      }

      if (hasCompletedOnboarding) {
        if (!localCompleted) {
          if (kDebugMode) {
            debugPrint(
              '[Auth] ✅ Remote onboarding completed - restoring local flag',
            );
          }
          await appConfigNotifier.setInitialOnboardingCompleted(true);
        }
        await OnboardingCompletionIdentityStore.setCompletedUserId(uid);
        if (kDebugMode) {
          debugPrint('[Auth] ✅ User has completed onboarding');
        }
        return;
      }

      // Explicit remote false.
      // If local completion belongs to this same user, preserve local state and
      // repair remote flag (handles delayed/non-blocking sync from onboarding).
      if (localCompleted && completedForUserId == uid) {
        if (kDebugMode) {
          debugPrint(
            '[Auth] ♻️ Remote onboarding false but local completion belongs to same user - preserving local and repairing remote',
          );
        }
        await _tryRepairRemoteOnboardingFlag(uid);
        return;
      }

      if (localCompleted) {
        if (kDebugMode) {
          debugPrint(
            '[Auth] 🔄 Remote onboarding not completed - resetting local flag',
          );
        }
        await appConfigNotifier.setInitialOnboardingCompleted(false);
        await OnboardingCompletionIdentityStore.clearCompletedUserId();
      } else if (completedForUserId != null) {
        await OnboardingCompletionIdentityStore.clearCompletedUserId();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[Auth] ⚠️ Error checking onboarding status (preserving local flag): $e',
        );
      }
      // Preserve local state on transient network/permission errors.
    }
  }

  Future<void> _tryRepairRemoteOnboardingFlag(String uid) async {
    try {
      await _authService.updateUserDocument(uid, {
        'onboardingCompleted': true,
        'onboardingCompletedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) {
        debugPrint('[Auth] ✅ Repaired remote onboardingCompleted flag');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] ⚠️ Failed to repair remote onboarding flag: $e');
      }
    }
  }

  // Register with Email and Password
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();

    try {
      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // 🔧 FIX: New users always need onboarding - reset local flag
      if (credential?.user != null) {
        await _checkAndResetOnboardingForNewUser(credential!.user!.uid);
      }

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

      // 🔧 FIX: Check and reset onboarding for new users
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _checkAndResetOnboardingForNewUser(currentUser.uid);
      }

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign In with Google
  Future<void> signInWithGoogle({bool forceAccountSelection = false}) async {
    state = const AsyncValue.loading();

    try {
      final credential = await _authService.signInWithGoogle(
        forceAccountSelection: forceAccountSelection,
      );

      // 🔧 FIX: Check and reset onboarding for new users
      if (credential?.user != null) {
        await _checkAndResetOnboardingForNewUser(credential!.user!.uid);
      }

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Sign In with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final credential = await _authService.signInWithApple();

      // 🔧 FIX: Check and reset onboarding for new users
      if (credential?.user != null) {
        await _checkAndResetOnboardingForNewUser(credential!.user!.uid);
      }

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

      // 🔄 Template Cloud Sync Service (pending template queue for retry)
      // Clear all pending templates and stop periodic sync on logout
      await TemplateCloudSyncService.clearAll();
      TemplateCloudSyncService.dispose();

      if (kDebugMode) {
        debugPrint(
          '[Auth] ✅ Cleared singleton services (usage tracker, progress cache, LA service, template sync)',
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

// AuthState enum is now defined in auth_providers_shared.dart
