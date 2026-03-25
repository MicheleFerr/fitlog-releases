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
enum AccountTier { free, premium }

/// Template quota information
class TemplateQuota {
  const TemplateQuota({
    required this.maxLibraryTemplates,
    this.usedLibraryTemplates = 0,
    this.distributedTemplateCount = 0,
    this.maxDistributionTemplates = 999,
  });

  /// Get quota based on XP tier (primary source of truth)
  factory TemplateQuota.forUserTier(
    UserTier tier, {
    int usedLibrary = 0,
    int distributedCount = 0,
  }) {
    return TemplateQuota(
      maxLibraryTemplates: tier.maxTemplates,
      usedLibraryTemplates: usedLibrary,
      distributedTemplateCount: distributedCount,
    );
  }

  /// Get quota based on account tier (for premium subscribers)
  /// Premium/Pro subscribers get bonus slots on top of their XP tier
  factory TemplateQuota.forTier(
    AccountTier tier, {
    int usedLibrary = 0,
    int distributedCount = 0,
  }) {
    switch (tier) {
      case AccountTier.free:
        return TemplateQuota(
          maxLibraryTemplates: 4,
          usedLibraryTemplates: usedLibrary,
          distributedTemplateCount: distributedCount,
        );
      case AccountTier.premium:
        return TemplateQuota(
          maxLibraryTemplates: 999, // Unlimited for premium
          usedLibraryTemplates: usedLibrary,
          distributedTemplateCount: distributedCount,
        );
    }
  }

  /// Get consolidated quota taking max of XP tier and account tier
  /// This ensures paying users always get at least what their subscription provides,
  /// while XP progression can give additional slots
  factory TemplateQuota.consolidated({
    required UserTier userTier,
    required AccountTier accountTier,
    int usedLibrary = 0,
    int distributedCount = 0,
  }) {
    final xpQuota = TemplateQuota.forUserTier(userTier);
    final accountQuota = TemplateQuota.forTier(accountTier);

    return TemplateQuota(
      maxLibraryTemplates:
          xpQuota.maxLibraryTemplates > accountQuota.maxLibraryTemplates
          ? xpQuota.maxLibraryTemplates
          : accountQuota.maxLibraryTemplates,
      usedLibraryTemplates: usedLibrary,
      distributedTemplateCount: distributedCount,
    );
  }

  factory TemplateQuota.fromJson(Map<String, dynamic> json) {
    final usedLibrary =
        json['usedLibraryTemplates'] ??
        json['libraryEditableCount'] ??
        json['usedPrivateTemplates'] ??
        0;
    final distributedCount =
        json['distributedTemplateCount'] ??
        json['usedPublicTemplates'] ??
        json['usedSharedTemplates'] ??
        0;

    return TemplateQuota(
      maxLibraryTemplates:
          json['maxLibraryTemplates'] ?? json['maxPrivateTemplates'] ?? 4,
      usedLibraryTemplates: usedLibrary,
      distributedTemplateCount: distributedCount,
      maxDistributionTemplates:
          json['maxPublicTemplates'] ?? json['maxSharedTemplates'] ?? 999,
    );
  }
  final int maxLibraryTemplates;
  final int usedLibraryTemplates;
  final int distributedTemplateCount;
  final int maxDistributionTemplates;

  /// Primary store-first API.
  bool get canSaveToLibrary => usedLibraryTemplates < maxLibraryTemplates;

  int get remainingLibrary => maxLibraryTemplates - usedLibraryTemplates;

  /// Legacy aliases kept for compatibility in older parts of the app.
  int get maxPrivateTemplates => maxLibraryTemplates;

  int get maxPublicTemplates => maxDistributionTemplates;

  int get usedPrivateTemplates => usedLibraryTemplates;

  int get usedPublicTemplates => distributedTemplateCount;

  bool get canSavePrivate => canSaveToLibrary;

  bool get canSavePublic => true;

  int get remainingPrivate => remainingLibrary;

  int get remainingPublic =>
      (maxDistributionTemplates - distributedTemplateCount).clamp(
        0,
        maxDistributionTemplates,
      );

  Map<String, dynamic> toJson() => {
    'maxLibraryTemplates': maxLibraryTemplates,
    'usedLibraryTemplates': usedLibraryTemplates,
    'libraryEditableCount': usedLibraryTemplates,
    'maxPrivateTemplates': maxPrivateTemplates,
    'maxPublicTemplates': maxPublicTemplates,
    'usedPrivateTemplates': usedPrivateTemplates,
    'usedPublicTemplates': usedPublicTemplates,
    'maxSharedTemplates': maxDistributionTemplates,
    'usedSharedTemplates': distributedTemplateCount,
    'distributedTemplateCount': distributedTemplateCount,
    'distributionMetered': false,
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
    this.debugTierOverride,
    this.debugAccountOverride,
    this.debugXPOverride,
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
      quota = TemplateQuota.forTier(
        tier,
        usedLibrary: usedPrivate,
        distributedCount: usedPublic,
      );
    }

    // Parse debug overrides (admin only)
    UserTier? debugTier;
    if (json['debugTierOverride'] != null) {
      final tierName = json['debugTierOverride'] as String;
      debugTier = UserTier.values.firstWhere(
        (t) => t.name == tierName,
        orElse: () => UserTier.starter,
      );
    }

    AccountTier? debugAccount;
    if (json['debugAccountOverride'] != null) {
      final accountName = json['debugAccountOverride'] as String;
      debugAccount = AccountTier.values.firstWhere(
        (a) => a.name == accountName,
        orElse: () => AccountTier.free,
      );
    }

    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'GymBro User',
      photoURL: json['photoURL'],
      accountTier: tier,
      templateQuota: quota,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: DateTime.parse(
        json['lastLoginAt'] ?? DateTime.now().toIso8601String(),
      ),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      isGuest: json['isGuest'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      debugTierOverride: debugTier,
      debugAccountOverride: debugAccount,
      debugXPOverride: json['debugXPOverride'] as int?,
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
      quota = TemplateQuota.forTier(
        tier,
        usedLibrary: usedPrivate,
        distributedCount: usedPublic,
      );
    }

    // Parse debug overrides (admin only)
    UserTier? debugTier;
    if (data['debugTierOverride'] != null) {
      final tierName = data['debugTierOverride'] as String;
      debugTier = UserTier.values.firstWhere(
        (t) => t.name == tierName,
        orElse: () => UserTier.starter,
      );
    }

    AccountTier? debugAccount;
    if (data['debugAccountOverride'] != null) {
      final accountName = data['debugAccountOverride'] as String;
      debugAccount = AccountTier.values.firstWhere(
        (a) => a.name == accountName,
        orElse: () => AccountTier.free,
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
      lastLoginAt:
          (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: data['preferences'] ?? {},
      stats: data['stats'] ?? {},
      isGuest: data['isGuest'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
      debugTierOverride: debugTier,
      debugAccountOverride: debugAccount,
      debugXPOverride: data['debugXPOverride'] as int?,
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

  /// Debug overrides (admin only, for testing tier limits)
  final UserTier? debugTierOverride;
  final AccountTier? debugAccountOverride;
  final int? debugXPOverride;

  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    final json = {
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

    // Add debug overrides if present
    if (debugTierOverride != null) {
      json['debugTierOverride'] = debugTierOverride!.name;
    }
    if (debugAccountOverride != null) {
      json['debugAccountOverride'] = debugAccountOverride!.name;
    }
    if (debugXPOverride != null) {
      json['debugXPOverride'] = debugXPOverride;
    }

    return json;
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final data = {
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

    // Add debug overrides if present
    if (debugTierOverride != null) {
      data['debugTierOverride'] = debugTierOverride!.name;
    }
    if (debugAccountOverride != null) {
      data['debugAccountOverride'] = debugAccountOverride!.name;
    }
    if (debugXPOverride != null) {
      data['debugXPOverride'] = debugXPOverride;
    }

    return data;
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
    bool? isAdmin,
    UserTier? debugTierOverride,
    AccountTier? debugAccountOverride,
    int? debugXPOverride,
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
      isAdmin: isAdmin ?? this.isAdmin,
      debugTierOverride: debugTierOverride ?? this.debugTierOverride,
      debugAccountOverride: debugAccountOverride ?? this.debugAccountOverride,
      debugXPOverride: debugXPOverride ?? this.debugXPOverride,
    );
  }

  /// Increment template usage
  UserProfile incrementTemplateUsage({required bool isPublic}) {
    final updatedQuota = TemplateQuota(
      maxLibraryTemplates: templateQuota.maxLibraryTemplates,
      usedLibraryTemplates: isPublic
          ? templateQuota.usedLibraryTemplates
          : templateQuota.usedLibraryTemplates + 1,
      distributedTemplateCount: isPublic
          ? templateQuota.distributedTemplateCount + 1
          : templateQuota.distributedTemplateCount,
      maxDistributionTemplates: templateQuota.maxDistributionTemplates,
    );

    return copyWith(templateQuota: updatedQuota);
  }

  /// Decrement template usage
  UserProfile decrementTemplateUsage({required bool isPublic}) {
    final updatedQuota = TemplateQuota(
      maxLibraryTemplates: templateQuota.maxLibraryTemplates,
      usedLibraryTemplates: isPublic
          ? templateQuota.usedLibraryTemplates
          : (templateQuota.usedLibraryTemplates - 1).clamp(0, 999),
      distributedTemplateCount: isPublic
          ? (templateQuota.distributedTemplateCount - 1).clamp(0, 999)
          : templateQuota.distributedTemplateCount,
      maxDistributionTemplates: templateQuota.maxDistributionTemplates,
    );

    return copyWith(templateQuota: updatedQuota);
  }

  /// Check if user has premium account
  bool get isPremium => accountTier != AccountTier.free;

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
