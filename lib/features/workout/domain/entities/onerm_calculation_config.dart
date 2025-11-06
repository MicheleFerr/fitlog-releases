/// Configuration for 1RM calculation strategy
///
/// Different strategies select different subsets of historical sets
/// to use for 1RM estimation, allowing users to optimize for:
/// - Recency (top N most recent sets)
/// - Quality (top N heaviest sets)
/// - Consistency (median of top sets)
/// - Completeness (all sets in time window)
///
/// Example usage:
/// ```dart
/// final config = OneRMCalculationConfig.topFiveSets;
/// final result = await APREAutoRegulationService.calculateAPREWeights(
///   userId: userId,
///   exerciseId: exerciseId,
///   protocol: APREProtocol.apre6RM,
///   config: config, // Use specific strategy
/// );
/// ```
enum OneRMCalculationConfig {
  /// Use the top 3 most recent sets (prioritizes recency)
  ///
  /// Best for: Users who train consistently and want most recent data
  /// Trade-off: Ignores older PRs, may miss peak performance
  ///
  /// Calculation: Selects the 3 most recent sets from history,
  /// regardless of weight. Calculates 1RM from these sets only.
  topThreeSets,

  /// Use the top 5 most recent sets (balanced approach)
  ///
  /// Best for: Most users - balances recency with data volume
  /// Trade-off: Still recency-biased, may miss older PRs
  ///
  /// Calculation: Selects the 5 most recent sets from history,
  /// regardless of weight. Calculates 1RM from these sets only.
  ///
  /// This is the default configuration for most users.
  topFiveSets,

  /// Use all sets within the cache validity window (7 days by default)
  ///
  /// Best for: Users who want comprehensive data, training 3-5x/week
  /// Trade-off: May include outliers or suboptimal performances
  ///
  /// Calculation: Uses all sets within the configured time window
  /// (default: 7 days). Provides most comprehensive data picture.
  allSetsInWindow,

  /// Use median of top 5 sets (prioritizes consistency)
  ///
  /// Best for: Users who want stable estimates, less sensitive to outliers
  /// Trade-off: Less responsive to rapid strength gains
  ///
  /// Calculation: Selects top 5 sets, calculates 1RM for each,
  /// then returns the median value instead of mean. Minimizes
  /// impact of outlier performances.
  medianOfTop5,
}

/// Extension providing human-readable labels and metadata for UI
///
/// Provides display names, descriptions, and use case recommendations
/// for each calculation strategy. Used in settings UI to help users
/// choose the most appropriate configuration.
extension OneRMCalculationConfigExtension on OneRMCalculationConfig {
  /// Display name for settings UI
  ///
  /// Short, descriptive label that indicates the strategy and its focus.
  String get displayName {
    switch (this) {
      case OneRMCalculationConfig.topThreeSets:
        return 'Top 3 Sets (Recency)';
      case OneRMCalculationConfig.topFiveSets:
        return 'Top 5 Sets (Balanced)';
      case OneRMCalculationConfig.allSetsInWindow:
        return 'All Recent Sets (Comprehensive)';
      case OneRMCalculationConfig.medianOfTop5:
        return 'Median Top 5 (Stable)';
    }
  }

  /// Description for settings UI tooltip
  ///
  /// Longer explanation of how the strategy works and what it optimizes for.
  /// Should help users understand the trade-offs of each option.
  String get description {
    switch (this) {
      case OneRMCalculationConfig.topThreeSets:
        return 'Uses your 3 most recent sets. Best for consistent training.';
      case OneRMCalculationConfig.topFiveSets:
        return 'Uses your 5 most recent sets. Recommended for most users.';
      case OneRMCalculationConfig.allSetsInWindow:
        return 'Uses all sets from the past week. Most comprehensive data.';
      case OneRMCalculationConfig.medianOfTop5:
        return 'Uses median of 5 best sets. Minimizes impact of outliers.';
    }
  }

  /// Recommended use case
  ///
  /// Brief indication of which training frequency or preference
  /// this configuration is best suited for.
  String get useCase {
    switch (this) {
      case OneRMCalculationConfig.topThreeSets:
        return 'Train 5-7x/week';
      case OneRMCalculationConfig.topFiveSets:
        return 'Train 3-5x/week (Default)';
      case OneRMCalculationConfig.allSetsInWindow:
        return 'Want full data picture';
      case OneRMCalculationConfig.medianOfTop5:
        return 'Prefer stable estimates';
    }
  }

  /// Default configuration (balanced approach)
  ///
  /// Returns [topFiveSets] as the recommended default for most users.
  /// This balances recency (important for progressive overload) with
  /// sufficient data volume to reduce variance.
  static OneRMCalculationConfig get defaultConfig =>
      OneRMCalculationConfig.topFiveSets;
}
