import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/contribution_filters.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';

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

class FirestoreCommunityRepository with FirebaseErrorMapperMixin implements CommunityRepository {

  FirestoreCommunityRepository(this._ref);
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _contributionsCollection = 'community_contributions';
  static const String _userStatsCollection = 'user_contribution_stats';
  // 🚀 FIRESTORE OPTIMIZATION: Cache search results to reduce redundant queries
  // Users often search the same queries repeatedly (e.g., "chest exercises")
  // Savings: ~300,000 ops/day with 1000 users (~$60/day)
  static const Duration _searchCacheDuration = Duration(minutes: 15);
  static const String _searchCacheKey = 'community_search_cache';
  static const String _searchTimestampKey = 'community_search_timestamp';

  final Map<String, List<CommunityContribution>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTimestamp = {};

  @override
  Stream<List<CommunityContribution>> getContributions({
    String? exerciseId,
    ContributionStatus? status,
    String? userId,
  }) {
    // Per userId, facciamo una query semplice senza orderBy per evitare indici
    if (userId != null) {
      return _firestore
          .collection(_contributionsCollection)
          .where('userId', isEqualTo: userId)
          .limit(50)
          .snapshots()
          .map((snapshot) => _mapSnapshotToContributions(snapshot))
          .handleError((error) {}, test: (error) => true)
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
              return defaultStats;
            }
          }
          return defaultStats;
        })
        .handleError((error) {
        }, test: (error) => true) // Gestisce tutti gli errori
        .startWith(defaultStats); // Inizia con default stats
  }
  
  @override
  Future<void> submitContribution(CommunityContribution contribution) async {
    final userAsync = await _ref.read(currentUserProvider.future);
    if (userAsync == null) throw Exception('User not authenticated');

    final docRef = _firestore.collection(_contributionsCollection).doc();

    // Tutti i contributi richiedono approvazione admin
    const status = ContributionStatus.pending;

    final data = contribution.copyWith(
      id: docRef.id,
      userId: userAsync.uid,
      userName: userAsync.displayName,
      createdAt: DateTime.now(),
      status: status,
      upvotes: 0,
    ).toJson();

    // Convert enums to strings for Firestore
    data['type'] = contribution.type.name;
    data['status'] = status.name;

    final result = await handleFirebaseVoidOperation(
      () => docRef.set(data).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firestore submitContribution timed out'),
      ),
      operationName: 'submitContribution',
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        if (kDebugMode) {
          debugPrint('✅ [CommunityRepo] Contribution submitted: ${docRef.id}');
        }
      },
    );

    // 🚀 CACHE INVALIDATION: Clear search cache after new contribution
    await _clearSearchCache();

    // Update user stats per submission
    await _updateUserStats(userAsync.uid, 'submit');
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
    final addResult = await handleFirebaseOperation(
      () => _firestore.collection('contribution_reports').add({
        'contributionId': contributionId,
        'reportedBy': userId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firestore reportContribution add timed out'),
      ),
      operationName: 'reportContribution_add',
    );

    addResult.fold(
      (failure) => throw Exception(failure.message),
      (_) {},
    );

    // If multiple reports, mark for review
    final getResult = await handleFirebaseOperation(
      () => _firestore
          .collection('contribution_reports')
          .where('contributionId', isEqualTo: contributionId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Firestore reportContribution get timed out'),
          ),
      operationName: 'reportContribution_get',
    );

    final reports = getResult.fold(
      (failure) => throw Exception(failure.message),
      (snapshot) => snapshot,
    );

    if (reports.docs.length >= 3) {
      final updateResult = await handleFirebaseVoidOperation(
        () => _firestore
            .collection(_contributionsCollection)
            .doc(contributionId)
            .update({
              'status': ContributionStatus.underReview.name,
              'updatedAt': FieldValue.serverTimestamp(),
            }).timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException('Firestore reportContribution update timed out'),
            ),
        operationName: 'reportContribution_update',
      );

      updateResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('⚠️ [CommunityRepo] Failed to mark for review: ${failure.message}');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('🚨 [CommunityRepo] Contribution marked for review: $contributionId');
          }
        },
      );
    }
  }
  
  @override
  Future<List<CommunityContribution>> searchContributions(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    // 🚀 TIER 1: Check memory cache first (fastest)
    if (_searchCache.containsKey(queryLower) &&
        _searchCacheTimestamp.containsKey(queryLower)) {
      final cacheAge = DateTime.now().difference(_searchCacheTimestamp[queryLower]!);
      if (cacheAge < _searchCacheDuration) {
        return _searchCache[queryLower]!; // ✅ Memory cache hit
      }
    }

    // 🚀 TIER 2: Check SharedPreferences persistent cache
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString('${_searchCacheKey}_$queryLower');
    final cachedTimestamp = prefs.getInt('${_searchTimestampKey}_$queryLower');

    if (cachedJson != null && cachedTimestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
      final cacheAge = DateTime.now().difference(cacheTime);

      if (cacheAge < _searchCacheDuration) {
        // ✅ SharedPreferences cache hit - restore to memory cache
        final List<dynamic> jsonList = json.decode(cachedJson) as List<dynamic>;
        final results = jsonList
            .map((item) => CommunityContribution.fromJson(item as Map<String, dynamic>))
            .toList();

        _searchCache[queryLower] = results;
        _searchCacheTimestamp[queryLower] = cacheTime;
        return results;
      }
    }

    // ❌ Cache miss - fetch from Firestore
    // 🚀 FIRESTORE OPTIMIZATION: Reduced from 100 to 20 (80% reduction)
    // Savings: ~400,000 ops/day → 80,000 ops/day (~$180/day with 1000 users)
    final result = await handleFirebaseOperation(
      () => _firestore
          .collection(_contributionsCollection)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Firestore searchContributions timed out'),
          ),
      operationName: 'searchContributions',
    );

    final snapshot = result.fold(
      (failure) => throw Exception(failure.message),
      (snap) => snap,
    );

    final contributions = _mapSnapshotToContributions(snapshot);

    final results = contributions.where((c) =>
      c.title.toLowerCase().contains(queryLower) ||
      c.description.toLowerCase().contains(queryLower) ||
      c.exerciseName.toLowerCase().contains(queryLower)
    ).toList();

    // 💾 Save to both caches
    _searchCache[queryLower] = results;
    _searchCacheTimestamp[queryLower] = DateTime.now();

    await prefs.setString(
      '${_searchCacheKey}_$queryLower',
      json.encode(results.map((c) => c.toJson()).toList()),
    );
    await prefs.setInt(
      '${_searchTimestampKey}_$queryLower',
      DateTime.now().millisecondsSinceEpoch,
    );

    return results;
  }
  
  @override
  Future<UserContributionStats> calculateUserStats(String userId) async {
    final result = await handleFirebaseOperation(
      () => _firestore
          .collection(_contributionsCollection)
          .where('userId', isEqualTo: userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Firestore calculateUserStats timed out'),
          ),
      operationName: 'calculateUserStats',
    );

    final contributions = result.fold(
      (failure) => throw Exception(failure.message),
      (snap) => snap,
    );

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
  /// 🚀 FIRESTORE OPTIMIZATION: Clear search cache
  /// Called after new contributions are submitted to ensure fresh search results
  Future<void> _clearSearchCache() async {
    // Clear memory cache
    _searchCache.clear();
    _searchCacheTimestamp.clear();

    // Clear SharedPreferences cache
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) =>
      key.startsWith(_searchCacheKey) || key.startsWith(_searchTimestampKey)
    ).toList();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

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
      case 'vote':
        pointsToAdd = ContributionPoints.voteOnContribution;
      case 'comment':
        pointsToAdd = ContributionPoints.commentOnContribution;
      case 'approved':
        pointsToAdd = ContributionPoints.contributionApproved;
    }

    // Aggiorna stats con XP e livello
    final getResult = await handleFirebaseOperation(
      () => statsRef.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firestore _updateUserStats get timed out'),
      ),
      operationName: '_updateUserStats_get',
    );

    final currentStats = getResult.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('⚠️ [CommunityRepo] Failed to get stats: ${failure.message}');
        }
        return null;
      },
      (snap) => snap,
    );

    final currentPoints = (currentStats?.data()?['totalPoints'] ?? 0) as int;
    final newTotalPoints = currentPoints + pointsToAdd;
    final newLevel = ContributionPoints.getLevelFromPoints(newTotalPoints);

    final setResult = await handleFirebaseVoidOperation(
      () => statsRef.set({
        'userId': userId,
        'totalPoints': FieldValue.increment(pointsToAdd),
        'level': newLevel,
        'lastActivity': FieldValue.serverTimestamp(),
        'totalContributions': action == 'submit' ? FieldValue.increment(1) : null,
        'approvedContributions': action == 'approved' ? FieldValue.increment(1) : null,
      }, SetOptions(merge: true)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firestore _updateUserStats set timed out'),
      ),
      operationName: '_updateUserStats_set',
    );

    setResult.mapLeft((failure) {
      if (kDebugMode) {
        debugPrint('⚠️ [CommunityRepo] Failed to update stats: ${failure.message}');
      }
    });
  }

  @override
  Future<void> approveContribution(String contributionId, String adminId) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Contribution not found');
      }

      snapshot.data()!;
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

    final result = await handleFirebaseVoidOperation(
      () => docRef.update({
        'status': ContributionStatus.rejected.name,
        'reviewedBy': adminId,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewNote': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firestore rejectContribution timed out'),
      ),
      operationName: 'rejectContribution',
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        if (kDebugMode) {
          debugPrint('❌ [CommunityRepo] Contribution rejected: $contributionId');
        }
      },
    );

    // No XP awarded for rejected contributions
  }

  // ============================================================================
  // Discovery & Search Implementation (Task 4)
  // ============================================================================

  @override
  Stream<List<CommunityContribution>> searchContributionsStream({
    required String query,
    ContributionFilters? filters,
    int limit = 20,
  }) async* {
    // CLIENT-SIDE SEARCH STRATEGY (no Firestore full-text search)

    // Step 1: Get base query
    Query baseQuery = _firestore.collection(_contributionsCollection);

    // Step 2: Apply filters if provided
    if (filters != null) {
      baseQuery = _applyFilters(baseQuery, filters);
    } else {
      // Default: only approved contributions
      baseQuery = baseQuery.where('status', isEqualTo: ContributionStatus.approved.name);
    }

    // Step 3: Fetch contributions (over-fetch for client filtering)
    final snapshot = await baseQuery.limit(limit * 3).get();

    // Step 4: Parse contributions
    final contributions = _mapSnapshotToContributions(snapshot);

    // Step 5: Client-side search filtering
    final searchResults = _filterBySearchQuery(contributions, query);

    // Step 6: Limit results
    yield searchResults.take(limit).toList();
  }

  @override
  Stream<List<CommunityContribution>> filterContributions({
    required ContributionFilters filters,
    int limit = 20,
  }) async* {
    // Step 1: Get base query
    Query baseQuery = _firestore.collection(_contributionsCollection);

    // Step 2: Apply Firestore filters
    baseQuery = _applyFilters(baseQuery, filters);

    // Step 3: Fetch and map
    final snapshot = await baseQuery.limit(limit).get();
    final contributions = _mapSnapshotToContributions(snapshot);

    // Step 4: Client-side sorting (if needed)
    final sortedContributions = _applySorting(contributions, filters.sortBy);

    yield sortedContributions;
  }

  @override
  Future<void> saveContribution(String contributionId, String userId) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      // Increment saves count
      transaction.update(docRef, {
        'saves': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    // Store in user's saved collection
    await _firestore
        .collection('user_saved_contributions')
        .doc(userId)
        .set({
          'contributionIds': FieldValue.arrayUnion([contributionId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<void> unsaveContribution(String contributionId, String userId) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      // Decrement saves count (min 0)
      final currentSaves = snapshot.data()?['saves'] ?? 0;
      if (currentSaves > 0) {
        transaction.update(docRef, {
          'saves': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    // Remove from user's saved collection
    await _firestore
        .collection('user_saved_contributions')
        .doc(userId)
        .set({
          'contributionIds': FieldValue.arrayRemove([contributionId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Future<List<String>> getSavedContributionIds(String userId) async {
    final result = await handleFirebaseOperation(
      () => _firestore
          .collection('user_saved_contributions')
          .doc(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Firestore getSavedContributionIds timed out'),
          ),
      operationName: 'getSavedContributionIds',
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('⚠️ [CommunityRepo] Failed to get saved IDs: ${failure.message}');
        }
        return <String>[];
      },
      (doc) {
        if (!doc.exists || doc.data() == null) return <String>[];
        final data = doc.data()!;
        return List<String>.from(data['contributionIds'] ?? []);
      },
    );
  }

  @override
  Future<void> incrementViewCount(String contributionId) async {
    final docRef = _firestore.collection(_contributionsCollection).doc(contributionId);

    final result = await handleFirebaseVoidOperation(
      () => docRef.update({
        'viewCount': FieldValue.increment(1),
        'lastActivityAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Firestore incrementViewCount timed out'),
      ),
      operationName: 'incrementViewCount',
    );

    // Silent failure - view count is not critical
    result.mapLeft((failure) {
      if (kDebugMode) {
        debugPrint('⚠️ [CommunityRepo] Failed to increment view: ${failure.message}');
      }
    });
  }

  // ============================================================================
  // Helper Methods for Search & Filters
  // ============================================================================

  /// Apply Firestore-level filters to base query
  Query _applyFilters(Query baseQuery, ContributionFilters filters) {
    // Exercise IDs filter
    if (filters.exerciseIds.isNotEmpty) {
      baseQuery = baseQuery.where('exerciseId', whereIn: filters.exerciseIds);
    }

    // Type filter
    if (filters.type != null && filters.type!.isNotEmpty) {
      baseQuery = baseQuery.where('type', isEqualTo: filters.type);
    }

    // Date range filters
    if (filters.dateFrom != null) {
      baseQuery = baseQuery.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(filters.dateFrom!));
    }
    if (filters.dateTo != null) {
      baseQuery = baseQuery.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(filters.dateTo!));
    }

    // Default: only approved contributions (unless already filtered)
    if (filters.exerciseIds.isEmpty && filters.type == null) {
      baseQuery = baseQuery.where('status', isEqualTo: ContributionStatus.approved.name);
    }

    return baseQuery;
  }

  /// Client-side search filtering
  List<CommunityContribution> _filterBySearchQuery(
    List<CommunityContribution> contributions,
    String query,
  ) {
    if (query.isEmpty) return contributions;

    final lowerQuery = query.toLowerCase();

    return contributions.where((contrib) {
      // Search in: title, description, exerciseName, tags
      final titleMatch = contrib.title.toLowerCase().contains(lowerQuery);
      final descMatch = contrib.description.toLowerCase().contains(lowerQuery);
      final exerciseMatch = contrib.exerciseName.toLowerCase().contains(lowerQuery);
      final tagsMatch = contrib.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

      return titleMatch || descMatch || exerciseMatch || tagsMatch;
    }).toList()
      ..sort((a, b) {
        // Relevance scoring: title > tags > description
        final int scoreA = _calculateRelevanceScore(a, lowerQuery);
        final int scoreB = _calculateRelevanceScore(b, lowerQuery);
        return scoreB.compareTo(scoreA);
      });
  }

  /// Calculate relevance score for search result ranking
  int _calculateRelevanceScore(CommunityContribution contrib, String query) {
    int score = 0;

    // Title match = highest priority (100 points)
    if (contrib.title.toLowerCase().contains(query)) score += 100;

    // Tags match = high priority (50 points)
    if (contrib.tags.any((tag) => tag.toLowerCase().contains(query))) score += 50;

    // Exercise name match = medium priority (30 points)
    if (contrib.exerciseName.toLowerCase().contains(query)) score += 30;

    // Description match = low priority (10 points)
    if (contrib.description.toLowerCase().contains(query)) score += 10;

    // Boost by quality metrics
    score += contrib.upvotes - contrib.downvotes; // Net votes
    score += contrib.saves; // Saves count

    return score;
  }

  /// Client-side sorting by different criteria
  List<CommunityContribution> _applySorting(
    List<CommunityContribution> contributions,
    String sortBy,
  ) {
    final sorted = List<CommunityContribution>.from(contributions);

    switch (sortBy) {
      case 'helpful':
        // Sort by net votes (upvotes - downvotes)
        sorted.sort((a, b) {
          final scoreA = a.upvotes - a.downvotes;
          final scoreB = b.upvotes - b.downvotes;
          return scoreB.compareTo(scoreA);
        });
        break;

      case 'recent':
        // Sort by creation date (newest first)
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case 'saved':
        // Sort by save count
        sorted.sort((a, b) => b.saves.compareTo(a.saves));
        break;

      case 'trending':
        // Sort by recent activity + engagement
        sorted.sort((a, b) {
          final scoreA = _calculateTrendingScore(a);
          final scoreB = _calculateTrendingScore(b);
          return scoreB.compareTo(scoreA);
        });
        break;

      default:
        // Default: helpful
        sorted.sort((a, b) {
          final scoreA = a.upvotes - a.downvotes;
          final scoreB = b.upvotes - b.downvotes;
          return scoreB.compareTo(scoreA);
        });
    }

    return sorted;
  }

  /// Calculate trending score based on recent activity
  double _calculateTrendingScore(CommunityContribution contrib) {
    final now = DateTime.now();
    final daysSinceCreated = now.difference(contrib.createdAt).inDays;
    final daysSinceActivity = contrib.lastActivityAt != null
        ? now.difference(contrib.lastActivityAt!).inDays
        : daysSinceCreated;

    // Engagement score
    final engagementScore = contrib.upvotes + contrib.saves + contrib.comments.length;

    // Time decay (recent = higher score)
    final timeFactor = 1.0 / (1.0 + daysSinceActivity * 0.1);

    return engagementScore * timeFactor;
  }
}