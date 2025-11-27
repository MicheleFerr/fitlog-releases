import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

part 'insight_rule.freezed.dart';
part 'insight_rule.g.dart';

/// Dynamic rules for insight generation
@freezed
abstract class InsightRule with _$InsightRule {
  const factory InsightRule({
    required InsightType insightType,
    required int minWeeks, // Minimum weeks of data required
    required double volumeThreshold, // ±% volume change to trigger
    required Map<ExperienceLevel, PersonalizedThreshold> personalizedThresholds,
  }) = _InsightRule;

  factory InsightRule.fromJson(Map<String, dynamic> json) =>
      _$InsightRuleFromJson(json);
}

/// Personalized thresholds based on experience level
@freezed
abstract class PersonalizedThreshold with _$PersonalizedThreshold {
  const factory PersonalizedThreshold({
    required double mev, // Minimum Effective Volume (sets per week)
    required double mav, // Maximum Adaptive Volume (sets per week)
    required double mrv, // Maximum Recoverable Volume (sets per week)
  }) = _PersonalizedThreshold;

  factory PersonalizedThreshold.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedThresholdFromJson(json);
}
