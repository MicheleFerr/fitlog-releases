/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data/repositories
 * 🎯 Feature: community
 * 🔧 Type: repository
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - BaseHybridRepository (local + premium sync)
 * - Hive (local storage)
 * - Firebase (premium cloud sync)
 */

import 'package:gymbro_flutter_new/core/data/repositories/base_hybrid_repository.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// Hybrid repository for community contributions
/// - FREE users: Local contributions only (can contribute locally)
/// - PREMIUM users: Local + Cloud sync + Access to global community
class HybridCommunityRepository extends BaseHybridRepository<CommunityContribution> {
  late Box<Map> _votesBox;
  late Box<Map> _statsBox;
  
  HybridCommunityRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : super(
    featureName: 'community',
    collectionName: 'community_contributions',
    requiresPremiumForCloud: true, // Community features require premium
    firestore: firestore,
    auth: auth,
  ) {
    _initializeAdditionalBoxes();
  }

  Future<void> _initializeAdditionalBoxes() async {
    _votesBox = await Hive.openBox<Map>('community_votes');
    _statsBox = await Hive.openBox<Map>('community_stats');
  }

  @override
  Map<String, dynamic> toJson(CommunityContribution entity) {
    return entity.toJson();
  }

  @override
  CommunityContribution fromJson(Map<String, dynamic> json) {
    return CommunityContribution.fromJson(json);
  }

  @override
  String getId(CommunityContribution entity) {
    return entity.id;
  }

  @override
  bool validate(CommunityContribution entity) {
    return entity.id.isNotEmpty && 
           entity.title.isNotEmpty && 
           entity.exerciseId.isNotEmpty;
  }

  /// Submit a contribution (local for free, synced for premium)
  Future<void> submitContribution(CommunityContribution contribution) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Set user info
    final newContribution = contribution.copyWith(
      userId: userId,
      createdAt: DateTime.now(),
      status: ContributionStatus.pending,
      upvotes: 0,
      downvotes: 0,
      upvotedBy: [],
      downvotedBy: [],
    );

    // Save using base repository (handles local + sync)
    await save(newContribution);

    // Update local stats
    await _updateLocalStats(userId, 'submit');

    debugPrint('✅ Contribution submitted: ${contribution.title}');
  }

  /// Vote on contribution (local for free users)
  Future<void> voteOnContribution(String contributionId, bool isUpvote) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Record vote locally
    final voteKey = '${userId}_$contributionId';
    await _votesBox.put(voteKey, {
      'userId': userId,
      'contributionId': contributionId,
      'isUpvote': isUpvote,
      'votedAt': DateTime.now().toIso8601String(),
    });

    // Update contribution locally
    final contribution = await get(contributionId);
    if (contribution != null) {
      final upvotedBy = List<String>.from(contribution.upvotedBy);
      final downvotedBy = List<String>.from(contribution.downvotedBy);

      // Remove existing vote
      upvotedBy.remove(userId);
      downvotedBy.remove(userId);

      // Add new vote
      if (isUpvote) {
        upvotedBy.add(userId);
      } else {
        downvotedBy.add(userId);
      }

      final updatedContribution = contribution.copyWith(
        upvotes: upvotedBy.length,
        downvotes: downvotedBy.length,
        upvotedBy: upvotedBy,
        downvotedBy: downvotedBy,
      );

      await update(updatedContribution);
    }

    // Update stats
    await _updateLocalStats(userId, 'vote');

    debugPrint('✅ Vote recorded: $contributionId (upvote: $isUpvote)');
  }

  /// Get contributions (local for free, merged with cloud for premium)
  Stream<List<CommunityContribution>> getContributions({
    String? exerciseId,
    ContributionStatus? status,
    String? userId,
  }) {
    return Stream.fromFuture(_getFilteredContributions(
      exerciseId: exerciseId,
      status: status,
      userId: userId,
    ));
  }

  Future<List<CommunityContribution>> _getFilteredContributions({
    String? exerciseId,
    ContributionStatus? status,
    String? userId,
  }) async {
    final contributions = await getAll();
    
    return contributions.where((c) {
      if (exerciseId != null && c.exerciseId != exerciseId) return false;
      if (status != null && c.status != status) return false;
      if (userId != null && c.userId != userId) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get trending contributions (premium feature)
  Stream<List<CommunityContribution>> getTrendingContributions() {
    if (!isPremiumUser) {
      // Free users only see their own local contributions
      return Stream.value([]);
    }

    // Premium users get global trending from cloud
    return Stream.fromFuture(_getTrendingFromCloud());
  }

  Future<List<CommunityContribution>> _getTrendingFromCloud() async {
    if (!canSyncToCloud) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('status', isEqualTo: ContributionStatus.approved.name)
          .orderBy('upvotes', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Failed to fetch trending: $e');
      return [];
    }
  }

  /// Get user statistics
  Stream<UserContributionStats> getUserStats(String userId) {
    return Stream.fromFuture(_calculateUserStats(userId));
  }

  Future<UserContributionStats> _calculateUserStats(String userId) async {
    // Get stats from local storage
    final statsKey = 'stats_$userId';
    final localStats = _statsBox.get(statsKey);
    
    if (localStats != null) {
      return UserContributionStats.fromJson(Map<String, dynamic>.from(localStats));
    }

    // Calculate from contributions
    final contributions = await _getFilteredContributions(userId: userId);
    
    int approved = 0;
    int rejected = 0;
    int pending = 0;
    int totalPoints = 0;
    final contributionsByType = <String, int>{};

    for (final c in contributions) {
      switch (c.status) {
        case ContributionStatus.approved:
          approved++;
          totalPoints += ContributionPoints.contributionApproved;
          break;
        case ContributionStatus.rejected:
          rejected++;
          break;
        case ContributionStatus.pending:
          pending++;
          totalPoints += ContributionPoints.submitContribution;
          break;
        default:
          break;
      }

      final typeKey = c.type.name;
      contributionsByType[typeKey] = (contributionsByType[typeKey] ?? 0) + 1;
    }

    final stats = UserContributionStats(
      userId: userId,
      totalContributions: contributions.length,
      approvedContributions: approved,
      rejectedContributions: rejected,
      pendingContributions: pending,
      totalPoints: totalPoints,
      level: ContributionPoints.getLevelFromPoints(totalPoints),
      contributionsByType: contributionsByType,
      approvalRate: contributions.isNotEmpty ? approved / contributions.length : 0.0,
    );

    // Cache stats
    await _statsBox.put(statsKey, stats.toJson());

    return stats;
  }

  /// Update local statistics
  Future<void> _updateLocalStats(String userId, String action) async {
    final statsKey = 'stats_$userId';
    final existingStats = _statsBox.get(statsKey);
    
    int pointsToAdd = 0;
    switch (action) {
      case 'submit':
        pointsToAdd = ContributionPoints.submitContribution;
        break;
      case 'vote':
        pointsToAdd = ContributionPoints.voteOnContribution;
        break;
      case 'comment':
        pointsToAdd = ContributionPoints.commentOnContribution;
        break;
      case 'approved':
        pointsToAdd = ContributionPoints.contributionApproved;
        break;
    }

    if (existingStats != null) {
      final stats = Map<String, dynamic>.from(existingStats);
      stats['totalPoints'] = (stats['totalPoints'] ?? 0) + pointsToAdd;
      stats['level'] = ContributionPoints.getLevelFromPoints(stats['totalPoints']);
      stats['lastActivity'] = DateTime.now().toIso8601String();
      
      if (action == 'submit') {
        stats['totalContributions'] = (stats['totalContributions'] ?? 0) + 1;
      }
      
      await _statsBox.put(statsKey, stats);
    } else {
      // Create new stats
      await _statsBox.put(statsKey, {
        'userId': userId,
        'totalPoints': pointsToAdd,
        'level': ContributionPoints.getLevelFromPoints(pointsToAdd),
        'totalContributions': action == 'submit' ? 1 : 0,
        'lastActivity': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Search contributions (local for free, global for premium)
  Future<List<CommunityContribution>> searchContributions(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();
    final contributions = await getAll();

    return contributions.where((c) =>
      c.title.toLowerCase().contains(queryLower) ||
      c.description.toLowerCase().contains(queryLower) ||
      c.exerciseName.toLowerCase().contains(queryLower)
    ).toList();
  }

  /// Report contribution (premium feature)
  Future<void> reportContribution(String contributionId, String reason) async {
    if (!isPremiumUser) {
      debugPrint('⚠️ Reporting requires premium membership');
      return;
    }

    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Queue report for sync
    await FirebaseFirestore.instance.collection('contribution_reports').add({
      'contributionId': contributionId,
      'reportedBy': userId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get contributions for review (premium feature)
  Stream<List<CommunityContribution>> getContributionsForReview() {
    final userId = currentUserId;
    if (userId == null || !isPremiumUser) {
      return Stream.value([]);
    }

    return Stream.fromFuture(_getContributionsForReview(userId));
  }

  Future<List<CommunityContribution>> _getContributionsForReview(String userId) async {
    if (!canSyncToCloud) return [];

    try {
      // Get from cloud for premium users
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('status', isEqualTo: ContributionStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final contributions = snapshot.docs
          .map((doc) => fromJson(doc.data()))
          .where((c) => 
            c.userId != userId &&
            !c.upvotedBy.contains(userId) && 
            !c.downvotedBy.contains(userId)
          )
          .take(10)
          .toList();

      // Cache some for offline access
      for (final c in contributions.take(5)) {
        await save(c);
      }

      return contributions;
    } catch (e) {
      debugPrint('⚠️ Failed to fetch for review: $e');
      return [];
    }
  }

  /// Comment on contribution
  Future<void> commentOnContribution(String contributionId, ContributionComment comment) async {
    final contribution = await get(contributionId);
    if (contribution == null) return;

    final updatedComments = List<ContributionComment>.from(contribution.comments)
      ..add(comment);

    final updated = contribution.copyWith(
      comments: updatedComments,
    );

    await update(updated);
    await _updateLocalStats(comment.userId, 'comment');
  }
}

/// Points system for contributions
class ContributionPoints {
  static const int submitContribution = 10;
  static const int voteOnContribution = 2;
  static const int commentOnContribution = 5;
  static const int contributionApproved = 50;
  static const int contributionFeatured = 100;

  static String getLevelFromPoints(int points) {
    if (points >= 5000) return 'Legend';
    if (points >= 2000) return 'Master';
    if (points >= 1000) return 'Expert';
    if (points >= 500) return 'Advanced';
    if (points >= 200) return 'Intermediate';
    if (points >= 50) return 'Beginner';
    return 'Rookie';
  }
}