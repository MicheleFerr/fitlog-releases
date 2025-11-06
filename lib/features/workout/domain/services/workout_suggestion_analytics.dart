import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/utils/analytics_helper.dart';

/// Analytics service per tracciare le performance del sistema di suggerimento workout
///
/// Raccoglie metriche per:
/// - Suggestion acceptance rate
/// - Level distribution (intelligent vs fallback)
/// - Template diversity
/// - User interaction patterns
class WorkoutSuggestionAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Cache per tracking time to decision
  static DateTime? _lastSuggestionShownTime;
  static String? _lastSuggestedTemplate;

  /// Track quando un suggerimento viene mostrato all'utente
  static Future<void> trackSuggestionShown({
    required String templateName,
    required String reason,
    required double confidence,
    required String suggestionLevel, // 'intelligent' | 'fallback'
    List<String>? pattern,
  }) async {
    try {
      // Cache per calcolare time to decision
      _lastSuggestionShownTime = DateTime.now();
      _lastSuggestedTemplate = templateName;

      final parameters = <String, dynamic>{
        'template_name': templateName,
        'reason': reason,
        'confidence': (confidence * 100).round(), // 0-100 for Firebase
        'level': suggestionLevel,
        'day_of_week': DateTime.now().weekday,
        'time_of_day': _getTimeOfDay(),
        'has_pattern': pattern != null,
        'pattern_length': pattern?.length ?? 0,
      };

      await _analytics.logEvent(
        name: 'workout_suggestion_shown',
        parameters: AnalyticsHelper.sanitizeParameters(parameters),
      );

      if (kDebugMode) {
        debugPrint('📊 Analytics: Suggestion shown - $templateName (confidence: ${confidence.toStringAsFixed(2)})');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error (suggestion_shown): $e');
      }
    }
  }

  /// Track quando l'utente interagisce con il suggerimento
  static Future<void> trackSuggestionAction({
    required String action, // 'accepted' | 'ignored' | 'dismissed'
    required String templateName,
  }) async {
    try {
      final timeToDecision = _calculateTimeToDecision();

      final parameters = <String, dynamic>{
        'action': action,
        'template_name': templateName,
        'time_to_decision_seconds': timeToDecision,
        'day_of_week': DateTime.now().weekday,
        'time_of_day': _getTimeOfDay(),
      };

      await _analytics.logEvent(
        name: 'workout_suggestion_action',
        parameters: AnalyticsHelper.sanitizeParameters(parameters),
      );

      // Track conversion rate
      if (action == 'accepted') {
        await _analytics.logEvent(
          name: 'workout_suggestion_accepted',
          parameters: {'template_name': templateName},
        );
      }

      if (kDebugMode) {
        debugPrint('📊 Analytics: Suggestion $action - $templateName (decision time: ${timeToDecision}s)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error (suggestion_action): $e');
      }
    }
  }

  /// Track quando un workout viene completato
  static Future<void> trackWorkoutCompletion({
    required String templateName,
    required bool wasFromSuggestion,
    required double completionRate, // 0.0-1.0
    int? totalExercises,
    int? completedExercises,
    int? durationMinutes,
  }) async {
    try {
      final parameters = <String, dynamic>{
        'template_name': templateName,
        'from_suggestion': wasFromSuggestion,
        'completion_rate': (completionRate * 100).round(),
        'total_exercises': totalExercises ?? 0,
        'completed_exercises': completedExercises ?? 0,
        'duration_minutes': durationMinutes ?? 0,
        'day_of_week': DateTime.now().weekday,
      };

      await _analytics.logEvent(
        name: 'workout_completed',
        parameters: AnalyticsHelper.sanitizeParameters(parameters),
      );

      // Track suggestion effectiveness
      if (wasFromSuggestion && templateName == _lastSuggestedTemplate) {
        await _analytics.logEvent(
          name: 'suggested_workout_completed',
          parameters: {
            'template_name': templateName,
            'completion_rate': (completionRate * 100).round(),
          },
        );
      }

      if (kDebugMode) {
        debugPrint('📊 Analytics: Workout completed - $templateName (from suggestion: $wasFromSuggestion, ${(completionRate * 100).round()}%)}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error (workout_completion): $e');
      }
    }
  }

  /// Track quando il sistema usa il fallback invece dell'intelligent provider
  static Future<void> trackFallbackUsed({
    required String reason, // 'no_history' | 'low_confidence' | 'error'
    String? errorDetails,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'workout_suggestion_fallback',
        parameters: {
          'reason': reason,
          'error_details': errorDetails ?? '',
          'day_of_week': DateTime.now().weekday,
        },
      );

      if (kDebugMode) {
        debugPrint('📊 Analytics: Fallback used - reason: $reason');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error (fallback_used): $e');
      }
    }
  }

  /// Track pattern detection performance
  static Future<void> trackPatternDetection({
    required bool patternFound,
    required double confidence,
    int? patternLength,
    int? sequenceLength,
    required int computationTimeMs,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'pattern_detection_result',
        parameters: AnalyticsHelper.sanitizeParameters({
          'pattern_found': patternFound,
          'confidence': (confidence * 100).round(),
          'pattern_length': patternLength ?? 0,
          'sequence_length': sequenceLength ?? 0,
          'computation_time_ms': computationTimeMs,
        }),
      );

      if (kDebugMode) {
        debugPrint('📊 Analytics: Pattern detection - found: $patternFound, confidence: ${confidence.toStringAsFixed(2)}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error (pattern_detection): $e');
      }
    }
  }

  // Helper methods

  static String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'early_morning';
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    if (hour < 21) return 'evening';
    return 'night';
  }

  static int _calculateTimeToDecision() {
    if (_lastSuggestionShownTime == null) return 0;

    final difference = DateTime.now().difference(_lastSuggestionShownTime!);
    return difference.inSeconds;
  }

  /// Set custom user properties for segmentation
  static Future<void> setUserProperties({
    required int workoutCount,
    required String preferredSplit, // 'push_pull_legs' | 'upper_lower' | 'full_body' | 'other'
    required bool hasActiveRoutine,
  }) async {
    try {
      await _analytics.setUserProperty(
        name: 'workout_count_range',
        value: _getWorkoutCountRange(workoutCount),
      );

      await _analytics.setUserProperty(
        name: 'preferred_split',
        value: preferredSplit,
      );

      await _analytics.setUserProperty(
        name: 'has_active_routine',
        value: hasActiveRoutine ? '1' : '0',
      );

      if (kDebugMode) {
        debugPrint('📊 Analytics: User properties updated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error (user_properties): $e');
      }
    }
  }

  static String _getWorkoutCountRange(int count) {
    if (count == 0) return 'new_user';
    if (count < 10) return 'beginner';
    if (count < 50) return 'intermediate';
    if (count < 200) return 'advanced';
    return 'expert';
  }
}
