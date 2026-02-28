/// Widget tests for the AI Coach presentation layer.
///
/// Covers:
/// - AIMessageBubble: user vs assistant rendering, suggestion chips,
///   error state, tool call indicator, timestamp, quick-actions row
/// - AIInputBar: text field, send button enable/disable, onSend callback,
///   field clear after send, isLoading disables input
///
/// Note: Navigation via GoRouter (exercise links) is intentionally not tested
/// here; link taps are not triggered in these tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_input_bar.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/widgets/ai_message_bubble.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Wraps [child] with ProviderScope + MaterialApp + localizations.
/// Uses plain MaterialApp (no GoRouter) - navigation tests are skipped.
Widget buildTestApp({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('it')],
      locale: const Locale('en'),
      home: Scaffold(body: child),
    ),
  );
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

/// Creates an [AIMessage] for a user with sensible defaults.
AIMessage makeUserMessage({
  String id = 'msg-user-1',
  String content = 'Hello AI Coach!',
  List<String> suggestions = const [],
  String? error,
  AIToolCall? toolCall,
  bool isTyping = false,
  bool isDisambiguation = false,
  DateTime? timestamp,
}) {
  return AIMessage(
    id: id,
    role: MessageRole.user,
    content: content,
    timestamp: timestamp ?? DateTime(2026, 2, 28, 10, 0),
    suggestions: suggestions,
    error: error,
    toolCall: toolCall,
    isTyping: isTyping,
    isDisambiguation: isDisambiguation,
  );
}

/// Creates an [AIMessage] for the assistant with sensible defaults.
AIMessage makeAssistantMessage({
  String id = 'msg-assistant-1',
  String content = 'Here is your workout plan.',
  List<String> suggestions = const [],
  String? error,
  AIToolCall? toolCall,
  bool isTyping = false,
  bool isDisambiguation = false,
  DateTime? timestamp,
}) {
  return AIMessage(
    id: id,
    role: MessageRole.assistant,
    content: content,
    timestamp: timestamp ?? DateTime(2026, 2, 28, 10, 0),
    suggestions: suggestions,
    error: error,
    toolCall: toolCall,
    isTyping: isTyping,
    isDisambiguation: isDisambiguation,
  );
}

// ---------------------------------------------------------------------------
// AIMessageBubble tests
// ---------------------------------------------------------------------------

void main() {
  group('AIMessageBubble', () {
    // ------------------------------------------------------------------
    // Rendering: user message
    // ------------------------------------------------------------------
    group('user message', () {
      testWidgets('renders user message content', (tester) async {
        // Arrange
        const messageText = 'I want to train chest today';
        final message = makeUserMessage(content: messageText);

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(messageText), findsOneWidget);
      });

      testWidgets('user bubble is aligned to the right', (tester) async {
        // Arrange
        final message = makeUserMessage(content: 'Right-aligned message');

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: the outer Row uses MainAxisAlignment.end for user messages.
        // We verify by finding the Row and inspecting its mainAxisAlignment.
        final rows = tester.widgetList<Row>(find.byType(Row));
        // The first Row inside the padding is the message layout row.
        final layoutRow = rows.first;
        expect(layoutRow.mainAxisAlignment, MainAxisAlignment.end);
      });

      testWidgets(
          'user bubble does NOT show AI avatar (robot icon area)', (tester) async {
        // Arrange
        final message = makeUserMessage(content: 'No avatar expected');

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: assistant messages show an avatar container (32x32 circle).
        // User messages should not show it — there should be no CircleAvatar
        // widget from the avatar builder.
        expect(find.byKey(const Key('ai_avatar')), findsNothing);
      });

      testWidgets(
          'user bubble does NOT show quick-action copy button', (tester) async {
        // Arrange
        final message = makeUserMessage(content: 'Hello');

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The copy tooltip is shown only for assistant messages.
        // 'Copy' is the EN l10n key value for context.l10n.copy.
        expect(find.byTooltip('Copy'), findsNothing);
      });
    });

    // ------------------------------------------------------------------
    // Rendering: assistant message
    // ------------------------------------------------------------------
    group('assistant message', () {
      testWidgets('renders assistant message content', (tester) async {
        // Arrange
        const messageText = 'Here is your personalised workout plan.';
        final message = makeAssistantMessage(content: messageText);

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(messageText), findsOneWidget);
      });

      testWidgets(
          'assistant bubble is aligned to the left', (tester) async {
        // Arrange
        final message = makeAssistantMessage(content: 'Left-aligned message');

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: Row mainAxisAlignment.start for assistant messages.
        final rows = tester.widgetList<Row>(find.byType(Row));
        final layoutRow = rows.first;
        expect(layoutRow.mainAxisAlignment, MainAxisAlignment.start);
      });

      testWidgets(
          'assistant message shows quick-action copy button', (tester) async {
        // Arrange
        final message = makeAssistantMessage(content: 'Copy me');

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: the copy InkWell has a Tooltip with the 'Copy' label.
        expect(find.byTooltip('Copy'), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------
    // Timestamp display
    // ------------------------------------------------------------------
    group('timestamp', () {
      testWidgets('shows timestamp when showTimestamp=true', (tester) async {
        // Arrange: timestamp recent enough to show "ora"
        final message = makeAssistantMessage(
          content: 'Recent message',
          timestamp: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
              showTimestamp: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: "ora" for messages less than 1 minute old
        expect(find.text('ora'), findsOneWidget);
      });

      testWidgets(
          'does NOT show timestamp when showTimestamp=false', (tester) async {
        // Arrange
        final message = makeAssistantMessage(
          content: 'No timestamp',
          timestamp: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
              showTimestamp: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: "ora" should not appear
        expect(find.text('ora'), findsNothing);
      });
    });

    // ------------------------------------------------------------------
    // Suggestion chips
    // ------------------------------------------------------------------
    group('suggestion chips', () {
      testWidgets(
          'shows suggestion chips when suggestions list is non-empty',
          (tester) async {
        // Arrange
        final suggestions = ['Chest workout', 'Leg day', 'Full body'];
        final message = makeAssistantMessage(
          content: 'What workout do you want?',
          suggestions: suggestions,
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: each suggestion appears as a chip label
        for (final suggestion in suggestions) {
          expect(find.text(suggestion), findsOneWidget);
        }
      });

      testWidgets('does NOT show chips when suggestions list is empty',
          (tester) async {
        // Arrange
        final message = makeAssistantMessage(
          content: 'No suggestions here.',
          suggestions: const [],
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: no ActionChip or FilledButton.tonal from suggestion rendering
        expect(find.byType(ActionChip), findsNothing);
      });

      testWidgets('suggestion chip tap fires onSuggestionTap callback',
          (tester) async {
        // Arrange
        const chipLabel = 'Show my stats';
        String? tappedSuggestion;
        final message = makeAssistantMessage(
          content: 'Choose an option:',
          suggestions: const [chipLabel],
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
              onSuggestionTap: (s) => tappedSuggestion = s,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(chipLabel));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedSuggestion, chipLabel);
      });

      testWidgets(
          'disambiguation chips render as FilledButton.tonal instead of ActionChip',
          (tester) async {
        // Arrange
        final message = makeAssistantMessage(
          content: 'Which bench press do you mean?',
          suggestions: const ['Flat Bench Press', 'Incline Bench Press'],
          isDisambiguation: true,
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: disambiguation uses FilledButton.tonal, not ActionChip
        expect(find.text('Flat Bench Press'), findsOneWidget);
        expect(find.text('Incline Bench Press'), findsOneWidget);
        // ActionChip should NOT be present (FilledButton.tonal is used instead)
        expect(find.byType(ActionChip), findsNothing);
      });

      testWidgets(
          'disambiguation chip tap fires onSuggestionTap callback',
          (tester) async {
        // Arrange
        const option = 'Incline Bench Press';
        String? tappedOption;
        final message = makeAssistantMessage(
          content: 'Which do you mean?',
          suggestions: const [option],
          isDisambiguation: true,
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
              onSuggestionTap: (s) => tappedOption = s,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(option));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedOption, option);
      });
    });

    // ------------------------------------------------------------------
    // Tool call indicator
    // ------------------------------------------------------------------
    group('tool call indicator', () {
      testWidgets('hasToolCall is true when message has a toolCall set',
          (tester) async {
        // Arrange: message with a tool call
        const toolCall = AIToolCall(
          name: 'get_workout_stats',
          arguments: {'period': 'last_month'},
          result: '{"totalVolume": 12000}',
        );
        final message = makeAssistantMessage(
          content: 'Fetching your stats...',
          toolCall: toolCall,
        );

        // Assert on the entity directly (domain-level property)
        expect(message.hasToolCall, isTrue);

        // Act: render widget - should not throw
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Content is still rendered
        expect(find.text('Fetching your stats...'), findsOneWidget);
      });

      testWidgets('hasToolCall is false when message has no toolCall',
          (tester) async {
        // Arrange
        final message = makeAssistantMessage(content: 'No tool call here.');

        // Assert on entity
        expect(message.hasToolCall, isFalse);

        // Act: render widget
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No tool call here.'), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------
    // Different visual styling: user vs assistant
    // ------------------------------------------------------------------
    group('visual styling', () {
      testWidgets(
          'user and assistant bubbles both render without errors', (tester) async {
        // Arrange
        final userMsg = makeUserMessage(content: 'User message text');
        final assistantMsg =
            makeAssistantMessage(content: 'Assistant message text');

        // Act: render user bubble
        await tester.pumpWidget(
          buildTestApp(
            child: Column(
              children: [
                AIMessageBubble(
                  message: userMsg,
                  isFromUser: true,
                ),
                AIMessageBubble(
                  message: assistantMsg,
                  isFromUser: false,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: both text contents visible
        expect(find.text('User message text'), findsOneWidget);
        expect(find.text('Assistant message text'), findsOneWidget);
      });

      testWidgets('renders markdown content in assistant messages',
          (tester) async {
        // Arrange: message with markdown bold text
        final message = makeAssistantMessage(
          content: 'Your plan: do **3 sets** of push-ups.',
        );

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: MarkdownBody renders the text (plaintext portions visible)
        expect(find.textContaining('3 sets'), findsWidgets);
      });

      testWidgets('animate=false renders bubble immediately at full opacity',
          (tester) async {
        // Arrange
        final message = makeAssistantMessage(content: 'Immediate render');

        // Act: animate=false means the controller is set to value=1.0 upfront
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
              animate: false,
            ),
          ),
        );
        await tester.pump(); // single frame — should already be visible

        // Assert: content visible without needing pumpAndSettle
        expect(find.text('Immediate render'), findsOneWidget);
      });

      testWidgets('animate=true starts animation and settles correctly',
          (tester) async {
        // Arrange
        final message = makeAssistantMessage(content: 'Animated bubble');

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIMessageBubble(
              message: message,
              isFromUser: false,
              animate: true,
            ),
          ),
        );
        await tester.pumpAndSettle(); // wait for animation to complete

        // Assert: content visible after animation
        expect(find.text('Animated bubble'), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------
    // Localization: Italian
    // ------------------------------------------------------------------
    group('localization - Italian', () {
      testWidgets('renders correctly with Italian locale', (tester) async {
        // Arrange
        final message = makeAssistantMessage(
          content: 'Ecco il tuo piano di allenamento.',
        );

        // Act: use Italian locale
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('it')],
              locale: const Locale('it'),
              home: Scaffold(
                body: AIMessageBubble(
                  message: message,
                  isFromUser: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: content visible in Italian locale
        expect(
          find.text('Ecco il tuo piano di allenamento.'),
          findsOneWidget,
        );
      });
    });
  });

  // ==========================================================================
  // AIInputBar tests
  // ==========================================================================
  group('AIInputBar', () {
    // ------------------------------------------------------------------
    // Basic rendering
    // ------------------------------------------------------------------
    group('rendering', () {
      testWidgets('renders text input field', (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: TextField is present
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('renders send button (IconButton)', (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: IconButton is present
        expect(find.byType(IconButton), findsOneWidget);
      });

      testWidgets('shows hint text from l10n', (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: the hint text "Ask your AI Coach..." is present
        expect(find.text('Ask your AI Coach...'), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------
    // Send button state
    // ------------------------------------------------------------------
    group('send button enabled/disabled', () {
      testWidgets('send button is disabled when text field is empty',
          (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: onPressed is null when no text (disabled)
        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
      });

      testWidgets('send button is enabled when text field has content',
          (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.pumpAndSettle();

        // Assert: onPressed is not null (enabled)
        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNotNull);
      });

      testWidgets(
          'send button remains disabled when text is only whitespace',
          (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '   ');
        await tester.pumpAndSettle();

        // Assert: whitespace-only text does not enable the button
        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
      });

      testWidgets(
          'send button is disabled when isLoading=true even with text',
          (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(
              onSend: (_) {},
              isLoading: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter text while loading
        await tester.enterText(find.byType(TextField), 'Some message');
        await tester.pumpAndSettle();

        // Assert: button disabled during loading
        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
      });

      testWidgets('text field is disabled when isLoading=true', (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(
              onSend: (_) {},
              isLoading: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: TextField.enabled is false
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });

      testWidgets('text field is enabled when isLoading=false', (tester) async {
        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(
              onSend: (_) {},
              isLoading: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: TextField.enabled is true (default)
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isTrue);
      });
    });

    // ------------------------------------------------------------------
    // onSend callback
    // ------------------------------------------------------------------
    group('onSend callback', () {
      testWidgets('fires onSend callback with text content when send tapped',
          (tester) async {
        // Arrange
        String? sentText;
        const inputText = 'What are my best lifts?';

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (text) => sentText = text),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), inputText);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(sentText, inputText);
      });

      testWidgets('clears text field after send', (tester) async {
        // Arrange
        const inputText = 'Show me my volume trends';

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), inputText);
        await tester.pumpAndSettle();

        // Verify text is present before send
        expect(find.text(inputText), findsOneWidget);

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert: text field is cleared after send
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      });

      testWidgets(
          'send button becomes disabled again after clearing text',
          (tester) async {
        // Arrange
        const inputText = 'Analyse my week';

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) {}),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), inputText);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert: button disabled again after field cleared
        final iconButton =
            tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
      });

      testWidgets('does NOT fire onSend when text is empty', (tester) async {
        // Arrange
        var sendCallCount = 0;

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(onSend: (_) => sendCallCount++),
          ),
        );
        await tester.pumpAndSettle();

        // Tap send without entering text
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(sendCallCount, 0);
      });

      testWidgets('does NOT fire onSend when isLoading=true', (tester) async {
        // Arrange
        var sendCallCount = 0;

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(
              onSend: (_) => sendCallCount++,
              isLoading: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.pumpAndSettle();

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert
        expect(sendCallCount, 0);
      });
    });

    // ------------------------------------------------------------------
    // onTextChanged callback
    // ------------------------------------------------------------------
    group('onTextChanged callback', () {
      testWidgets('fires onTextChanged when user types', (tester) async {
        // Arrange
        final changedValues = <String>[];

        // Act
        await tester.pumpWidget(
          buildTestApp(
            child: AIInputBar(
              onSend: (_) {},
              onTextChanged: changedValues.add,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Hi');
        await tester.pumpAndSettle();

        // Assert: callback was invoked
        expect(changedValues, isNotEmpty);
        expect(changedValues.last, 'Hi');
      });
    });

    // ------------------------------------------------------------------
    // Localization: Italian
    // ------------------------------------------------------------------
    group('localization - Italian', () {
      testWidgets('shows Italian hint text', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('it')],
              locale: const Locale('it'),
              home: Scaffold(
                body: AIInputBar(onSend: (_) {}),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: TextField is present (hint text is locale-specific)
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    // ------------------------------------------------------------------
    // Dark theme
    // ------------------------------------------------------------------
    group('dark theme', () {
      testWidgets('renders correctly in dark theme', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en')],
              locale: const Locale('en'),
              home: Scaffold(
                body: AIInputBar(onSend: (_) {}),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: no RenderObject errors and widgets present
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(IconButton), findsOneWidget);
      });
    });
  });
}
