/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: buddy_matching
/// 🔧 Type: repository interface
/// 🌍 Localization: N/A - Repository interface
/// 🎨 Theme: N/A - Repository interface  
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None
/// - Firebase: None (abstract interface)
/// - Hive: None (abstract interface)
library;

import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_match.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_action.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/ice_breaker.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/italian_city.dart';

/// Repository interface for buddy matching operations
abstract class BuddyMatchingRepository {
  // Profile Management
  Future<BuddyProfile?> getUserProfile(String userId);
  Future<void> createUserProfile(BuddyProfile profile);
  Future<void> updateUserProfile(BuddyProfile profile);
  Future<void> updateUserPreferences(String userId, BuddyPreferences preferences);
  Future<void> updateUserLocation(String userId, double latitude, double longitude, String? locationName);
  Future<void> setLookingForBuddy(String userId, bool isLooking);

  // Discovery & Matching
  Stream<List<BuddyProfile>> getPotentialMatches(String userId, {
    int limit = 20,
    double? maxDistance,
    FitnessLevel? fitnessLevel,
    List<WorkoutGoal>? goals,
  });
  
  Future<List<BuddyProfile>> searchProfiles({
    required String userId,
    String? query,
    double? maxDistance,
    FitnessLevel? fitnessLevel,
    List<WorkoutGoal>? goals,
    int? minAge,
    int? maxAge,
    bool? isVerified,
    int limit = 20,
  });

  // Matching Actions - Enhanced for Tier-1
  Future<BuddyMatch?> likeProfile(String currentUserId, String targetUserId, {bool isSuperLike = false});
  Future<BuddyMatch?> superLikeProfile(String currentUserId, String targetUserId);
  Future<void> dislikeProfile(String currentUserId, String targetUserId);
  Future<BuddyMatch?> confirmMatch(String matchId, String userId);
  Future<void> cancelMatch(String matchId, String userId);
  
  // Action tracking
  Future<void> recordAction(BuddyAction action);
  Future<List<BuddyAction>> getUserActions(String userId, {BuddyActionType? type});
  Stream<List<BuddyAction>> watchUserActions(String userId);

  // Match Management
  Stream<List<BuddyMatch>> getUserMatches(String userId, {MatchStatus? status});
  Future<BuddyMatch?> getMatch(String matchId);
  Future<void> updateMatchStatus(String matchId, MatchStatus status);
  Future<void> expireOldMatches(); // Cleanup expired matches

  // Partnership Management
  Future<BuddyMatch?> startPartnership(String matchId, String userId);
  Future<void> endPartnership(String matchId, String userId, {
    int? rating,
    String? feedback,
  });
  Future<void> updatePartnershipStats(String matchId, {
    int? sharedWorkouts,
    int? plannedWorkouts,
    int? completedWorkouts,
  });

  // Statistics & Analytics
  Future<Map<String, dynamic>> getUserMatchingStats(String userId);
  Future<List<BuddyProfile>> getTopRatedPartners(String userId, {int limit = 10});
  Future<double> getUserAverageRating(String userId);
  Future<List<BadgeType>> getUserEligibleBadges(String userId);
  Future<void> awardBadge(String userId, BadgeType badge);

  // Location & Distance
  Future<List<BuddyProfile>> getProfilesInRadius(
    String userId,
    double latitude,
    double longitude,
    double radiusKm, {
    int limit = 50,
  });

  // User Activity
  Future<void> updateUserActivity(String userId);
  Future<void> setUserOnlineStatus(String userId, bool isOnline);
  
  // Tier-1 Features
  // Super Likes & Boost
  Future<int> getSuperLikesRemaining(String userId);
  Future<void> resetDailySuperLikes(String userId);
  Future<void> activateBoost(String userId, Duration duration);
  Future<bool> isUserBoosted(String userId);
  Future<DateTime?> getBoostExpiry(String userId);
  
  // Verification
  Future<void> requestVerification(String userId, {String? instagramHandle});
  Future<void> verifyInstagramConnection(String userId, String instagramHandle);
  Future<void> requestPhotoVerification(String userId, String photoUrl);
  Future<void> updateVerificationStatus(String userId, {bool? isVerified, bool? isPhotoVerified});
  
  // City & Location System
  Future<List<ItalianCity>> getCitiesInRegion(String region);
  Future<List<String>> getCityZones(String cityCode);
  Future<void> updateUserCity(String userId, String cityCode, String? zoneName);
  Future<List<BuddyProfile>> getProfilesInCity(String cityCode, {String? zoneName, int limit = 50});
  Future<double> calculateDistanceBetweenUsers(String userId1, String userId2);
  
  // Ice Breakers & Chat
  Future<List<IceBreaker>> getIceBreakers({IceBreakerCategory? category});
  Future<IceBreaker?> getRandomIceBreaker(IceBreakerCategory category);
  Future<List<IceBreaker>> getSuggestedIceBreakers(String userId, String targetUserId);
  Future<void> recordIceBreakerUsage(String iceBreakerId);
  
  // Workout Together Tracking
  Future<void> recordWorkoutTogether(String user1Id, String user2Id, String workoutId);
  Future<void> completeWorkoutTogether(String workoutTogetherIds);
  Future<List<Map<String, dynamic>>> getWorkoutHistory(String userId, String partnerId);
  Future<void> updateWorkoutPartnershipStrength(String user1Id, String user2Id);
  
  // Security & Moderation
  Future<void> blockUser(String currentUserId, String targetUserId, {String? reason});
  Future<void> unblockUser(String currentUserId, String targetUserId);
  Future<List<String>> getBlockedUsers(String userId);
  Future<void> reportUser(String reporterId, String reportedUserId, ReportReason reason, {String? description});
  Future<void> incrementReportCount(String userId);
  Future<void> banUser(String userId, {String? reason, Duration? duration});
  Future<bool> isUserBanned(String userId);
  
  // Trust & Safety
  Future<double> getUserTrustScore(String userId);
  Future<List<BuddyProfile>> getModerationQueue();
  Future<void> updateUserSafetyStatus(String userId, {int? reportCount, bool? isBanned});
  
  // Development & Testing
  Future<void> seedDemoProfiles({bool forceRefresh = false});
  Future<List<BuddyProfile>> getDemoProfiles();
  Future<void> clearDemoData();
  Future<void> resetUserForTesting(String userId);

  // Preferences & Filters
  Future<void> saveSearchFilters(String userId, Map<String, dynamic> filters);
  Future<Map<String, dynamic>?> getSearchFilters(String userId);
}