import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/home/domain/entities/insight_feedback.dart';

/// Repository for managing user feedback on AI Coach insights
class InsightFeedbackRepository {

  InsightFeedbackRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'insight_feedback';

  /// Save or update feedback for an insight
  Future<void> saveFeedback(InsightFeedback feedback) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(feedback.id)
          .set(feedback.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save insight feedback: $e');
    }
  }

  /// Get feedback for a specific insight
  Future<InsightFeedback?> getFeedback(String feedbackId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(feedbackId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return InsightFeedback.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get insight feedback: $e');
    }
  }

  /// Get all feedback from a user
  Future<List<InsightFeedback>> getUserFeedback(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InsightFeedback.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user feedback: $e');
    }
  }

  /// Get feedback for a specific insight by hash
  /// This allows checking if user already gave feedback on this insight
  Future<InsightFeedback?> getFeedbackByHash({
    required String userId,
    required String insightHash,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('insightHash', isEqualTo: insightHash)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return InsightFeedback.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get feedback by hash: $e');
    }
  }

  /// Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(feedbackId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  /// Get feedback statistics for insight type (for analytics)
  Future<Map<String, dynamic>> getFeedbackStats(String insightType) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('insightType', isEqualTo: insightType)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'total': 0,
          'helpful': 0,
          'notHelpful': 0,
          'helpfulPercentage': 0.0,
        };
      }

      final total = snapshot.docs.length;
      final helpful = snapshot.docs
          .where((doc) => doc.data()['isHelpful'] as bool)
          .length;
      final notHelpful = total - helpful;
      final helpfulPercentage = (helpful / total) * 100;

      return {
        'total': total,
        'helpful': helpful,
        'notHelpful': notHelpful,
        'helpfulPercentage': helpfulPercentage,
      };
    } catch (e) {
      throw Exception('Failed to get feedback stats: $e');
    }
  }
}
