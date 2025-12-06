/// Warmup exercise suggestion with structured data
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'warmup_suggestion.freezed.dart';
part 'warmup_suggestion.g.dart';

/// Type of warmup exercise
enum WarmupType {
  /// Mobility exercises (stretching, range of motion)
  mobility,

  /// Activation exercises (muscle activation, stability)
  activation,
}

/// A suggested warmup exercise for a main exercise
@freezed
abstract class WarmupSuggestion with _$WarmupSuggestion {
  const factory WarmupSuggestion({
    /// ID of the warmup exercise in the database
    required String exerciseId,

    /// Display name of the exercise
    required String exerciseName,

    /// Number of sets to perform
    required int sets,

    /// Number of reps per set
    required int reps,

    /// Type of warmup (mobility or activation)
    required WarmupType type,
  }) = _WarmupSuggestion;

  factory WarmupSuggestion.fromJson(Map<String, dynamic> json) =>
      _$WarmupSuggestionFromJson(json);
}
