/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: data/repositories
 * 🎯 Feature: community
 * 🔧 Type: adapter
 * 🌍 Localization: N/A
 * 🎨 Theme: N/A
 * 📱 Platform: Universal
 * 
 * Adapter to bridge HybridCommunityRepository with existing interface
 */

import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/hybrid_community_repository.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';
import 'package:rxdart/rxdart.dart';

/// Adapter class to use HybridCommunityRepository with existing interface
class HybridCommunityRepositoryAdapter implements CommunityRepository {
  final HybridCommunityRepository _hybridRepository;
  
  HybridCommunityRepositoryAdapter() 
      : _hybridRepository = HybridCommunityRepository();

  @override
  Stream<List<CommunityContribution>> getContributions({
    String? exerciseId,
    ContributionStatus? status,
    String? userId,
  }) {
    return _hybridRepository.getContributions(
      exerciseId: exerciseId,
      status: status,
      userId: userId,
    );
  }

  @override
  Stream<List<CommunityContribution>> getTrendingContributions() {
    return _hybridRepository.getTrendingContributions();
  }

  @override
  Stream<List<CommunityContribution>> getContributionsForReview(String userId) {
    return _hybridRepository.getContributionsForReview();
  }

  @override
  Stream<UserContributionStats> getUserStats(String userId) {
    return _hybridRepository.getUserStats(userId);
  }

  @override
  Future<void> submitContribution(CommunityContribution contribution) async {
    await _hybridRepository.submitContribution(contribution);
  }

  @override
  Future<void> voteOnContribution(String contributionId, String userId, bool isUpvote) async {
    await _hybridRepository.voteOnContribution(contributionId, isUpvote);
  }

  @override
  Future<void> commentOnContribution(String contributionId, ContributionComment comment) async {
    await _hybridRepository.commentOnContribution(contributionId, comment);
  }

  @override
  Future<void> reportContribution(String contributionId, String userId, String reason) async {
    await _hybridRepository.reportContribution(contributionId, reason);
  }

  @override
  Future<List<CommunityContribution>> searchContributions(String query) async {
    return await _hybridRepository.searchContributions(query);
  }

  @override
  Future<UserContributionStats> calculateUserStats(String userId) async {
    return await _hybridRepository.getUserStats(userId).first;
  }
}