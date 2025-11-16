/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// Unit tests for FeatureGateConfig domain entity
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/feature_gate_config.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

void main() {
  group('FeatureGateConfig', () {
    test('should create with default values', () {
      const config = FeatureGateConfig(
        feature: AiCoachFeature.insights,
        displayNameKey: 'featureInsightsName',
        descriptionKey: 'featureInsightsDescription',
      );

      expect(config.feature, AiCoachFeature.insights);
      expect(config.displayNameKey, 'featureInsightsName');
      expect(config.descriptionKey, 'featureInsightsDescription');
      expect(config.rules, isEmpty);
      expect(config.isGloballyEnabled, true);
      expect(config.defaultEnabled, false);
      expect(config.userConfigurable, true);
    });

    test('should create with custom rules', () {
      final config = FeatureGateConfig(
        feature: AiCoachFeature.advancedAnalytics,
        displayNameKey: 'featureAdvancedAnalyticsName',
        descriptionKey: 'featureAdvancedAnalyticsDescription',
        rules: [
          GateRule(
            type: GateRuleType.minExperienceLevel,
            value: ExperienceLevel.intermediate.name,
          ),
          const GateRule(
            type: GateRuleType.minWorkoutCount,
            value: 5,
          ),
        ],
      );

      expect(config.rules.length, 2);
      expect(config.rules[0].type, GateRuleType.minExperienceLevel);
      expect(config.rules[1].type, GateRuleType.minWorkoutCount);
    });

    test('should serialize to/from JSON', () {
      const config = FeatureGateConfig(
        feature: AiCoachFeature.notifications,
        displayNameKey: 'featureNotificationsName',
        descriptionKey: 'featureNotificationsDescription',
        isGloballyEnabled: true,
        defaultEnabled: true,
        userConfigurable: true,
      );

      final json = config.toJson();
      final decoded = FeatureGateConfig.fromJson(json);

      expect(decoded.feature, config.feature);
      expect(decoded.displayNameKey, config.displayNameKey);
      expect(decoded.descriptionKey, config.descriptionKey);
      expect(decoded.isGloballyEnabled, config.isGloballyEnabled);
      expect(decoded.defaultEnabled, config.defaultEnabled);
      expect(decoded.userConfigurable, config.userConfigurable);
    });

    group('isEnabledByDefault', () {
      test('should return true when both defaultEnabled and isGloballyEnabled are true', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
          defaultEnabled: true,
          isGloballyEnabled: true,
        );

        expect(config.isEnabledByDefault, true);
      });

      test('should return false when defaultEnabled is false', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
          defaultEnabled: false,
          isGloballyEnabled: true,
        );

        expect(config.isEnabledByDefault, false);
      });

      test('should return false when isGloballyEnabled is false', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
          defaultEnabled: true,
          isGloballyEnabled: false,
        );

        expect(config.isEnabledByDefault, false);
      });
    });

    group('hasRules', () {
      test('should return true when rules list is not empty', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
          rules: [
            GateRule(
              type: GateRuleType.minWorkoutCount,
              value: 5,
            ),
          ],
        );

        expect(config.hasRules, true);
      });

      test('should return false when rules list is empty', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
        );

        expect(config.hasRules, false);
      });
    });

    group('minExperienceLevel', () {
      test('should return experience level when rule exists', () {
        final config = FeatureGateConfig(
          feature: AiCoachFeature.advancedAnalytics,
          displayNameKey: 'test',
          descriptionKey: 'test',
          rules: [
            GateRule(
              type: GateRuleType.minExperienceLevel,
              value: ExperienceLevel.intermediate.name,
            ),
          ],
        );

        expect(config.minExperienceLevel, ExperienceLevel.intermediate.name);
      });

      test('should return null when no experience level rule exists', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
          rules: [
            GateRule(
              type: GateRuleType.minWorkoutCount,
              value: 5,
            ),
          ],
        );

        expect(config.minExperienceLevel, null);
      });
    });

    group('minWorkoutCount', () {
      test('should return workout count when rule exists', () {
        const config = FeatureGateConfig(
          feature: AiCoachFeature.workoutSuggestions,
          displayNameKey: 'test',
          descriptionKey: 'test',
          rules: [
            GateRule(
              type: GateRuleType.minWorkoutCount,
              value: 3,
            ),
          ],
        );

        expect(config.minWorkoutCount, 3);
      });

      test('should return null when no workout count rule exists', () {
        final config = FeatureGateConfig(
          feature: AiCoachFeature.insights,
          displayNameKey: 'test',
          descriptionKey: 'test',
          rules: [
            GateRule(
              type: GateRuleType.minExperienceLevel,
              value: ExperienceLevel.beginner.name,
            ),
          ],
        );

        expect(config.minWorkoutCount, null);
      });
    });
  });

  group('GateRule', () {
    test('should create with required fields', () {
      const rule = GateRule(
        type: GateRuleType.minWorkoutCount,
        value: 5,
      );

      expect(rule.type, GateRuleType.minWorkoutCount);
      expect(rule.value, 5);
    });

    test('should serialize to/from JSON', () {
      const rule = GateRule(
        type: GateRuleType.minDaysSinceRegistration,
        value: 7,
      );

      final json = rule.toJson();
      final decoded = GateRule.fromJson(json);

      expect(decoded.type, rule.type);
      expect(decoded.value, rule.value);
    });
  });

  group('FeatureGateStatus', () {
    test('should create with enabled status', () {
      final status = FeatureGateStatus(
        feature: AiCoachFeature.insights,
        isEnabled: true,
        reasonKey: 'featureGateReasonAllRulesPassed',
        evaluatedAt: DateTime.now(),
      );

      expect(status.feature, AiCoachFeature.insights);
      expect(status.isEnabled, true);
      expect(status.reasonKey, 'featureGateReasonAllRulesPassed');
      expect(status.passedRules, isEmpty);
      expect(status.failedRules, isEmpty);
    });

    test('should create with failed rules', () {
      final status = FeatureGateStatus(
        feature: AiCoachFeature.advancedAnalytics,
        isEnabled: false,
        reasonKey: 'featureGateReasonInsufficientExperience',
        passedRules: [GateRuleType.minWorkoutCount],
        failedRules: [GateRuleType.minExperienceLevel],
        evaluatedAt: DateTime.now(),
      );

      expect(status.isEnabled, false);
      expect(status.passedRules.length, 1);
      expect(status.failedRules.length, 1);
      expect(status.failedRules.first, GateRuleType.minExperienceLevel);
    });

    test('should serialize to/from JSON', () {
      final status = FeatureGateStatus(
        feature: AiCoachFeature.notifications,
        isEnabled: true,
        reasonKey: 'featureGateReasonDefaultEnabled',
        evaluatedAt: DateTime.now(),
      );

      final json = status.toJson();
      final decoded = FeatureGateStatus.fromJson(json);

      expect(decoded.feature, status.feature);
      expect(decoded.isEnabled, status.isEnabled);
      expect(decoded.reasonKey, status.reasonKey);
    });

    group('allRulesPassed', () {
      test('should return true when no failed rules', () {
        final status = FeatureGateStatus(
          feature: AiCoachFeature.insights,
          isEnabled: true,
          reasonKey: 'featureGateReasonAllRulesPassed',
          passedRules: [
            GateRuleType.minWorkoutCount,
            GateRuleType.minExperienceLevel,
          ],
          evaluatedAt: DateTime.now(),
        );

        expect(status.allRulesPassed, true);
      });

      test('should return false when there are failed rules', () {
        final status = FeatureGateStatus(
          feature: AiCoachFeature.advancedAnalytics,
          isEnabled: false,
          reasonKey: 'featureGateReasonInsufficientWorkouts',
          failedRules: [GateRuleType.minWorkoutCount],
          evaluatedAt: DateTime.now(),
        );

        expect(status.allRulesPassed, false);
      });
    });

    group('hasFailedRules', () {
      test('should return true when there are failed rules', () {
        final status = FeatureGateStatus(
          feature: AiCoachFeature.recoveryInsights,
          isEnabled: false,
          reasonKey: 'featureGateReasonInsufficientExperience',
          failedRules: [GateRuleType.minExperienceLevel],
          evaluatedAt: DateTime.now(),
        );

        expect(status.hasFailedRules, true);
      });

      test('should return false when no failed rules', () {
        final status = FeatureGateStatus(
          feature: AiCoachFeature.insights,
          isEnabled: true,
          reasonKey: 'featureGateReasonAllRulesPassed',
          evaluatedAt: DateTime.now(),
        );

        expect(status.hasFailedRules, false);
      });
    });
  });
}
