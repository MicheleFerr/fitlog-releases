/// Shared auth providers - base providers without circular dependencies.
///
/// Extracted from auth_provider.dart to allow features like progress/
/// to access auth state without importing the full AuthController.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/data/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Current Firebase User Provider
final firebaseUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

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

enum AuthState { loading, authenticated, unauthenticated }
