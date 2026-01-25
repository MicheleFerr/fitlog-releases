import 'package:freezed_annotation/freezed_annotation.dart';

part 'rest_pause_template.freezed.dart';
part 'rest_pause_template.g.dart';

/// Template difficulty levels (shared with SupersetTemplate)
enum RestPauseDifficulty {
  beginner,
  intermediate,
  @JsonValue('intermediate-advanced')
  intermediateAdvanced,
  advanced,
}

/// Rest-Pause template configuration
/// Pre-defined or user-created rest-pause combinations with scientific backing
///
/// Rest-pause involves performing an exercise to near failure, resting briefly
/// (10-20 seconds), then continuing for more reps with the same weight.
/// This maximizes muscle fiber recruitment and metabolic stress.
@freezed
abstract class RestPauseTemplate with _$RestPauseTemplate {
  const factory RestPauseTemplate({
    required String id,
    required String name,
    /// Localization key for predefined templates (e.g., "templateBenchPressRestPause")
    /// If present, use l10n lookup for display name. If null (custom templates), use name directly.
    String? nameKey,

    /// The exercise to perform (e.g., "Bench Press", "Leg Extension")
    required String exerciseName,

    /// Initial reps to perform before first pause (e.g., "6-8")
    required String initialReps,

    /// Number of rest-pause clusters (typically 2-3)
    required int clusters,

    /// Target reps per cluster after initial set (e.g., "2-4")
    required String clusterReps,

    /// Rest duration between clusters in seconds (typically 10-20s)
    required int pauseDuration,

    /// Total sets of rest-pause to perform
    required int totalSets,

    /// Rest between full rest-pause sets in seconds
    required int restBetweenSets,

    /// Difficulty level
    required RestPauseDifficulty difficulty,

    /// Estimated time in minutes for the complete rest-pause sequence
    required int estimatedTimeMinutes,

    /// Scientific basis for this rest-pause configuration
    required String scientificBasis,

    /// Additional notes or tips
    String? notes,

    /// Time under tension pattern (e.g., "2-0-1")
    String? tut,

    /// Equipment needed
    List<String>? equipmentRequired,

    /// Alternative equipment options
    List<String>? equipmentAlternatives,

    /// Target muscles
    List<String>? targetMuscles,

    /// Whether this is a custom user template
    @Default(false) bool isCustom,

    /// Creation timestamp for custom templates
    DateTime? createdAt,
  }) = _RestPauseTemplate;

  factory RestPauseTemplate.fromJson(Map<String, dynamic> json) =>
      _$RestPauseTemplateFromJson(json);
}
