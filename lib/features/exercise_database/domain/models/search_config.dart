/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/models
/// 🎯 Feature: exercise_database
/// 🔧 Type: domain model
///
/// Configuration models for exercise fuzzy search
library;


/// Configuration object for exercise search parameters
///
/// Externalizes all search settings to enable:
/// - A/B testing different thresholds
/// - Remote configuration via Firebase Remote Config
/// - User preferences (save custom settings)
/// - Testing with different configurations
///
/// Example usage:
/// ```dart
/// final config = SearchConfig(
///   strictThreshold: 0.70,
///   typeThreshold: 0.55,
///   maxResults: 10,
///   enableUserBoost: true,
///   enableCategoryBoost: false,
///   mlWeights: MLFormulaWeights(fuzzy: 0.6, user: 0.3, category: 0.1),
/// );
///
/// final results = await searchService.searchExercises(
///   exercises: exercises,
///   query: query,
///   config: config,
/// );
/// ```
class SearchConfig {

  /// Create search configuration
  const SearchConfig({
    this.strictThreshold = 0.65,
    this.typeThreshold = 0.50,
    this.maxResults = 50,
    this.enableUserBoost = true,
    this.enableCategoryBoost = true,
    this.mlWeights,
  });
  /// Threshold for strict matches (exact name/alias matching)
  ///
  /// Range: 0.0 - 1.0
  /// Default: 0.65
  /// Recommended: 0.60 - 0.75
  ///
  /// Higher values = stricter matching (fewer results, higher quality)
  /// Lower values = looser matching (more results, may include typos)
  final double strictThreshold;

  /// Threshold for typo correction (fuzzy matching for misspellings)
  ///
  /// Range: 0.0 - 1.0
  /// Default: 0.50
  /// Recommended: 0.45 - 0.60
  ///
  /// Higher values = stricter typo correction (only obvious typos)
  /// Lower values = looser typo correction (more aggressive correction)
  final double typeThreshold;

  /// Maximum number of results to return
  ///
  /// Default: 50 (for full search)
  /// Autocomplete: 10 (limit dropdown size)
  /// API: 100 (for pagination)
  final int maxResults;

  /// Enable ML boost based on user's exercise usage history
  ///
  /// When true, frequently used exercises appear higher in results
  ///
  /// Default: true
  final bool enableUserBoost;

  /// Enable ML boost based on current workout category
  ///
  /// When true, exercises matching the workout category rank higher
  ///
  /// Default: true
  final bool enableCategoryBoost;

  /// ML formula weights for score calculation
  ///
  /// Defines how fuzzy score, user boost, and category boost are combined
  ///
  /// Default: 50% fuzzy, 30% user, 20% category
  final MLFormulaWeights? mlWeights;

  /// Default configuration for autocomplete (tighter limits)
  static const autocomplete = SearchConfig(
    strictThreshold: 0.65,
    typeThreshold: 0.50,
    maxResults: 10, // Limit dropdown size
    enableUserBoost: true,
    enableCategoryBoost: true,
  );

  /// Strict configuration (high quality, fewer results)
  static const strict = SearchConfig(
    strictThreshold: 0.75,
    typeThreshold: 0.60,
    maxResults: 20,
    enableUserBoost: true,
    enableCategoryBoost: true,
  );

  /// Relaxed configuration (more results, includes more typos)
  static const relaxed = SearchConfig(
    strictThreshold: 0.55,
    typeThreshold: 0.40,
    maxResults: 100,
    enableUserBoost: false,
    enableCategoryBoost: false,
  );

  /// Copy with modifications
  SearchConfig copyWith({
    double? strictThreshold,
    double? typeThreshold,
    int? maxResults,
    bool? enableUserBoost,
    bool? enableCategoryBoost,
    MLFormulaWeights? mlWeights,
  }) {
    return SearchConfig(
      strictThreshold: strictThreshold ?? this.strictThreshold,
      typeThreshold: typeThreshold ?? this.typeThreshold,
      maxResults: maxResults ?? this.maxResults,
      enableUserBoost: enableUserBoost ?? this.enableUserBoost,
      enableCategoryBoost: enableCategoryBoost ?? this.enableCategoryBoost,
      mlWeights: mlWeights ?? this.mlWeights,
    );
  }

  /// Validate configuration
  ///
  /// Throws [ArgumentError] if invalid
  void validate() {
    if (strictThreshold < 0.0 || strictThreshold > 1.0) {
      throw ArgumentError('strictThreshold must be between 0.0 and 1.0');
    }
    if (typeThreshold < 0.0 || typeThreshold > 1.0) {
      throw ArgumentError('typeThreshold must be between 0.0 and 1.0');
    }
    if (maxResults <= 0) {
      throw ArgumentError('maxResults must be positive');
    }
    mlWeights?.validate();
  }

  @override
  String toString() {
    return 'SearchConfig('
        'strict: $strictThreshold, '
        'type: $typeThreshold, '
        'max: $maxResults, '
        'userBoost: $enableUserBoost, '
        'categoryBoost: $enableCategoryBoost'
        ')';
  }
}

/// ML formula weights for combining fuzzy score, user boost, and category boost
///
/// Default formula: finalScore = (0.5 * fuzzy) + (0.3 * user) + (0.2 * category)
///
/// These weights can be tuned based on:
/// - User feedback (which results do users select?)
/// - A/B testing (which weights lead to better engagement?)
/// - Use case (autocomplete vs full search vs recommendations)
///
/// Example presets:
/// ```dart
/// // Default (balanced)
/// MLFormulaWeights.balanced // 50% fuzzy, 30% user, 20% category
///
/// // Fuzzy-first (prioritize exact matching)
/// MLFormulaWeights.fuzzyFirst // 70% fuzzy, 20% user, 10% category
///
/// // Personalized (prioritize user history)
/// MLFormulaWeights.personalized // 30% fuzzy, 60% user, 10% category
///
/// // Category-focused (prioritize workout context)
/// MLFormulaWeights.categoryFocused // 40% fuzzy, 20% user, 40% category
/// ```
class MLFormulaWeights {

  /// Create ML formula weights
  const MLFormulaWeights({
    this.fuzzyWeight = 0.5,
    this.userWeight = 0.3,
    this.categoryWeight = 0.2,
  });
  /// Weight for fuzzy matching score (0.0 - 1.0)
  ///
  /// Default: 0.5 (50%)
  ///
  /// Higher values = prioritize exact name/alias matching
  final double fuzzyWeight;

  /// Weight for user boost (exercise usage frequency) (0.0 - 1.0)
  ///
  /// Default: 0.3 (30%)
  ///
  /// Higher values = prioritize user's frequently used exercises
  final double userWeight;

  /// Weight for category boost (workout context) (0.0 - 1.0)
  ///
  /// Default: 0.2 (20%)
  ///
  /// Higher values = prioritize exercises matching workout category
  final double categoryWeight;

  /// Balanced preset (default)
  static const balanced = MLFormulaWeights(
    fuzzyWeight: 0.5,
    userWeight: 0.3,
    categoryWeight: 0.2,
  );

  /// Fuzzy-first preset (prioritize exact matching)
  static const fuzzyFirst = MLFormulaWeights(
    fuzzyWeight: 0.7,
    userWeight: 0.2,
    categoryWeight: 0.1,
  );

  /// Personalized preset (prioritize user history)
  static const personalized = MLFormulaWeights(
    fuzzyWeight: 0.3,
    userWeight: 0.6,
    categoryWeight: 0.1,
  );

  /// Category-focused preset (prioritize workout context)
  static const categoryFocused = MLFormulaWeights(
    fuzzyWeight: 0.4,
    userWeight: 0.2,
    categoryWeight: 0.4,
  );

  /// Validate weights
  ///
  /// Ensures:
  /// - All weights are between 0.0 and 1.0
  /// - Weights sum to ~1.0 (within 0.001 tolerance)
  ///
  /// Throws [ArgumentError] if invalid
  void validate() {
    if (fuzzyWeight < 0.0 || fuzzyWeight > 1.0) {
      throw ArgumentError('fuzzyWeight must be between 0.0 and 1.0');
    }
    if (userWeight < 0.0 || userWeight > 1.0) {
      throw ArgumentError('userWeight must be between 0.0 and 1.0');
    }
    if (categoryWeight < 0.0 || categoryWeight > 1.0) {
      throw ArgumentError('categoryWeight must be between 0.0 and 1.0');
    }

    final sum = fuzzyWeight + userWeight + categoryWeight;
    if ((sum - 1.0).abs() > 0.001) {
      throw ArgumentError(
        'Weights must sum to 1.0 (got $sum). '
        'Adjust fuzzy ($fuzzyWeight) + user ($userWeight) + category ($categoryWeight).',
      );
    }
  }

  /// Check if weights are valid (without throwing)
  bool get isValid {
    try {
      validate();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Calculate final ML score
  ///
  /// Formula: (fuzzy * fuzzyScore) + (user * userBoost) + (category * categoryBoost)
  ///
  /// [fuzzyScore] - Fuzzy matching score (0.0-1.0)
  /// [userBoost] - User boost score (0.0-1.0)
  /// [categoryBoost] - Category boost score (0.0-1.0)
  ///
  /// Returns: Final combined score (0.0-1.0)
  double calculateScore({
    required double fuzzyScore,
    required double userBoost,
    required double categoryBoost,
  }) {
    final score = (fuzzyWeight * fuzzyScore) +
        (userWeight * userBoost) +
        (categoryWeight * categoryBoost);

    // Cap at 1.0
    return score > 1.0 ? 1.0 : score;
  }

  /// Copy with modifications
  MLFormulaWeights copyWith({
    double? fuzzyWeight,
    double? userWeight,
    double? categoryWeight,
  }) {
    return MLFormulaWeights(
      fuzzyWeight: fuzzyWeight ?? this.fuzzyWeight,
      userWeight: userWeight ?? this.userWeight,
      categoryWeight: categoryWeight ?? this.categoryWeight,
    );
  }

  @override
  String toString() {
    return 'MLFormulaWeights(fuzzy: $fuzzyWeight, user: $userWeight, category: $categoryWeight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MLFormulaWeights &&
        other.fuzzyWeight == fuzzyWeight &&
        other.userWeight == userWeight &&
        other.categoryWeight == categoryWeight;
  }

  @override
  int get hashCode {
    return fuzzyWeight.hashCode ^ userWeight.hashCode ^ categoryWeight.hashCode;
  }
}
