import 'package:freezed_annotation/freezed_annotation.dart';

part 'superset_template.freezed.dart';
part 'superset_template.g.dart';

/// User persona types for template targeting
enum UserPersona {
  marco,      // Principiante intimidito
  chiara,     // Mamma multitasking
  luca,       // Powerlifter serio
  sofia,      // Estetica-driven
  roberto,    // Professionista busy
  generic,    // Nessuna persona specifica
}

/// Template difficulty levels
enum TemplateDifficulty {
  beginner,
  intermediate,
  @JsonValue('intermediate-advanced')
  intermediateAdvanced,
  advanced,
}

/// Superset template configuration
/// Pre-defined or user-created superset combinations with scientific backing
@freezed
abstract class SupersetTemplate with _$SupersetTemplate {
  const factory SupersetTemplate({
    required String id,
    required String name,
    /// Exercise IDs for database lookup (stored in JSON)
    required List<String> exerciseIds,
    /// Exercise names - populated at runtime from database lookup (localized)
    /// Not stored in JSON, computed from exerciseIds
    @Default([]) List<String> exerciseNames,
    required int rounds,
    required String repsRange,
    required int restAfterRound,
    required int restBetween,
    required TemplateDifficulty difficulty,
    required int estimatedTimeMinutes,
    required String scientificBasis,
    String? notes,
    String? tut,
    List<String>? equipmentRequired,
    List<String>? equipmentAlternatives,
    UserPersona? targetPersona,
    List<String>? targetMuscles,
    @Default(false) bool isCustom,
    DateTime? createdAt,
  }) = _SupersetTemplate;

  factory SupersetTemplate.fromJson(Map<String, dynamic> json) =>
      _$SupersetTemplateFromJson(json);
}
