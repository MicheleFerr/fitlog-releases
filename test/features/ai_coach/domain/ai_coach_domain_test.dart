/// Unit tests for the AI Coach domain layer.
///
/// Tests all pure domain entities and their computed properties without
/// any external dependencies. No mocking required - these are value objects.
///
/// Coverage targets:
/// - AIContext: toPromptString(), all fields, copyWith immutability
/// - AIMessage: isVisible, hasToolCall, all roles
/// - AIQuota: isExhausted, remaining messages
/// - RateLimitResult: factory constructors, computed getters
/// - DocumentSyncStatus: isUpToDate, hasError, needsSync
/// - ExerciseSuggestion: hasData
/// - ScientificPaper: formatCitation(), toContextString()
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/document_sync_status.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/exercise_suggestion.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/rate_limit_result.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/scientific_paper.dart';

void main() {
  // ---------------------------------------------------------------------------
  // WorkoutSummary
  // ---------------------------------------------------------------------------

  group('WorkoutSummary', () {
    test('creates with all required fields', () {
      final summary = WorkoutSummary(
        id: 'ws-1',
        name: 'Push Day',
        completedAt: DateTime.utc(2026, 2, 28, 10, 0),
      );

      expect(summary.id, 'ws-1');
      expect(summary.name, 'Push Day');
      expect(summary.durationMinutes, isNull);
      expect(summary.exerciseCount, isNull);
    });

    test('creates with optional fields populated', () {
      final summary = WorkoutSummary(
        id: 'ws-2',
        name: 'Leg Day',
        completedAt: DateTime.utc(2026, 2, 27),
        durationMinutes: 60,
        exerciseCount: 5,
      );

      expect(summary.durationMinutes, 60);
      expect(summary.exerciseCount, 5);
    });

    test('copyWith produces new instance with changed field', () {
      final original = WorkoutSummary(
        id: 'ws-3',
        name: 'Back Day',
        completedAt: DateTime.utc(2026, 2, 26),
        durationMinutes: 45,
      );
      final updated = original.copyWith(name: 'Pull Day');

      expect(updated.name, 'Pull Day');
      expect(updated.id, 'ws-3');
      expect(updated.durationMinutes, 45);
      // Immutability: original is unchanged
      expect(original.name, 'Back Day');
    });

    test('equality holds for identical instances', () {
      final ts = DateTime.utc(2026, 1, 1);
      final a = WorkoutSummary(id: 'ws-4', name: 'Cardio', completedAt: ts);
      final b = WorkoutSummary(id: 'ws-4', name: 'Cardio', completedAt: ts);

      expect(a, equals(b));
    });
  });

  // ---------------------------------------------------------------------------
  // AIContext
  // ---------------------------------------------------------------------------

  group('AIContext', () {
    // Shared fixture used across multiple tests
    WorkoutSummary buildLastWorkout({int hoursAgo = 2}) => WorkoutSummary(
          id: 'ws-fixture',
          name: 'Chest Day',
          completedAt: DateTime.now().subtract(Duration(hours: hoursAgo)),
        );

    AIContext buildContext({
      int streak = 7,
      WorkoutSummary? lastWorkout,
      Map<String, int>? oneRM,
      RecoveryStatus recovery = RecoveryStatus.green,
      String tier = 'premium',
      String? experienceLevel,
      String? fitnessGoal,
    }) =>
        AIContext(
          currentStreak: streak,
          lastWorkout: lastWorkout,
          top5OneRM: oneRM ?? const {'Bench Press': 100, 'Squat': 120},
          recoveryStatus: recovery,
          userTier: tier,
          experienceLevel: experienceLevel,
          fitnessGoal: fitnessGoal,
        );

    group('field defaults and construction', () {
      test('stores all required fields correctly', () {
        final ctx = buildContext(
          streak: 14,
          oneRM: {'Deadlift': 180},
          recovery: RecoveryStatus.amber,
          tier: 'free',
        );

        expect(ctx.currentStreak, 14);
        expect(ctx.top5OneRM, {'Deadlift': 180});
        expect(ctx.recoveryStatus, RecoveryStatus.amber);
        expect(ctx.userTier, 'free');
        expect(ctx.experienceLevel, isNull);
        expect(ctx.fitnessGoal, isNull);
      });

      test('stores optional experienceLevel and fitnessGoal', () {
        final ctx = buildContext(
          experienceLevel: 'athlete',
          fitnessGoal: 'strength',
        );

        expect(ctx.experienceLevel, 'athlete');
        expect(ctx.fitnessGoal, 'strength');
      });

      test('allows empty top5OneRM map', () {
        final ctx = buildContext(oneRM: {});

        expect(ctx.top5OneRM, isEmpty);
      });
    });

    group('copyWith immutability', () {
      test('copyWith creates new instance with changed streak', () {
        final original = buildContext(streak: 5);
        final updated = original.copyWith(currentStreak: 10);

        expect(updated.currentStreak, 10);
        expect(original.currentStreak, 5);
      });

      test('copyWith preserves unchanged fields', () {
        final workout = buildLastWorkout();
        final original = buildContext(
          streak: 3,
          lastWorkout: workout,
          tier: 'premium',
        );
        final updated = original.copyWith(currentStreak: 4);

        expect(updated.lastWorkout, workout);
        expect(updated.userTier, 'premium');
      });

      test('copyWith can clear optional lastWorkout', () {
        final original = buildContext(lastWorkout: buildLastWorkout());
        final updated = original.copyWith(lastWorkout: null);

        expect(updated.lastWorkout, isNull);
      });
    });

    group('toPromptString()', () {
      test('returns non-empty string', () {
        final ctx = buildContext();

        expect(ctx.toPromptString(), isNotEmpty);
      });

      test('includes User Context header', () {
        final ctx = buildContext();

        expect(ctx.toPromptString(), contains('## User Context'));
      });

      test('includes tier information', () {
        final ctx = buildContext(tier: 'premium');

        expect(ctx.toPromptString(), contains('Tier: premium'));
      });

      test('includes streak count', () {
        final ctx = buildContext(streak: 21);

        expect(ctx.toPromptString(), contains('Streak: 21 days'));
      });

      test('includes last workout name when present', () {
        final ctx = buildContext(lastWorkout: buildLastWorkout(hoursAgo: 3));

        expect(ctx.toPromptString(), contains('Chest Day'));
      });

      test('includes last workout hours ago when present', () {
        final ctx = buildContext(lastWorkout: buildLastWorkout(hoursAgo: 5));
        final prompt = ctx.toPromptString();

        // The prompt should contain "5h ago"
        expect(prompt, contains('h ago'));
      });

      test('shows "Never" when no last workout', () {
        final ctx = buildContext(lastWorkout: null);

        expect(ctx.toPromptString(), contains('Last workout: Never'));
      });

      test('includes all 1RM entries', () {
        final ctx = buildContext(
          oneRM: {'Bench Press': 100, 'Squat': 120, 'Deadlift': 150},
        );
        final prompt = ctx.toPromptString();

        expect(prompt, contains('Bench Press: 100kg'));
        expect(prompt, contains('Squat: 120kg'));
        expect(prompt, contains('Deadlift: 150kg'));
      });

      test('includes recovery status in uppercase', () {
        final ctx = buildContext(recovery: RecoveryStatus.red);

        expect(ctx.toPromptString(), contains('Recovery: RED'));
      });

      test('includes GREEN recovery status', () {
        final ctx = buildContext(recovery: RecoveryStatus.green);

        expect(ctx.toPromptString(), contains('Recovery: GREEN'));
      });

      test('includes AMBER recovery status', () {
        final ctx = buildContext(recovery: RecoveryStatus.amber);

        expect(ctx.toPromptString(), contains('Recovery: AMBER'));
      });

      test('includes experience level when provided', () {
        final ctx = buildContext(experienceLevel: 'beginner');

        expect(ctx.toPromptString(), contains('Experience: beginner'));
      });

      test('omits experience level when null', () {
        final ctx = buildContext(experienceLevel: null);

        expect(ctx.toPromptString(), isNot(contains('Experience:')));
      });

      test('includes fitness goal when provided', () {
        final ctx = buildContext(fitnessGoal: 'muscle');

        expect(ctx.toPromptString(), contains('Goal: muscle'));
      });

      test('replaces pipe separator in fitness goal', () {
        final ctx = buildContext(fitnessGoal: 'muscle|strength');
        final prompt = ctx.toPromptString();

        // Pipe should be replaced with ", "
        expect(prompt, contains('Goal: muscle, strength'));
        expect(prompt, isNot(contains('muscle|strength')));
      });

      test('omits fitness goal when null', () {
        final ctx = buildContext(fitnessGoal: null);

        expect(ctx.toPromptString(), isNot(contains('Goal:')));
      });

      test('handles empty 1RM map gracefully', () {
        final ctx = buildContext(oneRM: {});
        // Should not throw and should still produce a valid prompt
        final prompt = ctx.toPromptString();

        expect(prompt, isNotEmpty);
        expect(prompt, contains('Top 1RM:'));
      });

      test('produces multi-line string with newlines', () {
        final ctx = buildContext();
        final prompt = ctx.toPromptString();

        expect(prompt.contains('\n'), isTrue);
      });
    });

    group('RecoveryStatus enum', () {
      test('has three values', () {
        expect(RecoveryStatus.values.length, 3);
      });

      test('values are green, amber, red', () {
        expect(RecoveryStatus.values, containsAll([
          RecoveryStatus.green,
          RecoveryStatus.amber,
          RecoveryStatus.red,
        ]));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // AIMessage
  // ---------------------------------------------------------------------------

  group('AIMessage', () {
    AIMessage buildMessage({
      String id = 'msg-1',
      MessageRole role = MessageRole.user,
      String content = 'Hello',
      AIToolCall? toolCall,
      bool isTyping = false,
      String? error,
      List<String> suggestions = const [],
      bool isDisambiguation = false,
    }) =>
        AIMessage(
          id: id,
          role: role,
          content: content,
          timestamp: DateTime(2026, 2, 28, 12, 0),
          toolCall: toolCall,
          isTyping: isTyping,
          error: error,
          suggestions: suggestions,
          isDisambiguation: isDisambiguation,
        );

    group('field defaults', () {
      test('isTyping defaults to false', () {
        final msg = buildMessage();

        expect(msg.isTyping, isFalse);
      });

      test('suggestions defaults to empty list', () {
        final msg = buildMessage();

        expect(msg.suggestions, isEmpty);
      });

      test('isDisambiguation defaults to false', () {
        final msg = buildMessage();

        expect(msg.isDisambiguation, isFalse);
      });

      test('toolCall defaults to null', () {
        final msg = buildMessage();

        expect(msg.toolCall, isNull);
      });

      test('error defaults to null', () {
        final msg = buildMessage();

        expect(msg.error, isNull);
      });
    });

    group('isVisible computed property', () {
      test('user role is visible', () {
        final msg = buildMessage(role: MessageRole.user);

        expect(msg.isVisible, isTrue);
      });

      test('assistant role is visible', () {
        final msg = buildMessage(role: MessageRole.assistant);

        expect(msg.isVisible, isTrue);
      });

      test('system role is NOT visible', () {
        final msg = buildMessage(role: MessageRole.system);

        expect(msg.isVisible, isFalse);
      });

      test('tool role is NOT visible', () {
        final msg = buildMessage(role: MessageRole.tool);

        expect(msg.isVisible, isFalse);
      });
    });

    group('hasToolCall computed property', () {
      test('returns false when toolCall is null', () {
        final msg = buildMessage(toolCall: null);

        expect(msg.hasToolCall, isFalse);
      });

      test('returns true when toolCall is set', () {
        const toolCall = AIToolCall(
          name: 'get_workout_stats',
          arguments: {'exercise': 'Bench Press'},
        );
        final msg = buildMessage(toolCall: toolCall);

        expect(msg.hasToolCall, isTrue);
      });

      test('returns true with toolCall that has a result', () {
        const toolCall = AIToolCall(
          name: 'search_exercises',
          arguments: {},
          result: '["Bench Press", "Incline Press"]',
        );
        final msg = buildMessage(role: MessageRole.tool, toolCall: toolCall);

        expect(msg.hasToolCall, isTrue);
      });
    });

    group('copyWith immutability', () {
      test('copyWith changes content without affecting original', () {
        final original = buildMessage(content: 'Hello');
        final updated = original.copyWith(content: 'Updated');

        expect(updated.content, 'Updated');
        expect(original.content, 'Hello');
      });

      test('copyWith can set isTyping to true', () {
        final original = buildMessage();
        final typing = original.copyWith(isTyping: true);

        expect(typing.isTyping, isTrue);
        expect(original.isTyping, isFalse);
      });

      test('copyWith can add suggestions', () {
        final original = buildMessage();
        final withSuggestions = original.copyWith(
          suggestions: ['How do I improve?', 'What was my PR?'],
        );

        expect(withSuggestions.suggestions.length, 2);
        expect(original.suggestions, isEmpty);
      });

      test('copyWith can add error', () {
        final original = buildMessage();
        final withError = original.copyWith(error: 'Network error');

        expect(withError.error, 'Network error');
        expect(original.error, isNull);
      });
    });

    group('MessageRole enum', () {
      test('has four values', () {
        expect(MessageRole.values.length, 4);
      });

      test('contains user, assistant, system, tool', () {
        expect(MessageRole.values, containsAll([
          MessageRole.user,
          MessageRole.assistant,
          MessageRole.system,
          MessageRole.tool,
        ]));
      });
    });

    group('AIToolCall', () {
      test('creates with required fields', () {
        const toolCall = AIToolCall(
          name: 'get_1rm',
          arguments: {'exercise': 'Squat', 'unit': 'kg'},
        );

        expect(toolCall.name, 'get_1rm');
        expect(toolCall.arguments, {'exercise': 'Squat', 'unit': 'kg'});
        expect(toolCall.result, isNull);
      });

      test('creates with optional result', () {
        const toolCall = AIToolCall(
          name: 'get_1rm',
          arguments: {},
          result: '120',
        );

        expect(toolCall.result, '120');
      });

      test('copyWith immutability on toolCall', () {
        const original = AIToolCall(name: 'tool_a', arguments: {});
        final updated = original.copyWith(result: 'done');

        expect(updated.result, 'done');
        expect(original.result, isNull);
      });
    });

    group('equality', () {
      test('two messages with same data are equal', () {
        final ts = DateTime(2026, 1, 1);
        final a = AIMessage(
          id: 'x',
          role: MessageRole.user,
          content: 'Hi',
          timestamp: ts,
        );
        final b = AIMessage(
          id: 'x',
          role: MessageRole.user,
          content: 'Hi',
          timestamp: ts,
        );

        expect(a, equals(b));
      });
    });
  });

  // ---------------------------------------------------------------------------
  // AIQuota
  // ---------------------------------------------------------------------------

  group('AIQuota', () {
    test('creates with all required fields', () {
      const quota = AIQuota(
        accountTier: 'premium',
        usedToday: 5,
        limitPerDay: 20,
        remainingToday: 15,
      );

      expect(quota.accountTier, 'premium');
      expect(quota.usedToday, 5);
      expect(quota.limitPerDay, 20);
      expect(quota.remainingToday, 15);
    });

    group('isExhausted', () {
      test('returns false when remaining is positive', () {
        const quota = AIQuota(
          accountTier: 'free',
          usedToday: 10,
          limitPerDay: 20,
          remainingToday: 10,
        );

        expect(quota.isExhausted, isFalse);
      });

      test('returns true when remaining is exactly zero', () {
        const quota = AIQuota(
          accountTier: 'free',
          usedToday: 20,
          limitPerDay: 20,
          remainingToday: 0,
        );

        expect(quota.isExhausted, isTrue);
      });

      test('returns true when remaining is negative (over-limit)', () {
        const quota = AIQuota(
          accountTier: 'free',
          usedToday: 21,
          limitPerDay: 20,
          remainingToday: -1,
        );

        expect(quota.isExhausted, isTrue);
      });

      test('returns false when only 1 message remains', () {
        const quota = AIQuota(
          accountTier: 'premium',
          usedToday: 19,
          limitPerDay: 20,
          remainingToday: 1,
        );

        expect(quota.isExhausted, isFalse);
      });

      test('returns false for fully fresh quota', () {
        const quota = AIQuota(
          accountTier: 'premium',
          usedToday: 0,
          limitPerDay: 20,
          remainingToday: 20,
        );

        expect(quota.isExhausted, isFalse);
      });

      test('handles unlimited tier with very large limit', () {
        const quota = AIQuota(
          accountTier: 'enterprise',
          usedToday: 1000,
          limitPerDay: 999999,
          remainingToday: 998999,
        );

        expect(quota.isExhausted, isFalse);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // RateLimitResult
  // ---------------------------------------------------------------------------

  group('RateLimitResult', () {
    group('RateLimitResult.allowed() factory', () {
      test('creates result with allowed status', () {
        final result = RateLimitResult.allowed();

        expect(result.status, RateLimitStatus.allowed);
      });

      test('has empty message', () {
        final result = RateLimitResult.allowed();

        expect(result.message, isEmpty);
      });

      test('has zero waitSeconds', () {
        final result = RateLimitResult.allowed();

        expect(result.waitSeconds, 0);
      });
    });

    group('RateLimitResult.blocked() factory', () {
      test('creates result with blocked status', () {
        final result = RateLimitResult.blocked(
          message: 'Daily limit of 20 messages reached.',
        );

        expect(result.status, RateLimitStatus.blocked);
      });

      test('stores the provided message', () {
        const msg = 'You have reached your daily limit.';
        final result = RateLimitResult.blocked(message: msg);

        expect(result.message, msg);
      });

      test('has zero waitSeconds by default', () {
        final result = RateLimitResult.blocked(message: 'Blocked');

        expect(result.waitSeconds, 0);
      });
    });

    group('RateLimitResult.throttled() factory', () {
      test('creates result with throttled status', () {
        final result = RateLimitResult.throttled(
          message: 'Approaching limit.',
          waitSeconds: 30,
        );

        expect(result.status, RateLimitStatus.throttled);
      });

      test('stores the provided message', () {
        final result = RateLimitResult.throttled(
          message: 'Slow down a bit.',
          waitSeconds: 10,
        );

        expect(result.message, 'Slow down a bit.');
      });

      test('stores waitSeconds correctly', () {
        final result = RateLimitResult.throttled(
          message: 'Wait before next message.',
          waitSeconds: 60,
        );

        expect(result.waitSeconds, 60);
      });

      test('allows zero waitSeconds in throttled state', () {
        final result = RateLimitResult.throttled(
          message: 'Warning',
          waitSeconds: 0,
        );

        expect(result.waitSeconds, 0);
      });
    });

    group('computed getters', () {
      test('isAllowed is true for allowed status', () {
        expect(RateLimitResult.allowed().isAllowed, isTrue);
      });

      test('isAllowed is false for blocked status', () {
        expect(
          RateLimitResult.blocked(message: 'no').isAllowed,
          isFalse,
        );
      });

      test('isAllowed is false for throttled status', () {
        expect(
          RateLimitResult.throttled(message: 'slow', waitSeconds: 5).isAllowed,
          isFalse,
        );
      });

      test('isBlocked is true for blocked status', () {
        expect(
          RateLimitResult.blocked(message: 'no').isBlocked,
          isTrue,
        );
      });

      test('isBlocked is false for allowed status', () {
        expect(RateLimitResult.allowed().isBlocked, isFalse);
      });

      test('isBlocked is false for throttled status', () {
        expect(
          RateLimitResult.throttled(message: 'slow', waitSeconds: 5).isBlocked,
          isFalse,
        );
      });

      test('isThrottled is true for throttled status', () {
        expect(
          RateLimitResult.throttled(message: 'slow', waitSeconds: 5).isThrottled,
          isTrue,
        );
      });

      test('isThrottled is false for allowed status', () {
        expect(RateLimitResult.allowed().isThrottled, isFalse);
      });

      test('isThrottled is false for blocked status', () {
        expect(
          RateLimitResult.blocked(message: 'no').isThrottled,
          isFalse,
        );
      });

      test('exactly one of isAllowed/isBlocked/isThrottled is true', () {
        final results = [
          RateLimitResult.allowed(),
          RateLimitResult.blocked(message: 'blocked'),
          RateLimitResult.throttled(message: 'throttled', waitSeconds: 10),
        ];

        for (final result in results) {
          final trueCount = [
            result.isAllowed,
            result.isBlocked,
            result.isThrottled,
          ].where((v) => v).length;
          expect(trueCount, 1,
              reason: 'Exactly one getter should be true for ${result.status}');
        }
      });
    });

    group('RateLimitStatus enum', () {
      test('has three values', () {
        expect(RateLimitStatus.values.length, 3);
      });

      test('contains allowed, throttled, blocked', () {
        expect(RateLimitStatus.values, containsAll([
          RateLimitStatus.allowed,
          RateLimitStatus.throttled,
          RateLimitStatus.blocked,
        ]));
      });
    });

    group('copyWith immutability', () {
      test('copyWith on allowed produces new instance', () {
        final original = RateLimitResult.allowed();
        final updated = original.copyWith(message: 'updated');

        expect(updated.message, 'updated');
        expect(original.message, isEmpty);
      });

      test('copyWith on blocked changes waitSeconds', () {
        final original = RateLimitResult.blocked(message: 'blocked');
        final updated = original.copyWith(waitSeconds: 120);

        expect(updated.waitSeconds, 120);
        expect(original.waitSeconds, 0);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // DocumentSyncStatus
  // ---------------------------------------------------------------------------

  group('DocumentSyncStatus', () {
    DocumentSyncStatus buildStatus({
      String localVersion = 'v1',
      String remoteVersion = 'v1',
      DateTime? lastSyncAt,
      int documentsCount = 10,
      bool isSyncing = false,
      String? error,
    }) =>
        DocumentSyncStatus(
          localVersion: localVersion,
          remoteVersion: remoteVersion,
          lastSyncAt: lastSyncAt ?? DateTime(2026, 2, 28),
          documentsCount: documentsCount,
          isSyncing: isSyncing,
          error: error,
        );

    group('isUpToDate', () {
      test('returns true when versions match', () {
        final status = buildStatus(
          localVersion: 'v2',
          remoteVersion: 'v2',
        );

        expect(status.isUpToDate, isTrue);
      });

      test('returns false when versions differ', () {
        final status = buildStatus(
          localVersion: 'v1',
          remoteVersion: 'v2',
        );

        expect(status.isUpToDate, isFalse);
      });

      test('returns true for initial empty versions matching', () {
        final status = buildStatus(
          localVersion: '',
          remoteVersion: '',
        );

        expect(status.isUpToDate, isTrue);
      });

      test('is case-sensitive for version strings', () {
        final status = buildStatus(
          localVersion: 'V1',
          remoteVersion: 'v1',
        );

        expect(status.isUpToDate, isFalse);
      });
    });

    group('hasError', () {
      test('returns false when error is null', () {
        final status = buildStatus(error: null);

        expect(status.hasError, isFalse);
      });

      test('returns true when error is set', () {
        final status = buildStatus(error: 'Network timeout');

        expect(status.hasError, isTrue);
      });

      test('returns true for empty string error', () {
        // An empty string is still non-null, so hasError should be true
        final status = buildStatus(error: '');

        expect(status.hasError, isTrue);
      });
    });

    group('needsSync', () {
      test('returns true when out of date and not syncing', () {
        final status = buildStatus(
          localVersion: 'v1',
          remoteVersion: 'v2',
          isSyncing: false,
        );

        expect(status.needsSync, isTrue);
      });

      test('returns false when up to date', () {
        final status = buildStatus(
          localVersion: 'v2',
          remoteVersion: 'v2',
          isSyncing: false,
        );

        expect(status.needsSync, isFalse);
      });

      test('returns false when already syncing (even if out of date)', () {
        final status = buildStatus(
          localVersion: 'v1',
          remoteVersion: 'v2',
          isSyncing: true,
        );

        expect(status.needsSync, isFalse);
      });

      test('returns false when up to date and syncing', () {
        final status = buildStatus(
          localVersion: 'v3',
          remoteVersion: 'v3',
          isSyncing: true,
        );

        expect(status.needsSync, isFalse);
      });
    });

    group('combined computed properties', () {
      test('in-progress sync: isSyncing true, versions differ', () {
        final status = buildStatus(
          localVersion: 'v1',
          remoteVersion: 'v2',
          isSyncing: true,
        );

        expect(status.isUpToDate, isFalse);
        expect(status.needsSync, isFalse); // syncing already in progress
        expect(status.isSyncing, isTrue);
      });

      test('error state does not affect isUpToDate', () {
        final status = buildStatus(
          localVersion: 'v3',
          remoteVersion: 'v3',
          error: 'Previous sync failed',
        );

        expect(status.isUpToDate, isTrue);
        expect(status.hasError, isTrue);
      });
    });

    group('field storage', () {
      test('stores documentsCount correctly', () {
        final status = buildStatus(documentsCount: 42);

        expect(status.documentsCount, 42);
      });

      test('stores lastSyncAt correctly', () {
        final syncTime = DateTime(2026, 2, 15, 8, 30);
        final status = buildStatus(lastSyncAt: syncTime);

        expect(status.lastSyncAt, syncTime);
      });
    });

    group('copyWith immutability', () {
      test('copyWith updates remoteVersion without mutating original', () {
        final original = buildStatus(localVersion: 'v1', remoteVersion: 'v1');
        final updated = original.copyWith(remoteVersion: 'v2');

        expect(updated.remoteVersion, 'v2');
        expect(original.remoteVersion, 'v1');
        expect(updated.isUpToDate, isFalse);
        expect(original.isUpToDate, isTrue);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // ExerciseSuggestion
  // ---------------------------------------------------------------------------

  group('ExerciseSuggestion', () {
    group('hasData computed property', () {
      test('returns false when sessionCount is zero', () {
        const suggestion = ExerciseSuggestion(
          exerciseName: 'Bench Press',
          sessionCount: 0,
          suggestedQuestions: [],
        );

        expect(suggestion.hasData, isFalse);
      });

      test('returns true when sessionCount is one', () {
        const suggestion = ExerciseSuggestion(
          exerciseName: 'Bench Press',
          sessionCount: 1,
          suggestedQuestions: [],
        );

        expect(suggestion.hasData, isTrue);
      });

      test('returns true when sessionCount is large', () {
        const suggestion = ExerciseSuggestion(
          exerciseName: 'Squat',
          sessionCount: 100,
          suggestedQuestions: [],
        );

        expect(suggestion.hasData, isTrue);
      });
    });

    group('field storage', () {
      test('stores exerciseName correctly', () {
        const suggestion = ExerciseSuggestion(
          exerciseName: 'Romanian Deadlift',
          sessionCount: 5,
          suggestedQuestions: [],
        );

        expect(suggestion.exerciseName, 'Romanian Deadlift');
      });

      test('stores lastSessionDate as null when not provided', () {
        const suggestion = ExerciseSuggestion(
          exerciseName: 'Pull-up',
          sessionCount: 0,
          suggestedQuestions: [],
        );

        expect(suggestion.lastSessionDate, isNull);
      });

      test('stores lastSessionDate when provided', () {
        final date = DateTime(2026, 2, 20);
        final suggestion = ExerciseSuggestion(
          exerciseName: 'Pull-up',
          sessionCount: 3,
          lastSessionDate: date,
          suggestedQuestions: const [],
        );

        expect(suggestion.lastSessionDate, date);
      });

      test('stores suggestedQuestions list', () {
        final icon = const IconData(0xe3af, fontFamily: 'MaterialIcons');
        final suggestion = ExerciseSuggestion(
          exerciseName: 'Bench Press',
          sessionCount: 5,
          suggestedQuestions: [
            SuggestedQuestion(
              displayText: 'What is my max?',
              fullQuestion: 'What is my max on Bench Press?',
              icon: icon,
            ),
          ],
        );

        expect(suggestion.suggestedQuestions.length, 1);
        expect(suggestion.suggestedQuestions.first.displayText, 'What is my max?');
        expect(suggestion.suggestedQuestions.first.fullQuestion,
            'What is my max on Bench Press?');
      });
    });

    group('copyWith immutability', () {
      test('copyWith updates sessionCount without mutating original', () {
        const original = ExerciseSuggestion(
          exerciseName: 'Overhead Press',
          sessionCount: 0,
          suggestedQuestions: [],
        );
        final updated = original.copyWith(sessionCount: 5);

        expect(updated.sessionCount, 5);
        expect(updated.hasData, isTrue);
        expect(original.sessionCount, 0);
        expect(original.hasData, isFalse);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // SuggestedQuestion
  // ---------------------------------------------------------------------------

  group('SuggestedQuestion', () {
    test('stores all fields correctly', () {
      final icon = const IconData(0xe3af, fontFamily: 'MaterialIcons');
      final question = SuggestedQuestion(
        displayText: 'Volume trend?',
        fullQuestion: 'What is my volume trend for Squat?',
        icon: icon,
      );

      expect(question.displayText, 'Volume trend?');
      expect(question.fullQuestion, 'What is my volume trend for Squat?');
      expect(question.icon, icon);
    });

    test('copyWith creates new instance', () {
      final icon = const IconData(0xe3af, fontFamily: 'MaterialIcons');
      final original = SuggestedQuestion(
        displayText: 'Old text',
        fullQuestion: 'Old full question',
        icon: icon,
      );
      final updated = original.copyWith(displayText: 'New text');

      expect(updated.displayText, 'New text');
      expect(original.displayText, 'Old text');
      expect(updated.fullQuestion, 'Old full question');
    });
  });

  // ---------------------------------------------------------------------------
  // ScientificPaper
  // ---------------------------------------------------------------------------

  group('ScientificPaper', () {
    ScientificPaper buildPaper({
      String id = 'paper-1',
      String title = 'Effects of Resistance Training Volume on Hypertrophy',
      List<String>? authors,
      int year = 2017,
      String doi = '10.1519/JSC.0000000000001764',
      String abstract = 'This study examined...',
      String summary = 'Higher volume leads to greater hypertrophy.',
      String url = 'https://pubmed.ncbi.nlm.nih.gov/12345',
      String license = 'CC BY 4.0',
      List<String>? categories,
      List<String>? keywords,
      bool active = true,
    }) =>
        ScientificPaper(
          id: id,
          title: title,
          authors: authors ??
              ['Schoenfeld', 'Contreras', 'Krieger'],
          year: year,
          doi: doi,
          abstract: abstract,
          summary: summary,
          url: url,
          license: license,
          categories: categories ?? ['hypertrophy', 'strength'],
          keywords: keywords ?? ['volume', 'resistance training'],
          uploadedAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 2, 1),
          active: active,
        );

    group('field storage', () {
      test('stores all required fields', () {
        final paper = buildPaper();

        expect(paper.id, 'paper-1');
        expect(paper.title, contains('Hypertrophy'));
        expect(paper.year, 2017);
        expect(paper.doi, '10.1519/JSC.0000000000001764');
        expect(paper.active, isTrue);
        expect(paper.metadata, isNull);
      });

      test('stores optional metadata when provided', () {
        final paper = buildPaper().copyWith(
          metadata: {'journal': 'JSCR', 'volume': '31', 'issue': '4'},
        );

        expect(paper.metadata, isNotNull);
        expect(paper.metadata!['journal'], 'JSCR');
      });
    });

    group('formatCitation()', () {
      test('formats single author correctly', () {
        final paper = buildPaper(authors: ['Smith'], year: 2020);

        expect(paper.formatCitation(), 'Smith (2020)');
      });

      test('formats two authors with comma', () {
        final paper = buildPaper(
          authors: ['Schoenfeld', 'Contreras'],
          year: 2019,
        );

        expect(paper.formatCitation(), 'Schoenfeld, Contreras (2019)');
      });

      test('formats three authors with commas', () {
        final paper = buildPaper(
          authors: ['Schoenfeld', 'Contreras', 'Krieger'],
          year: 2017,
        );

        expect(paper.formatCitation(), 'Schoenfeld, Contreras, Krieger (2017)');
      });

      test('uses et al. for four authors', () {
        final paper = buildPaper(
          authors: ['Author A', 'Author B', 'Author C', 'Author D'],
          year: 2021,
        );
        // takes first 3 then adds et al.
        expect(paper.formatCitation(),
            'Author A, Author B, Author C et al. (2021)');
      });

      test('uses et al. for many authors', () {
        final paper = buildPaper(
          authors: List.generate(10, (i) => 'Author ${i + 1}'),
          year: 2022,
        );
        final citation = paper.formatCitation();

        expect(citation, contains('et al.'));
        expect(citation, contains('(2022)'));
        // Should only list first 3 authors
        expect(citation, contains('Author 1'));
        expect(citation, contains('Author 3'));
        expect(citation, isNot(contains('Author 4')));
      });

      test('includes the year in parentheses', () {
        final paper = buildPaper(year: 2015);

        expect(paper.formatCitation(), contains('(2015)'));
      });
    });

    group('toContextString()', () {
      test('returns non-empty string', () {
        final paper = buildPaper();

        expect(paper.toContextString(), isNotEmpty);
      });

      test('includes title', () {
        final paper = buildPaper(
          title: 'Muscle Protein Synthesis Study',
        );

        expect(paper.toContextString(), contains('Muscle Protein Synthesis Study'));
      });

      test('includes formatted citation via Authors field', () {
        final paper = buildPaper(
          authors: ['Schoenfeld', 'Contreras'],
          year: 2019,
        );

        expect(paper.toContextString(), contains('Schoenfeld, Contreras (2019)'));
      });

      test('includes summary', () {
        final paper = buildPaper(
          summary: 'Short summary for AI consumption.',
        );

        expect(paper.toContextString(), contains('Short summary for AI consumption.'));
      });

      test('includes categories joined by comma', () {
        final paper = buildPaper(
          categories: ['hypertrophy', 'endurance', 'recovery'],
        );
        final context = paper.toContextString();

        expect(context, contains('hypertrophy'));
        expect(context, contains('endurance'));
        expect(context, contains('recovery'));
      });

      test('includes URL', () {
        final paper = buildPaper(url: 'https://example.com/paper');

        expect(paper.toContextString(), contains('https://example.com/paper'));
      });

      test('contains Title:, Authors:, Summary:, Categories:, URL: labels', () {
        final paper = buildPaper();
        final context = paper.toContextString();

        expect(context, contains('Title:'));
        expect(context, contains('Authors:'));
        expect(context, contains('Summary:'));
        expect(context, contains('Categories:'));
        expect(context, contains('URL:'));
      });
    });

    group('copyWith immutability', () {
      test('copyWith updates active field without changing original', () {
        final original = buildPaper(active: true);
        final updated = original.copyWith(active: false);

        expect(updated.active, isFalse);
        expect(original.active, isTrue);
      });

      test('copyWith updates year', () {
        final original = buildPaper(year: 2017);
        final updated = original.copyWith(year: 2023);

        expect(updated.year, 2023);
        expect(original.year, 2017);
      });
    });
  });
}
