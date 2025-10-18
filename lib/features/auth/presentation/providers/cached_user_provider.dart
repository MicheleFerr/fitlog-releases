/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: auth
/// 🔧 Type: provider
/// 🌍 Localization: N/A - Provider class
/// 🎨 Theme: N/A - Provider class
/// 📱 Platform: Universal
///
/// CACHED USER PROVIDER - Optimized version with in-memory caching
/// Reduces Firebase reads by caching user profile data
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

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

/// OPTIMIZED User Profile Provider with caching
/// Reduces Firebase reads by caching profile data for 5 minutes
final cachedUserProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final firestore = FirebaseFirestore.instance;
  final cache = ref.watch(userProfileCacheProvider);

  // Watch Firebase auth state
  await for (final firebaseUser in FirebaseAuth.instance.authStateChanges()) {
    if (firebaseUser == null) {
      // User logged out, clear cache
      cache.clearAll();
      yield null;
    } else {
      // Check cache first
      final cachedProfile = cache.get(firebaseUser.uid);
      if (cachedProfile != null) {
        // Return cached profile immediately
        yield cachedProfile;

        // Still listen for updates in background (non-blocking)
        _listenForUpdates(firebaseUser.uid, firestore, cache);
        continue;
      }

      try {
        // No cache, fetch from Firestore
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

          // Create profile and cache it
          final profile = UserProfile.fromJson(data);
          cache.set(firebaseUser.uid, profile);
          yield profile;
        } else {
          // Use existing UserProfile.fromFirestore method
          final profile = UserProfile.fromFirestore(snapshot);
          cache.set(firebaseUser.uid, profile);
          yield profile;
        }

        // Listen for real-time updates
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

        // Cache even the fallback to avoid repeated errors
        cache.set(firebaseUser.uid, fallbackProfile);
        yield fallbackProfile;
      }
    }
  }
});

/// Helper function to listen for updates in background
void _listenForUpdates(String uid, FirebaseFirestore firestore, UserProfileCache cache) {
  // This runs in background and updates cache when changes occur
  firestore
      .collection('users')
      .doc(uid)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.exists) {
          final profile = UserProfile.fromFirestore(snapshot);
          cache.set(uid, profile);
        }
      });
}

/// Provider to check if user is premium (using cached data)
final isCachedPremiumUserProvider = Provider<bool>((ref) {
  final userProfile = ref.watch(cachedUserProfileProvider);

  return userProfile.when(
    data: (profile) => profile?.accountTier == AccountTier.premium ||
                       profile?.accountTier == AccountTier.pro,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to get user's display name (using cached data)
final cachedUserDisplayNameProvider = Provider<String>((ref) {
  final userProfile = ref.watch(cachedUserProfileProvider);

  return userProfile.when(
    data: (profile) => profile?.displayName ?? 'GymBro User',
    loading: () => 'Loading...',
    error: (_, __) => 'GymBro User',
  );
});