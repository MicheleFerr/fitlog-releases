/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: domain
 * 🎯 Feature: buddy_matching
 * 🔧 Type: entity
 * 🌍 Localization: N/A - Entity class
 * 🎨 Theme: N/A - Entity class
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: None
 * - Firebase: None  
 * - Hive: None
 */

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'buddy_preferences.dart';

part 'buddy_profile.freezed.dart';
part 'buddy_profile.g.dart';

/// Badge types for buddy profiles
enum BadgeType {
  workoutBuddy,
  consistentPartner,
  motivator,
  newbie,
  veteran,
  verified,
  instagramVerified,
  superLiker,
  earlyAdopter;

  /// Tier-1 badges that require special verification
  bool get isTier1Badge {
    switch (this) {
      case BadgeType.verified:
      case BadgeType.instagramVerified:
      case BadgeType.superLiker:
      case BadgeType.earlyAdopter:
        return true;
      default:
        return false;
    }
  }

  String get displayName {
    switch (this) {
      case BadgeType.workoutBuddy:
        return 'Workout Buddy';
      case BadgeType.consistentPartner:
        return 'Partner Affidabile';
      case BadgeType.motivator:
        return 'Motivatore';
      case BadgeType.newbie:
        return 'Nuovo Arrivato';
      case BadgeType.veteran:
        return 'Veterano';
      case BadgeType.verified:
        return 'Verificato';
      case BadgeType.instagramVerified:
        return 'Instagram Verificato';
      case BadgeType.superLiker:
        return 'Super Liker';
      case BadgeType.earlyAdopter:
        return 'Early Adopter';
    }
  }

  String get description {
    switch (this) {
      case BadgeType.workoutBuddy:
        return 'Ha una partnership attiva';
      case BadgeType.consistentPartner:
        return 'Partner affidabile per 30+ giorni';
      case BadgeType.motivator:
        return 'Aiuta sempre i suoi buddy';
      case BadgeType.newbie:
        return 'Nuovo nel matching';
      case BadgeType.veteran:
        return '6+ mesi di esperienza';
      case BadgeType.verified:
        return 'Profilo verificato';
      case BadgeType.instagramVerified:
        return 'Account Instagram collegato';
      case BadgeType.superLiker:
        return 'Usa spesso Super Like';
      case BadgeType.earlyAdopter:
        return 'Uno dei primi utenti';
    }
  }
}

@freezed
class BuddyProfile with _$BuddyProfile {
  const factory BuddyProfile({
    required String uid,
    required String displayName,
    String? photoURL,
    required BuddyPreferences preferences,
    @Default([]) List<BadgeType> badges,
    @Default(0) int partnershipsCount,
    @Default(0) int successfulPartnerships,
    @Default(0.0) double averageRating,
    @Default(0) int totalRatings,
    DateTime? lastSeen,
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    // Statistics
    @Default(0) int totalWorkouts,
    @Default(0.0) double totalVolume,
    String? currentPartnershipId,
    DateTime? partnershipStartDate,
    // Matching history
    @Default([]) List<String> likedProfiles,
    @Default([]) List<String> dislikedProfiles,
    @Default([]) List<String> mutualMatches,
    // Tier-1 features
    @Default(3) int superLikesRemaining,
    DateTime? lastSuperLikeReset,
    DateTime? boostExpiry,
    @Default(false) bool isBoosted,
    @Default(0) int reportCount,
    @Default(false) bool isBanned,
    @Default(false) bool isPhotoVerified,
    @Default([]) List<String> blockedUsers,
    @Default([]) List<String> reportedUsers,
    // Workout tracking
    @Default([]) List<String> workoutTogetherIds,
    @Default(0) int completedWorkoutsTogether,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BuddyProfile;

  factory BuddyProfile.fromJson(Map<String, dynamic> json) =>
      _$BuddyProfileFromJson(json);

  /// Create from Firestore document
  factory BuddyProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BuddyProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? 'GymBro User',
      photoURL: data['photoURL'] as String?,
      preferences: BuddyPreferences.fromFirestore(
        data['preferences'] ?? <String, dynamic>{}
      ),
      badges: (data['badges'] as List<dynamic>?)
          ?.map((badge) => BadgeType.values.firstWhere(
                (b) => b.name == badge,
                orElse: () => BadgeType.newbie,
              ))
          .toList() ?? [],
      partnershipsCount: data['partnershipsCount'] ?? 0,
      successfulPartnerships: data['successfulPartnerships'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalRatings: data['totalRatings'] ?? 0,
      lastSeen: data['lastSeen'] != null 
          ? (data['lastSeen'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      totalWorkouts: data['totalWorkouts'] ?? 0,
      totalVolume: (data['totalVolume'] ?? 0.0).toDouble(),
      currentPartnershipId: data['currentPartnershipId'] as String?,
      partnershipStartDate: data['partnershipStartDate'] != null
          ? (data['partnershipStartDate'] as Timestamp).toDate()
          : null,
      likedProfiles: (data['likedProfiles'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      dislikedProfiles: (data['dislikedProfiles'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      mutualMatches: (data['mutualMatches'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      superLikesRemaining: data['superLikesRemaining'] ?? 3,
      lastSuperLikeReset: data['lastSuperLikeReset'] != null
          ? (data['lastSuperLikeReset'] as Timestamp).toDate()
          : null,
      boostExpiry: data['boostExpiry'] != null
          ? (data['boostExpiry'] as Timestamp).toDate()
          : null,
      isBoosted: data['isBoosted'] ?? false,
      reportCount: data['reportCount'] ?? 0,
      isBanned: data['isBanned'] ?? false,
      isPhotoVerified: data['isPhotoVerified'] ?? false,
      blockedUsers: (data['blockedUsers'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      reportedUsers: (data['reportedUsers'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      workoutTogetherIds: (data['workoutTogetherIds'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      completedWorkoutsTogether: data['completedWorkoutsTogether'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

extension BuddyProfileX on BuddyProfile {
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoURL': photoURL,
      'preferences': preferences.toFirestore(),
      'badges': badges.map((badge) => badge.name).toList(),
      'partnershipsCount': partnershipsCount,
      'successfulPartnerships': successfulPartnerships,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'isActive': isActive,
      'isVerified': isVerified,
      'totalWorkouts': totalWorkouts,
      'totalVolume': totalVolume,
      'currentPartnershipId': currentPartnershipId,
      'partnershipStartDate': partnershipStartDate != null 
          ? Timestamp.fromDate(partnershipStartDate!) 
          : null,
      'likedProfiles': likedProfiles,
      'dislikedProfiles': dislikedProfiles,
      'mutualMatches': mutualMatches,
      'superLikesRemaining': superLikesRemaining,
      'lastSuperLikeReset': lastSuperLikeReset != null ? Timestamp.fromDate(lastSuperLikeReset!) : null,
      'boostExpiry': boostExpiry != null ? Timestamp.fromDate(boostExpiry!) : null,
      'isBoosted': isBoosted,
      'reportCount': reportCount,
      'isBanned': isBanned,
      'isPhotoVerified': isPhotoVerified,
      'blockedUsers': blockedUsers,
      'reportedUsers': reportedUsers,
      'workoutTogetherIds': workoutTogetherIds,
      'completedWorkoutsTogether': completedWorkoutsTogether,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Check if user is currently online (seen within 5 minutes)
  bool get isOnline {
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen!).inMinutes < 5;
  }

  /// Check if user was recently active (seen within 30 minutes)
  bool get isRecentlyActive {
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen!).inMinutes < 30;
  }

  /// Get online status string
  String get onlineStatus {
    if (isOnline) return 'Online';
    if (isRecentlyActive) return 'Attivo di recente';
    if (lastSeen == null) return 'Mai visto';
    
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inHours < 1) return '${diff.inMinutes}m fa';
    if (diff.inHours < 24) return '${diff.inHours}h fa';
    if (diff.inDays < 7) return '${diff.inDays}g fa';
    return 'Più di una settimana fa';
  }

  /// Check if user has active partnership
  bool get hasActivePartnership => currentPartnershipId != null;

  /// Get success rate as percentage
  double get successRate {
    if (partnershipsCount == 0) return 0.0;
    return (successfulPartnerships / partnershipsCount) * 100;
  }

  /// Check if user has specific badge
  bool hasBadge(BadgeType badge) => badges.contains(badge);

  /// Get distance to another profile (requires both to have location)
  double? distanceTo(BuddyProfile other) {
    if (!preferences.hasLocation || !other.preferences.hasLocation) {
      return null;
    }

    // Haversine formula for distance calculation
    const double earthRadius = 6371; // km

    final double lat1Rad = preferences.latitude! * (3.14159 / 180);
    final double lat2Rad = other.preferences.latitude! * (3.14159 / 180);
    final double deltaLatRad = (other.preferences.latitude! - preferences.latitude!) * (3.14159 / 180);
    final double deltaLngRad = (other.preferences.longitude! - preferences.longitude!) * (3.14159 / 180);

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Check if this profile can match with another profile
  bool canMatch(BuddyProfile other) {
    // Already liked/disliked
    if (likedProfiles.contains(other.uid) || dislikedProfiles.contains(other.uid)) {
      return false;
    }

    // Both must be looking for buddy
    if (!preferences.isLookingForBuddy || !other.preferences.isLookingForBuddy) {
      return false;
    }

    // Distance check
    final distance = distanceTo(other);
    if (distance != null && distance > preferences.maxDistance) {
      return false;
    }

    // Age check (basic implementation - would need birth date in full version)
    // For now, assume all users are within age range

    // Both must be active
    if (!isActive || !other.isActive) {
      return false;
    }

    return true;
  }

  /// Get compatibility score with another profile
  double getCompatibilityScore(BuddyProfile other) {
    if (!canMatch(other)) return 0.0;
    
    double score = preferences.getCompatibilityScore(other.preferences);
    
    // Bonus for verified users
    if (isVerified && other.isVerified) {
      score += 5.0;
    }

    // Bonus for high rating users
    if (averageRating >= 4.5 && other.averageRating >= 4.5) {
      score += 5.0;
    }

    // Bonus for experienced users
    if (partnershipsCount >= 3 && other.partnershipsCount >= 3) {
      score += 3.0;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Check if user can send super like
  bool get canSuperLike => superLikesRemaining > 0;

  /// Check if user is currently boosted
  bool get isCurrentlyBoosted {
    if (!isBoosted || boostExpiry == null) return false;
    return DateTime.now().isBefore(boostExpiry!);
  }

  /// Check if user needs super like reset (daily)
  bool get needsSuperLikeReset {
    if (lastSuperLikeReset == null) return true;
    final now = DateTime.now();
    final lastReset = lastSuperLikeReset!;
    return now.day != lastReset.day || 
           now.month != lastReset.month || 
           now.year != lastReset.year;
  }

  /// Check if user is blocked or banned
  bool get isBlocked => isBanned || reportCount >= 5;

  /// Check if user can be matched with (not blocked/banned)
  bool get isMatchable => !isBlocked && isActive;

  /// Check if user has blocked another user
  bool hasBlocked(String userId) => blockedUsers.contains(userId);

  /// Check if user has reported another user
  bool hasReported(String userId) => reportedUsers.contains(userId);

  /// Get Instagram verification status
  bool get hasInstagramVerification => hasBadge(BadgeType.instagramVerified);

  /// Calculate workout partnership strength
  double get workoutPartnershipStrength {
    if (completedWorkoutsTogether == 0) return 0.0;
    final totalWorkouts = workoutTogetherIds.isNotEmpty ? workoutTogetherIds.length : 1;
    return ((completedWorkoutsTogether / totalWorkouts) * 100).clamp(0.0, 100.0);
  }

  /// Check if user can start a boost (cooldown period)
  bool canStartBoost() {
    if (boostExpiry == null) return true;
    return DateTime.now().isAfter(boostExpiry!.add(const Duration(hours: 24)));
  }

  /// Get trust score based on verification and behavior
  double get trustScore {
    double score = 50.0; // Base score

    // Verification bonuses
    if (isVerified) score += 20.0;
    if (hasInstagramVerification) score += 15.0;
    if (isPhotoVerified) score += 10.0;

    // Activity bonuses
    if (partnershipsCount >= 1) score += 5.0;
    if (partnershipsCount >= 5) score += 10.0;
    if (averageRating >= 4.0) score += 10.0;

    // Penalties
    score -= reportCount * 10.0;
    if (isBanned) score = 0.0;

    return score.clamp(0.0, 100.0);
  }
}