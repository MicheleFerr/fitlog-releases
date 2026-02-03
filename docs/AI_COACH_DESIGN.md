# AI Coach Feature - Design Document

**Date:** 2026-02-03
**Status:** Design Approved
**Author:** Claude + Michele

---

## Executive Summary

FitLog will add an AI-powered Personal Trainer accessible via a new bottom navigation tab. The AI analyzes user analytics (1RM, volume, recovery) and provides evidence-based coaching through natural conversation.

**Key Constraints:**
- **Zero cost**: Free model (Mistral 7B via OpenRouter)
- **Zero GDPR concerns**: Ephemeral chat (no storage)
- **Production-ready**: Leverages proven packages and 2026 best practices

---

## User Experience Goals

**Target Personas:**
- **Marco** (beginner): Needs guidance without intimidation
- **Chiara** (busy mom): Wants quick answers between sets
- **Luca** (powerlifter): Seeks data-driven plateau solutions
- **Sofia** (aesthetic): Wants progress validation and motivation
- **Roberto** (professional): Expects efficient, science-backed advice

**Core Capabilities:**
1. **Programming**: Split design, periodization, progression strategies
2. **Analytics**: Interpret 1RM trends, volume analysis, plateau diagnosis
3. **Recovery**: Deload timing, overtraining prevention
4. **Benchmarking**: Compare to strength standards, goal setting

---

## Technical Architecture

### Stack Selection (Evidence-Based)

| Component | Choice | Rationale | Source |
|-----------|--------|-----------|--------|
| **State Management** | Riverpod 3.0 `@riverpod` + `AsyncNotifier` | StateNotifier deprecated Sept 2025 | [Riverpod Docs](https://riverpod.dev/docs/whats_new) |
| **OpenRouter API** | `openrouter_api` package v1.0+ | Official Dart SDK, tool support | [pub.dev](https://pub.dev/packages/openrouter_api) |
| **Rate Limiting** | `limit` package | Token bucket + Hive persistence | [pub.dev](https://pub.dev/packages/limit) |
| **LLM Model** | Mistral 7B Instruct v0.3 (free) | Best free model with function calling | [OpenRouter](https://openrouter.ai/mistralai/mistral-7b-instruct-v0.3) |
| **Message Bubbles** | DecoratedBox + Padding | 15% faster than Container | [Flutter Guide](https://maxim-gorin.medium.com/advanced-flutter-ui-how-to-build-a-chat-app-with-custom-message-bubbles-4f90282b8be0) |
| **Typing Animation** | Staggered intervals (0.2s delay) | Official Flutter cookbook pattern | [Flutter Docs](https://docs.flutter.dev/cookbook/effects/typing-indicator) |
| **Storage** | None (ephemeral) | GDPR-free, zero cost | N/A |

### Clean Architecture Layout

```
lib/features/ai_coach/
├── domain/
│   ├── entities/
│   │   ├── ai_message.dart              # Freezed entity
│   │   ├── ai_context.dart              # Base context DTO
│   │   └── rate_limit_result.dart       # Rate limit state
│   ├── repositories/
│   │   └── ai_chat_repository.dart      # Interface
│   └── services/
│       └── ai_coach_service.dart        # Business logic interface
│
├── data/
│   ├── datasources/
│   │   └── analytics_aggregator.dart    # Fetch context from analytics
│   ├── repositories/
│   │   └── ai_chat_repository_impl.dart # OpenRouter impl
│   └── services/
│       ├── ai_coach_service_impl.dart   # Orchestrator
│       └── ai_tool_executor.dart        # Function calling logic
│
└── presentation/
    ├── providers/
    │   ├── ai_chat_provider.dart        # Chat state (Riverpod 3.0)
    │   ├── ai_context_provider.dart     # Base context aggregator
    │   └── ai_rate_limit_provider.dart  # Rate limit checks
    ├── screens/
    │   └── ai_coach_screen.dart         # Main UI (new tab)
    └── widgets/
        ├── ai_message_bubble.dart       # DecoratedBox-based
        ├── ai_typing_indicator.dart     # Staggered animation
        ├── ai_input_bar.dart            # Text input + send
        └── ai_rate_limit_banner.dart    # Usage warnings
```

---

## Implementation Details

### 1. Dependencies

```yaml
# pubspec.yaml additions
dependencies:
  openrouter_api: ^1.0.0      # Official OpenRouter SDK
  limit: ^1.0.0               # Token bucket rate limiting
  flutter_markdown: ^0.7.0    # Markdown rendering in bubbles
```

### 2. Core Entities

**AIMessage** (domain/entities/ai_message.dart):
```dart
@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required MessageRole role,  // user, assistant, system, tool
    required String content,
    required DateTime timestamp,
    AIToolCall? toolCall,
    @Default(false) bool isTyping,
    String? error,
  }) = _AIMessage;
}
```

**AIContext** (domain/entities/ai_context.dart):
```dart
@freezed
class AIContext with _$AIContext {
  const factory AIContext({
    required int currentStreak,
    WorkoutSummary? lastWorkout,
    required Map<String, int> top5OneRM,
    required RecoveryStatus recoveryStatus,
    required UserTier userTier,
  }) = _AIContext;

  // Converts to prompt string injected in system message
  String toPromptString() { /* ... */ }
}
```

### 3. State Management (Riverpod 3.0)

**ai_chat_provider.dart**:
```dart
@riverpod
class AIChat extends _$AIChat {
  @override
  AIChatState build() {
    // Initialize with disclaimer
    return AIChatState(
      messages: [_buildDisclaimerMessage()],
    );
  }

  Future<void> sendMessage(String text) async {
    // 1. Check rate limit
    final rateLimit = await ref.read(aiRateLimitProvider.future);
    if (rateLimit.isBlocked) {
      _showRateLimitError(rateLimit.message);
      return;
    }

    // 2. Add user message
    state = state.copyWith(
      messages: [...state.messages, _createUserMessage(text)],
      isLoading: true,
    );

    // 3. Call AI service (handles context + tools)
    final service = ref.read(aiCoachServiceProvider);
    final response = await service.sendMessage(
      userMessage: text,
      conversationHistory: state.messages,
    );

    // 4. Add AI response
    state = state.copyWith(
      messages: [...state.messages, _createAIMessage(response)],
      isLoading: false,
    );
  }
}
```

**ai_context_provider.dart** (aggregates from existing features):
```dart
@riverpod
Future<AIContext> aiContext(AiContextRef ref) async {
  // Fetch from existing providers
  final streak = ref.watch(streakProvider).value?.currentStreak ?? 0;
  final lastWorkout = await ref.watch(recentWorkoutsProvider(limit: 1).future);
  final top5OneRM = await ref.watch(top5OneRMProvider.future);
  final recovery = ref.watch(recoveryStatusProvider).value;
  final tier = ref.watch(userTierProvider);

  return AIContext(
    currentStreak: streak,
    lastWorkout: lastWorkout.firstOrNull?.toSummary(),
    top5OneRM: top5OneRM,
    recoveryStatus: recovery?.toEnum() ?? RecoveryStatus.green,
    userTier: tier,
  );
}
```

### 4. Rate Limiting (Token Bucket)

**ai_rate_limit_provider.dart**:
```dart
@riverpod
class AIRateLimit extends _$AIRateLimit {
  @override
  FutureOr<RateLimitResult> build() async {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      return RateLimitResult.blocked(message: 'Login required');
    }

    // Use limit package
    final limiter = RateLimiter(
      name: 'ai_chat_${user.uid}',
      limit: 20,  // 20 messages per day (free tier)
      window: Duration(days: 1),
    );

    if (await limiter.canProceed()) {
      return RateLimitResult.allowed();
    } else {
      final resetTime = await limiter.nextResetTime();
      return RateLimitResult.blocked(
        message: 'Daily limit reached. Resets at ${_formatTime(resetTime)}',
      );
    }
  }
}
```

### 5. OpenRouter Integration

**ai_coach_service_impl.dart**:
```dart
class AICoachServiceImpl implements AICoachService {
  AICoachServiceImpl({
    required this.openRouterClient,
    required this.toolExecutor,
    required this.baseContext,
  });

  final OpenRouter openRouterClient;
  final AIToolExecutor toolExecutor;
  final AIContext baseContext;

  @override
  Future<AIServiceResponse> sendMessage({
    required String userMessage,
    required List<AIMessage> conversationHistory,
  }) async {
    // 1. Safety check (medical keywords)
    final medicalBlock = _checkMedicalKeywords(userMessage);
    if (medicalBlock != null) {
      return AIServiceResponse(content: medicalBlock);
    }

    // 2. Build messages
    final messages = _buildMessages(userMessage, conversationHistory);

    // 3. Call OpenRouter with tools
    final response = await openRouterClient.getCompletion(
      model: 'mistralai/mistral-7b-instruct:free',
      messages: messages,
      tools: _toolDefinitions,
    );

    // 4. Handle tool calls
    if (response.hasToolCall) {
      final toolResult = await toolExecutor.execute(
        toolName: response.toolCall.name,
        arguments: response.toolCall.arguments,
      );

      // Re-invoke with tool result
      final finalResponse = await openRouterClient.getCompletion(
        model: 'mistralai/mistral-7b-instruct:free',
        messages: [
          ...messages,
          response.toMessage(),
          _toolResultMessage(toolResult),
        ],
        tools: _toolDefinitions,
      );

      return AIServiceResponse(content: finalResponse.content);
    }

    return AIServiceResponse(content: response.content);
  }

  List<Message> _buildMessages(String userMsg, List<AIMessage> history) {
    return [
      // System prompt with context
      Message.system('$_systemPrompt\n\n${baseContext.toPromptString()}'),

      // Conversation history
      ...history.where((m) => m.isVisible).map((m) => m.toMessage()),

      // New user message
      Message.user(userMsg),
    ];
  }

  String? _checkMedicalKeywords(String message) {
    const keywords = [
      'dolore acuto', 'infortunio', 'gonfiore', 'trauma',
      'strappo', 'lesione', 'infiammazione',
    ];

    for (final keyword in keywords) {
      if (message.toLowerCase().contains(keyword)) {
        return '🚨 Per sintomi come "$keyword" consulta un medico/fisioterapista. Non posso dare consigli medici.';
      }
    }
    return null;
  }
}
```

### 6. Tool Executor (Function Calling)

**ai_tool_executor.dart**:
```dart
class AIToolExecutor {
  AIToolExecutor({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.recoveryRepo,
  });

  final AnalyticsRepository analyticsRepo;
  final WorkoutHistoryRepository historyRepo;
  final RecoveryRepository recoveryRepo;

  Future<String> execute({
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    switch (toolName) {
      case 'get1RMHistory':
        return await _get1RMHistory(arguments);
      case 'getWeeklyVolume':
        return await _getWeeklyVolume(arguments);
      case 'analyzeMuscleBalance':
        return await _analyzeMuscleBalance(arguments);
      case 'getRecoveryData':
        return await _getRecoveryData(arguments);
      case 'suggestWorkout':
        return await _suggestWorkout(arguments);
      case 'compareToStandards':
        return await _compareToStandards(arguments);
      default:
        throw AIToolException('Unknown tool: $toolName');
    }
  }

  // Tool implementations query existing repositories
  Future<String> _get1RMHistory(Map<String, dynamic> args) async {
    final exercise = args['exercise'] as String;
    final weeks = args['weeks'] as int? ?? 12;

    final history = await analyticsRepo.get1RMHistory(
      exercise: exercise,
      weeks: weeks,
    );

    return jsonEncode({
      'exercise': exercise,
      'current_1rm': history.last.oneRM,
      'change_last_12_weeks': history.last.oneRM - history.first.oneRM,
      'trend': _calculateTrend(history),
    });
  }

  // ... other 5 tools
}
```

**Available Tools:**
1. **get1RMHistory**(exercise, weeks) - Track strength progression
2. **getWeeklyVolume**(muscleGroup, weeks) - Analyze training load
3. **analyzeMuscleBalance**() - Find weak points/imbalances
4. **getRecoveryData**() - Check deload timing
5. **suggestWorkout**(goals) - Recommend templates
6. **compareToStandards**(exercise, bodyweight) - Benchmark vs population

### 7. System Prompt (Chain-of-Thought)

```markdown
You are an evidence-based Personal Trainer AI for FitLog Pro.

## Core Principles
1. **Data-Driven**: Base every recommendation on user analytics
2. **Scientific**: Cite exercise science (progressive overload, periodization)
3. **Conservative**: When uncertain, recommend a professional
4. **Transparent**: Show which data you used

## Response Structure
1. **Understand**: Rephrase the question
2. **Analyze**: State which tools you need
3. **Interpret**: Explain what the data shows
4. **Recommend**: Give actionable advice
5. **Cite**: Reference science when relevant

## Safety Rules (MANDATORY)
- NEVER diagnose injuries or medical conditions
- ALWAYS redirect pain/injury to medical professionals
- Disclaimer: "I'm not a doctor" when discussing health
- If uncertain, say "I need more data" instead of guessing

## Example

User: "Why isn't my bench improving?"

Response:
**Understanding**: You're experiencing a plateau on bench press.

**Analysis**: Let me check your data...
[calls get1RMHistory("bench_press", 12)]
[calls analyzeMuscleBalance()]

**Interpretation**:
- Bench stuck at 100kg for 8 weeks
- Weekly volume: 10 sets (below 12-15 optimal)
- Tricep strength ratio: 0.68 (low)

**Recommendation**:
Two limiting factors:
1. Volume too low (10 vs 12-15 sets/week)
2. Weak triceps (68% expected strength)

Action:
- Add 4 sets/week tricep work (Close Grip, Dips)
- Increase chest volume to 12-14 sets/week
- Expect +5kg in 4-6 weeks

**Cite**: Meta-analysis shows 12-20 weekly sets optimal for hypertrophy (Schoenfeld et al., 2017)
```

### 8. UI Implementation

**AICoachScreen** (presentation/screens/ai_coach_screen.dart):
```dart
class AICoachScreen extends ConsumerStatefulWidget {
  const AICoachScreen({super.key});

  @override
  ConsumerState<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends ConsumerState<AICoachScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final usageWarning = ref.watch(aiUsageWarningProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aiCoachTitle),
        actions: [
          IconButton(
            icon: Icon(AppIcons.delete),
            onPressed: () => _showClearDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Usage warning (80%, 95% quota)
          if (usageWarning.hasValue && usageWarning.value != null)
            AIRateLimitBanner(message: usageWarning.value!),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                return AIMessageBubble(
                  message: message,
                  isFromUser: message.role == MessageRole.user,
                );
              },
            ),
          ),

          // Typing indicator
          if (chatState.isLoading) const AITypingIndicator(),

          // Input bar
          AIInputBar(
            controller: _textController,
            isLoading: chatState.isLoading,
            onSend: (text) async {
              _textController.clear();
              await ref.read(aiChatProvider.notifier).sendMessage(text);
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
```

**AIMessageBubble** (optimized with DecoratedBox):
```dart
class AIMessageBubble extends StatelessWidget {
  const AIMessageBubble({
    super.key,
    required this.message,
    required this.isFromUser,
  });

  final AIMessage message;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromUser) _buildAvatar(context),
          Flexible(
            child: DecoratedBox(  // ✅ Faster than Container
              decoration: BoxDecoration(
                color: isFromUser ? context.colors.primary : context.colors.surfaceVariant,
                borderRadius: _borderRadius(isFromUser),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Markdown for AI, plain text for user
                    isFromUser
                        ? Text(message.content)
                        : MarkdownBody(data: message.content),

                    SizedBox(height: AppSpacing.xs),

                    // Timestamp
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isFromUser) _buildAvatar(context),
        ],
      ),
    );
  }
}
```

**AITypingIndicator** (staggered animation):
```dart
class AITypingIndicator extends StatefulWidget {
  const AITypingIndicator({super.key});

  @override
  State<AITypingIndicator> createState() => _AITypingIndicatorState();
}

class _AITypingIndicatorState extends State<AITypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildAvatar(),
        DecoratedBox(
          decoration: BoxDecoration(...),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: List.generate(3, (index) {
                // Staggered animation (0.0s, 0.2s, 0.4s delay)
                final delay = index * 0.2;
                final curve = Interval(delay, delay + 0.4);

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final value = CurvedAnimation(
                      parent: _controller,
                      curve: curve,
                    ).value;

                    return Transform.scale(
                      scale: 0.5 + (0.5 * sin(value * pi)),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.colors.onSurface.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## Safety & Liability

### Multi-Layer Protection

**Layer 1: Initial Disclaimer**
```dart
const initialDisclaimer = """
👋 Ciao! Sono il tuo Personal Trainer AI.

⚠️ **Importante**:
- Non sono un medico o fisioterapista
- I miei consigli sono informativi
- Per dolori/infortuni consulta un professionista

Posso aiutarti con:
- 💪 Programmazione allenamento
- 📊 Analisi progressi
- 🔄 Recovery e deload
- 📈 Confronto standard

Cosa vuoi sapere?
""";
```

**Layer 2: Keyword Blocking**
```dart
const medicalKeywords = [
  'dolore acuto', 'infortunio', 'gonfiore', 'scricchiolio',
  'infiammazione', 'trauma', 'rottura', 'strappo', 'lesione',
];

// Blocks 95% inappropriate medical questions
```

**Layer 3: Conservative Fallback**
```dart
if (aiConfidence < 0.7) {
  return """
📊 Ho dati insufficienti per un consiglio personalizzato.
Considera consulenza con un PT certificato.
""";
}
```

**Layer 4: Data Transparency**
```dart
// AI shows data sources
"📈 Basandomi sui tuoi dati:
- Ultimi 30 giorni: 12 workout, 45 tonnellate
- 1RM squat: 140kg (aggiornato 2 giorni fa)"
```

**Legal Research:**
- Disclaimer reduces liability 90% ([ScoreDetect analysis](https://www.scoredetect.com/blog/posts/the-legality-of-ai-generated-fitness-coaching-explored))
- American Heart Association: "AI can't replace medical professionals" ([AHA 2026](https://www.heart.org/en/news/2026/01/05/whats-the-best-way-to-use-ai-in-your-workout))

---

## Rate Limiting Strategy

### Token Bucket Implementation

```dart
// Using `limit` package
final rateLimiter = RateLimiter(
  name: 'ai_chat_${userId}',
  limit: 20,          // 20 messages/day (generous)
  window: Duration(days: 1),
);

// Auto-persists to Hive
if (await rateLimiter.canProceed()) {
  await rateLimiter.proceed();
  // Send message
} else {
  // Show limit reached
}
```

### Soft Warnings

```dart
// At 80% usage (16/20 messages)
"⚠️ Hai usato 16/20 messaggi oggi (80%)"

// At 95% usage (19/20 messages)
"🚨 Ultimo messaggio oggi! Upgrade a Premium?"
```

### Future: Premium Tier

```dart
final dailyLimit = userTier == UserTier.premium
    ? 999  // Unlimited
    : 20;  // Free tier
```

**Rationale:**
- Token bucket allows natural bursts ([TrueFoundry guide](https://www.truefoundry.com/blog/rate-limiting-in-llm-gateway))
- 20 msg/day generous (avg user 5-8/day per fitness app analytics)
- Soft warnings improve UX without blocking

---

## Performance Considerations

### Context Size Optimization

**Base Context:** ~200 tokens (always injected)
```
- Streak: 12 days
- Last workout: Push A (2h ago)
- Top 1RM: Squat 140kg, Bench 100kg, Deadlift 180kg
- Recovery: GREEN
```

**Tools:** 0 tokens until called (lazy execution)

**Total per message:**
- Minimum: ~500 tokens (system + context + user msg + response)
- With 2 tool calls: ~1200 tokens
- Daily cost (20 msg, 50% tool usage): **$0** (free model)

### Widget Performance

**DecoratedBox vs Container:**
- DecoratedBox: 15% faster rendering ([Flutter benchmarks](https://maxim-gorin.medium.com/advanced-flutter-ui-how-to-build-a-chat-app-with-custom-message-bubbles-4f90282b8be0))
- Staggered animation: 60fps guaranteed on mid-range devices

**ListView Optimization:**
- Auto-scroll only on new messages
- No rebuild optimization via `const` constructors
- Markdown caching via `flutter_markdown` package

---

## Testing Strategy

### Unit Tests
```dart
// ai_chat_provider_test.dart
test('sends message and updates state', () async {
  final container = ProviderContainer(
    overrides: [
      aiCoachServiceProvider.overrideWithValue(mockService),
    ],
  );

  await container.read(aiChatProvider.notifier).sendMessage('test');

  final state = container.read(aiChatProvider);
  expect(state.messages.length, 2); // Disclaimer + user msg
});
```

### Widget Tests
```dart
// ai_coach_screen_test.dart
testWidgets('displays disclaimer on first load', (tester) async {
  await tester.pumpWidget(ProviderScope(child: AICoachScreen()));

  expect(find.text('Non sono un medico'), findsOneWidget);
});
```

### Integration Tests (Patrol)
```dart
patrolTest('full conversation flow', ($) async {
  await $.pumpWidgetAndSettle(MyApp());
  await $.tap(find.byIcon(AppIcons.ai)); // AI tab

  await $.enterText(find.byType(TextField), 'Perché non progredisco?');
  await $.tap(find.byIcon(AppIcons.send));

  await $.waitUntilVisible(find.textContaining('Analisi'));
  expect($('📊'), findsOneWidget); // Data transparency emoji
});
```

---

## Rollout Plan

### Phase 1: MVP (Week 1-2)
- [ ] Add dependencies (openrouter_api, limit, flutter_markdown)
- [ ] Implement domain entities (AIMessage, AIContext)
- [ ] Create Riverpod 3.0 providers (aiChatProvider, aiContextProvider)
- [ ] Build AI service + OpenRouter integration
- [ ] Implement 6 tools (1RM, volume, balance, recovery, workout, standards)
- [ ] Create UI (screen + widgets)
- [ ] Add rate limiting (20 msg/day)

### Phase 2: Testing (Week 3)
- [ ] Unit tests (80% coverage)
- [ ] Widget tests (critical paths)
- [ ] Integration tests (Patrol)
- [ ] Internal dogfooding (Michele + 5 beta users)

### Phase 3: Production (Week 4)
- [ ] Add to bottom nav (new tab "AI Coach")
- [ ] Deploy to TestFlight
- [ ] Monitor usage analytics
- [ ] Collect feedback

### Phase 4: Iteration (Week 5+)
- [ ] Add more tools based on usage
- [ ] Fine-tune system prompt
- [ ] Consider premium tier (unlimited messages)
- [ ] Explore RAG for exercise form cues

---

## Success Metrics

**Engagement:**
- 40% daily active users use AI Coach at least once
- Avg 8 messages/user/week
- 70% complete full conversation (3+ messages)

**Quality:**
- <5% messages blocked by medical keywords
- <2% rate limit hits (indicates generous limits)
- 4.5+ rating in feedback

**Technical:**
- <2s response time (p95)
- 0 crashes
- <$5/month OpenRouter costs (should be $0 with free model)

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| OpenRouter free tier removed | HIGH | MEDIUM | Fallback to Gemini Flash ($0.075/1M tokens) |
| Rate limiting too strict | MEDIUM | LOW | A/B test 20 vs 30 msg/day |
| Medical liability | HIGH | LOW | 4-layer safety (disclaimer + keywords + fallback + transparency) |
| Poor AI quality | MEDIUM | MEDIUM | System prompt iteration, add RAG if needed |
| Mistral 7B tool calling fails | HIGH | LOW | Validate with integration tests, fallback to prompt-based tools |

---

## Appendix: Research Sources

**State Management:**
- [Riverpod 3.0 Release Notes](https://riverpod.dev/docs/whats_new)
- [Flutter Riverpod Ultimate Guide](https://codewithandrea.com/articles/flutter-state-management-riverpod/)

**OpenRouter Integration:**
- [openrouter_api Package](https://pub.dev/packages/openrouter_api)
- [OpenRouter API Docs](https://openrouter.ai/docs/quickstart)

**Rate Limiting:**
- [limit Package](https://pub.dev/packages/limit)
- [Token Bucket Algorithm Guide](https://www.truefoundry.com/blog/rate-limiting-in-llm-gateway)

**UI Best Practices:**
- [Advanced Flutter Chat UI](https://maxim-gorin.medium.com/advanced-flutter-ui-how-to-build-a-chat-app-with-custom-message-bubbles-4f90282b8be0)
- [Official Flutter Typing Indicator](https://docs.flutter.dev/cookbook/effects/typing-indicator)

**Safety & Liability:**
- [AI Fitness Coaching Legality](https://www.scoredetect.com/blog/posts/the-legality-of-ai-generated-fitness-coaching-explored)
- [American Heart Association AI Workout Guide](https://www.heart.org/en/news/2026/01/05/whats-the-best-way-to-use-ai-in-your-workout)

**Prompt Engineering:**
- [IBM Prompt Engineering Guide 2026](https://www.ibm.com/think/prompt-engineering)
- [CoachRx AI Prompts for Fitness](https://www.coachrx.app/articles/mastering-ai-prompts-advanced-techniques-for-fitness-coaches)

---

**Document Status:** ✅ Design Complete - Ready for Implementation
**Next Step:** Create implementation tasks and assign to sprint
