import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return FirestoreCommunityRepository(ref);
});

abstract class CommunityRepository {
  Stream<List<CommunityContribution>> getContributions({
    String? exerciseId,
    ContributionStatus? status,
    String? userId,
  });

  Stream<List<CommunityContribution>> getTrendingContributions();
  Stream<List<CommunityContribution>> getContributionsForReview(String userId);
  Stream<UserContributionStats> getUserStats(String userId);

  Future<void> submitContribution(CommunityContribution contribution);
  Future<void> voteOnContribution(String contributionId, String userId, bool isUpvote);
  Future<void> commentOnContribution(String contributionId, ContributionComment comment);
  Future<void> reportContribution(String contributionId, String userId, String reason);

  // Admin moderation
  Future<void> approveContribution(String contributionId, String adminId);
  Future<void> rejectContribution(String contributionId, String adminId, String reason);

  Future<List<CommunityContribution>> searchContributions(String query);
  Future<UserContributionStats> calculateUserStats(String userId);

  // Discovery & Search (Task 3)
  Stream<List<CommunityContribution>> searchContributionsStream({
    required String query,
    ContributionFilters? filters,
    int limit = 20,
  });

  Stream<List<CommunityContribution>> filterContributions({
    required ContributionFilters filters,
    int limit = 20,
  });

  // Save/unsave contributions
  Future<void> saveContribution(String contributionId, String userId);
  Future<void> unsaveContribution(String contributionId, String userId);
  Future<List<String>> getSavedContributionIds(String userId);

  // Analytics
  Future<void> incrementViewCount(String contributionId);
}

class FirestoreCommunityRepository implements CommunityRepository {
  
  FirestoreCommunityRepository(this._ref);
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _contributionsCollection = 'community_contributions';
  static const String _userStatsCollection = 'user_contribution_stats';
  static const String _votesCollection = 'contribution_votes';
  
  @override
  Stream<List<CommunityContribution>> getContributions({
    String? exerciseId,
    ContributionStatus? status,
    String? userId,
  }) {
    if (kDebugMode) {
      debugPrint('🔍 [CommunityRepo] Getting contributions - exerciseId: $exerciseId, status: $status, userId: $userId');
    }

    // Per userId, facciamo una query semplice senza orderBy per evitare indici
    if (userId != null) {
      if (kDebugMode) {
        debugPrint('📋 [CommunityRepo] Querying contributions for userId: $userId');
      }
      return _firestore
          .collection(_contributionsCollection)
          .where('userId', isEqualTo: userId)
          .limit(50)
          .snapshots()
          .map((snapshot) {
            if (kDebugMode) {
              debugPrint('📊 [CommunityRepo] Found ${snapshot.docs.length} contributions for user $userId');
            }
            final contributions = _mapSnapshotToContributions(snapshot);
            if (kDebugMode) {
              debugPrint('✅ [CommunityRepo] Mapped ${contributions.length} contributions successfully');
            }
            for (var contrib in contributions) {
              if (kDebugMode) {
                debugPrint('   - ${contrib.title} (${contrib.status.name})');
              }
            }
            return contributions;
          })
          .handleError((error) {
            if (kDebugMode) {
              debugPrint('❌ [CommunityRepo] Error fetching user contributions: $error');
            }
          }, test: (error) => true)
          .startWith(<CommunityContribution>[]);
    }
    
    Query query = _firestore.collection(_contributionsCollection);
    
    // Altri filtri
    if (exerciseId != null) {
      query = query.where('exerciseId', isEqualTo: exerciseId);
    } else if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    
    // Se non ci sono filtri, ordina semplicemente
    if (exerciseId == null && status == null) {
      query = query.orderBy('createdAt', descending: true);
    }
    
    return query
        .limit(50)
        .snapshots()
        .map(_mapSnapshotToContributions)
        .handleError((error) {
          // print('Error fetching contributions: $error');
        }, test: (error) => true)
        .startWith(<CommunityContribution>[]);
  }
  
  @override
  Stream<List<CommunityContribution>> getTrendingContributions() {
    // Simplified query - just get recent contributions
    return _firestore
        .collection(_contributionsCollection)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(_mapSnapshotToContributions)
        .handleError((error) {
          // print('Error fetching trending contributions: $error');
        }, test: (error) => true)
        .startWith(<CommunityContribution>[]); // Inizia con lista vuota
  }
  
  @override
  Stream<List<CommunityContribution>> getContributionsForReview(String userId) {
    // Simplified query - just get recent contributions not by this user
    return _firestore
        .collection(_contributionsCollection)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final contributions = _mapSnapshotToContributions(snapshot);
          // Filter out user's own contributions and already voted
          return contributions.where((c) => 
            c.userId != userId &&
            !c.upvotedBy.contains(userId) && 
            !c.downvotedBy.contains(userId)
          ).take(10).toList();
        })
        .handleError((error) {
          // print('Error fetching contributions for review: $error');
        }, test: (error) => true)
        .startWith(<CommunityContribution>[]); // Inizia con lista vuota
  }
  
  @override
  Stream<UserContributionStats> getUserStats(String userId) {
    final defaultStats = UserContributionStats(
      userId: userId,
      totalContributions: 0,
      approvedContributions: 0,
      rejectedContributions: 0,
      pendingContributions: 0,
      totalVotes: 0,
      totalPoints: 0,
      currentStreak: 0,
      longestStreak: 0,
      level: 'Rookie',
      badges: const [],
      lastContributionDate: null,
      contributionsByType: const {},
      approvalRate: 0.0,
      weeklyRank: 0,
      monthlyRank: 0,
      allTimeRank: 0,
    );
    
    // Ritorna direttamente lo stream con gestione errori
    return _firestore
        .collection(_userStatsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            try {
              return UserContributionStats.fromJson(snapshot.data()!);
            } catch (e) {
              // print('Error parsing user stats: $e');
              return defaultStats;
            }
          }
          return defaultStats;
        })
        .handleError((error) {
          // print('Error fetching user stats: $error');
        }, test: (error) => true) // Gestisce tutti gli errori
        .startWith(defaultStats); // Inizia con default stats
  }
  
  @override
  Future<void> submitContribution(CommunityContribution contribution) async {
    final userAsync = await _ref.read(currentUserProvider.future);
    if (userAsync == null) throw Exception('User not authenticated');

    if (kDebugMode) {
      debugPrint('📝 [CommunityRepo] Submitting contribution for user ${userAsync.uid}');
    }

    final docRef = _firestore.collection(_contributionsCollection).doc();

    // Tutti i contributi richiedono approvazione admin
    const status = ContributionStatus.pending;

    final data = contribution.copyWith(
      id: docRef.id,
      userId: userAsync.uid,
      userName: userAsync.displayName ?? 'Anonymous',
      createdAt: DateTime.now(),
      status: status,
      upvotes: 0,
    ).toJson();

    // Convert enums to strings for Firestore
    data['type'] = contribution.type.name;
    data['status'] = status.name;

    if (kDebugMode) {
      debugPrint('💾 [CommunityRepo] Saving contribution with ID: ${docRef.id}');
    }
    if (kDebugMode) {
      debugPrint('📋 [CommunityRepo] Data: ${data['exerciseName']} - ${data['type']} - ${data['title']}');
    }
    if (kDebugMode) {
      debugPrint('✅ [CommunityRepo] Status: ${status.name}');
    }

    await docRef.set(data);

    if (kDebugMode) {
      debugPrint('✅ [CommunityRepo] Contribution saved to Firestore successfully');
    }

    // Update user stats per submission
    await _updateUserStats(userAsync.uid, 'submit');

    if (kDebugMode) {
      debugPrint('🏆 [CommunityRepo] User stats updated (+10 XP)');
    }
  }
  
  @override
  Future<void> voteOnContribution(String contributionId, String userId, bool isUpvote) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final data = snapshot.data()!;
      final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(data['downvotedBy'] ?? []);
      
      // Remove existing vote if any
      upvotedBy.remove(userId);
      downvotedBy.remove(userId);
      
      // Add new vote
      if (isUpvote) {
        upvotedBy.add(userId);
      } else {
        downvotedBy.add(userId);
      }
      
      // Update counts
      final upvotes = upvotedBy.length;
      final downvotes = downvotedBy.length;
      
      // Auto-approve if enough upvotes
      String status = data['status'];
      if (upvotes >= 10 && downvotes < 3) {
        status = ContributionStatus.approved.name;
      } else if (downvotes >= 10) {
        status = ContributionStatus.rejected.name;
      }
      
      transaction.update(docRef, {
        'upvotes': upvotes,
        'downvotes': downvotes,
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    
    // Update user stats
    await _updateUserStats(userId, 'vote');
  }
  
  @override
  Future<void> commentOnContribution(String contributionId, ContributionComment comment) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);
    
    await docRef.update({
      'comments': FieldValue.arrayUnion([comment.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Update user stats
    await _updateUserStats(comment.userId, 'comment');
  }
  
  @override
  Future<void> reportContribution(String contributionId, String userId, String reason) async {
    // Create report document
    await _firestore.collection('contribution_reports').add({
      'contributionId': contributionId,
      'reportedBy': userId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // If multiple reports, mark for review
    final reports = await _firestore
        .collection('contribution_reports')
        .where('contributionId', isEqualTo: contributionId)
        .get();
    
    if (reports.docs.length >= 3) {
      await _firestore
          .collection(_contributionsCollection)
          .doc(contributionId)
          .update({
            'status': ContributionStatus.underReview.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    }
  }
  
  @override
  Future<List<CommunityContribution>> searchContributions(String query) async {
    if (query.isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    
    // Simple search - in production use Algolia or similar
    final snapshot = await _firestore
        .collection(_contributionsCollection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    
    final contributions = _mapSnapshotToContributions(snapshot);
    
    return contributions.where((c) =>
      c.title.toLowerCase().contains(queryLower) ||
      c.description.toLowerCase().contains(queryLower) ||
      c.exerciseName.toLowerCase().contains(queryLower)
    ).toList();
  }
  
  @override
  Future<UserContributionStats> calculateUserStats(String userId) async {
    final contributions = await _firestore
        .collection(_contributionsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    
    int approved = 0;
    int rejected = 0;
    int pending = 0;
    final contributionsByType = <String, int>{};
    
    for (final doc in contributions.docs) {
      final status = doc.data()['status'];
      if (status == ContributionStatus.approved.name) {
        approved++;
      } else if (status == ContributionStatus.rejected.name) rejected++;
      else if (status == ContributionStatus.pending.name) pending++;
      
      final type = doc.data()['type'] as String;
      contributionsByType[type] = (contributionsByType[type] ?? 0) + 1;
    }
    
    final total = contributions.docs.length;
    final approvalRate = total > 0 ? approved / total : 0.0;
    
    // Calculate points
    final points = (approved * ContributionPoints.contributionApproved) +
                  (pending * ContributionPoints.submitContribution);
    
    final level = ContributionPoints.getLevelFromPoints(points);
    
    return UserContributionStats(
      userId: userId,
      totalContributions: total,
      approvedContributions: approved,
      rejectedContributions: rejected,
      pendingContributions: pending,
      totalPoints: points,
      level: level,
      contributionsByType: contributionsByType,
      approvalRate: approvalRate,
    );
  }
  
  // Helper methods
  List<CommunityContribution> _mapSnapshotToContributions(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      // Convert Firestore timestamps
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updatedAt'] is Timestamp) {
        data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
      }
      if (data['reviewedAt'] is Timestamp) {
        data['reviewedAt'] = (data['reviewedAt'] as Timestamp).toDate().toIso8601String();
      }
      
      // Convert string enums back to enum values
      data['type'] = ContributionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ContributionType.tip,
      );
      data['status'] = ContributionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ContributionStatus.pending,
      );
      
      // Ensure lists are properly typed
      data['upvotedBy'] = List<String>.from(data['upvotedBy'] ?? []);
      data['downvotedBy'] = List<String>.from(data['downvotedBy'] ?? []);
      data['comments'] = (data['comments'] as List<dynamic>?)
          ?.map((c) => ContributionComment.fromJson(c as Map<String, dynamic>))
          .toList() ?? [];
      
      return CommunityContribution.fromJson(data);
    }).toList();
  }
  
  Future<void> _updateUserStats(String userId, String action) async {
    final statsRef = _firestore.collection(_userStatsCollection).doc(userId);
    
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
    
    // print('🏆 Adding $pointsToAdd XP to user $userId for action: $action');
    
    // Aggiorna stats con XP e livello
    final currentStats = await statsRef.get();
    final currentPoints = (currentStats.data()?['totalPoints'] ?? 0) as int;
    final newTotalPoints = currentPoints + pointsToAdd;
    final newLevel = ContributionPoints.getLevelFromPoints(newTotalPoints);
    
    await statsRef.set({
      'userId': userId,
      'totalPoints': FieldValue.increment(pointsToAdd),
      'level': newLevel,
      'lastActivity': FieldValue.serverTimestamp(),
      'totalContributions': action == 'submit' ? FieldValue.increment(1) : null,
      'approvedContributions': action == 'approved' ? FieldValue.increment(1) : null,
    }, SetOptions(merge: true));
    
    // print('✅ User stats updated: +$pointsToAdd XP, Level: $newLevel');
  }

  @override
  Future<void> approveContribution(String contributionId, String adminId) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Contribution not found');
      }

      final data = snapshot.data()!;
      final contributorUserId = data['userId'] as String;

      // Update contribution status
      transaction.update(docRef, {
        'status': ContributionStatus.approved.name,
        'reviewedBy': adminId,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // Award XP to contributor (+50 XP for approved contribution)
    final contribution = await docRef.get();
    if (contribution.exists) {
      final userId = contribution.data()!['userId'] as String;
      await _updateUserStats(userId, 'approved');
    }
  }

  @override
  Future<void> rejectContribution(String contributionId, String adminId, String reason) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);

    await docRef.update({
      'status': ContributionStatus.rejected.name,
      'reviewedBy': adminId,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewNote': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // No XP awarded for rejected contributions
  }
}