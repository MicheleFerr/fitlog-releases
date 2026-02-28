// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';

void main() {
  // ========================================================
  // UnifiedFeedbackType
  // ========================================================
  group('UnifiedFeedbackType', () {
    group('values', () {
      test('has 6 cases', () {
        expect(UnifiedFeedbackType.values.length, 6);
      });

      test('each type has a non-empty value string', () {
        for (final type in UnifiedFeedbackType.values) {
          expect(type.value, isNotEmpty);
        }
      });
    });

    group('fromString', () {
      test('returns exercise for "exercise"', () {
        expect(
          UnifiedFeedbackType.fromString('exercise'),
          UnifiedFeedbackType.exercise,
        );
      });

      test('returns aiInsight for "ai_insight"', () {
        expect(
          UnifiedFeedbackType.fromString('ai_insight'),
          UnifiedFeedbackType.aiInsight,
        );
      });

      test('returns analytics for "analytics"', () {
        expect(
          UnifiedFeedbackType.fromString('analytics'),
          UnifiedFeedbackType.analytics,
        );
      });

      test('returns buddyReport for "buddy_report"', () {
        expect(
          UnifiedFeedbackType.fromString('buddy_report'),
          UnifiedFeedbackType.buddyReport,
        );
      });

      test('returns general for "general"', () {
        expect(
          UnifiedFeedbackType.fromString('general'),
          UnifiedFeedbackType.general,
        );
      });

      test('returns exercisePatch for "exercise_patch"', () {
        expect(
          UnifiedFeedbackType.fromString('exercise_patch'),
          UnifiedFeedbackType.exercisePatch,
        );
      });

      test('throws ArgumentError for unknown string', () {
        expect(
          () => UnifiedFeedbackType.fromString('unknown_type'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('exercise returns "Exercise Feedback"', () {
        expect(UnifiedFeedbackType.exercise.displayName, 'Exercise Feedback');
      });

      test('aiInsight returns "AI Insight Feedback"', () {
        expect(UnifiedFeedbackType.aiInsight.displayName, 'AI Insight Feedback');
      });

      test('analytics returns "Analytics Feedback"', () {
        expect(UnifiedFeedbackType.analytics.displayName, 'Analytics Feedback');
      });

      test('buddyReport returns "User Report"', () {
        expect(UnifiedFeedbackType.buddyReport.displayName, 'User Report');
      });

      test('general returns "General Feedback"', () {
        expect(UnifiedFeedbackType.general.displayName, 'General Feedback');
      });

      test('exercisePatch returns "Exercise Patch"', () {
        expect(UnifiedFeedbackType.exercisePatch.displayName, 'Exercise Patch');
      });
    });

    group('icon', () {
      test('each type has a non-empty icon string', () {
        for (final type in UnifiedFeedbackType.values) {
          expect(type.icon, isNotEmpty);
        }
      });
    });
  });

  // ========================================================
  // UnifiedFeedbackStatus
  // ========================================================
  group('UnifiedFeedbackStatus', () {
    group('values', () {
      test('has 5 cases', () {
        expect(UnifiedFeedbackStatus.values.length, 5);
      });
    });

    group('fromString', () {
      test('returns open for "open"', () {
        expect(
          UnifiedFeedbackStatus.fromString('open'),
          UnifiedFeedbackStatus.open,
        );
      });

      test('returns reviewing for "reviewing"', () {
        expect(
          UnifiedFeedbackStatus.fromString('reviewing'),
          UnifiedFeedbackStatus.reviewing,
        );
      });

      test('returns resolved for "resolved"', () {
        expect(
          UnifiedFeedbackStatus.fromString('resolved'),
          UnifiedFeedbackStatus.resolved,
        );
      });

      test('returns dismissed for "dismissed"', () {
        expect(
          UnifiedFeedbackStatus.fromString('dismissed'),
          UnifiedFeedbackStatus.dismissed,
        );
      });

      test('returns closed for "closed"', () {
        expect(
          UnifiedFeedbackStatus.fromString('closed'),
          UnifiedFeedbackStatus.closed,
        );
      });

      test('falls back to open for unknown string', () {
        expect(
          UnifiedFeedbackStatus.fromString('invalid_status'),
          UnifiedFeedbackStatus.open,
        );
      });
    });

    group('isActionable', () {
      test('open is actionable', () {
        expect(UnifiedFeedbackStatus.open.isActionable, isTrue);
      });

      test('reviewing is actionable', () {
        expect(UnifiedFeedbackStatus.reviewing.isActionable, isTrue);
      });

      test('resolved is not actionable', () {
        expect(UnifiedFeedbackStatus.resolved.isActionable, isFalse);
      });

      test('dismissed is not actionable', () {
        expect(UnifiedFeedbackStatus.dismissed.isActionable, isFalse);
      });

      test('closed is not actionable', () {
        expect(UnifiedFeedbackStatus.closed.isActionable, isFalse);
      });
    });

    group('isCompleted', () {
      test('resolved is completed', () {
        expect(UnifiedFeedbackStatus.resolved.isCompleted, isTrue);
      });

      test('dismissed is completed', () {
        expect(UnifiedFeedbackStatus.dismissed.isCompleted, isTrue);
      });

      test('closed is completed', () {
        expect(UnifiedFeedbackStatus.closed.isCompleted, isTrue);
      });

      test('open is not completed', () {
        expect(UnifiedFeedbackStatus.open.isCompleted, isFalse);
      });

      test('reviewing is not completed', () {
        expect(UnifiedFeedbackStatus.reviewing.isCompleted, isFalse);
      });
    });

    group('displayName', () {
      test('open returns "Open"', () {
        expect(UnifiedFeedbackStatus.open.displayName, 'Open');
      });

      test('reviewing returns "Reviewing"', () {
        expect(UnifiedFeedbackStatus.reviewing.displayName, 'Reviewing');
      });

      test('resolved returns "Resolved"', () {
        expect(UnifiedFeedbackStatus.resolved.displayName, 'Resolved');
      });

      test('dismissed returns "Dismissed"', () {
        expect(UnifiedFeedbackStatus.dismissed.displayName, 'Dismissed');
      });

      test('closed returns "Closed"', () {
        expect(UnifiedFeedbackStatus.closed.displayName, 'Closed');
      });
    });

    group('colorKey', () {
      test('each status has a non-empty colorKey', () {
        for (final status in UnifiedFeedbackStatus.values) {
          expect(status.colorKey, isNotEmpty);
        }
      });
    });
  });

  // ========================================================
  // FeedbackSeverity
  // ========================================================
  group('FeedbackSeverity', () {
    group('values', () {
      test('has 4 cases', () {
        expect(FeedbackSeverity.values.length, 4);
      });
    });

    group('level ordering', () {
      test('low has level 1', () {
        expect(FeedbackSeverity.low.level, 1);
      });

      test('medium has level 2', () {
        expect(FeedbackSeverity.medium.level, 2);
      });

      test('high has level 3', () {
        expect(FeedbackSeverity.high.level, 3);
      });

      test('critical has level 4', () {
        expect(FeedbackSeverity.critical.level, 4);
      });

      test('levels are strictly increasing', () {
        final levels = FeedbackSeverity.values.map((s) => s.level).toList();
        for (var i = 0; i < levels.length - 1; i++) {
          expect(levels[i], lessThan(levels[i + 1]));
        }
      });
    });

    group('fromString', () {
      test('returns low for "low"', () {
        expect(FeedbackSeverity.fromString('low'), FeedbackSeverity.low);
      });

      test('returns medium for "medium"', () {
        expect(FeedbackSeverity.fromString('medium'), FeedbackSeverity.medium);
      });

      test('returns high for "high"', () {
        expect(FeedbackSeverity.fromString('high'), FeedbackSeverity.high);
      });

      test('returns critical for "critical"', () {
        expect(
          FeedbackSeverity.fromString('critical'),
          FeedbackSeverity.critical,
        );
      });

      test('falls back to medium for unknown string', () {
        expect(
          FeedbackSeverity.fromString('unknown_severity'),
          FeedbackSeverity.medium,
        );
      });
    });

    group('fromLevel', () {
      test('returns low for level 1', () {
        expect(FeedbackSeverity.fromLevel(1), FeedbackSeverity.low);
      });

      test('returns medium for level 2', () {
        expect(FeedbackSeverity.fromLevel(2), FeedbackSeverity.medium);
      });

      test('returns high for level 3', () {
        expect(FeedbackSeverity.fromLevel(3), FeedbackSeverity.high);
      });

      test('returns critical for level 4', () {
        expect(FeedbackSeverity.fromLevel(4), FeedbackSeverity.critical);
      });

      test('falls back to medium for unknown level', () {
        expect(FeedbackSeverity.fromLevel(99), FeedbackSeverity.medium);
      });
    });

    group('displayName', () {
      test('low returns "Low"', () {
        expect(FeedbackSeverity.low.displayName, 'Low');
      });

      test('medium returns "Medium"', () {
        expect(FeedbackSeverity.medium.displayName, 'Medium');
      });

      test('high returns "High"', () {
        expect(FeedbackSeverity.high.displayName, 'High');
      });

      test('critical returns "Critical"', () {
        expect(FeedbackSeverity.critical.displayName, 'Critical');
      });
    });

    group('colorKey', () {
      test('each severity has a non-empty colorKey', () {
        for (final severity in FeedbackSeverity.values) {
          expect(severity.colorKey, isNotEmpty);
        }
      });
    });

    group('icon', () {
      test('each severity has a non-empty icon', () {
        for (final severity in FeedbackSeverity.values) {
          expect(severity.icon, isNotEmpty);
        }
      });
    });
  });
}
