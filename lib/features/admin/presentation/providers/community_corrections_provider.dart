/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/providers
/// 🎯 Feature: admin
/// 🔧 Type: provider
///
/// Provider per gestire i contributi della community per admin
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/auth/admin_role_helper.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/community/data/repositories/community_repository.dart';
import 'package:gymbro_flutter_new/features/community/domain/entities/community_contribution.dart';

/// Provider per i contributi della community per admin
final communityCorrectionsProvider = AsyncNotifierProvider<CommunityCorrectionsNotifier, List<CommunityContribution>>(CommunityCorrectionsNotifier.new);

/// Notifier per gestire i contributi della community da admin
class CommunityCorrectionsNotifier extends AsyncNotifier<List<CommunityContribution>> {
  @override
  Future<List<CommunityContribution>> build() async {
    final contributions = await _loadCorrections();
    return contributions;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Carica tutti i contributi della community
  Future<List<CommunityContribution>> _loadCorrections() async {
    try {
      if (kDebugMode) {
        debugPrint('🔍 Loading community contributions...');
      }

      final querySnapshot = await _firestore
          .collection('community_contributions')
          .limit(50)
          .get();

      if (kDebugMode) {
        debugPrint('📊 Found ${querySnapshot.docs.length} contributions in Firestore');
      }

      final contributions = querySnapshot.docs.map((doc) {
        if (kDebugMode) {
          debugPrint('📝 Processing contribution: ${doc.id} - ${doc.data()}');
        }
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
        if (kDebugMode) {
          debugPrint('🧪 No contributions found, adding test data');
        }
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

      if (kDebugMode) {
        debugPrint('✅ Successfully loaded ${contributions.length} contributions');
      }
      return contributions;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error loading community contributions: $e');
      }
      debugPrint('🔍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Ricarica i contributi
  Future<void> refreshCorrections() async {
    final contributions = await _loadCorrections();
    state = AsyncValue.data(contributions);
  }

  /// Approva una correzione
  Future<void> approveCorrection(String correctionId) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      // ========================================
      // 🔐 SECURITY: Check admin via custom claims (secure)
      // ========================================
      // REPLACED: user.email != 'ferrara-michele@hotmail.it' (insecure)
      // NEW: Uses Firebase Custom Claims (server-validated)
      final isAdmin = await AdminRoleHelper.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = ref.read(communityRepositoryProvider);
      await repository.approveContribution(correctionId, user.uid);

      // Ricarica le correzioni per aggiornare la UI
      final contributions = await _loadCorrections();
      state = AsyncValue.data(contributions);

      if (kDebugMode) {
        debugPrint('✅ Correction approved: $correctionId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error approving correction: $e');
      }
      rethrow;
    }
  }

  /// Rifiuta una correzione
  Future<void> rejectCorrection(String correctionId, String reason) async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not authenticated');

      // ========================================
      // 🔐 SECURITY: Check admin via custom claims (secure)
      // ========================================
      // REPLACED: user.email != 'ferrara-michele@hotmail.it' (insecure)
      // NEW: Uses Firebase Custom Claims (server-validated)
      final isAdmin = await AdminRoleHelper.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Unauthorized: Admin only');
      }

      final repository = ref.read(communityRepositoryProvider);
      await repository.rejectContribution(correctionId, user.uid, reason);

      // Ricarica le correzioni per aggiornare la UI
      final contributions = await _loadCorrections();
      state = AsyncValue.data(contributions);

      if (kDebugMode) {
        debugPrint('✅ Correction rejected: $correctionId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error rejecting correction: $e');
      }
      rethrow;
    }
  }
}

