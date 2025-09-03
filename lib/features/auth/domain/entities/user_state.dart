/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain
 * 🎯 Feature: auth
 * 🔧 Type: entity
 * 🌍 Localization: N/A - Entity class
 * 🎨 Theme: N/A - Entity class
 * 📱 Platform: Universal
 * 
 * TYPE-SAFE USER STATE - Prevents null pointer and type errors
 */

import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile_consolidated.dart';

/// Type-safe user state using sealed classes
/// This ensures compile-time safety when accessing user data
sealed class UserState {
  const UserState();
  
  /// Pattern matching helper for cleaner code
  T when<T>({
    required T Function(UserProfile profile) authenticated,
    required T Function() anonymous,
    required T Function() unauthenticated,
    required T Function() loading,
    required T Function(Object error, StackTrace stackTrace) error,
  }) {
    return switch (this) {
      UserAuthenticated(:final profile) => authenticated(profile),
      UserAnonymous() => anonymous(),
      UserUnauthenticated() => unauthenticated(),
      UserLoading() => loading(),
      UserError(error: final err, stackTrace: final st) => error(err, st),
    };
  }
  
  /// Simplified pattern matching for common cases
  T maybeWhen<T>({
    T Function(UserProfile profile)? authenticated,
    T Function()? orElse,
  }) {
    if (this is UserAuthenticated && authenticated != null) {
      return authenticated((this as UserAuthenticated).profile);
    }
    return orElse != null ? orElse() : throw UnimplementedError();
  }
  
  /// Quick getters for common checks
  bool get isAuthenticated => this is UserAuthenticated;
  bool get isAnonymous => this is UserAnonymous;
  bool get isUnauthenticated => this is UserUnauthenticated;
  bool get isLoading => this is UserLoading;
  bool get hasError => this is UserError;
  
  /// Safe profile access
  UserProfile? get profileOrNull => 
      this is UserAuthenticated ? (this as UserAuthenticated).profile : null;
  
  /// Premium status check
  bool get isPremium => 
      this is UserAuthenticated && (this as UserAuthenticated).profile.isPremium;
}

/// User is authenticated with a profile
class UserAuthenticated extends UserState {
  final UserProfile profile;
  
  const UserAuthenticated(this.profile);
  
  @override
  String toString() => 'UserAuthenticated(${profile.displayName})';
}

/// User is anonymous/guest
class UserAnonymous extends UserState {
  const UserAnonymous();
  
  @override
  String toString() => 'UserAnonymous()';
}

/// User is not authenticated
class UserUnauthenticated extends UserState {
  const UserUnauthenticated();
  
  @override
  String toString() => 'UserUnauthenticated()';
}

/// User state is loading
class UserLoading extends UserState {
  const UserLoading();
  
  @override
  String toString() => 'UserLoading()';
}

/// Error loading user state
class UserError extends UserState {
  final Object error;
  final StackTrace stackTrace;
  
  const UserError(this.error, this.stackTrace);
  
  @override
  String toString() => 'UserError($error)';
}

/// Extension for easier widget building
extension UserStateWidgetExt on UserState {
  /// Use in build methods for conditional rendering
  T buildWhen<T>({
    required T Function(UserProfile profile) authenticated,
    required T Function() unauthenticated,
    T Function()? loading,
    T Function(Object error)? error,
  }) {
    return when(
      authenticated: authenticated,
      anonymous: unauthenticated,
      unauthenticated: unauthenticated,
      loading: loading ?? unauthenticated,
      error: (e, s) => error?.call(e) ?? unauthenticated(),
    );
  }
}