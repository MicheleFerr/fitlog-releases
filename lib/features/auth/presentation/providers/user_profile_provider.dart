/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: auth
/// 🔧 Type: provider
/// 🌍 Localization: N/A - Provider logic
/// 🎨 Theme: N/A - Provider logic
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: StateNotifierProvider
/// - Firebase: Auth/Firestore
/// - Hive: None
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// Stream provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for user profile from Firestore
final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final userStream = ref.watch(currentUserProvider.stream);

  await for (final user in userStream) {
    if (user == null) {
      yield null;
    } else {
      // Stream user profile changes from Firestore
      yield* FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return UserProfile.fromFirestore(doc);
          });
    }
  }
});

/// State notifier for managing user profile updates
/// Now uses the existing userProfileProvider stream instead of duplicate fetch
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }
  final Ref _ref;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _init() {
    // Listen to the existing userProfileProvider stream instead of duplicate fetch
    _ref.listen(userProfileProvider, (previous, next) {
      state = next;
    });
  }
  
  Future<void> _createDefaultProfile(String uid) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final profile = UserProfile(
      uid: uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'GymBro User',
      photoURL: user.photoURL,
      accountTier: AccountTier.free,
      templateQuota: TemplateQuota.forTier(AccountTier.free),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    await _firestore.collection('users').doc(uid).set(
      profile.toFirestore(),
      SetOptions(merge: true),
    );
    
    state = AsyncValue.data(profile);
  }
  
  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    try {
      await _firestore.collection('users').doc(currentProfile.uid).update(updates);
      // No need to manually refresh - userProfileProvider stream will auto-update
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
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;
    
    // Calculate new quota based on tier
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
      
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// Sync template count from actual templates in database
  Future<void> syncTemplateCount() async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;
    
    try {
      // Count actual templates in database
      final templatesSnapshot = await _firestore
          .collection('workoutTemplates')
          .where('userId', isEqualTo: currentProfile.uid)
          .get();
      
      int privateCount = 0;
      int publicCount = 0;
      
      for (final doc in templatesSnapshot.docs) {
        final data = doc.data();
        // Safe field access with null check (Task 6.1)
        if (data['isPublic'] as bool? ?? false) {
          publicCount++;
        } else {
          privateCount++;
        }
      }
      
      // Update quota with actual counts
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

/// Provider for user profile notifier
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier(ref);
});

/// Convenient provider for checking template quota
final canSaveTemplateProvider = Provider.family<bool, bool>((ref, isPublic) {
  final profileAsync = ref.watch(userProfileNotifierProvider);
  
  return profileAsync.when(
    data: (profile) {
      if (profile == null) return false;
      return isPublic 
          ? profile.templateQuota.canSavePublic
          : profile.templateQuota.canSavePrivate;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for remaining template quota
final remainingTemplateQuotaProvider = Provider.family<int, bool>((ref, isPublic) {
  final profileAsync = ref.watch(userProfileNotifierProvider);
  
  return profileAsync.when(
    data: (profile) {
      if (profile == null) return 0;
      return isPublic 
          ? profile.templateQuota.remainingPublic
          : profile.templateQuota.remainingPrivate;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});