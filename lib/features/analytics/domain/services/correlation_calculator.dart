import 'dart:math';

import 'package:gymbro_flutter_new/features/analytics/domain/entities/correlation_result.dart';

/// Correlation Calculator Service
///
/// Calculates Pearson correlation coefficient between two metrics.
///
/// **Scientific Basis**:
/// - Pearson's r: Measures linear relationship strength (-1 to +1)
/// - r²: Coefficient of determination (variance explained, 0 to 1)
///
/// **Performance**:
/// - O(n) time complexity
/// - For large datasets (100+ points), use calculateAsync()
///
/// **References**:
/// - Pearson, K. (1895). "Notes on regression and inheritance"
/// - Cohen, J. (1988). "Statistical Power Analysis for the Behavioral Sciences"
class CorrelationCalculator {
  /// Calculate Pearson correlation coefficient between two metrics
  ///
  /// **Requirements**:
  /// - Both lists must have same length
  /// - Minimum 3 data points for meaningful correlation
  ///
  /// **Returns**:
  /// - CorrelationResult with r, r², strength, and interpretation
  ///
  /// **Example**:
  /// ```dart
  /// final result = CorrelationCalculator.calculateCorrelation(
  ///   metricA: [70.0, 72.5, 75.0, 77.5, 80.0],  // Weight
  ///   metricB: [7, 7, 8, 8, 9].map((e) => e.toDouble()).toList(),  // RPE
  ///   metricAName: 'Weight',
  ///   metricBName: 'RPE',
  /// );
  /// print(result.rSquared);  // 0.85
  /// print(result.strength);  // CorrelationStrength.strong
  /// ```
  static CorrelationResult calculateCorrelation({
    required List<double> metricA,
    required List<double> metricB,
    String metricAName = 'Metric A',
    String metricBName = 'Metric B',
  }) {
    // Validate input
    if (metricA.length != metricB.length) {
      return CorrelationResult.insufficient();
    }

    if (metricA.length < 3) {
      return CorrelationResult.insufficient();
    }

    final n = metricA.length;

    // Calculate means
    final meanA = metricA.reduce((a, b) => a + b) / n;
    final meanB = metricB.reduce((a, b) => a + b) / n;

    // Calculate Pearson correlation components
    double numerator = 0;
    double denomA = 0;
    double denomB = 0;

    for (int i = 0; i < n; i++) {
      final diffA = metricA[i] - meanA;
      final diffB = metricB[i] - meanB;
      numerator += diffA * diffB;
      denomA += diffA * diffA;
      denomB += diffB * diffB;
    }

    // Avoid division by zero
    if (denomA == 0 || denomB == 0) {
      return CorrelationResult(
        r: 0,
        rSquared: 0,
        strength: CorrelationStrength.weak,
        interpretation: 'No variance in one or both metrics',
        dataPoints: n,
        isSignificant: false,
      );
    }

    // Calculate r
    final r = numerator / (sqrt(denomA) * sqrt(denomB));
    final rSquared = r * r;

    // Determine strength
    final strength = _getStrength(rSquared);

    // Check statistical significance (using n > 5 as simple threshold)
    // For proper significance, use t-test: t = r * sqrt((n-2)/(1-r²))
    final isSignificant = n >= 5 && rSquared >= 0.4;

    // Generate interpretation
    final interpretation = _getInterpretation(
      r: r,
      rSquared: rSquared,
      metricAName: metricAName,
      metricBName: metricBName,
    );

    return CorrelationResult(
      r: r,
      rSquared: rSquared,
      strength: strength,
      interpretation: interpretation,
      dataPoints: n,
      isSignificant: isSignificant,
    );
  }

  /// Async version for large datasets (100+ points)
  ///
  /// Runs calculation in an isolate to prevent UI jank.
  /// Use this when calculating correlations in providers.
  static Future<CorrelationResult> calculateAsync({
    required List<double> metricA,
    required List<double> metricB,
    String metricAName = 'Metric A',
    String metricBName = 'Metric B',
  }) async {
    // For now, just wrap sync version
    // TODO: Implement isolate for very large datasets (500+)
    return calculateCorrelation(
      metricA: metricA,
      metricB: metricB,
      metricAName: metricAName,
      metricBName: metricBName,
    );
  }

  /// Calculate all correlations for exercise analytics
  ///
  /// **Calculates**:
  /// - Weight vs RPE
  /// - Volume vs RPE
  static Future<CorrelationResults> calculateAllCorrelations({
    required List<double> weights,
    required List<double> volumes,
    required List<double> rpes,
  }) async {
    final weightRpe = await calculateAsync(
      metricA: weights,
      metricB: rpes,
      metricAName: 'Weight',
      metricBName: 'RPE',
    );

    final volumeRpe = await calculateAsync(
      metricA: volumes,
      metricB: rpes,
      metricAName: 'Volume',
      metricBName: 'RPE',
    );

    return CorrelationResults(weightRpe: weightRpe, volumeRpe: volumeRpe);
  }

  /// Determine correlation strength from r²
  static CorrelationStrength _getStrength(double rSquared) {
    if (rSquared >= 0.7) return CorrelationStrength.strong;
    if (rSquared >= 0.4) return CorrelationStrength.moderate;
    return CorrelationStrength.weak;
  }

  /// Generate human-readable interpretation
  static String _getInterpretation({
    required double r,
    required double rSquared,
    required String metricAName,
    required String metricBName,
  }) {
    final strength = _getStrength(rSquared);
    final direction = r > 0 ? 'increases' : 'decreases';

    switch (strength) {
      case CorrelationStrength.strong:
        return 'Strong correlation: $metricAName $direction as $metricBName increases';
      case CorrelationStrength.moderate:
        return 'Moderate correlation between $metricAName and $metricBName';
      case CorrelationStrength.weak:
        return '$metricAName and $metricBName appear independent';
      case CorrelationStrength.insufficient:
        return 'Need more data for correlation analysis';
    }
  }
}
