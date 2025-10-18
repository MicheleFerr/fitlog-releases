/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: auth
/// 🔧 Type: provider
/// 🌍 Localization: N/A - Provider class
/// 🎨 Theme: N/A - Provider class
/// 📱 Platform: Universal
/// 
/// UNIFIED USER PROVIDER - Compatibility layer for safe migration
/// This provider unifies all duplicate user providers without breaking existing code
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// ============================================================================
/// COMPATIBILITY LAYER - Uses EXISTING providers to avoid breaking changes
/// ============================================================================

/// Unified Firebase User Provider (replaces 4 duplicate definitions)
/// This uses the EXISTING Firebase Auth stream
final unifiedFirebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Unified User Profile Provider (uses EXISTING UserProfile entity)
/// This is compatible with current codebase
final unifiedUserProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final firestore = FirebaseFirestore.instance;
  
  // Watch Firebase auth state
  await for (final firebaseUser in FirebaseAuth.instance.authStateChanges()) {
    if (firebaseUser == null) {
      yield null;
    } else {
      try {
        // Listen to user document changes
        await for (final snapshot in firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots()) {
          
          if (!snapshot.exists) {
            // Create basic profile from Firebase user
            // Using EXISTING UserProfile structure to avoid breaking changes
            final data = {
              'uid': firebaseUser.uid,
              'email': firebaseUser.email ?? '',
              'displayName': firebaseUser.displayName ?? 'GymBro User',
              'photoURL': firebaseUser.photoURL,
              'accountTier': 'free',
              'templateQuota': {
                'maxPrivateTemplates': 10,
                'maxPublicTemplates': 2,
                'usedPrivateTemplates': 0,
                'usedPublicTemplates': 0,
              },
              'createdAt': DateTime.now().toIso8601String(),
              'lastLoginAt': DateTime.now().toIso8601String(),
              'preferences': {},
              'stats': {},
              'isGuest': firebaseUser.isAnonymous,
            };
            
            // Save to Firestore
            await snapshot.reference.set(data);
            
            // Return the profile
            yield UserProfile.fromJson(data);
          } else {
            // Use existing UserProfile.fromFirestore method
            yield UserProfile.fromFirestore(snapshot);
          }
        }
      } catch (error) {
        // Log error but provide fallback
        // print('Error loading user profile: $error');
        
        // Fallback to basic profile
        yield UserProfile(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'GymBro User',
          photoURL: firebaseUser.photoURL,
          accountTier: AccountTier.free,
          templateQuota: TemplateQuota.forTier(AccountTier.free),
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: {},
          stats: {},
          isGuest: firebaseUser.isAnonymous,
        );
      }
    }
  }
});

/// ============================================================================
/// HELPER PROVIDERS - Compatible with existing code patterns
/// ============================================================================

/// Get current user ID (compatible with existing usage)
/// Alias for backwards compatibility
final unifiedUserProvider = unifiedUserProfileProvider;

final unifiedUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(unifiedFirebaseUserProvider).value;
  return user?.uid;
});

/// Check if user is authenticated (compatible with existing usage)
final unifiedIsAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(unifiedFirebaseUserProvider).value;
  return user != null && !user.isAnonymous;
});

/// Check if user is premium (compatible with existing usage)
final unifiedIsPremiumProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(unifiedUserProfileProvider);
  final profile = profileAsync.value;
  return profile?.isPremium ?? false;
});

/// Get display name with fallback (compatible with existing usage)
final unifiedDisplayNameProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(unifiedUserProfileProvider);
  final profile = profileAsync.value;
  return profile?.displayName ?? 'Guest';
});

/// Get account tier (compatible with existing usage)
final unifiedAccountTierProvider = Provider<AccountTier>((ref) {
  final profileAsync = ref.watch(unifiedUserProfileProvider);
  final profile = profileAsync.value;
  return profile?.accountTier ?? AccountTier.free;
});

/// ============================================================================
/// MIGRATION HELPERS - Gradual migration from old providers
/// ============================================================================

/// Extension to help migrate existing code gradually
extension UnifiedUserProviderMigration on WidgetRef {
  /// Drop-in replacement for ref.watch(currentUserProvider)
  /// Works with ANY of the 4 duplicate definitions
  AsyncValue<User?> get watchCurrentUser {
    return watch(unifiedFirebaseUserProvider);
  }
  
  /// Drop-in replacement for ref.watch(userProfileProvider)
  AsyncValue<UserProfile?> get watchUserProfile {
    return watch(unifiedUserProfileProvider);
  }
  
  /// Quick access to profile without AsyncValue
  UserProfile? get userProfile {
    return watch(unifiedUserProfileProvider).value;
  }
  
  /// Quick check if premium
  bool get isPremiumUser {
    return watch(unifiedIsPremiumProvider);
  }
  
  /// Quick get user ID
  String? get userId {
    return watch(unifiedUserIdProvider);
  }
}

/// ============================================================================
/// USAGE EXAMPLES - How to migrate existing code
/// ============================================================================

/// Example 1: Replace duplicate currentUserProvider
/// 
/// OLD:
/// ```dart
/// final user = ref.watch(currentUserProvider).value;
/// ```
/// 
/// NEW:
/// ```dart
/// final user = ref.watchCurrentUser.value;
/// // OR
/// final user = ref.watch(unifiedFirebaseUserProvider).value;
/// ```

/// Example 2: Replace userProfileProvider
/// 
/// OLD:
/// ```dart
/// final profile = ref.watch(userProfileProvider).value;
/// ```
/// 
/// NEW:
/// ```dart
/// final profile = ref.userProfile;
/// // OR
/// final profile = ref.watch(unifiedUserProfileProvider).value;
/// ```

/// Example 3: Check premium status
/// 
/// OLD:
/// ```dart
/// final profile = ref.watch(userProfileProvider).value;
/// if (profile?.isPremium == true) { ... }
/// ```
/// 
/// NEW:
/// ```dart
/// if (ref.isPremiumUser) { ... }
/// ```