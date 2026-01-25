/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: auth
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';

/// Account tier levels (subscription-based)
enum AccountTier {
  free,
  premium,
  pro,
}

/// Template quota information
class TemplateQuota {

  const TemplateQuota({
    required this.maxPrivateTemplates,
    required this.maxPublicTemplates,
    this.usedPrivateTemplates = 0,
    this.usedPublicTemplates = 0,
  });

  /// Get quota based on XP tier (primary source of truth)
  factory TemplateQuota.forUserTier(UserTier tier, {
    int usedPrivate = 0,
    int usedPublic = 0,
  }) {
    return TemplateQuota(
      maxPrivateTemplates: tier.maxTemplates,
      maxPublicTemplates: tier.maxPublicTemplates,
      usedPrivateTemplates: usedPrivate,
      usedPublicTemplates: usedPublic,
    );
  }

  /// Get quota based on account tier (for premium subscribers)
  /// Premium/Pro subscribers get bonus slots on top of their XP tier
  factory TemplateQuota.forTier(AccountTier tier, {
    int usedPrivate = 0,
    int usedPublic = 0,
  }) {
    switch (tier) {
      case AccountTier.free:
        return TemplateQuota(
          maxPrivateTemplates: 4,
          maxPublicTemplates: 2,
          usedPrivateTemplates: usedPrivate,
          usedPublicTemplates: usedPublic,
        );
      case AccountTier.premium:
        return TemplateQuota(
          maxPrivateTemplates: 999, // Unlimited for premium
          maxPublicTemplates: 999,  // Unlimited for premium
          usedPrivateTemplates: usedPrivate,
          usedPublicTemplates: usedPublic,
        );
      case AccountTier.pro:
        return TemplateQuota(
          maxPrivateTemplates: 999, // Virtually unlimited
          maxPublicTemplates: 50,
          usedPrivateTemplates: usedPrivate,
          usedPublicTemplates: usedPublic,
        );
    }
  }

  /// Get consolidated quota taking max of XP tier and account tier
  /// This ensures paying users always get at least what their subscription provides,
  /// while XP progression can give additional slots
  factory TemplateQuota.consolidated({
    required UserTier userTier,
    required AccountTier accountTier,
    int usedPrivate = 0,
    int usedPublic = 0,
  }) {
    final xpQuota = TemplateQuota.forUserTier(userTier);
    final accountQuota = TemplateQuota.forTier(accountTier);

    return TemplateQuota(
      maxPrivateTemplates: xpQuota.maxPrivateTemplates > accountQuota.maxPrivateTemplates
          ? xpQuota.maxPrivateTemplates
          : accountQuota.maxPrivateTemplates,
      maxPublicTemplates: xpQuota.maxPublicTemplates > accountQuota.maxPublicTemplates
          ? xpQuota.maxPublicTemplates
          : accountQuota.maxPublicTemplates,
      usedPrivateTemplates: usedPrivate,
      usedPublicTemplates: usedPublic,
    );
  }
  
  factory TemplateQuota.fromJson(Map<String, dynamic> json) {
    return TemplateQuota(
      maxPrivateTemplates: json['maxPrivateTemplates'] ?? 4,
      maxPublicTemplates: json['maxPublicTemplates'] ?? 2,
      usedPrivateTemplates: json['usedPrivateTemplates'] ?? 0,
      usedPublicTemplates: json['usedPublicTemplates'] ?? 0,
    );
  }
  final int maxPrivateTemplates;
  final int maxPublicTemplates;
  final int usedPrivateTemplates;
  final int usedPublicTemplates;
  
  /// Check if user can save a new private template
  bool get canSavePrivate => usedPrivateTemplates < maxPrivateTemplates;
  
  /// Check if user can save a new public template
  bool get canSavePublic => usedPublicTemplates < maxPublicTemplates;
  
  /// Get remaining private templates
  int get remainingPrivate => maxPrivateTemplates - usedPrivateTemplates;
  
  /// Get remaining public templates  
  int get remainingPublic => maxPublicTemplates - usedPublicTemplates;
  
  Map<String, dynamic> toJson() => {
    'maxPrivateTemplates': maxPrivateTemplates,
    'maxPublicTemplates': maxPublicTemplates,
    'usedPrivateTemplates': usedPrivateTemplates,
    'usedPublicTemplates': usedPublicTemplates,
  };
}

/// User profile entity with tier and quota information
class UserProfile {
  
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.accountTier = AccountTier.free,
    required this.templateQuota,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
    this.stats = const {},
    this.isGuest = false,
    this.isAdmin = false,
  });
  
  /// Create from JSON data (for caching)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse account tier
    final tierString = json['accountTier'] as String? ?? 'free';
    final tier = AccountTier.values.firstWhere(
      (t) => t.name == tierString,
      orElse: () => AccountTier.free,
    );
    
    // Parse template quota
    TemplateQuota quota;
    if (json['templateQuota'] != null) {
      quota = TemplateQuota.fromJson(json['templateQuota']);
    } else {
      // Calculate used templates for backward compatibility
      final usedPrivate = json['stats']?['privateTemplateCount'] ?? 0;
      final usedPublic = json['stats']?['publicTemplateCount'] ?? 0;
      quota = TemplateQuota.forTier(tier, 
        usedPrivate: usedPrivate,
        usedPublic: usedPublic,
      );
    }
    
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'GymBro User',
      photoURL: json['photoURL'],
      accountTier: tier,
      templateQuota: quota,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      isGuest: json['isGuest'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  /// Create from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse account tier
    final tierString = data['accountTier'] as String? ?? 'free';
    final tier = AccountTier.values.firstWhere(
      (t) => t.name == tierString,
      orElse: () => AccountTier.free,
    );
    
    // Parse template quota
    TemplateQuota quota;
    if (data['templateQuota'] != null) {
      quota = TemplateQuota.fromJson(data['templateQuota']);
    } else {
      // Calculate used templates for backward compatibility
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
      preferences: data['preferences'] ?? {},
      stats: data['stats'] ?? {},
      isGuest: data['isGuest'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
    );
  }
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final AccountTier accountTier;
  final TemplateQuota templateQuota;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> stats;
  final bool isGuest;
  final bool isAdmin;
  
  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'accountTier': accountTier.name,
      'templateQuota': templateQuota.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'preferences': preferences,
      'stats': stats,
      'isGuest': isGuest,
      'isAdmin': isAdmin,
    };
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
      'preferences': preferences,
      'stats': stats,
      'isGuest': isGuest,
      'isAdmin': isAdmin,
    };
  }
  
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
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? stats,
    bool? isGuest,
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
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      isGuest: isGuest ?? this.isGuest,
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

  /// Check if user has premium account
  bool get isPremium => accountTier == AccountTier.premium || accountTier == AccountTier.pro;

  /// Get day cutoff hour for workout tracking (default: 4 = 04:00)
  /// Used to determine when "today" starts for workout completion
  /// Example: cutoffHour = 4 → workouts before 04:00 count as "yesterday"
  int get dayCutoffHour => preferences['dayCutoffHour'] as int? ?? 4;

  /// Update day cutoff hour preference
  /// [cutoffHour] must be in range 0-23 (hour of day)
  UserProfile updateDayCutoffHour(int cutoffHour) {
    assert(cutoffHour >= 0 && cutoffHour <= 23, 'Cutoff hour must be 0-23');

    final updatedPreferences = Map<String, dynamic>.from(preferences);
    updatedPreferences['dayCutoffHour'] = cutoffHour;

    return copyWith(preferences: updatedPreferences);
  }
}