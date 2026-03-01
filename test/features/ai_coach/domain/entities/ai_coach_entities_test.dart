/// AI Coach entities tests - AIMessage, AIToolCall, RateLimitResult,
/// AIQuota, DocumentSyncStatus JSON round-trips and computed properties.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/document_sync_status.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/rate_limit_result.dart';

void main() {
  group('MessageRole', () {
    test('has 4 values', () {
      expect(MessageRole.values.length, 4);
    });
  });

  group('AIToolCall JSON', () {
    test('round-trip with all fields', () {
      final tc = AIToolCall(
        name: 'getWorkoutStats',
        arguments: {'userId': 'u1', 'days': 30},
        result: '{"totalWorkouts": 15}',
      );
      final json = tc.toJson();
      final restored = AIToolCall.fromJson(json);
      expect(restored.name, 'getWorkoutStats');
      expect(restored.arguments['userId'], 'u1');
      expect(restored.arguments['days'], 30);
      expect(restored.result, '{"totalWorkouts": 15}');
    });

    test('round-trip with null result', () {
      final tc = AIToolCall(
        name: 'search',
        arguments: {'query': 'bench press'},
      );
      final restored = AIToolCall.fromJson(tc.toJson());
      expect(restored.result, isNull);
    });
  });

  group('AIMessage JSON', () {
    test('round-trip with all fields', () {
      final msg = AIMessage(
        id: 'msg1',
        role: MessageRole.assistant,
        content: 'Hello!',
        timestamp: DateTime(2025, 3, 1, 10, 0),
        toolCall: AIToolCall(
          name: 'getStats',
          arguments: {'type': 'weekly'},
        ),
        isTyping: true,
        error: 'timeout',
        suggestions: ['How are you?', 'Show stats'],
        isDisambiguation: true,
      );
      final json = msg.toJson();
      final restored = AIMessage.fromJson(json);
      expect(restored.id, 'msg1');
      expect(restored.role, MessageRole.assistant);
      expect(restored.content, 'Hello!');
      expect(restored.timestamp, DateTime(2025, 3, 1, 10, 0));
      expect(restored.toolCall, isNotNull);
      expect(restored.toolCall!.name, 'getStats');
      expect(restored.isTyping, isTrue);
      expect(restored.error, 'timeout');
      expect(restored.suggestions, ['How are you?', 'Show stats']);
      expect(restored.isDisambiguation, isTrue);
    });

    test('round-trip with defaults', () {
      final msg = AIMessage(
        id: 'msg2',
        role: MessageRole.user,
        content: 'Hi',
        timestamp: DateTime(2025, 1, 1),
      );
      final restored = AIMessage.fromJson(msg.toJson());
      expect(restored.toolCall, isNull);
      expect(restored.isTyping, isFalse);
      expect(restored.error, isNull);
      expect(restored.suggestions, isEmpty);
      expect(restored.isDisambiguation, isFalse);
    });

    test('round-trip all MessageRole values', () {
      for (final role in MessageRole.values) {
        final msg = AIMessage(
          id: 'r',
          role: role,
          content: 'x',
          timestamp: DateTime(2025, 1, 1),
        );
        final restored = AIMessage.fromJson(msg.toJson());
        expect(restored.role, role);
      }
    });
  });

  group('AIMessage computed', () {
    test('isVisible for user and assistant', () {
      final user = AIMessage(
        id: '1', role: MessageRole.user, content: 'Hi',
        timestamp: DateTime(2025, 1, 1),
      );
      expect(user.isVisible, isTrue);

      final assistant = AIMessage(
        id: '2', role: MessageRole.assistant, content: 'Hello',
        timestamp: DateTime(2025, 1, 1),
      );
      expect(assistant.isVisible, isTrue);
    });

    test('isVisible false for system and tool', () {
      final system = AIMessage(
        id: '3', role: MessageRole.system, content: 'system prompt',
        timestamp: DateTime(2025, 1, 1),
      );
      expect(system.isVisible, isFalse);

      final tool = AIMessage(
        id: '4', role: MessageRole.tool, content: 'result',
        timestamp: DateTime(2025, 1, 1),
      );
      expect(tool.isVisible, isFalse);
    });

    test('hasToolCall', () {
      final withTool = AIMessage(
        id: '1', role: MessageRole.assistant, content: '',
        timestamp: DateTime(2025, 1, 1),
        toolCall: AIToolCall(name: 'fn', arguments: {}),
      );
      expect(withTool.hasToolCall, isTrue);

      final without = AIMessage(
        id: '2', role: MessageRole.user, content: 'hi',
        timestamp: DateTime(2025, 1, 1),
      );
      expect(without.hasToolCall, isFalse);
    });
  });

  group('RateLimitStatus', () {
    test('has 3 values', () {
      expect(RateLimitStatus.values.length, 3);
    });
  });

  group('RateLimitResult', () {
    test('allowed factory', () {
      final r = RateLimitResult.allowed();
      expect(r.status, RateLimitStatus.allowed);
      expect(r.message, '');
      expect(r.waitSeconds, 0);
      expect(r.isAllowed, isTrue);
      expect(r.isThrottled, isFalse);
      expect(r.isBlocked, isFalse);
    });

    test('blocked factory', () {
      final r = RateLimitResult.blocked(message: 'Daily limit reached');
      expect(r.status, RateLimitStatus.blocked);
      expect(r.message, 'Daily limit reached');
      expect(r.isBlocked, isTrue);
      expect(r.isAllowed, isFalse);
    });

    test('throttled factory', () {
      final r = RateLimitResult.throttled(
        message: 'Slow down',
        waitSeconds: 30,
      );
      expect(r.status, RateLimitStatus.throttled);
      expect(r.message, 'Slow down');
      expect(r.waitSeconds, 30);
      expect(r.isThrottled, isTrue);
      expect(r.isAllowed, isFalse);
      expect(r.isBlocked, isFalse);
    });

    test('default waitSeconds is 0', () {
      final r = RateLimitResult(
        status: RateLimitStatus.allowed,
        message: '',
      );
      expect(r.waitSeconds, 0);
    });
  });

  group('AIQuota', () {
    test('constructor stores all fields', () {
      final q = AIQuota(
        accountTier: 'free',
        usedToday: 5,
        limitPerDay: 20,
        remainingToday: 15,
      );
      expect(q.accountTier, 'free');
      expect(q.usedToday, 5);
      expect(q.limitPerDay, 20);
      expect(q.remainingToday, 15);
    });

    test('isExhausted when remainingToday <= 0', () {
      final exhausted = AIQuota(
        accountTier: 'free',
        usedToday: 20,
        limitPerDay: 20,
        remainingToday: 0,
      );
      expect(exhausted.isExhausted, isTrue);

      final negative = AIQuota(
        accountTier: 'free',
        usedToday: 21,
        limitPerDay: 20,
        remainingToday: -1,
      );
      expect(negative.isExhausted, isTrue);
    });

    test('isExhausted false when remaining > 0', () {
      final available = AIQuota(
        accountTier: 'premium',
        usedToday: 5,
        limitPerDay: 50,
        remainingToday: 45,
      );
      expect(available.isExhausted, isFalse);
    });
  });

  group('DocumentSyncStatus', () {
    test('constructor stores all fields', () {
      final status = DocumentSyncStatus(
        localVersion: 'v1',
        remoteVersion: 'v2',
        lastSyncAt: DateTime(2025, 3, 1),
        documentsCount: 10,
        isSyncing: false,
        error: 'network error',
      );
      expect(status.localVersion, 'v1');
      expect(status.remoteVersion, 'v2');
      expect(status.documentsCount, 10);
      expect(status.isSyncing, isFalse);
      expect(status.error, 'network error');
    });

    test('isUpToDate when versions match', () {
      final upToDate = DocumentSyncStatus(
        localVersion: 'v2',
        remoteVersion: 'v2',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: false,
      );
      expect(upToDate.isUpToDate, isTrue);
    });

    test('isUpToDate false when versions differ', () {
      final outdated = DocumentSyncStatus(
        localVersion: 'v1',
        remoteVersion: 'v2',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: false,
      );
      expect(outdated.isUpToDate, isFalse);
    });

    test('hasError', () {
      final withError = DocumentSyncStatus(
        localVersion: 'v1',
        remoteVersion: 'v1',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: false,
        error: 'something failed',
      );
      expect(withError.hasError, isTrue);

      final noError = DocumentSyncStatus(
        localVersion: 'v1',
        remoteVersion: 'v1',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: false,
      );
      expect(noError.hasError, isFalse);
    });

    test('needsSync when outdated and not syncing', () {
      final needs = DocumentSyncStatus(
        localVersion: 'v1',
        remoteVersion: 'v2',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: false,
      );
      expect(needs.needsSync, isTrue);
    });

    test('needsSync false when up to date', () {
      final upToDate = DocumentSyncStatus(
        localVersion: 'v2',
        remoteVersion: 'v2',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: false,
      );
      expect(upToDate.needsSync, isFalse);
    });

    test('needsSync false when syncing', () {
      final syncing = DocumentSyncStatus(
        localVersion: 'v1',
        remoteVersion: 'v2',
        lastSyncAt: DateTime(2025, 1, 1),
        documentsCount: 5,
        isSyncing: true,
      );
      expect(syncing.needsSync, isFalse);
    });
  });
}
