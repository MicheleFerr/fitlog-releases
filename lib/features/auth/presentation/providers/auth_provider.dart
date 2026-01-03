import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_model.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';

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
              displayName: user.displayName ?? (user.isAnonymous ? 'Guest User' : 'GymBro User'),
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
          displayName: user.displayName ?? (user.isAnonymous ? 'Guest User' : 'GymBro User'),
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
  /// 🔧 FIX: Clear local cache on logout to prevent data leakage between users
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      // 🔐 SECURITY: Clear local workout history cache before sign out
      // This prevents the next user from seeing previous user's data
      try {
        final historyRepo = ref.read(workoutHistoryRepositoryProvider);
        await historyRepo.clearCache();
        if (kDebugMode) {
          debugPrint('🗑️ [Auth] Cleared workout history cache on logout');
        }
      } catch (e) {
        // Don't block logout if cache clear fails
        if (kDebugMode) {
          debugPrint('⚠️ [Auth] Failed to clear cache on logout: $e');
        }
      }

      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
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
      // 🔐 SECURITY: Clear local cache before account deletion
      try {
        final historyRepo = ref.read(workoutHistoryRepositoryProvider);
        await historyRepo.clearCache();
        if (kDebugMode) {
          debugPrint('🗑️ [Auth] Cleared workout history cache on account deletion');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ [Auth] Failed to clear cache on delete: $e');
        }
      }

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
