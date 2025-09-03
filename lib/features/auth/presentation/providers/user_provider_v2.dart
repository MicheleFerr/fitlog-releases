/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: auth
 * 🔧 Type: provider
 * 🌍 Localization: N/A - Provider class
 * 🎨 Theme: N/A - Provider class
 * 📱 Platform: Universal
 * 
 * CONSOLIDATED USER PROVIDER V2 - Type-safe user state management
 * This is the NEW standard provider - replaces both currentUserProvider and userProfileProvider
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile_consolidated.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_state.dart';

/// Main user state provider - USE THIS FOR EVERYTHING
/// Provides type-safe access to user state with proper error handling
final userStateProvider = StreamProvider<UserState>((ref) async* {
  final firestore = FirebaseFirestore.instance;
  
  yield const UserLoading();
  
  await for (final firebaseUser in FirebaseAuth.instance.authStateChanges()) {
    if (firebaseUser == null) {
      yield const UserUnauthenticated();
    } else if (firebaseUser.isAnonymous) {
      yield const UserAnonymous();
    } else {
      try {
        // Listen to user document changes
        await for (final snapshot in firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots()) {
          
          if (!snapshot.exists) {
            // Create new user document
            final newProfile = UserProfile.fromFirebaseUser(firebaseUser);
            await snapshot.reference.set(newProfile.toFirestore());
            yield UserAuthenticated(newProfile);
          } else {
            // Parse existing user document
            final profile = UserProfile.fromFirestore(snapshot);
            yield UserAuthenticated(profile);
          }
        }
      } catch (error, stackTrace) {
        // Log error but provide fallback
        print('Error loading user profile: $error');
        
        // Fallback to basic profile from Firebase Auth
        try {
          final fallbackProfile = UserProfile.fromFirebaseUser(firebaseUser);
          yield UserAuthenticated(fallbackProfile);
        } catch (_) {
          yield UserError(error, stackTrace);
        }
      }
    }
  }
});

/// Synchronous access to current user state
final currentUserStateProvider = Provider<UserState>((ref) {
  return ref.watch(userStateProvider).when(
    data: (state) => state,
    loading: () => const UserLoading(),
    error: (error, stack) => UserError(error, stack),
  );
});

/// Quick access to user profile (null if not authenticated)
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  final state = ref.watch(currentUserStateProvider);
  return state.profileOrNull;
});

/// Quick check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(currentUserStateProvider);
  return state.isAuthenticated;
});

/// Quick check if user is premium
final isPremiumUserProvider = Provider<bool>((ref) {
  final state = ref.watch(currentUserStateProvider);
  return state.isPremium;
});

/// Get current user ID (null if not authenticated)
final currentUserIdProvider = Provider<String?>((ref) {
  final profile = ref.watch(currentUserProfileProvider);
  return profile?.uid;
});

/// Get current user display name
final currentUserDisplayNameProvider = Provider<String>((ref) {
  final profile = ref.watch(currentUserProfileProvider);
  return profile?.displayName ?? 'Guest';
});

/// Get current user account tier
final currentAccountTierProvider = Provider<AccountTier>((ref) {
  final profile = ref.watch(currentUserProfileProvider);
  return profile?.accountTier ?? AccountTier.free;
});

/// Get template quota
final templateQuotaProvider = Provider<TemplateQuota>((ref) {
  final profile = ref.watch(currentUserProfileProvider);
  return profile?.templateQuota ?? TemplateQuota.forTier(AccountTier.free);
});

/// Example usage in widgets:
/// 
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final userState = ref.watch(currentUserStateProvider);
///     
///     return userState.when(
///       authenticated: (profile) => Text('Welcome ${profile.displayName}'),
///       anonymous: () => Text('Welcome Guest'),
///       unauthenticated: () => Text('Please sign in'),
///       loading: () => CircularProgressIndicator(),
///       error: (e, s) => Text('Error: $e'),
///     );
///   }
/// }
/// ```

/// Migration helper - Maps old providers to new ones
/// TODO: Remove after full migration
extension MigrationHelpers on WidgetRef {
  /// Replaces ref.watch(userProfileProvider)
  AsyncValue<UserProfile?> get watchUserProfile {
    return watch(userStateProvider).whenData((state) => state.profileOrNull);
  }
  
  /// Replaces ref.watch(currentUserProvider)
  User? get watchFirebaseUser {
    return FirebaseAuth.instance.currentUser;
  }
}