import 'package:freezed_annotation/freezed_annotation.dart';

part 'dropset_template.freezed.dart';
part 'dropset_template.g.dart';

/// Template difficulty levels (shared with SupersetTemplate)
enum DropsetDifficulty {
  beginner,
  intermediate,
  @JsonValue('intermediate-advanced')
  intermediateAdvanced,
  advanced,
}

/// Dropset template configuration
/// Pre-defined or user-created dropset combinations with scientific backing
///
/// A dropset involves performing an exercise to near failure, then immediately
/// reducing the weight and continuing for more reps without rest.
@freezed
abstract class DropsetTemplate with _$DropsetTemplate {
  const factory DropsetTemplate({
    required String id,
    required String name,

    /// The exercise to perform (e.g., "Bicep Curl", "Leg Press")
    required String exerciseName,

    /// Number of drop sets (typically 2-4)
    required int drops,

    /// Starting reps before first drop (e.g., "8-10")
    required String initialReps,

    /// Weight reduction percentage per drop (e.g., 20 = reduce by 20% each drop)
    required int dropPercentage,

    /// Rest between drops in seconds (usually 0-10s, just enough to change weight)
    required int restBetweenDrops,

    /// Total sets of dropsets to perform
    required int totalSets,

    /// Rest between full dropset rounds in seconds
    required int restBetweenSets,

    /// Difficulty level
    required DropsetDifficulty difficulty,

    /// Estimated time in minutes for the complete dropset sequence
    required int estimatedTimeMinutes,

    /// Scientific basis for this dropset configuration
    required String scientificBasis,

    /// Additional notes or tips
    String? notes,

    /// Time under tension pattern (e.g., "2-0-1" for eccentric-pause-concentric)
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
  }) = _DropsetTemplate;

  factory DropsetTemplate.fromJson(Map<String, dynamic> json) =>
      _$DropsetTemplateFromJson(json);
}
