import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';

/// Registry for dynamically loading and managing insight analyzers
///
/// Implements the Registry pattern to enable:
/// - Plugin architecture (easily add new analyzers)
/// - Feature gating (enable/disable by user tier)
/// - Dependency injection (retrieve analyzers by type)
class AnalyzerRegistry {
  /// Factory constructor returns singleton instance
  factory AnalyzerRegistry() => _instance;

  /// Private constructor for singleton
  AnalyzerRegistry._internal();

  /// Singleton instance
  static final AnalyzerRegistry _instance = AnalyzerRegistry._internal();

  /// Registered analyzers by type
  final Map<InsightType, InsightAnalyzer> _analyzers = {};

  /// Registers an analyzer for a specific insight type
  ///
  /// Throws [StateError] if an analyzer is already registered for this type
  void registerAnalyzer(InsightAnalyzer analyzer) {
    if (_analyzers.containsKey(analyzer.type)) {
      throw StateError(
        'Analyzer already registered for type: ${analyzer.type}',
      );
    }
    _analyzers[analyzer.type] = analyzer;
  }

  /// Retrieves an analyzer by insight type
  ///
  /// Throws [StateError] if no analyzer is registered for this type
  InsightAnalyzer getAnalyzer(InsightType type) {
    final analyzer = _analyzers[type];
    if (analyzer == null) {
      throw StateError('No analyzer registered for type: $type');
    }
    return analyzer;
  }

  /// Retrieves all analyzers that should run for the given user context
  ///
  /// Filters analyzers based on:
  /// - Feature gating (free vs. premium)
  /// - User preferences
  ///
  /// Returns analyzers sorted by priority (critical first)
  List<InsightAnalyzer> getAllEnabledAnalyzers(UserContext context) {
    final enabledAnalyzers = _analyzers.values
        .where((analyzer) => analyzer.shouldAnalyze(context))
        .toList();

    // Sort by priority (lower number = higher priority)
    enabledAnalyzers.sort((a, b) => a.basePriority.compareTo(b.basePriority));

    return enabledAnalyzers;
  }

  /// Checks if an analyzer is registered for the given type
  bool isRegistered(InsightType type) {
    return _analyzers.containsKey(type);
  }

  /// Unregisters an analyzer (used for testing)
  void unregisterAnalyzer(InsightType type) {
    _analyzers.remove(type);
  }

  /// Clears all registered analyzers (used for testing)
  void clearAll() {
    _analyzers.clear();
  }

  /// Returns total number of registered analyzers
  int get count => _analyzers.length;
}
