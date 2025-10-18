/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Provider per gestire i contributi della community per admin
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';

/// Provider per i contributi della community per admin
final communityCorrectionsProvider = StateNotifierProvider<CommunityCorrectionsNotifier, AsyncValue<List<CommunityContribution>>>((ref) {
  return CommunityCorrectionsNotifier(ref);
});

/// Notifier per gestire i contributi della community da admin
class CommunityCorrectionsNotifier extends StateNotifier<AsyncValue<List<CommunityContribution>>> {

  CommunityCorrectionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadCorrections();
  }
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Carica tutti i contributi della community
  Future<void> _loadCorrections() async {
    try {
      state = const AsyncValue.loading();
      debugPrint('🔍 Loading community contributions...');

      final querySnapshot = await _firestore
          .collection('community_contributions')
          .limit(50)
          .get();

      debugPrint('📊 Found ${querySnapshot.docs.length} contributions in Firestore');

      final contributions = querySnapshot.docs.map((doc) {
        debugPrint('📝 Processing contribution: ${doc.id} - ${doc.data()}');
        final data = doc.data();
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
        if (data['type'] is String) {
          data['type'] = ContributionType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => ContributionType.tip,
          );
        }
        if (data['status'] is String) {
          data['status'] = ContributionStatus.values.firstWhere(
            (e) => e.name == data['status'],
            orElse: () => ContributionStatus.pending,
          );
        }

        // Ensure lists are properly typed
        data['upvotedBy'] = List<String>.from(data['upvotedBy'] ?? []);
        data['downvotedBy'] = List<String>.from(data['downvotedBy'] ?? []);
        data['comments'] = [];

        return CommunityContribution.fromJson(data);
      }).toList();

      // TEMPORARY: Add test data if no contributions exist
      if (contributions.isEmpty) {
        debugPrint('🧪 No contributions found, adding test data');
        final testContribution = CommunityContribution(
          id: 'test-123',
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          userId: 'test-user',
          userName: 'Test User',
          type: ContributionType.tip,
          status: ContributionStatus.pending,
          title: 'Miglior presa per principianti',
          description: 'Per i principianti, consiglio di mantenere una presa leggermente più larga delle spalle e concentrarsi sulla tecnica prima di aumentare il peso.',
          createdAt: DateTime.now(),
          upvotes: 0,
          downvotes: 0,
          upvotedBy: [],
          downvotedBy: [],
          comments: [],
        );
        contributions.add(testContribution);
      }

      debugPrint('✅ Successfully loaded ${contributions.length} contributions');
      state = AsyncValue.data(contributions);
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading community contributions: $e');
      debugPrint('🔍 Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Ricarica i contributi
  Future<void> refreshCorrections() async {
    await _loadCorrections();
  }

  /// Approva una correzione
  Future<void> approveCorrection(String correctionId) async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      // Verifica che l'utente sia admin
      if (user.email != 'ferrara-michele@hotmail.it') {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = _ref.read(communityRepositoryProvider);
      await repository.approveContribution(correctionId, user.uid);

      // Ricarica le correzioni per aggiornare la UI
      await _loadCorrections();

      debugPrint('✅ Correction approved: $correctionId');
    } catch (e) {
      debugPrint('❌ Error approving correction: $e');
      rethrow;
    }
  }

  /// Rifiuta una correzione
  Future<void> rejectCorrection(String correctionId, String reason) async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      // Verifica che l'utente sia admin
      if (user.email != 'ferrara-michele@hotmail.it') {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = _ref.read(communityRepositoryProvider);
      await repository.rejectContribution(correctionId, user.uid, reason);

      // Ricarica le correzioni per aggiornare la UI
      await _loadCorrections();

      debugPrint('✅ Correction rejected: $correctionId');
    } catch (e) {
      debugPrint('❌ Error rejecting correction: $e');
      rethrow;
    }
  }
}

