/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// Ratio Breakdown Entity - Tracks exercise contributions to ratios
///
/// **Design Rationale**:
/// - Composition over Inheritance: Separate entity from MuscleBalanceMetrics
/// - Single Responsibility: Each entity has a focused purpose
/// - Immutable: All entities are immutable for predictability
library;

/// Exercise contribution to a ratio category (push/pull/upper/lower)
///
/// **Properties**:
/// - exerciseName: Display name of the exercise
/// - muscleGroup: Target muscle group
/// - volume: Total volume in kg
/// - percentage: Percentage contribution to category total
/// - isPrimary: True if muscle is the primary target
class ExerciseContribution {
  const ExerciseContribution({
    required this.exerciseName,
    required this.muscleGroup,
    required this.volume,
    required this.percentage,
    this.isPrimary = true,
  });

  /// Name of the exercise
  final String exerciseName;

  /// Target muscle group
  final String muscleGroup;

  /// Total volume in kg
  final double volume;

  /// Percentage of category total (0-100)
  final double percentage;

  /// True if this is the primary targeted muscle
  final bool isPrimary;

  @override
  String toString() => 'ExerciseContribution($exerciseName, $volume kg, $percentage%)';
}

/// Category breakdown with exercises grouped by muscle
///
/// **Properties**:
/// - categoryName: Name of the category (e.g., "Push", "Pull")
/// - totalVolume: Sum of all exercise volumes
/// - exercisesByMuscle: Exercises grouped by muscle group
class CategoryBreakdown {
  const CategoryBreakdown({
    required this.categoryName,
    required this.totalVolume,
    required this.exercisesByMuscle,
  });

  /// Name of the category
  final String categoryName;

  /// Total volume for this category
  final double totalVolume;

  /// Exercises grouped by muscle group
  /// Key: muscle group name, Value: list of exercise contributions
  final Map<String, List<ExerciseContribution>> exercisesByMuscle;

  /// Get all exercises flattened
  List<ExerciseContribution> get allExercises {
    return exercisesByMuscle.values.expand((e) => e).toList()
      ..sort((a, b) => b.volume.compareTo(a.volume));
  }

  /// Get top N exercises by volume
  List<ExerciseContribution> topExercises(int count) {
    return allExercises.take(count).toList();
  }

  /// Check if category has data
  bool get hasData => totalVolume > 0;

  @override
  String toString() => 'CategoryBreakdown($categoryName, $totalVolume kg)';
}

/// Complete ratio breakdown for expandable cards
///
/// **Properties**:
/// - pushBreakdown: Push exercises breakdown
/// - pullBreakdown: Pull exercises breakdown
/// - upperBreakdown: Upper body exercises breakdown
/// - lowerBreakdown: Lower body exercises breakdown
class RatioBreakdown {
  const RatioBreakdown({
    required this.pushBreakdown,
    required this.pullBreakdown,
    required this.upperBreakdown,
    required this.lowerBreakdown,
  });

  /// Empty breakdown (no data)
  factory RatioBreakdown.empty() => const RatioBreakdown(
        pushBreakdown: CategoryBreakdown(
          categoryName: 'Push',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
        pullBreakdown: CategoryBreakdown(
          categoryName: 'Pull',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
        upperBreakdown: CategoryBreakdown(
          categoryName: 'Upper',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
        lowerBreakdown: CategoryBreakdown(
          categoryName: 'Lower',
          totalVolume: 0,
          exercisesByMuscle: {},
        ),
      );

  final CategoryBreakdown pushBreakdown;
  final CategoryBreakdown pullBreakdown;
  final CategoryBreakdown upperBreakdown;
  final CategoryBreakdown lowerBreakdown;

  /// Get breakdown for push/pull ratio
  (CategoryBreakdown, CategoryBreakdown) get pushPullPair => (pushBreakdown, pullBreakdown);

  /// Get breakdown for upper/lower ratio
  (CategoryBreakdown, CategoryBreakdown) get upperLowerPair => (upperBreakdown, lowerBreakdown);

  /// Check if any data exists
  bool get hasData =>
      pushBreakdown.hasData ||
      pullBreakdown.hasData ||
      upperBreakdown.hasData ||
      lowerBreakdown.hasData;

  @override
  String toString() => 'RatioBreakdown(push: ${pushBreakdown.totalVolume}, '
      'pull: ${pullBreakdown.totalVolume}, '
      'upper: ${upperBreakdown.totalVolume}, '
      'lower: ${lowerBreakdown.totalVolume})';
}
