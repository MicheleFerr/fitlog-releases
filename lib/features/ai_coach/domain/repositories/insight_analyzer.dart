import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Strategy interface for AI Coach insight analyzers
///
/// Each analyzer implements this interface to analyze workout data
/// and generate specific types of insights.
///
/// Example implementations:
/// - VolumeBalanceAnalyzer: Detects muscle group imbalances
/// - ProgressiveOverloadAnalyzer: Tracks weight progression
/// - CNSFatigueAnalyzer: Monitors central nervous system stress
abstract class InsightAnalyzer {
  /// Analyzes workout data and returns an insight if applicable
  ///
  /// Returns null if:
  /// - Insufficient data for analysis
  /// - No actionable insight detected
  /// - Feature is not enabled for user's tier
  ///
  /// [workouts] - List of user's workouts to analyze
  /// [context] - User context for personalized thresholds
  Future<AIInsight?> analyze(
    List<Workout> workouts,
    UserContext context,
  );

  /// The type of insight this analyzer generates
  InsightType get type;

  /// Base priority for this insight type (1-10 scale)
  ///
  /// Lower number = higher priority
  /// 1 = Critical (CNS fatigue, injury risk)
  /// 5 = Important (plateau, volume optimization)
  /// 10 = Informational (motivational, tips)
  int get basePriority;

  /// Whether this analyzer should run for the given user context
  ///
  /// Used for feature gating (free vs. premium tiers)
  ///
  /// Example: CNS Fatigue analyzer only runs for Pro tier users
  bool shouldAnalyze(UserContext context);
}
