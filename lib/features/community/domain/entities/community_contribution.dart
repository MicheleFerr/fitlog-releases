import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_contribution.freezed.dart';
part 'community_contribution.g.dart';

enum ContributionType {
  correction,   // Correzione di info errate
  tip,         // Suggerimento/consiglio
  warning,     // Avviso sicurezza
  variant,     // Variante esercizio
  translation, // Traduzione
  technique,   // Correzione tecnica
}

enum ContributionStatus {
  pending,     // In attesa di review
  approved,    // Approvato dalla community
  rejected,    // Rifiutato
  underReview, // In fase di review (3+ votes)
}

@freezed
class CommunityContribution with _$CommunityContribution {
  const factory CommunityContribution({
    required String id,
    required String exerciseId,
    required String exerciseName,
    required String userId,
    required String userName,
    String? userAvatar,
    required ContributionType type,
    required ContributionStatus status,
    required String title,
    required String description,
    String? originalValue,
    String? suggestedValue,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    @Default([]) List<String> upvotedBy,
    @Default([]) List<String> downvotedBy,
    @Default([]) List<ContributionComment> comments,
    String? reviewNote,
    String? reviewedBy,
    DateTime? reviewedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isFeatured,
    @Default(0) int trustScore, // 0-100 basato su track record utente
    Map<String, dynamic>? metadata,
  }) = _CommunityContribution;

  factory CommunityContribution.fromJson(Map<String, dynamic> json) =>
      _$CommunityContributionFromJson(json);
}

@freezed
class ContributionComment with _$ContributionComment {
  const factory ContributionComment({
    required String id,
    required String userId,
    required String userName,
    String? userAvatar,
    required String text,
    required DateTime createdAt,
    @Default(0) int likes,
    @Default([]) List<String> likedBy,
  }) = _ContributionComment;

  factory ContributionComment.fromJson(Map<String, dynamic> json) =>
      _$ContributionCommentFromJson(json);
}

@freezed
class UserContributionStats with _$UserContributionStats {
  const factory UserContributionStats({
    required String userId,
    @Default(0) int totalContributions,
    @Default(0) int approvedContributions,
    @Default(0) int rejectedContributions,
    @Default(0) int pendingContributions,
    @Default(0) int totalVotes,
    @Default(0) int totalPoints,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default('Rookie') String level,
    @Default([]) List<ContributorBadge> badges,
    DateTime? lastContributionDate,
    @Default({}) Map<String, int> contributionsByType,
    @Default(0.0) double approvalRate,
    @Default(0) int weeklyRank,
    @Default(0) int monthlyRank,
    @Default(0) int allTimeRank,
  }) = _UserContributionStats;

  factory UserContributionStats.fromJson(Map<String, dynamic> json) =>
      _$UserContributionStatsFromJson(json);
}

@freezed
class ContributorBadge with _$ContributorBadge {
  const factory ContributorBadge({
    required String id,
    required String name,
    required String description,
    required String icon,
    required DateTime earnedAt,
    @Default(false) bool isRare,
    String? category,
  }) = _ContributorBadge;

  factory ContributorBadge.fromJson(Map<String, dynamic> json) =>
      _$ContributorBadgeFromJson(json);
}

// Helper class per calcolare punti
class ContributionPoints {
  static const int submitContribution = 10;
  static const int contributionApproved = 50;
  static const int contributionFeatured = 100;
  static const int voteOnContribution = 5;
  static const int commentOnContribution = 3;
  static const int dailyStreak = 20;
  static const int weeklyBonus = 100;
  
  static String getLevelFromPoints(int points) {
    if (points < 100) return 'Rookie';
    if (points < 500) return 'Contributor';
    if (points < 1000) return 'Expert';
    if (points < 5000) return 'Master';
    if (points < 10000) return 'Legend';
    return 'Mythic';
  }
  
  static String getLevelIcon(String level) {
    switch (level) {
      case 'Rookie': return '🌱';
      case 'Contributor': return '⭐';
      case 'Expert': return '💪';
      case 'Master': return '🏆';
      case 'Legend': return '👑';
      case 'Mythic': return '💎';
      default: return '🌱';
    }
  }
}