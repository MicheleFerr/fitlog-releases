/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: domain
/// 🎯 Feature: buddy_matching
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
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddy_match.freezed.dart';
part 'buddy_match.g.dart';

/// Status of a buddy match
enum MatchStatus {
  pending,      // One user liked, waiting for response
  confirmed,    // Both users liked, match confirmed
  partnership,  // Active workout partnership
  completed,    // Partnership ended successfully
  expired,      // Match expired without confirmation
  cancelled;    // Match cancelled by user

  String get displayName {
    switch (this) {
      case MatchStatus.pending:
        return 'In attesa';
      case MatchStatus.confirmed:
        return 'Confermato';
      case MatchStatus.partnership:
        return 'Partnership attiva';
      case MatchStatus.completed:
        return 'Completato';
      case MatchStatus.expired:
        return 'Scaduto';
      case MatchStatus.cancelled:
        return 'Cancellato';
    }
  }
}

@freezed
class BuddyMatch with _$BuddyMatch {
  const factory BuddyMatch({
    required String id,
    required String user1Id,
    required String user2Id,
    required MatchStatus status,
    required double compatibilityScore,
    String? initiatorId, // Who liked first
    DateTime? user1LikedAt,
    DateTime? user2LikedAt,
    DateTime? confirmedAt,
    DateTime? partnershipStartedAt,
    DateTime? partnershipEndedAt,
    DateTime? expiresAt,
    // Partnership data
    @Default(0) int sharedWorkouts,
    @Default(0) int plannedWorkouts,
    @Default(0) int completedWorkouts,
    // Communication
    String? lastMessageId,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount1, // User1's unread messages
    @Default(0) int unreadCount2, // User2's unread messages
    // Ratings (after partnership ends)
    int? user1Rating, // 1-5 stars
    int? user2Rating,
    String? user1Feedback,
    String? user2Feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BuddyMatch;

  /// Create a new match when first user likes second user
  factory BuddyMatch.create({
    required String user1Id,
    required String user2Id,
    required double compatibilityScore,
    required String initiatorId,
  }) {
    final now = DateTime.now();
    final isUser1Initiator = initiatorId == user1Id;
    
    return BuddyMatch(
      id: '', // Will be set by repository
      user1Id: user1Id,
      user2Id: user2Id,
      status: MatchStatus.pending,
      compatibilityScore: compatibilityScore,
      initiatorId: initiatorId,
      user1LikedAt: isUser1Initiator ? now : null,
      user2LikedAt: !isUser1Initiator ? now : null,
      expiresAt: now.add(const Duration(days: 7)), // Match expires in 7 days
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Firestore document
  factory BuddyMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BuddyMatch(
      id: doc.id,
      user1Id: data['user1Id'],
      user2Id: data['user2Id'],
      status: MatchStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => MatchStatus.pending,
      ),
      compatibilityScore: (data['compatibilityScore'] ?? 0.0).toDouble(),
      initiatorId: data['initiatorId'] as String?,
      user1LikedAt: data['user1LikedAt'] != null
          ? (data['user1LikedAt'] as Timestamp).toDate()
          : null,
      user2LikedAt: data['user2LikedAt'] != null
          ? (data['user2LikedAt'] as Timestamp).toDate()
          : null,
      confirmedAt: data['confirmedAt'] != null
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
      partnershipStartedAt: data['partnershipStartedAt'] != null
          ? (data['partnershipStartedAt'] as Timestamp).toDate()
          : null,
      partnershipEndedAt: data['partnershipEndedAt'] != null
          ? (data['partnershipEndedAt'] as Timestamp).toDate()
          : null,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      sharedWorkouts: data['sharedWorkouts'] ?? 0,
      plannedWorkouts: data['plannedWorkouts'] ?? 0,
      completedWorkouts: data['completedWorkouts'] ?? 0,
      lastMessageId: data['lastMessageId'] as String?,
      lastMessageAt: data['lastMessageAt'] != null
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : null,
      unreadCount1: data['unreadCount1'] ?? 0,
      unreadCount2: data['unreadCount2'] ?? 0,
      user1Rating: data['user1Rating'] as int?,
      user2Rating: data['user2Rating'] as int?,
      user1Feedback: data['user1Feedback'] as String?,
      user2Feedback: data['user2Feedback'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  const BuddyMatch._(); // Private constructor for adding methods

  factory BuddyMatch.fromJson(Map<String, dynamic> json) =>
      _$BuddyMatchFromJson(json);

  /// Check if this is a mutual match (both users liked each other)
  bool get isMutualMatch => user1LikedAt != null && user2LikedAt != null;
}

extension BuddyMatchX on BuddyMatch {
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'status': status.name,
      'compatibilityScore': compatibilityScore,
      'initiatorId': initiatorId,
      'user1LikedAt': user1LikedAt != null ? Timestamp.fromDate(user1LikedAt!) : null,
      'user2LikedAt': user2LikedAt != null ? Timestamp.fromDate(user2LikedAt!) : null,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'partnershipStartedAt': partnershipStartedAt != null ? Timestamp.fromDate(partnershipStartedAt!) : null,
      'partnershipEndedAt': partnershipEndedAt != null ? Timestamp.fromDate(partnershipEndedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'sharedWorkouts': sharedWorkouts,
      'plannedWorkouts': plannedWorkouts,
      'completedWorkouts': completedWorkouts,
      'lastMessageId': lastMessageId,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'unreadCount1': unreadCount1,
      'unreadCount2': unreadCount2,
      'user1Rating': user1Rating,
      'user2Rating': user2Rating,
      'user1Feedback': user1Feedback,
      'user2Feedback': user2Feedback,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Get the other user's ID
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  /// Check if current user has liked
  bool hasUserLiked(String userId) {
    if (userId == user1Id) return user1LikedAt != null;
    if (userId == user2Id) return user2LikedAt != null;
    return false;
  }

  /// Check if both users have liked (mutual match)
  bool get isMutualMatch => user1LikedAt != null && user2LikedAt != null;

  /// Check if match has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!) && status == MatchStatus.pending;
  }

  /// Get unread count for specific user
  int getUnreadCount(String userId) {
    if (userId == user1Id) return unreadCount1;
    if (userId == user2Id) return unreadCount2;
    return 0;
  }

  /// Check if user can start partnership
  bool canStartPartnership(String userId) {
    return status == MatchStatus.confirmed && 
           (userId == user1Id || userId == user2Id);
  }

  /// Check if partnership is active
  bool get isActivePartnership => status == MatchStatus.partnership;

  /// Get partnership duration in days
  int? get partnershipDurationDays {
    if (partnershipStartedAt == null) return null;
    final endDate = partnershipEndedAt ?? DateTime.now();
    return endDate.difference(partnershipStartedAt!).inDays;
  }

  /// Get workout completion rate for partnership
  double get workoutCompletionRate {
    if (plannedWorkouts == 0) return 0.0;
    return completedWorkouts / plannedWorkouts;
  }

  /// Get average rating (when both users have rated)
  double? get averageRating {
    if (user1Rating == null || user2Rating == null) return null;
    return (user1Rating! + user2Rating!) / 2.0;
  }

  /// Check if partnership was successful (good ratings and completion)
  bool get wasSuccessfulPartnership {
    final avgRating = averageRating;
    return status == MatchStatus.completed &&
           avgRating != null && 
           avgRating >= 4.0 &&
           workoutCompletionRate >= 0.7;
  }

  /// Get time until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null || isExpired) return null;
    return expiresAt!.difference(DateTime.now());
  }

  /// Get status for display with additional context
  String getStatusDisplay({String? currentUserId}) {
    switch (status) {
      case MatchStatus.pending:
        if (currentUserId != null) {
          final hasCurrentUserLiked = hasUserLiked(currentUserId);
          final timeLeft = timeUntilExpiration;
          if (hasCurrentUserLiked) {
            return timeLeft != null 
                ? 'In attesa di risposta (${timeLeft.inDays}g rimasti)'
                : 'In attesa di risposta';
          } else {
            return timeLeft != null 
                ? 'Vuole fare workout con te! (${timeLeft.inDays}g per rispondere)'
                : 'Vuole fare workout con te!';
          }
        }
        return status.displayName;
      case MatchStatus.confirmed:
        return 'Match confermato! Inizia una partnership';
      case MatchStatus.partnership:
        final duration = partnershipDurationDays;
        return duration != null 
            ? 'Partnership attiva da ${duration}g'
            : 'Partnership attiva';
      case MatchStatus.completed:
        final rating = averageRating;
        return rating != null 
            ? 'Completato (${rating.toStringAsFixed(1)}⭐)'
            : 'Completato';
      default:
        return status.displayName;
    }
  }
}