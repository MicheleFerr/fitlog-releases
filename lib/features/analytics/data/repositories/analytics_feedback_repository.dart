/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/repositories
/// 🎯 Feature: analytics_feedback
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ANALYTICS FEEDBACK REPOSITORY
///
/// Repository per gestire feedback utente sulla schermata Analytics.
/// Gestisce operazioni CRUD su Firestore collection 'analytics_page_feedback'.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_page_feedback.dart';

/// Repository per feedback Analytics
class AnalyticsFeedbackRepository {
  AnalyticsFeedbackRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collectionName = 'analytics_page_feedback';

  // ========================================
  // USER OPERATIONS
  // ========================================

  /// Salva o aggiorna feedback utente
  ///
  /// Il feedback viene salvato con ID formato: {userId}_{timestamp}
  /// Se l'utente ha già dato feedback recente (< 30 giorni), questo
  /// metodo NON dovrebbe essere chiamato (check fatto nel provider).
  Future<void> saveFeedback(AnalyticsPageFeedback feedback) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(feedback.id)
          .set(feedback.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save analytics feedback: $e');
    }
  }

  /// Ottieni ultimo feedback dell'utente (più recente)
  ///
  /// Usato per:
  /// 1. Check se utente ha già dato feedback
  /// 2. Verificare se sono passati 30+ giorni (feedback ricorrente)
  Future<AnalyticsPageFeedback?> getUserLastFeedback(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return AnalyticsPageFeedback.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get user last feedback: $e');
    }
  }

  /// Ottieni tutti i feedback dell'utente (cronologia completa)
  ///
  /// Ordinati dal più recente al più vecchio.
  /// Usato per mostrare cronologia feedback all'utente (se richiesto).
  Future<List<AnalyticsPageFeedback>> getUserFeedbackHistory(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AnalyticsPageFeedback.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user feedback history: $e');
    }
  }

  /// Elimina feedback specifico (admin o user)
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection(_collectionName).doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  // ========================================
  // ADMIN OPERATIONS
  // ========================================

  /// Ottieni tutti i feedback (ADMIN ONLY)
  ///
  /// Parametri:
  /// - [limit]: Numero massimo di feedback da recuperare (default: 50)
  /// - [isHelpful]: Filtra per tipo (true = helpful, false = not helpful, null = tutti)
  ///
  /// Ordinati dal più recente al più vecchio.
  Future<List<AnalyticsPageFeedback>> getAllFeedback({
    int? limit,
    bool? isHelpful,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName);

      // Applica filtro isHelpful se specificato
      if (isHelpful != null) {
        query = query.where('isHelpful', isEqualTo: isHelpful);
      }

      // Ordina per timestamp (più recenti prima)
      query = query.orderBy('timestamp', descending: true);

      // Applica limit se specificato
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnalyticsPageFeedback.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all feedback: $e');
    }
  }

  /// Ottieni statistiche aggregate (ADMIN ONLY)
  ///
  /// Ritorna:
  /// - totalFeedback: Totale feedback ricevuti
  /// - totalHelpful: Numero feedback positivi (👍)
  /// - totalNotHelpful: Numero feedback negativi (👎)
  /// - helpfulPercentage: Percentuale feedback positivi
  /// - uniqueUsers: Numero utenti unici che hanno dato feedback
  /// - bySection: Stats suddivise per sezione (overview/progress/insights/routine)
  Future<Map<String, dynamic>> getOverallStats() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalFeedback': 0,
          'totalHelpful': 0,
          'totalNotHelpful': 0,
          'helpfulPercentage': 0.0,
          'uniqueUsers': 0,
          'bySection': <String, dynamic>{},
        };
      }

      final total = snapshot.docs.length;
      final helpful =
          snapshot.docs.where((doc) => doc.data()['isHelpful'] as bool).length;
      final notHelpful = total - helpful;
      final helpfulPercentage = helpful > 0 ? (helpful / total) * 100 : 0.0;

      // Conta utenti unici
      final uniqueUsers = snapshot.docs
          .map((doc) => doc.data()['userId'] as String)
          .toSet()
          .length;

      // Stats per sezione
      final bySection = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final section = data['lastViewedSection'] as String? ?? 'unknown';
        final isHelpful = data['isHelpful'] as bool;

        if (!bySection.containsKey(section)) {
          bySection[section] = {
            'total': 0,
            'helpful': 0,
            'notHelpful': 0,
          };
        }

        bySection[section]!['total'] = (bySection[section]!['total'] as int) + 1;
        if (isHelpful) {
          bySection[section]!['helpful'] =
              (bySection[section]!['helpful'] as int) + 1;
        } else {
          bySection[section]!['notHelpful'] =
              (bySection[section]!['notHelpful'] as int) + 1;
        }
      }

      return {
        'totalFeedback': total,
        'totalHelpful': helpful,
        'totalNotHelpful': notHelpful,
        'helpfulPercentage': helpfulPercentage,
        'uniqueUsers': uniqueUsers,
        'bySection': bySection,
      };
    } catch (e) {
      throw Exception('Failed to get overall stats: $e');
    }
  }

  /// Ottieni feedback per sezione specifica (ADMIN ONLY)
  ///
  /// Utile per capire quale sezione (overview/progress/insights/routine)
  /// riceve più feedback positivi/negativi.
  Future<List<AnalyticsPageFeedback>> getFeedbackBySection(
    String section, {
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('lastViewedSection', isEqualTo: section)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnalyticsPageFeedback.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedback by section: $e');
    }
  }

  /// Ottieni conteggio feedback per range di date (ADMIN ONLY)
  ///
  /// Utile per tracking trend nel tempo.
  Future<int> getFeedbackCountInRange({
    required DateTime startDate,
    required DateTime endDate,
    bool? isHelpful,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (isHelpful != null) {
        query = query.where('isHelpful', isEqualTo: isHelpful);
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get feedback count in range: $e');
    }
  }
}
