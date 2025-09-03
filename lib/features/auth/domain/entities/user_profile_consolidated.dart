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
 * CONSOLIDATED USER MODEL - Single source of truth for user data
 * This replaces both UserModel and old UserProfile
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Account tier levels
enum AccountTier {
  free,
  premium,
  pro,
}

/// Template quota information
class TemplateQuota {
  final int maxPrivateTemplates;
  final int maxPublicTemplates;
  final int usedPrivateTemplates;
  final int usedPublicTemplates;
  
  const TemplateQuota({
    required this.maxPrivateTemplates,
    required this.maxPublicTemplates,
    this.usedPrivateTemplates = 0,
    this.usedPublicTemplates = 0,
  });
  
  bool get canSavePrivate => usedPrivateTemplates < maxPrivateTemplates;
  bool get canSavePublic => usedPublicTemplates < maxPublicTemplates;
  int get remainingPrivate => maxPrivateTemplates - usedPrivateTemplates;
  int get remainingPublic => maxPublicTemplates - usedPublicTemplates;
  
  factory TemplateQuota.forTier(AccountTier tier, {
    int usedPrivate = 0,
    int usedPublic = 0,
  }) {
    switch (tier) {
      case AccountTier.free:
        return TemplateQuota(
          maxPrivateTemplates: 10,
          maxPublicTemplates: 2,
          usedPrivateTemplates: usedPrivate,
          usedPublicTemplates: usedPublic,
        );
      case AccountTier.premium:
        return TemplateQuota(
          maxPrivateTemplates: 50,
          maxPublicTemplates: 10,
          usedPrivateTemplates: usedPrivate,
          usedPublicTemplates: usedPublic,
        );
      case AccountTier.pro:
        return TemplateQuota(
          maxPrivateTemplates: 999,
          maxPublicTemplates: 999,
          usedPrivateTemplates: usedPrivate,
          usedPublicTemplates: usedPublic,
        );
    }
  }
  
  Map<String, dynamic> toJson() => {
    'maxPrivateTemplates': maxPrivateTemplates,
    'maxPublicTemplates': maxPublicTemplates,
    'usedPrivateTemplates': usedPrivateTemplates,
    'usedPublicTemplates': usedPublicTemplates,
  };
  
  factory TemplateQuota.fromJson(Map<String, dynamic> json) {
    return TemplateQuota(
      maxPrivateTemplates: json['maxPrivateTemplates'] ?? 10,
      maxPublicTemplates: json['maxPublicTemplates'] ?? 2,
      usedPrivateTemplates: json['usedPrivateTemplates'] ?? 0,
      usedPublicTemplates: json['usedPublicTemplates'] ?? 0,
    );
  }
}

/// User preferences
class UserPreferences {
  final String? language;
  final String? theme;
  final bool? notificationsEnabled;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    this.language,
    this.theme,
    this.notificationsEnabled,
    this.customSettings = const {},
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      language: map['language'] as String?,
      theme: map['theme'] as String?,
      notificationsEnabled: map['notificationsEnabled'] as bool?,
      customSettings: Map<String, dynamic>.from(
        map['customSettings'] ?? const {},
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'language': language,
    'theme': theme,
    'notificationsEnabled': notificationsEnabled,
    'customSettings': customSettings,
  };
}

/// User statistics
class UserStats {
  final int totalWorkouts;
  final int currentStreak;
  final int longestStreak;
  final double totalVolume;
  final int totalExercises;
  final Map<String, dynamic> achievements;

  const UserStats({
    this.totalWorkouts = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalVolume = 0.0,
    this.totalExercises = 0,
    this.achievements = const {},
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalWorkouts: map['totalWorkouts'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      totalVolume: (map['totalVolume'] as num?)?.toDouble() ?? 0.0,
      totalExercises: map['totalExercises'] as int? ?? 0,
      achievements: Map<String, dynamic>.from(
        map['achievements'] ?? const {},
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'totalWorkouts': totalWorkouts,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalVolume': totalVolume,
    'totalExercises': totalExercises,
    'achievements': achievements,
  };
}

/// CONSOLIDATED USER PROFILE - Single source of truth
/// This is the ONLY user model to use throughout the app
class UserProfile {
  // Core identification
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  
  // Account metadata
  final AccountTier accountTier;
  final TemplateQuota templateQuota;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isGuest;
  
  // User data
  final UserPreferences preferences;
  final UserStats stats;
  
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.accountTier = AccountTier.free,
    required this.templateQuota,
    required this.createdAt,
    required this.lastLoginAt,
    this.isGuest = false,
    required this.preferences,
    required this.stats,
  });
  
  /// Create from Firebase Auth User (for initial creation)
  factory UserProfile.fromFirebaseUser(firebase_auth.User user) {
    final tier = AccountTier.free;
    return UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'GymBro User',
      photoURL: user.photoURL,
      accountTier: tier,
      templateQuota: TemplateQuota.forTier(tier),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isGuest: user.isAnonymous,
      preferences: const UserPreferences(),
      stats: const UserStats(),
    );
  }
  
  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null for user: ${doc.id}');
    }
    
    // Parse account tier with backwards compatibility
    AccountTier tier;
    if (data['accountTier'] != null) {
      final tierString = data['accountTier'] as String;
      tier = AccountTier.values.firstWhere(
        (t) => t.name == tierString,
        orElse: () => AccountTier.free,
      );
    } else if (data['isPremium'] == true) {
      // Backwards compatibility: migrate old isPremium boolean
      tier = AccountTier.premium;
    } else {
      tier = AccountTier.free;
    }
    
    // Parse template quota
    TemplateQuota quota;
    if (data['templateQuota'] != null) {
      quota = TemplateQuota.fromJson(data['templateQuota']);
    } else {
      // Calculate for backward compatibility
      final usedPrivate = data['stats']?['privateTemplateCount'] ?? 0;
      final usedPublic = data['stats']?['publicTemplateCount'] ?? 0;
      quota = TemplateQuota.forTier(tier, 
        usedPrivate: usedPrivate,
        usedPublic: usedPublic,
      );
    }
    
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'GymBro User',
      photoURL: data['photoURL'],
      accountTier: tier,
      templateQuota: quota,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGuest: data['isGuest'] ?? false,
      preferences: UserPreferences.fromMap(
        data['preferences'] ?? {},
      ),
      stats: UserStats.fromMap(
        data['stats'] ?? {},
      ),
    );
  }
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'accountTier': accountTier.name,
      'templateQuota': templateQuota.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isGuest': isGuest,
      'preferences': preferences.toMap(),
      'stats': stats.toMap(),
    };
  }
  
  /// Helper getters
  bool get isPremium => accountTier == AccountTier.premium || accountTier == AccountTier.pro;
  bool get isPro => accountTier == AccountTier.pro;
  bool get isFree => accountTier == AccountTier.free;
  
  /// Copy with updated values
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    AccountTier? accountTier,
    TemplateQuota? templateQuota,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isGuest,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      accountTier: accountTier ?? this.accountTier,
      templateQuota: templateQuota ?? this.templateQuota,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isGuest: isGuest ?? this.isGuest,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
  
  /// Increment template usage
  UserProfile incrementTemplateUsage({required bool isPublic}) {
    final updatedQuota = TemplateQuota(
      maxPrivateTemplates: templateQuota.maxPrivateTemplates,
      maxPublicTemplates: templateQuota.maxPublicTemplates,
      usedPrivateTemplates: isPublic 
          ? templateQuota.usedPrivateTemplates 
          : templateQuota.usedPrivateTemplates + 1,
      usedPublicTemplates: isPublic 
          ? templateQuota.usedPublicTemplates + 1 
          : templateQuota.usedPublicTemplates,
    );
    
    return copyWith(templateQuota: updatedQuota);
  }
  
  /// Decrement template usage
  UserProfile decrementTemplateUsage({required bool isPublic}) {
    final updatedQuota = TemplateQuota(
      maxPrivateTemplates: templateQuota.maxPrivateTemplates,
      maxPublicTemplates: templateQuota.maxPublicTemplates,
      usedPrivateTemplates: isPublic 
          ? templateQuota.usedPrivateTemplates 
          : (templateQuota.usedPrivateTemplates - 1).clamp(0, 999),
      usedPublicTemplates: isPublic 
          ? (templateQuota.usedPublicTemplates - 1).clamp(0, 999)
          : templateQuota.usedPublicTemplates,
    );
    
    return copyWith(templateQuota: updatedQuota);
  }
  
  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, '
           'tier: ${accountTier.name}, isPremium: $isPremium)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }
  
  @override
  int get hashCode => uid.hashCode;
}