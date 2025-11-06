/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data
/// 🎯 Feature: buddy_matching
/// 🔧 Type: repository implementation
/// 🌍 Localization: N/A - Repository implementation
/// 🎨 Theme: N/A - Repository implementation
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: None (injected via constructor)
/// - Firebase: Firestore, Auth
/// - Hive: None
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_profile.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_match.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_preferences.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/buddy_action.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/entities/ice_breaker.dart';
import 'package:gymbro_flutter_new/features/buddy_matching/domain/repositories/buddy_matching_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/italian_city.dart';

class FirebaseBuddyMatchingRepository implements BuddyMatchingRepository {

  FirebaseBuddyMatchingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Collections
  CollectionReference get _profilesCollection => _firestore.collection('buddy_profiles');
  CollectionReference get _matchesCollection => _firestore.collection('buddy_matches');
  CollectionReference get _filtersCollection => _firestore.collection('user_search_filters');

  @override
  Future<BuddyProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _profilesCollection.doc(userId).get();
      if (!doc.exists) return null;
      return BuddyProfile.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> createUserProfile(BuddyProfile profile) async {
    try {
      await _profilesCollection.doc(profile.uid).set({
        ...profile.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(BuddyProfile profile) async {
    try {
      await _profilesCollection.doc(profile.uid).update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(String userId, BuddyPreferences preferences) async {
    try {
      await _profilesCollection.doc(userId).update({
        'preferences': preferences.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  @override
  Future<void> updateUserLocation(String userId, double latitude, double longitude, String? locationName) async {
    try {
      await _profilesCollection.doc(userId).update({
        'preferences.latitude': latitude,
        'preferences.longitude': longitude,
        'preferences.locationName': locationName,
        'preferences.lastLocationUpdate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user location: $e');
    }
  }

  @override
  Future<void> setLookingForBuddy(String userId, bool isLooking) async {
    try {
      await _profilesCollection.doc(userId).update({
        'preferences.isLookingForBuddy': isLooking,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update looking for buddy status: $e');
    }
  }

  @override
  Stream<List<BuddyProfile>> getPotentialMatches(String userId, {
    int limit = 20,
    double? maxDistance,
    FitnessLevel? fitnessLevel,
    List<WorkoutGoal>? goals,
  }) {
    try {
      Query query = _profilesCollection
          .where('preferences.isLookingForBuddy', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit * 2); // Get more to filter out

      // Add fitness level filter if specified
      if (fitnessLevel != null) {
        query = query.where('preferences.fitnessLevel', isEqualTo: fitnessLevel.name);
      }

      return query.snapshots().asyncMap((snapshot) async {
        final currentUser = await getUserProfile(userId);
        if (currentUser == null) return <BuddyProfile>[];

        final profiles = snapshot.docs
            .map((doc) => BuddyProfile.fromFirestore(doc))
            .where((profile) => profile.uid != userId) // Exclude self
            .where((profile) => currentUser.canMatch(profile)) // Check matching rules
            .toList();

        // Sort by compatibility score
        profiles.sort((a, b) => 
          b.getCompatibilityScore(currentUser).compareTo(a.getCompatibilityScore(currentUser))
        );

        // Apply distance filter if location is available
        if (maxDistance != null && currentUser.preferences.hasLocation) {
          profiles.removeWhere((profile) {
            final distance = currentUser.distanceTo(profile);
            return distance != null && distance > maxDistance;
          });
        }

        return profiles.take(limit).toList();
      });
    } catch (e) {
      throw Exception('Failed to get potential matches: $e');
    }
  }

  @override
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
  }) async {
    try {
      Query firestoreQuery = _profilesCollection
          .where('preferences.isLookingForBuddy', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit * 2);

      // Add filters
      if (fitnessLevel != null) {
        firestoreQuery = firestoreQuery.where('preferences.fitnessLevel', isEqualTo: fitnessLevel.name);
      }

      if (isVerified != null) {
        firestoreQuery = firestoreQuery.where('isVerified', isEqualTo: isVerified);
      }

      final snapshot = await firestoreQuery.get();
      final currentUser = await getUserProfile(userId);
      if (currentUser == null) return [];

      var profiles = snapshot.docs
          .map((doc) => BuddyProfile.fromFirestore(doc))
          .where((profile) => profile.uid != userId)
          .where((profile) => currentUser.canMatch(profile))
          .toList();

      // Apply text search filter
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        profiles = profiles.where((profile) {
          return profile.displayName.toLowerCase().contains(queryLower) ||
                 (profile.preferences.bio?.toLowerCase().contains(queryLower) ?? false) ||
                 (profile.preferences.locationName?.toLowerCase().contains(queryLower) ?? false);
        }).toList();
      }

      // Apply distance filter
      if (maxDistance != null && currentUser.preferences.hasLocation) {
        profiles = profiles.where((profile) {
          final distance = currentUser.distanceTo(profile);
          return distance == null || distance <= maxDistance;
        }).toList();
      }

      // Apply goal filter
      if (goals != null && goals.isNotEmpty) {
        profiles = profiles.where((profile) {
          return profile.preferences.goals.any((goal) => goals.contains(goal));
        }).toList();
      }

      // Sort by compatibility
      profiles.sort((a, b) => 
        b.getCompatibilityScore(currentUser).compareTo(a.getCompatibilityScore(currentUser))
      );

      return profiles.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to search profiles: $e');
    }
  }

  @override
  Future<BuddyMatch?> likeProfile(String currentUserId, String targetUserId, {bool isSuperLike = false}) async {
    try {
      // Check if there's already a match between these users
      final existingMatch = await _getExistingMatch(currentUserId, targetUserId);
      
      if (existingMatch != null) {
        // If target user has already liked current user, it's a mutual match
        if (!existingMatch.hasUserLiked(currentUserId) && existingMatch.hasUserLiked(targetUserId)) {
          final updatedMatch = existingMatch.copyWith(
            status: MatchStatus.confirmed,
            confirmedAt: DateTime.now(),
          );
          
          if (currentUserId == existingMatch.user1Id) {
            final match = updatedMatch.copyWith(user1LikedAt: DateTime.now());
            await _matchesCollection.doc(existingMatch.id).update(match.toFirestore());
            return match;
          } else {
            final match = updatedMatch.copyWith(user2LikedAt: DateTime.now());
            await _matchesCollection.doc(existingMatch.id).update(match.toFirestore());
            return match;
          }
        }
        return existingMatch;
      }

      // Get compatibility score
      final currentUser = await getUserProfile(currentUserId);
      final targetUser = await getUserProfile(targetUserId);
      
      if (currentUser == null || targetUser == null) {
        throw Exception('User profiles not found');
      }

      final compatibilityScore = currentUser.getCompatibilityScore(targetUser);
      
      // Create new match
      final match = BuddyMatch.create(
        user1Id: currentUserId,
        user2Id: targetUserId,
        compatibilityScore: compatibilityScore,
        initiatorId: currentUserId,
      );

      final docRef = await _matchesCollection.add(match.toFirestore());
      final createdMatch = match.copyWith(id: docRef.id);
      
      // Update user profiles with liked/matched users
      await _updateProfileMatchHistory(currentUserId, targetUserId, true);

      return createdMatch;
    } catch (e) {
      throw Exception('Failed to like profile: $e');
    }
  }

  @override
  Future<void> dislikeProfile(String currentUserId, String targetUserId) async {
    try {
      await _updateProfileMatchHistory(currentUserId, targetUserId, false);
    } catch (e) {
      throw Exception('Failed to dislike profile: $e');
    }
  }

  @override
  Future<BuddyMatch?> confirmMatch(String matchId, String userId) async {
    try {
      final match = await getMatch(matchId);
      if (match == null) return null;

      final now = DateTime.now();
      final isUser1 = userId == match.user1Id;
      
      final updatedMatch = match.copyWith(
        status: MatchStatus.confirmed,
        confirmedAt: now,
        user1LikedAt: isUser1 ? (match.user1LikedAt ?? now) : match.user1LikedAt,
        user2LikedAt: !isUser1 ? (match.user2LikedAt ?? now) : match.user2LikedAt,
      );

      await _matchesCollection.doc(matchId).update(updatedMatch.toFirestore());
      return updatedMatch;
    } catch (e) {
      throw Exception('Failed to confirm match: $e');
    }
  }

  @override
  Future<void> cancelMatch(String matchId, String userId) async {
    try {
      await _matchesCollection.doc(matchId).update({
        'status': MatchStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel match: $e');
    }
  }

  @override
  Stream<List<BuddyMatch>> getUserMatches(String userId, {MatchStatus? status}) {
    try {
      Query query = _matchesCollection.where(Filter.or(
        Filter('user1Id', isEqualTo: userId),
        Filter('user2Id', isEqualTo: userId),
      ));

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      query = query.orderBy('updatedAt', descending: true);

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => BuddyMatch.fromFirestore(doc)).toList()
      );
    } catch (e) {
      throw Exception('Failed to get user matches: $e');
    }
  }

  @override
  Future<BuddyMatch?> getMatch(String matchId) async {
    try {
      final doc = await _matchesCollection.doc(matchId).get();
      if (!doc.exists) return null;
      return BuddyMatch.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get match: $e');
    }
  }

  @override
  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    try {
      await _matchesCollection.doc(matchId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update match status: $e');
    }
  }

  @override
  Future<void> expireOldMatches() async {
    try {
      final expiredMatches = await _matchesCollection
          .where('status', isEqualTo: MatchStatus.pending.name)
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredMatches.docs) {
        batch.update(doc.reference, {
          'status': MatchStatus.expired.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to expire old matches: $e');
    }
  }

  @override
  Future<BuddyMatch?> startPartnership(String matchId, String userId) async {
    try {
      final match = await getMatch(matchId);
      if (match == null || !match.canStartPartnership(userId)) return null;

      final now = DateTime.now();
      final updatedMatch = match.copyWith(
        status: MatchStatus.partnership,
        partnershipStartedAt: now,
      );

      await _matchesCollection.doc(matchId).update(updatedMatch.toFirestore());

      // Update user profiles with partnership info
      await _updateUserPartnership(match.user1Id, matchId, now);
      await _updateUserPartnership(match.user2Id, matchId, now);

      return updatedMatch;
    } catch (e) {
      throw Exception('Failed to start partnership: $e');
    }
  }

  @override
  Future<void> endPartnership(String matchId, String userId, {
    int? rating,
    String? feedback,
  }) async {
    try {
      final match = await getMatch(matchId);
      if (match == null) return;

      final now = DateTime.now();
      final isUser1 = userId == match.user1Id;

      final updates = <String, dynamic>{
        'status': MatchStatus.completed.name,
        'partnershipEndedAt': Timestamp.fromDate(now),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (rating != null) {
        updates[isUser1 ? 'user1Rating' : 'user2Rating'] = rating;
      }

      if (feedback != null) {
        updates[isUser1 ? 'user1Feedback' : 'user2Feedback'] = feedback;
      }

      await _matchesCollection.doc(matchId).update(updates);

      // Update user profiles - remove current partnership
      await _clearUserPartnership(match.user1Id);
      await _clearUserPartnership(match.user2Id);

      // Update partnership statistics
      final wasSuccessful = match.copyWith(
        user1Rating: isUser1 ? rating : match.user1Rating,
        user2Rating: !isUser1 ? rating : match.user2Rating,
      ).wasSuccessfulPartnership;

      if (wasSuccessful) {
        await _incrementUserSuccessfulPartnerships(match.user1Id);
        await _incrementUserSuccessfulPartnerships(match.user2Id);
      }
    } catch (e) {
      throw Exception('Failed to end partnership: $e');
    }
  }

  @override
  Future<void> updatePartnershipStats(String matchId, {
    int? sharedWorkouts,
    int? plannedWorkouts,
    int? completedWorkouts,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (sharedWorkouts != null) updates['sharedWorkouts'] = sharedWorkouts;
      if (plannedWorkouts != null) updates['plannedWorkouts'] = plannedWorkouts;
      if (completedWorkouts != null) updates['completedWorkouts'] = completedWorkouts;

      await _matchesCollection.doc(matchId).update(updates);
    } catch (e) {
      throw Exception('Failed to update partnership stats: $e');
    }
  }

  // Helper methods...
  Future<BuddyMatch?> _getExistingMatch(String user1Id, String user2Id) async {
    try {
      final query1 = await _matchesCollection
          .where('user1Id', isEqualTo: user1Id)
          .where('user2Id', isEqualTo: user2Id)
          .limit(1)
          .get();

      if (query1.docs.isNotEmpty) {
        return BuddyMatch.fromFirestore(query1.docs.first);
      }

      final query2 = await _matchesCollection
          .where('user1Id', isEqualTo: user2Id)
          .where('user2Id', isEqualTo: user1Id)
          .limit(1)
          .get();

      if (query2.docs.isNotEmpty) {
        return BuddyMatch.fromFirestore(query2.docs.first);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateProfileMatchHistory(String currentUserId, String targetUserId, bool isLike) async {
    final field = isLike ? 'likedProfiles' : 'dislikedProfiles';
    await _profilesCollection.doc(currentUserId).update({
      field: FieldValue.arrayUnion([targetUserId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateUserPartnership(String userId, String partnershipId, DateTime startDate) async {
    await _profilesCollection.doc(userId).update({
      'currentPartnershipId': partnershipId,
      'partnershipStartDate': Timestamp.fromDate(startDate),
      'partnershipsCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _clearUserPartnership(String userId) async {
    await _profilesCollection.doc(userId).update({
      'currentPartnershipId': FieldValue.delete(),
      'partnershipStartDate': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _incrementUserSuccessfulPartnerships(String userId) async {
    await _profilesCollection.doc(userId).update({
      'successfulPartnerships': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Implement remaining abstract methods...
  @override
  Future<Map<String, dynamic>> getUserMatchingStats(String userId) async {
    // Implementation for statistics
    return {};
  }

  @override
  Future<List<BuddyProfile>> getTopRatedPartners(String userId, {int limit = 10}) async {
    // Implementation for top rated partners
    return [];
  }

  @override
  Future<double> getUserAverageRating(String userId) async {
    // Implementation for average rating
    return 0.0;
  }

  @override
  Future<List<BadgeType>> getUserEligibleBadges(String userId) async {
    // Implementation for eligible badges
    return [];
  }

  @override
  Future<void> awardBadge(String userId, BadgeType badge) async {
    // Implementation for awarding badges
  }

  @override
  Future<List<BuddyProfile>> getProfilesInRadius(
    String userId,
    double latitude,
    double longitude,
    double radiusKm, {
    int limit = 50,
  }) async {
    // Implementation for radius search
    return [];
  }

  @override
  Future<void> updateUserActivity(String userId) async {
    await _profilesCollection.doc(userId).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setUserOnlineStatus(String userId, bool isOnline) async {
    await _profilesCollection.doc(userId).update({
      'isActive': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId, {String? reason}) async {
    await _profilesCollection.doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([targetUserId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    await _profilesCollection.doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([targetUserId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<String>> getBlockedUsers(String userId) async {
    final doc = await _profilesCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>?;
    return List<String>.from(data?['blockedUsers'] ?? []);
  }

  @override
  Future<void> reportUser(String reporterId, String reportedUserId, ReportReason reason, {String? description}) async {
    await _firestore.collection('buddy_reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason.name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    await incrementReportCount(reportedUserId);
  }

  @override
  Future<void> saveSearchFilters(String userId, Map<String, dynamic> filters) async {
    await _filtersCollection.doc(userId).set(filters);
  }

  @override
  Future<Map<String, dynamic>?> getSearchFilters(String userId) async {
    final doc = await _filtersCollection.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Action tracking
  @override
  Future<void> recordAction(BuddyAction action) async {
    await _firestore.collection('buddy_actions').add(action.toFirestore());
  }

  @override
  Future<List<BuddyAction>> getUserActions(String userId, {BuddyActionType? type}) async {
    Query query = _firestore.collection('buddy_actions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => BuddyAction.fromFirestore(doc)).toList();
  }

  @override
  Stream<List<BuddyAction>> watchUserActions(String userId) {
    return _firestore.collection('buddy_actions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => BuddyAction.fromFirestore(doc)).toList());
  }

  // Tier-1 Features - Super Likes & Boost
  @override
  Future<BuddyMatch?> superLikeProfile(String currentUserId, String targetUserId) async {
    return likeProfile(currentUserId, targetUserId, isSuperLike: true);
  }

  @override
  Future<int> getSuperLikesRemaining(String userId) async {
    final profile = await getUserProfile(userId);
    return profile?.superLikesRemaining ?? 0;
  }

  @override
  Future<void> resetDailySuperLikes(String userId) async {
    await _profilesCollection.doc(userId).update({
      'superLikesRemaining': 5,
      'lastSuperLikeReset': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> activateBoost(String userId, Duration duration) async {
    final expiryTime = DateTime.now().add(duration);
    await _profilesCollection.doc(userId).update({
      'boostExpiresAt': Timestamp.fromDate(expiryTime),
      'isBoosted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> isUserBoosted(String userId) async {
    final expiry = await getBoostExpiry(userId);
    return expiry != null && expiry.isAfter(DateTime.now());
  }

  @override
  Future<DateTime?> getBoostExpiry(String userId) async {
    final doc = await _profilesCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>?;
    final timestamp = data?['boostExpiresAt'] as Timestamp?;
    return timestamp?.toDate();
  }

  // Verification
  @override
  Future<void> requestVerification(String userId, {String? instagramHandle}) async {
    await _firestore.collection('verification_requests').add({
      'userId': userId,
      'instagramHandle': instagramHandle,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> verifyInstagramConnection(String userId, String instagramHandle) async {
    await _profilesCollection.doc(userId).update({
      'instagramHandle': instagramHandle,
      'isInstagramVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> requestPhotoVerification(String userId, String photoUrl) async {
    await _firestore.collection('photo_verification_requests').add({
      'userId': userId,
      'photoUrl': photoUrl,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateVerificationStatus(String userId, {bool? isVerified, bool? isPhotoVerified}) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (isVerified != null) updates['isVerified'] = isVerified;
    if (isPhotoVerified != null) updates['isPhotoVerified'] = isPhotoVerified;
    await _profilesCollection.doc(userId).update(updates);
  }

  // City & Location System
  @override
  Future<List<ItalianCity>> getCitiesInRegion(String region) async {
    final snapshot = await _firestore.collection('italian_cities')
        .where('region', isEqualTo: region)
        .get();
    return snapshot.docs.map((doc) => ItalianCity.fromFirestore(doc)).toList();
  }

  @override
  Future<List<String>> getCityZones(String cityCode) async {
    final doc = await _firestore.collection('italian_cities').doc(cityCode).get();
    final data = doc.data();
    return List<String>.from(data?['zones'] ?? []);
  }

  @override
  Future<void> updateUserCity(String userId, String cityCode, String? zoneName) async {
    await _profilesCollection.doc(userId).update({
      'cityCode': cityCode,
      'zoneName': zoneName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<BuddyProfile>> getProfilesInCity(String cityCode, {String? zoneName, int limit = 50}) async {
    Query query = _profilesCollection
        .where('cityCode', isEqualTo: cityCode)
        .where('isActive', isEqualTo: true)
        .limit(limit);

    if (zoneName != null) {
      query = query.where('zoneName', isEqualTo: zoneName);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => BuddyProfile.fromFirestore(doc)).toList();
  }

  @override
  Future<double> calculateDistanceBetweenUsers(String userId1, String userId2) async {
    final user1 = await getUserProfile(userId1);
    final user2 = await getUserProfile(userId2);
    if (user1 == null || user2 == null) return double.infinity;
    return user1.distanceTo(user2) ?? double.infinity;
  }

  // Ice Breakers & Chat
  @override
  Future<List<IceBreaker>> getIceBreakers({IceBreakerCategory? category}) async {
    Query query = _firestore.collection('ice_breakers');
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => IceBreaker.fromFirestore(doc)).toList();
  }

  @override
  Future<IceBreaker?> getRandomIceBreaker(IceBreakerCategory category) async {
    final iceBreakers = await getIceBreakers(category: category);
    if (iceBreakers.isEmpty) return null;
    iceBreakers.shuffle();
    return iceBreakers.first;
  }

  @override
  Future<List<IceBreaker>> getSuggestedIceBreakers(String userId, String targetUserId) async {
    // Get ice breakers based on common interests/goals
    final currentUser = await getUserProfile(userId);
    final targetUser = await getUserProfile(targetUserId);
    if (currentUser == null || targetUser == null) return [];

    // For now, return workout-related ice breakers
    return getIceBreakers(category: IceBreakerCategory.workout);
  }

  @override
  Future<void> recordIceBreakerUsage(String iceBreakerId) async {
    await _firestore.collection('ice_breakers').doc(iceBreakerId).update({
      'usageCount': FieldValue.increment(1),
    });
  }

  // Workout Together Tracking
  @override
  Future<void> recordWorkoutTogether(String user1Id, String user2Id, String workoutId) async {
    await _firestore.collection('workouts_together').add({
      'user1Id': user1Id,
      'user2Id': user2Id,
      'workoutId': workoutId,
      'status': 'planned',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeWorkoutTogether(String workoutTogetherId) async {
    await _firestore.collection('workouts_together').doc(workoutTogetherId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getWorkoutHistory(String userId, String partnerId) async {
    final snapshot = await _firestore.collection('workouts_together')
        .where(Filter.or(
          Filter.and(
            Filter('user1Id', isEqualTo: userId),
            Filter('user2Id', isEqualTo: partnerId),
          ),
          Filter.and(
            Filter('user1Id', isEqualTo: partnerId),
            Filter('user2Id', isEqualTo: userId),
          ),
        ))
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
  }

  @override
  Future<void> updateWorkoutPartnershipStrength(String user1Id, String user2Id) async {
    // Update partnership strength based on workout history
    final history = await getWorkoutHistory(user1Id, user2Id);
    final completedCount = history.where((w) => w['status'] == 'completed').length;

    // Find existing match
    final match = await _getExistingMatch(user1Id, user2Id);
    if (match != null) {
      await updatePartnershipStats(match.id, completedWorkouts: completedCount);
    }
  }

  // Security & Moderation
  @override
  Future<void> incrementReportCount(String userId) async {
    await _profilesCollection.doc(userId).update({
      'reportCount': FieldValue.increment(1),
      'lastReportedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> banUser(String userId, {String? reason, Duration? duration}) async {
    final banExpiry = duration != null ? DateTime.now().add(duration) : null;
    await _profilesCollection.doc(userId).update({
      'isBanned': true,
      'banReason': reason,
      'bannedAt': FieldValue.serverTimestamp(),
      'banExpiresAt': banExpiry != null ? Timestamp.fromDate(banExpiry) : null,
    });
  }

  @override
  Future<bool> isUserBanned(String userId) async {
    final doc = await _profilesCollection.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>?;
    final isBanned = data?['isBanned'] as bool? ?? false;

    if (!isBanned) return false;

    // Check if ban has expired
    final banExpiry = data?['banExpiresAt'] as Timestamp?;
    if (banExpiry != null && banExpiry.toDate().isBefore(DateTime.now())) {
      // Unban user
      await _profilesCollection.doc(userId).update({
        'isBanned': false,
        'banExpiresAt': FieldValue.delete(),
      });
      return false;
    }

    return true;
  }

  // Trust & Safety
  @override
  Future<double> getUserTrustScore(String userId) async {
    final profile = await getUserProfile(userId);
    if (profile == null) return 0.0;

    // Calculate trust score based on:
    // - Verification status
    // - Partnership success rate
    // - Report count
    double score = 50.0; // Base score

    if (profile.isVerified) score += 20.0;
    if (profile.partnershipsCount > 0) {
      final successRate = profile.successfulPartnerships / profile.partnershipsCount;
      score += successRate * 20.0;
    }

    // Deduct for reports (max -30)
    final reportPenalty = (profile.reportCount * 10).clamp(0, 30);
    score -= reportPenalty.toDouble();

    return score.clamp(0.0, 100.0);
  }

  @override
  Future<List<BuddyProfile>> getModerationQueue() async {
    final snapshot = await _profilesCollection
        .where('reportCount', isGreaterThanOrEqualTo: 3)
        .orderBy('reportCount', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => BuddyProfile.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateUserSafetyStatus(String userId, {int? reportCount, bool? isBanned}) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (reportCount != null) updates['reportCount'] = reportCount;
    if (isBanned != null) updates['isBanned'] = isBanned;
    await _profilesCollection.doc(userId).update(updates);
  }

  // Development & Testing
  @override
  Future<void> seedDemoProfiles({bool forceRefresh = false}) async {
    // Implementation for seeding demo profiles
    throw UnimplementedError('seedDemoProfiles not yet implemented');
  }

  @override
  Future<List<BuddyProfile>> getDemoProfiles() async {
    final snapshot = await _profilesCollection
        .where('isDemo', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => BuddyProfile.fromFirestore(doc)).toList();
  }

  @override
  Future<void> clearDemoData() async {
    final batch = _firestore.batch();
    final demoProfiles = await _profilesCollection.where('isDemo', isEqualTo: true).get();
    for (final doc in demoProfiles.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> resetUserForTesting(String userId) async {
    await _profilesCollection.doc(userId).update({
      'likedProfiles': [],
      'dislikedProfiles': [],
      'matchedProfiles': [],
      'superLikesRemaining': 5,
      'reportCount': 0,
      'isBanned': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}