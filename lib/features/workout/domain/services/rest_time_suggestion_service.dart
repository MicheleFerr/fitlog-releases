import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:flutter/foundation.dart';

/// Service for suggesting rest time adjustments based on performance
class RestTimeSuggestionService {
  /// Check if rest time increase should be suggested
  /// Returns suggested rest time if applicable, null otherwise
  static RestTimeSuggestion? checkRestTimeSuggestion({
    required Exercise exercise,
    required double newWeight,
    required double lastWeight,
    required int currentRestTime,
    required bool autoAdjustEnabled,
  }) {
    // Debug logging
    if (kDebugMode) {
      debugPrint('[APRE-DEBUG] RestTimeSuggestionService.checkRestTimeSuggestion called');
    }
    if (kDebugMode) {
      debugPrint('[APRE-DEBUG]   exercise.autoAdjustmentType: ${exercise.autoAdjustmentType}');
    }
    if (kDebugMode) {
      debugPrint('[APRE-DEBUG]   autoAdjustEnabled: $autoAdjustEnabled');
    }
    if (kDebugMode) {
      debugPrint('[APRE-DEBUG]   newWeight: $newWeight, lastWeight: $lastWeight');
    }
    if (kDebugMode) {
      debugPrint('[APRE-DEBUG]   currentRestTime: $currentRestTime');
    }

    // Only suggest for APRE exercises with auto-adjust enabled
    if (exercise.autoAdjustmentType != AutoAdjustmentType.apre || !autoAdjustEnabled) {
      if (kDebugMode) {
        debugPrint('[APRE-DEBUG]   SKIPPED: autoAdjustmentType=${exercise.autoAdjustmentType}, enabled=$autoAdjustEnabled');
      }
      return null;
    }

    // Performance dropped (weight decreased)
    if (newWeight < lastWeight) {
      final weightDrop = lastWeight - newWeight;
      final dropPercentage = (weightDrop / lastWeight) * 100;

      // Suggest rest increase based on performance drop
      int suggestion;
      if (dropPercentage > 10) {
        suggestion = 60; // Significant drop → +1 minute
      } else if (dropPercentage > 5) {
        suggestion = 30; // Moderate drop → +30 seconds
      } else {
        suggestion = 15; // Small drop → +15 seconds
      }

      final suggestedRestTime = currentRestTime + suggestion;

      return RestTimeSuggestion(
        type: RestTimeSuggestionType.increase,
        currentRestTime: currentRestTime,
        suggestedRestTime: suggestedRestTime,
        reason: 'Peso ridotto da ${lastWeight.toStringAsFixed(1)}kg a ${newWeight.toStringAsFixed(1)}kg',
        weightDrop: weightDrop,
      );
    }

    // Performance improved significantly (weight increased a lot)
    if (newWeight > lastWeight + 5 && currentRestTime > 60) {
      final suggestedRestTime = (currentRestTime - 15).clamp(60, currentRestTime);

      return RestTimeSuggestion(
        type: RestTimeSuggestionType.decrease,
        currentRestTime: currentRestTime,
        suggestedRestTime: suggestedRestTime,
        reason: 'Peso aumentato! Puoi ridurre il recupero',
        weightDrop: 0,
      );
    }

    return null;
  }

  /// Format time in MM:SS
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

enum RestTimeSuggestionType {
  increase,
  decrease,
}

class RestTimeSuggestion {

  RestTimeSuggestion({
    required this.type,
    required this.currentRestTime,
    required this.suggestedRestTime,
    required this.reason,
    required this.weightDrop,
  });
  final RestTimeSuggestionType type;
  final int currentRestTime;
  final int suggestedRestTime;
  final String reason;
  final double weightDrop;

  String get message {
    if (type == RestTimeSuggestionType.increase) {
      return '$reason\nSuggerimento: aumentare recupero a ${RestTimeSuggestionService.formatTime(suggestedRestTime)}';
    } else {
      return '$reason\nSuggerimento: ridurre recupero a ${RestTimeSuggestionService.formatTime(suggestedRestTime)}';
    }
  }
}
