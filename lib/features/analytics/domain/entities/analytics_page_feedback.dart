/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics_feedback
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ANALYTICS PAGE FEEDBACK ENTITY
///
/// Entity per feedback utente sulla schermata Analytics.
/// Include logica di eligibility: utente deve aver usato Analytics
/// per almeno 7 giorni e completato 10+ workout prima di dare feedback.
///
/// Feedback ricorrente: ogni 30 giorni l'utente può dare nuovo feedback.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_page_feedback.freezed.dart';
part 'analytics_page_feedback.g.dart';

/// Feedback dell'utente sulla schermata Analytics
@freezed
class AnalyticsPageFeedback with _$AnalyticsPageFeedback {
  const factory AnalyticsPageFeedback({
    /// Unique identifier: {userId}_{timestamp}
    required String id,

    /// Firebase Auth UID dell'utente
    required String userId,

    /// Feedback positivo (true = 👍) o negativo (false = 👎)
    required bool isHelpful,

    /// Commento opzionale dell'utente
    String? comment,

    /// Timestamp quando il feedback è stato dato
    required DateTime timestamp,

    // ========================================
    // METADATA OPZIONALE PER ANALYTICS
    // ========================================

    /// Numero totale di workout visualizzati in Analytics
    /// (utile per capire quanto l'utente ha usato la feature)
    int? totalWorkoutsViewed,

    /// Ultima sezione vista prima di dare feedback
    /// Valori: 'overview', 'progress', 'insights', 'routine'
    String? lastViewedSection,

    /// Device info per analytics (es: "iOS 18.1", "Android 14")
    Map<String, dynamic>? deviceInfo,
  }) = _AnalyticsPageFeedback;

  /// Create from Firestore JSON
  factory AnalyticsPageFeedback.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsPageFeedbackFromJson(json);
}

/// Extension per utility methods
extension AnalyticsPageFeedbackX on AnalyticsPageFeedback {
  /// Check se il feedback è recente (< 30 giorni)
  /// Usato per determinare se l'utente può dare nuovo feedback
  bool isRecent() {
    final now = DateTime.now();
    final daysSince = now.difference(timestamp).inDays;
    return daysSince < 30;
  }

  /// Get feedback type as string (for admin dashboard)
  String get feedbackType => isHelpful ? 'helpful' : 'not_helpful';

  /// Get formatted timestamp
  String get formattedTimestamp => '${timestamp.day}/${timestamp.month}/${timestamp.year}';
}
