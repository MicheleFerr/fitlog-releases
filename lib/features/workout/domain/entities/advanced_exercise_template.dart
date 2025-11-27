import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

part 'advanced_exercise_template.freezed.dart';
part 'advanced_exercise_template.g.dart';

/// Advanced Exercise Template for saving complex exercise configurations.
/// Supports superset, dropset, and rest-pause configurations.
/// Free users limited to 3 templates, premium unlimited.
@freezed
class AdvancedExerciseTemplate with _$AdvancedExerciseTemplate {
  const AdvancedExerciseTemplate._();

  const factory AdvancedExerciseTemplate({
    /// Unique template ID (UUID)
    required String id,

    /// User ID who owns this template
    required String userId,

    /// User-defined template name
    required String name,

    /// Optional description
    String? description,

    /// Type of advanced exercise
    required AdvancedExerciseType type,

    /// Configuration data based on type
    required AdvancedExerciseConfig config,

    /// Tags for organization
    @Default([]) List<String> tags,

    /// Number of times this template has been used
    @Default(0) int usageCount,

    /// Whether this is a favorite template
    @Default(false) bool isFavorite,

    /// Created timestamp
    required DateTime createdAt,

    /// Last modified timestamp
    required DateTime updatedAt,

    /// Last used timestamp
    DateTime? lastUsedAt,
  }) = _AdvancedExerciseTemplate;

  factory AdvancedExerciseTemplate.fromJson(Map<String, dynamic> json) =>
      _$AdvancedExerciseTemplateFromJson(json);

  /// Creates a new template from a superset exercise
  factory AdvancedExerciseTemplate.fromSuperset({
    required String id,
    required String userId,
    required String name,
    required SupersetExercise superset,
    String? description,
    List<String> tags = const [],
  }) {
    return AdvancedExerciseTemplate(
      id: id,
      userId: userId,
      name: name,
      description: description,
      type: AdvancedExerciseType.superset,
      config: SupersetConfig(
        exerciseNames: superset.exercises.map((e) => e.name).toList(),
        exerciseIds: superset.exercises.map((e) => e.id).toList(),
        targetSets: superset.supersetSets.length,
        restBetweenExercises: 0, // True superset has no rest
        restBetweenRounds: superset.restTime ?? 90,
      ),
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a new template from a dropset exercise
  factory AdvancedExerciseTemplate.fromDropSet({
    required String id,
    required String userId,
    required String name,
    required DropSetExercise dropSet,
    String? description,
    List<String> tags = const [],
  }) {
    // Calculate percentage drops from stages
    final stages = dropSet.stages;
    final firstWeight = stages.isNotEmpty ? stages.first.weight : 1.0;
    final percentageDrops = stages.map((stage) {
      return firstWeight > 0 ? (stage.weight / firstWeight) * 100 : 100.0;
    }).toList();

    return AdvancedExerciseTemplate(
      id: id,
      userId: userId,
      name: name,
      description: description,
      type: AdvancedExerciseType.dropset,
      config: DropSetConfig(
        exerciseName: dropSet.name,
        exerciseId: dropSet.id,
        drops: stages.length,
        percentageDrops: percentageDrops,
        restBetweenDrops: 0, // Drop sets typically have no rest
      ),
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a new template from a rest-pause exercise
  factory AdvancedExerciseTemplate.fromRestPause({
    required String id,
    required String userId,
    required String name,
    required RestPauseExercise restPause,
    String? description,
    List<String> tags = const [],
  }) {
    // Get rest duration from first rest-pause set, or default to 15 seconds
    final restDuration = restPause.restPauseSets.isNotEmpty
        ? restPause.restPauseSets.first.restSeconds
        : 15;

    return AdvancedExerciseTemplate(
      id: id,
      userId: userId,
      name: name,
      description: description,
      type: AdvancedExerciseType.restPause,
      config: RestPauseConfig(
        exerciseName: restPause.name,
        exerciseId: restPause.id,
        miniSets: restPause.restPauseSets.length,
        restDuration: restDuration,
        targetReps: restPause.targetReps,
      ),
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Display icon based on type
  String get iconName {
    switch (type) {
      case AdvancedExerciseType.superset:
        return 'link';
      case AdvancedExerciseType.dropset:
        return 'trending_down';
      case AdvancedExerciseType.restPause:
        return 'pause';
    }
  }

  /// Display label based on type
  String get typeLabel {
    switch (type) {
      case AdvancedExerciseType.superset:
        return 'Superset';
      case AdvancedExerciseType.dropset:
        return 'Drop Set';
      case AdvancedExerciseType.restPause:
        return 'Rest-Pause';
    }
  }
}

/// Type of advanced exercise
enum AdvancedExerciseType {
  superset,
  dropset,
  restPause,
}

/// Base configuration class for advanced exercises
@freezed
sealed class AdvancedExerciseConfig with _$AdvancedExerciseConfig {
  const factory AdvancedExerciseConfig.superset({
    required List<String> exerciseNames,
    required List<String> exerciseIds,
    required int targetSets,
    @Default(0) int restBetweenExercises,
    @Default(90) int restBetweenRounds,
  }) = SupersetConfig;

  const factory AdvancedExerciseConfig.dropSet({
    required String exerciseName,
    required String exerciseId,
    required int drops,
    required List<double> percentageDrops,
    @Default(0) int restBetweenDrops,
  }) = DropSetConfig;

  const factory AdvancedExerciseConfig.restPause({
    required String exerciseName,
    required String exerciseId,
    required int miniSets,
    @Default(15) int restDuration,
    int? targetReps,
  }) = RestPauseConfig;

  factory AdvancedExerciseConfig.fromJson(Map<String, dynamic> json) =>
      _$AdvancedExerciseConfigFromJson(json);
}

/// Free tier limit for templates
const int kFreeTemplateLimit = 3;

/// Check if user can create more templates
bool canCreateTemplate(int currentCount, bool isPremium) {
  if (isPremium) return true;
  return currentCount < kFreeTemplateLimit;
}

/// Get remaining template slots for free users
int getRemainingTemplateSlots(int currentCount, bool isPremium) {
  if (isPremium) return -1; // Unlimited
  return (kFreeTemplateLimit - currentCount).clamp(0, kFreeTemplateLimit);
}
