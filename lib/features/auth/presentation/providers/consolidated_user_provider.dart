/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: auth
/// 🔧 Type: provider (CANONICAL - Single Source of Truth)
/// 🌍 Localization: N/A - Provider logic
/// 🎨 Theme: N/A - Provider logic
/// 📱 Platform: Universal
///
/// ============================================================================
/// CONSOLIDATED USER PROVIDER - SINGLE SOURCE OF TRUTH
/// ============================================================================
///
/// This file replaces 5 duplicate user providers:
/// - current_user_provider.dart (49 usages)
/// - user_profile_provider.dart (30 usages)
/// - unified_user_provider.dart (20 usages)
/// - user_provider_v2.dart (16 usages)
/// - cached_user_provider.dart (6 usages)
///
/// Features consolidated:
/// ✅ Firebase Auth state management
/// ✅ Firestore user profile sync
/// ✅ In-memory caching (5-min TTL for performance)
/// ✅ Template quota management (increment/decrement/sync)
/// ✅ Account tier upgrades
/// ✅ Helper providers (isPremium, displayName, userId, etc.)
/// ✅ Backward-compatible aliases for gradual migration
///
/// Dependencies:
/// - Riverpod: StreamProvider, NotifierProvider
/// - Firebase: Auth, Firestore
/// - Entity: UserProfile (stable version)
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// ============================================================================
/// CACHING LAYER (from cached_user_provider.dart)
/// ============================================================================

/// Cache duration for user profile (5 minutes)
const _cacheDuration = Duration(minutes: 5);

/// In-memory cache for user profiles
class UserProfileCache {
  final Map<String, UserProfile> _cache = {};
  final Map<String, DateTime> _cacheExpiry = {};

  /// Get cached profile if valid
  UserProfile? get(String uid) {
    if (_cache.containsKey(uid)) {
      final expiry = _cacheExpiry[uid];
      if (expiry != null && DateTime.now().isBefore(expiry)) {
        return _cache[uid];
      }
      // Cache expired, remove it
      _cache.remove(uid);
      _cacheExpiry.remove(uid);
    }
    return null;
  }

  /// Store profile in cache
  void set(String uid, UserProfile profile) {
    _cache[uid] = profile;
    _cacheExpiry[uid] = DateTime.now().add(_cacheDuration);
  }

  /// Clear cache for a specific user
  void clear(String uid) {
    _cache.remove(uid);
    _cacheExpiry.remove(uid);
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
    _cacheExpiry.clear();
  }
}

/// Global cache instance
final _userProfileCache = UserProfileCache();

/// Provider for the cache (for testing and cache management)
final userProfileCacheProvider = Provider<UserProfileCache>((ref) {
  return _userProfileCache;
});

/// ============================================================================
/// CORE PROVIDERS (Single Source of Truth)
/// ============================================================================

/// Provider for the current Firebase authenticated user
/// Replaces: currentUserProvider from current_user_provider.dart
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for the current user ID
/// Replaces: currentUserIdProvider, unifiedUserIdProvider
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.uid;
});

/// Provider to check if user is authenticated
/// Replaces: isAuthenticatedProvider, unifiedIsAuthenticatedProvider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user != null && !user.isAnonymous;
});

/// ============================================================================
/// USER PROFILE STREAM PROVIDER (with caching)
/// ============================================================================

/// CANONICAL User Profile Provider - USE THIS FOR USER PROFILE ACCESS
///
/// Features:
/// - Real-time Firestore sync
/// - 5-minute in-memory cache for performance
/// - Auto-creates profile for new users
/// - Fallback to basic profile on errors
///
/// Replaces: userProfileProvider, cachedUserProfileProvider,
///           unifiedUserProfileProvider, userStateProvider
final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final firestore = FirebaseFirestore.instance;
  final cache = ref.watch(userProfileCacheProvider);

  await for (final firebaseUser in FirebaseAuth.instance.authStateChanges()) {
    if (firebaseUser == null) {
      // User logged out, clear cache
      cache.clearAll();
      yield null;
    } else {
      // Check cache first and yield immediately for fast UI
      final cachedProfile = cache.get(firebaseUser.uid);
      if (cachedProfile != null) {
        yield cachedProfile;
        // DON'T continue - fall through to start Firestore listener
      }

      try {
        // Fetch current state from Firestore (skip if we already have cache)
        if (cachedProfile == null) {
          final snapshot = await firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

          if (!snapshot.exists) {
            // Create basic profile from Firebase user
            final data = {
              'uid': firebaseUser.uid,
              'email': firebaseUser.email ?? '',
              'displayName': firebaseUser.displayName ?? 'GymBro User',
              'photoURL': firebaseUser.photoURL,
              'accountTier': 'free',
              'templateQuota': {
                'maxPrivateTemplates': 4,
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

            // Create profile and cache it
            final profile = UserProfile.fromJson(data);
            cache.set(firebaseUser.uid, profile);
            yield profile;
          } else {
            // Use existing profile
            final profile = UserProfile.fromFirestore(snapshot);
            cache.set(firebaseUser.uid, profile);
            yield profile;
          }
        }

        // ALWAYS listen for real-time updates (even if we started from cache)
        await for (final updateSnapshot in firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots()) {

          if (updateSnapshot.exists) {
            final updatedProfile = UserProfile.fromFirestore(updateSnapshot);
            cache.set(firebaseUser.uid, updatedProfile);
            yield updatedProfile;
          }
        }
      } catch (error) {
        // Fallback to basic profile
        final fallbackProfile = UserProfile(
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

        // Cache fallback to avoid repeated errors
        cache.set(firebaseUser.uid, fallbackProfile);
        yield fallbackProfile;
      }
    }
  }
});

/// ============================================================================
/// NOTIFIER (for mutations)
/// ============================================================================

/// Notifier for managing user profile updates
/// Handles: template quota, tier upgrades, profile updates
class UserProfileNotifier extends Notifier<AsyncValue<UserProfile?>> {
  final _firestore = FirebaseFirestore.instance;

  @override
  AsyncValue<UserProfile?> build() {
    // Listen to the userProfileProvider stream
    ref.listen(userProfileProvider, (previous, next) {
      state = next;
    });

    return const AsyncValue.loading();
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    try {
      await _firestore.collection('users').doc(currentProfile.uid).update(updates);
      // Stream will auto-update
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Increment template count
  Future<void> incrementTemplateCount({required bool isPublic}) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.incrementTemplateUsage(isPublic: isPublic);

    try {
      await _firestore.collection('users').doc(currentProfile.uid).update({
        'templateQuota': updatedProfile.templateQuota.toJson(),
      });

      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Decrement template count
  Future<void> decrementTemplateCount({required bool isPublic}) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.decrementTemplateUsage(isPublic: isPublic);

    try {
      await _firestore.collection('users').doc(currentProfile.uid).update({
        'templateQuota': updatedProfile.templateQuota.toJson(),
      });

      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Check if user can save a template
  Future<bool> canSaveTemplate({required bool isPublic}) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return false;

    return isPublic
        ? currentProfile.templateQuota.canSavePublic
        : currentProfile.templateQuota.canSavePrivate;
  }

  /// Get remaining quota
  int getRemainingQuota({required bool isPublic}) {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return 0;

    return isPublic
        ? currentProfile.templateQuota.remainingPublic
        : currentProfile.templateQuota.remainingPrivate;
  }

  /// Upgrade user tier
  Future<void> upgradeTier(AccountTier newTier) async {
    // FIX: If local state is loading/null, read from stream provider which has data
    var currentProfile = state.valueOrNull;
    if (currentProfile == null) {
      // Fallback: read from userProfileProvider (the stream that has data)
      currentProfile = ref.read(userProfileProvider).valueOrNull;
    }

    if (currentProfile == null) {
      return;
    }

    final newQuota = TemplateQuota.forTier(
      newTier,
      usedPrivate: currentProfile.templateQuota.usedPrivateTemplates,
      usedPublic: currentProfile.templateQuota.usedPublicTemplates,
    );

    final updatedProfile = currentProfile.copyWith(
      accountTier: newTier,
      templateQuota: newQuota,
    );

    try {
      await _firestore.collection('users').doc(currentProfile.uid).update({
        'accountTier': newTier.name,
        'templateQuota': newQuota.toJson(),
      });

      // Update local state immediately
      state = AsyncValue.data(updatedProfile);

      // Update cache with new profile (so userProfileProvider has fresh data)
      final cache = ref.read(userProfileCacheProvider);
      cache.set(currentProfile.uid, updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Sync template count from actual templates in database
  Future<void> syncTemplateCount() async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    try {
      final templatesSnapshot = await _firestore
          .collection('workoutTemplates')
          .where('userId', isEqualTo: currentProfile.uid)
          .get();

      int privateCount = 0;
      int publicCount = 0;

      for (final doc in templatesSnapshot.docs) {
        final data = doc.data();
        if (data['isPublic'] as bool? ?? false) {
          publicCount++;
        } else {
          privateCount++;
        }
      }

      final updatedQuota = TemplateQuota(
        maxPrivateTemplates: currentProfile.templateQuota.maxPrivateTemplates,
        maxPublicTemplates: currentProfile.templateQuota.maxPublicTemplates,
        usedPrivateTemplates: privateCount,
        usedPublicTemplates: publicCount,
      );

      final updatedProfile = currentProfile.copyWith(templateQuota: updatedQuota);

      await _firestore.collection('users').doc(currentProfile.uid).update({
        'templateQuota': updatedQuota.toJson(),
      });

      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Provider for user profile notifier (for mutations)
final userProfileNotifierProvider =
    NotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>(UserProfileNotifier.new);

/// ============================================================================
/// HELPER PROVIDERS (commonly used derived state)
/// ============================================================================

/// Check if user is premium
/// Replaces: isPremiumUserProvider, isCachedPremiumUserProvider, unifiedIsPremiumProvider
/// 🔧 PERF FIX: Use .select() to only rebuild when accountTier changes
final isPremiumUserProvider = Provider<bool>((ref) {
  final accountTier = ref.watch(
    userProfileProvider.select((asyncValue) => asyncValue.valueOrNull?.accountTier),
  );

  return accountTier == AccountTier.premium || accountTier == AccountTier.pro;
});

/// Get user's display name
/// Replaces: cachedUserDisplayNameProvider, unifiedDisplayNameProvider, currentUserDisplayNameProvider
/// 🔧 PERF FIX: Use .select() to only rebuild when displayName changes
final userDisplayNameProvider = Provider<String>((ref) {
  final displayName = ref.watch(
    userProfileProvider.select((asyncValue) => asyncValue.valueOrNull?.displayName),
  );

  return displayName ?? 'GymBro User';
});

/// Get user's account tier
/// Replaces: currentAccountTierProvider, unifiedAccountTierProvider
/// 🔧 PERF FIX: Use .select() to only rebuild when accountTier changes
final accountTierProvider = Provider<AccountTier>((ref) {
  final accountTier = ref.watch(
    userProfileProvider.select((asyncValue) => asyncValue.valueOrNull?.accountTier),
  );

  return accountTier ?? AccountTier.free;
});

/// Get template quota
/// Replaces: templateQuotaProvider
/// 🔧 PERF FIX: Use .select() to only rebuild when templateQuota changes
final templateQuotaProvider = Provider<TemplateQuota>((ref) {
  final templateQuota = ref.watch(
    userProfileProvider.select((asyncValue) => asyncValue.valueOrNull?.templateQuota),
  );

  return templateQuota ?? TemplateQuota.forTier(AccountTier.free);
});

/// Check if user can save a template
/// Replaces: canSaveTemplateProvider
/// 🔧 PERF FIX: Use .select() to only rebuild when templateQuota changes
final canSaveTemplateProvider = Provider.family<bool, bool>((ref, isPublic) {
  final templateQuota = ref.watch(
    userProfileNotifierProvider.select((asyncValue) => asyncValue.valueOrNull?.templateQuota),
  );

  if (templateQuota == null) return false;
  return isPublic ? templateQuota.canSavePublic : templateQuota.canSavePrivate;
});

/// Get remaining template quota
/// Replaces: remainingTemplateQuotaProvider
/// 🔧 PERF FIX: Use .select() to only rebuild when templateQuota changes
final remainingTemplateQuotaProvider = Provider.family<int, bool>((ref, isPublic) {
  final templateQuota = ref.watch(
    userProfileNotifierProvider.select((asyncValue) => asyncValue.valueOrNull?.templateQuota),
  );

  if (templateQuota == null) return 0;
  return isPublic ? templateQuota.remainingPublic : templateQuota.remainingPrivate;
});

/// ============================================================================
/// BACKWARD COMPATIBILITY ALIASES (for gradual migration)
/// ============================================================================

/// Alias for unified provider compatibility
final unifiedUserProfileProvider = userProfileProvider;
final unifiedUserProvider = userProfileProvider;
final unifiedFirebaseUserProvider = currentUserProvider;
final unifiedUserIdProvider = currentUserIdProvider;
final unifiedIsAuthenticatedProvider = isAuthenticatedProvider;
final unifiedIsPremiumProvider = isPremiumUserProvider;
final unifiedDisplayNameProvider = userDisplayNameProvider;
final unifiedAccountTierProvider = accountTierProvider;

/// Alias for cached provider compatibility
final cachedUserProfileProvider = userProfileProvider;
final isCachedPremiumUserProvider = isPremiumUserProvider;
final cachedUserDisplayNameProvider = userDisplayNameProvider;

/// Alias for v2 provider compatibility
final userStateProvider = userProfileProvider; // Returns UserProfile? (compatible)
final currentUserStateProvider = userProfileProvider;
final currentUserProfileProvider = userProfileProvider;

/// ============================================================================
/// MIGRATION HELPER EXTENSIONS
/// ============================================================================

/// Extension to help migrate existing code gradually
extension ConsolidatedUserProviderMigration on WidgetRef {
  /// Drop-in replacement for ref.watch(currentUserProvider)
  AsyncValue<User?> get watchCurrentUser {
    return watch(currentUserProvider);
  }

  /// Drop-in replacement for ref.watch(userProfileProvider)
  AsyncValue<UserProfile?> get watchUserProfile {
    return watch(userProfileProvider);
  }

  /// Quick access to profile without AsyncValue
  UserProfile? get userProfile {
    return watch(userProfileProvider).value;
  }

  /// Quick check if premium
  bool get isPremiumUser {
    return watch(isPremiumUserProvider);
  }

  /// Quick get user ID
  String? get userId {
    return watch(currentUserIdProvider);
  }

  /// Quick get display name
  String get displayName {
    return watch(userDisplayNameProvider);
  }
}

/// ============================================================================
/// USAGE EXAMPLES
/// ============================================================================

/// Example 1: Watch user profile in widget
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final userProfile = ref.watch(userProfileProvider);
///
///     return userProfile.when(
///       data: (profile) => Text(profile?.displayName ?? 'Guest'),
///       loading: () => LoadingIndicator(),
///       error: (e, s) => Text('Error: $e'),
///     );
///   }
/// }
/// ```

/// Example 2: Check premium status
/// ```dart
/// final isPremium = ref.watch(isPremiumUserProvider);
/// if (isPremium) {
///   // Show premium features
/// }
/// ```

/// Example 3: Increment template quota
/// ```dart
/// await ref.read(userProfileNotifierProvider.notifier)
///     .incrementTemplateCount(isPublic: false);
/// ```

/// Example 4: Quick access with extensions
/// ```dart
/// final profile = ref.userProfile; // Quick access
/// if (ref.isPremiumUser) { ... }
/// final name = ref.displayName;
/// ```
