/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/datasources
/// 🎯 Feature: ai_coach
/// 🔧 Type: datasource
///
/// Firebase Feature Gate Datasource - Optimized for minimal reads/writes
///
/// ARCHITECTURE PATTERN: Single Document + Map
/// ✅ 1 read per app start (vs 8 with subcollections)
/// ✅ 1 write per unlock (vs 2 with subcollections)
/// ✅ 87.5% read reduction
/// ✅ $0/month for 10K users (within free tier)
///
/// Document structure:
/// users/{userId}/aiCoach (single document)
/// {
///   'features': {
///     'workoutSuggestions': true,
///     'advancedAnalytics': false,
///     'recoveryInsights': false,
///     // ... all 8 features in ONE document
///   },
///   'lastUpdated': timestamp,
///   'experienceLevel': 'beginner',
///   'workoutCount': 5,
///   'daysSinceRegistration': 14
/// }
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firebase datasource for feature gates
///
/// Optimized for minimal Firestore reads/writes:
/// - Single document per user (not subcollection)
/// - All features in one map field
/// - Batch updates for multiple feature changes
class FirebaseFeatureGateDatasource {
  FirebaseFeatureGateDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Collection and subcollection paths
  static const String _usersCollection = 'users';
  static const String _aiCoachDocument = 'aiCoach';

  /// Get user's AI Coach document reference
  DocumentReference<Map<String, dynamic>> _getUserAiCoachDoc(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection('private')
        .doc(_aiCoachDocument);
  }

  /// Get all feature preferences for user
  ///
  /// Returns map of feature → enabled status
  /// Single read operation (optimized)
  Future<Map<String, bool>> getFeaturePreferences(String userId) async {
    try {
      final doc = await _getUserAiCoachDoc(userId).get();

      if (!doc.exists) {
        // First time user - return empty (will use defaults)
        return {};
      }

      final data = doc.data();
      if (data == null || data['features'] == null) {
        return {};
      }

      // Extract features map and cast to Map<String, bool>
      final featuresRaw = data['features'] as Map<String, dynamic>;
      return featuresRaw.map(
        (key, value) => MapEntry(key, value as bool? ?? false),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateDatasource] Error getting preferences: $e');
      }
      rethrow;
    }
  }

  /// Update feature preference
  ///
  /// Uses merge: true to only update specific feature
  /// Single write operation (optimized)
  Future<void> setFeaturePreference({
    required String userId,
    required String featureName,
    required bool enabled,
  }) async {
    try {
      await _getUserAiCoachDoc(userId).set(
        {
          'features': {
            featureName: enabled,
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [FeatureGateDatasource] Updated $featureName → $enabled',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateDatasource] Error setting preference: $e');
      }
      rethrow;
    }
  }

  /// Batch update multiple features
  ///
  /// Efficient for onboarding or bulk changes
  /// Still single write operation (SetOptions.merge)
  Future<void> setMultipleFeaturePreferences({
    required String userId,
    required Map<String, bool> features,
  }) async {
    try {
      await _getUserAiCoachDoc(userId).set(
        {
          'features': features,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (kDebugMode) {
        debugPrint(
          '✅ [FeatureGateDatasource] Batch updated ${features.length} features',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ [FeatureGateDatasource] Error batch setting preferences: $e',
        );
      }
      rethrow;
    }
  }

  /// Update user context (experience level, workout count, health metrics, etc.)
  ///
  /// Used by feature gate evaluation and HealthKit sync
  ///
  /// **Health Metrics** (from HealthKit sync):
  /// - steps_today: Daily step count
  /// - resting_heart_rate: Overnight average HR
  /// - workouts_this_week: Workout count (last 7 days)
  /// - active_energy_today: Active calories burned
  /// - exercise_minutes_today: Exercise time in minutes
  Future<void> updateUserContext({
    required String userId,
    String? experienceLevel,
    int? workoutCount,
    int? daysSinceRegistration,
    Map<String, dynamic>? healthMetrics,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (experienceLevel != null) {
        updates['experienceLevel'] = experienceLevel;
      }
      if (workoutCount != null) {
        updates['workoutCount'] = workoutCount;
      }
      if (daysSinceRegistration != null) {
        updates['daysSinceRegistration'] = daysSinceRegistration;
      }
      if (healthMetrics != null && healthMetrics.isNotEmpty) {
        updates['healthMetrics'] = healthMetrics;
      }

      await _getUserAiCoachDoc(userId).set(
        updates,
        SetOptions(merge: true),
      );

      if (kDebugMode) {
        debugPrint('✅ [FeatureGateDatasource] Updated user context');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateDatasource] Error updating context: $e');
      }
      rethrow;
    }
  }

  /// Get user context (for gate evaluation)
  ///
  /// Returns experience level, workout count, etc.
  Future<Map<String, dynamic>?> getUserContext(String userId) async {
    try {
      final doc = await _getUserAiCoachDoc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      return {
        'experienceLevel': data?['experienceLevel'] as String? ?? 'beginner',
        'workoutCount': data?['workoutCount'] as int? ?? 0,
        'daysSinceRegistration': data?['daysSinceRegistration'] as int? ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateDatasource] Error getting context: $e');
      }
      rethrow;
    }
  }

  /// Stream feature preferences (for real-time updates)
  ///
  /// ⚠️ USE SPARINGLY - Real-time streams cost 40 reads/day per user
  /// Prefer polling with cache (implemented in Task 2.1-2.4)
  Stream<Map<String, bool>> streamFeaturePreferences(String userId) {
    return _getUserAiCoachDoc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return {};

      final data = snapshot.data();
      if (data == null || data['features'] == null) return {};

      final featuresRaw = data['features'] as Map<String, dynamic>;
      return featuresRaw.map(
        (key, value) => MapEntry(key, value as bool? ?? false),
      );
    });
  }

  /// Delete all user feature data (GDPR Right to Erasure - Article 17)
  Future<void> deleteUserFeatureData(String userId) async {
    try {
      await _getUserAiCoachDoc(userId).delete();

      if (kDebugMode) {
        debugPrint('✅ [FeatureGateDatasource] Deleted user feature data');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateDatasource] Error deleting data: $e');
      }
      rethrow;
    }
  }

  /// Export user feature data (GDPR Right to Portability - Article 20)
  Future<Map<String, dynamic>> exportUserFeatureData(String userId) async {
    try {
      final doc = await _getUserAiCoachDoc(userId).get();

      if (!doc.exists) {
        return {
          'features': {},
          'context': {},
          'exportedAt': DateTime.now().toIso8601String(),
        };
      }

      final data = doc.data() ?? {};

      return {
        'features': data['features'] ?? {},
        'context': {
          'experienceLevel': data['experienceLevel'],
          'workoutCount': data['workoutCount'],
          'daysSinceRegistration': data['daysSinceRegistration'],
        },
        'lastUpdated': (data['lastUpdated'] as Timestamp?)?.toDate().toIso8601String(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FeatureGateDatasource] Error exporting data: $e');
      }
      rethrow;
    }
  }
}
