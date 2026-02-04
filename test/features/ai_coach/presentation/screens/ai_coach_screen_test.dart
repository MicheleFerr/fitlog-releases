import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/rate_limit_result.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_chat_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/screens/ai_coach_screen.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_input_bar.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_message_bubble.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_rate_limit_banner.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_typing_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_theme.dart';

void main() {
  group('AICoachScreen Widget Tests', () {
    Widget createTestWidget({
      required AIChatState chatState,
      RateLimitResult? rateLimitResult,
    }) {
      return ProviderScope(
        overrides: [
          aIChatProvider.overrideWith(() => _FakeChatNotifier(chatState)),
          if (rateLimitResult != null)
            aIRateLimitProvider.overrideWith(
              () => _FakeRateLimitNotifier(rateLimitResult),
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AICoachScreen(),
        ),
      );
    }

    testWidgets('shows disclaimer message on initial load',
        (WidgetTester tester) async {
      final disclaimerMessage = AIMessage(
        id: 'disclaimer',
        role: MessageRole.system,
        content: 'Disclaimer text',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(messages: [disclaimerMessage]),
        ),
      );

      expect(find.byType(AIMessageBubble), findsOneWidget);
      expect(find.text('Disclaimer text'), findsOneWidget);
    });

    testWidgets('shows typing indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(
            messages: [],
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(AITypingIndicator), findsOneWidget);

      // Pump past staggered Future.delayed timers in AITypingIndicator
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('hides typing indicator when not loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(
            messages: [],
            isLoading: false,
          ),
        ),
      );

      expect(find.byType(AITypingIndicator), findsNothing);
    });

    testWidgets('displays user and AI messages', (WidgetTester tester) async {
      final userMessage = AIMessage(
        id: '1',
        role: MessageRole.user,
        content: 'User question',
        timestamp: DateTime.now(),
      );

      final aiMessage = AIMessage(
        id: '2',
        role: MessageRole.assistant,
        content: 'AI answer',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(
            messages: [userMessage, aiMessage],
          ),
        ),
      );

      expect(find.byType(AIMessageBubble), findsNWidgets(2));
      expect(find.text('User question'), findsOneWidget);
      expect(find.text('AI answer'), findsOneWidget);
    });

    testWidgets('shows rate limit warning banner when throttled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(messages: []),
          rateLimitResult: RateLimitResult.throttled(
            message: '⚠️ Solo 2 messaggi rimasti!',
            waitSeconds: 0,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AIRateLimitBanner), findsOneWidget);
      expect(find.text('⚠️ Solo 2 messaggi rimasti!'), findsOneWidget);
    });

    testWidgets('shows rate limit error banner when blocked',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(messages: []),
          rateLimitResult: RateLimitResult.blocked(
            message: 'Limite giornaliero raggiunto',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AIRateLimitBanner), findsOneWidget);
      expect(find.text('Limite giornaliero raggiunto'), findsOneWidget);
    });

    testWidgets('hides rate limit banner when allowed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(messages: []),
          rateLimitResult: RateLimitResult.allowed(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AIRateLimitBanner), findsNothing);
    });

    testWidgets('shows input bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(messages: []),
        ),
      );

      expect(find.byType(AIInputBar), findsOneWidget);
    });

    testWidgets('input bar is disabled when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(
            messages: [],
            isLoading: true,
          ),
        ),
      );

      final inputBar = tester.widget<AIInputBar>(find.byType(AIInputBar));
      expect(inputBar.isLoading, true);

      // Pump past staggered Future.delayed timers in AITypingIndicator
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('shows error message when error present',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(
            messages: [],
            error: 'Network error occurred',
          ),
        ),
      );

      expect(find.text('Network error occurred'), findsOneWidget);
    });

    testWidgets('clear button shows confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chatState: AIChatState(messages: []),
        ),
      );

      // Find and tap clear button (delete icon in AppBar)
      final clearButton = find.byIcon(Icons.delete);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Cancella conversazione'), findsOneWidget);
      expect(
        find.text(
          'Vuoi cancellare tutti i messaggi? Questa azione non può essere annullata.',
        ),
        findsOneWidget,
      );
      expect(find.text('Annulla'), findsOneWidget);
      expect(find.text('Cancella'), findsOneWidget);
    });
  });
}

/// Fake chat notifier for testing
class _FakeChatNotifier extends AIChat {
  _FakeChatNotifier(this._state);

  final AIChatState _state;

  @override
  AIChatState build() => _state;

  @override
  Future<void> sendMessage(String text) async {
    // No-op for testing
  }

  @override
  void clearMessages() {
    // No-op for testing
  }
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
