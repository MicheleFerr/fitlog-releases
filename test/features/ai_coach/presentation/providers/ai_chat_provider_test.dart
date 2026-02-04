import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/rate_limit_result.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/ai_coach_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_coach_service_impl.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_chat_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAICoachServiceImpl extends Mock implements AICoachServiceImpl {}

void main() {
  group('AIChat Provider', () {
    late MockAICoachServiceImpl mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockAICoachServiceImpl();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has disclaimer message', () {
      container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(mockService),
        ],
      );

      final state = container.read(aIChatProvider);

      expect(state.messages.length, 1);
      expect(state.messages.first.id, 'disclaimer');
      expect(state.messages.first.role, MessageRole.system);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('sendMessage adds user message to state', () async {
      container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(mockService),
          aIRateLimitProvider.overrideWith(
            () => _FakeRateLimitNotifier(
              RateLimitResult.allowed(),
            ),
          ),
        ],
      );

      when(() => mockService.sendMessage(
            userMessage: any(named: 'userMessage'),
            conversationHistory: any(named: 'conversationHistory'),
            userId: any(named: 'userId'),
          )).thenAnswer(
        (_) async => AIServiceResponse(content: 'AI response'),
      );

      final notifier = container.read(aIChatProvider.notifier);
      await notifier.sendMessage('Hello AI');

      final state = container.read(aIChatProvider);

      // Should have disclaimer + user message + AI response
      expect(state.messages.length, 3);
      expect(state.messages[1].role, MessageRole.user);
      expect(state.messages[1].content, 'Hello AI');
      expect(state.messages[2].role, MessageRole.assistant);
      expect(state.messages[2].content, 'AI response');
    });

    test('sendMessage blocks when rate limit exceeded', () async {
      container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(mockService),
          aIRateLimitProvider.overrideWith(
            () => _FakeRateLimitNotifier(
              RateLimitResult.blocked(message: 'Limit reached'),
            ),
          ),
        ],
      );

      final notifier = container.read(aIChatProvider.notifier);
      await notifier.sendMessage('Hello AI');

      final state = container.read(aIChatProvider);

      // Should only have disclaimer (message blocked)
      expect(state.messages.length, 1);
      expect(state.error, 'Limit reached');

      // Should NOT call service
      verifyNever(() => mockService.sendMessage(
            userMessage: any(named: 'userMessage'),
            conversationHistory: any(named: 'conversationHistory'),
            userId: any(named: 'userId'),
          ));
    });

    test('sendMessage sets loading state correctly', () async {
      container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(mockService),
          aIRateLimitProvider.overrideWith(
            () => _FakeRateLimitNotifier(
              RateLimitResult.allowed(),
            ),
          ),
        ],
      );

      when(() => mockService.sendMessage(
            userMessage: any(named: 'userMessage'),
            conversationHistory: any(named: 'conversationHistory'),
            userId: any(named: 'userId'),
          )).thenAnswer(
        (_) async {
          // Simulate delay
          await Future.delayed(const Duration(milliseconds: 100));
          return AIServiceResponse(content: 'AI response');
        },
      );

      final notifier = container.read(aIChatProvider.notifier);
      final future = notifier.sendMessage('Hello AI');

      // Wait a bit to check loading state
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(aIChatProvider).isLoading, true);

      await future;
      expect(container.read(aIChatProvider).isLoading, false);
    });

    test('clearMessages resets to disclaimer only', () async {
      container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(mockService),
          aIRateLimitProvider.overrideWith(
            () => _FakeRateLimitNotifier(
              RateLimitResult.allowed(),
            ),
          ),
        ],
      );

      when(() => mockService.sendMessage(
            userMessage: any(named: 'userMessage'),
            conversationHistory: any(named: 'conversationHistory'),
            userId: any(named: 'userId'),
          )).thenAnswer(
        (_) async => AIServiceResponse(content: 'AI response'),
      );

      final notifier = container.read(aIChatProvider.notifier);

      // Add some messages
      await notifier.sendMessage('Message 1');
      await notifier.sendMessage('Message 2');

      expect(container.read(aIChatProvider).messages.length, greaterThan(1));

      // Clear messages
      notifier.clearMessages();

      final state = container.read(aIChatProvider);
      expect(state.messages.length, 1);
      expect(state.messages.first.id, 'disclaimer');
    });

    test('error from service updates state.error', () async {
      container = ProviderContainer(
        overrides: [
          aiCoachServiceProvider.overrideWithValue(mockService),
          aIRateLimitProvider.overrideWith(
            () => _FakeRateLimitNotifier(
              RateLimitResult.allowed(),
            ),
          ),
        ],
      );

      when(() => mockService.sendMessage(
            userMessage: any(named: 'userMessage'),
            conversationHistory: any(named: 'conversationHistory'),
            userId: any(named: 'userId'),
          )).thenThrow(Exception('Network error'));

      final notifier = container.read(aIChatProvider.notifier);
      await notifier.sendMessage('Hello AI');

      final state = container.read(aIChatProvider);

      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });
  });
}

/// Fake rate limit notifier for testing
class _FakeRateLimitNotifier extends AIRateLimit {
  _FakeRateLimitNotifier(this._result);

  final RateLimitResult _result;

  @override
  Future<RateLimitResult> build() async {
    return _result;
  }

  @override
  Future<void> incrementUsage() async {
    // No-op for testing
  }
}
