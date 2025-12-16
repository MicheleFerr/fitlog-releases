# AI Coach UX Improvements - Task Plan

**Generated**: 2025-01-19 18:45
**Source**: task-master.dev (WebFetch)
**Complexity Score**: HIGH
**Reason**: New conversational AI system + Multi-layer refactor (Domain/Data/Presentation) + 50 tasks
**Total Tasks**: 50
**Estimated Time**: ~35-40 hours (5-8 weeks at 2hr/day)
**Plan Version**: 1.0

**Context Snapshot**:
- App Version: 1.0.0+49
- Flutter Version: 3.16.0
- Key Packages: riverpod ^2.4.9, firebase_core ^4.2.0, openai_api (to add)
- Target Platforms: iOS 14+, Android 8+
- Related PRs/Issues: None
- Parent Milestone: None
- Last Commit: 47844489 (perf: comprehensive widget performance optimizations)

---

## 📋 Original Request

> Implementare miglioramenti UX strategici per AI Coach basati su competitive analysis:
>
> **P0 Critical** (5 weeks):
> 1. Conversational AI Chat Interface (LLM-powered, real-time dialogue)
> 2. Adaptive Notification Engine (context-aware timing prediction)
> 3. Contextual Insight Delivery (inline during workout, not post-workout)
>
> **P1 High-Impact** (3 weeks):
> 4. AI Coach Onboarding Flow (4-step interactive tutorial)
> 5. Gamification Rebalancing (reduce 14→6 achievements, add Journey Milestones)
> 6. Visual Hierarchy Overhaul (animated severity indicators, critical modals)
>
> Target: Match Freeletics (4.6 rating) UX quality, achieve +40-50% retention boost

---

## 🎯 Task Breakdown

### P0.1: Conversational AI Chat Interface (18 tasks, ~12h)

#### Domain Layer

**Task 1.1**: Create AIMessage entity
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/entities/ai_message.dart`
- **Dependencies**: None (blocking: 1.2, 1.3)
- **Est. Time**: 20 min
- **Verification**: Entity compiles + freezed code generated + JSON serialization works
- **Code Prompt**:
  ```dart
  @freezed class AIMessage with _$AIMessage {
    factory AIMessage({
      required String id,
      required String content,
      required MessageRole role, // user, assistant, system
      required DateTime timestamp,
      @Default(false) bool isStreaming,
      Map<String, dynamic>? metadata,
    }) = _AIMessage;
    factory AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);
  }
  ```

**Task 1.2**: Define ChatRepository abstract interface
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/repositories/chat_repository.dart`
- **Dependencies**: 1.1 (blocks: 1.3, 1.7)
- **Est. Time**: 25 min
- **Verification**: Interface has sendMessage(String, WorkoutContext), getHistory(String userId), clearHistory() methods
- **Code Prompt**:
  ```dart
  abstract class ChatRepository {
    Stream<AIMessage> sendMessage({required String message, required WorkoutContext context});
    Future<List<AIMessage>> getHistory(String userId);
    Future<void> clearHistory(String userId);
  }
  ```

**Task 1.3**: Create SendMessageUseCase
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/usecases/send_message_usecase.dart`
- **Dependencies**: 1.2
- **Est. Time**: 20 min
- **Verification**: UseCase call() method returns Stream<AIMessage>, properly handles errors
- **Code Prompt**:
  ```dart
  class SendMessageUseCase {
    final ChatRepository _repository;
    SendMessageUseCase(this._repository);

    Stream<AIMessage> call({required String message, required WorkoutContext context}) {
      return _repository.sendMessage(message: message, context: context);
    }
  }
  ```

**Task 1.4**: Create GetChatHistoryUseCase
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/usecases/get_chat_history_usecase.dart`
- **Dependencies**: 1.2
- **Est. Time**: 15 min
- **Verification**: Returns Future<List<AIMessage>> ordered by timestamp descending
- **Code Prompt**: Simple repository delegation with userId parameter

#### Data Layer

**Task 1.5**: Implement OpenAI API datasource
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/datasources/openai_remote_datasource.dart`
- **Dependencies**: 1.1 (blocks: 1.7)
- **Est. Time**: 45 min
- **Verification**: Streams SSE responses, handles 429/500 errors, implements retry logic
- **Code Prompt**:
  ```dart
  class OpenAIRemoteDatasource {
    final Dio _client;

    Stream<AIMessage> sendMessage(String message, String systemPrompt) async* {
      final response = await _client.post(
        '/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'stream': true,
        },
      );
      // Parse SSE chunks and yield AIMessage updates
    }
  }
  ```

**Task 1.6**: Create local chat cache with Hive
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/datasources/chat_local_datasource.dart`
- **Dependencies**: None (blocks: 1.7)
- **Est. Time**: 40 min
- **Verification**: Persists messages to Hive, retrieves last 100, deletes older than 30 days
- **Code Prompt**:
  ```dart
  class ChatLocalDatasource {
    final Box<Map<String, dynamic>> _chatBox;

    Future<void> saveMessage(AIMessage message) async {
      await _chatBox.put(message.id, message.toJson());
      await _pruneOldMessages(); // Keep last 100 only
    }

    Future<List<AIMessage>> getHistory(String userId) async {
      final messages = _chatBox.values
          .map((json) => AIMessage.fromJson(json))
          .where((msg) => msg.userId == userId)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages.take(100).toList();
    }
  }
  ```

**Task 1.7**: Implement ChatRepositoryImpl
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/repositories/chat_repository_impl.dart`
- **Dependencies**: 1.5, 1.6 (blocks: 1.9, 1.10)
- **Est. Time**: 35 min
- **Verification**: Delegates to remote datasource, caches results locally, handles offline gracefully
- **Code Prompt**:
  ```dart
  class ChatRepositoryImpl implements ChatRepository {
    final OpenAIRemoteDatasource _remote;
    final ChatLocalDatasource _local;

    @override
    Stream<AIMessage> sendMessage({required String message, required WorkoutContext context}) async* {
      final systemPrompt = PromptBuilder.buildSystemPrompt(context);
      await for (final chunk in _remote.sendMessage(message, systemPrompt)) {
        await _local.saveMessage(chunk); // Cache streaming chunks
        yield chunk;
      }
    }
  }
  ```

**Task 1.8**: Add prompt engineering utility
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/utils/prompt_builder.dart`
- **Dependencies**: None (blocks: 1.7)
- **Est. Time**: 30 min
- **Verification**: Builds system prompt with user profile, workout history, injury data, goal
- **Code Prompt**:
  ```dart
  class PromptBuilder {
    static String buildSystemPrompt(WorkoutContext context) {
      return '''
      You are a professional fitness coach AI assistant for GymBro app.

      User Profile:
      - Experience: ${context.userProfile.experienceLevel}
      - Goal: ${context.userProfile.primaryGoal}
      - Injuries: ${context.userProfile.injuryHistory.join(', ')}

      Current Workout:
      - Exercises: ${context.currentWorkout.exercises.length}
      - Total Volume: ${context.currentWorkout.totalVolume}kg

      Recent History:
      ${context.recentWorkouts.map((w) => '- ${w.date}: ${w.exercises.length} exercises').join('\n')}

      Instructions:
      - Be encouraging and supportive
      - Provide actionable advice based on exercise science
      - Keep responses under 150 words
      - Use emojis sparingly (max 2 per message)
      ''';
    }
  }
  ```

#### Presentation Layer - State Management

**Task 1.9**: Create chatMessagesProvider (Riverpod)
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/chat_messages_provider.dart`
- **Dependencies**: 1.3, 1.7 (blocks: 1.13)
- **Est. Time**: 30 min
- **Verification**: StreamNotifier updates message list in real-time, handles loading/error states
- **Code Prompt**:
  ```dart
  @riverpod
  class ChatMessages extends _$ChatMessages {
    @override
    Stream<List<AIMessage>> build() {
      final repository = ref.watch(chatRepositoryProvider);
      final userId = ref.watch(currentUserIdProvider);
      return repository.getHistory(userId).asStream();
    }

    void addMessage(AIMessage message) {
      state = AsyncData([...state.value ?? [], message]);
    }
  }
  ```

**Task 1.10**: Create sendMessageProvider (Riverpod async)
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/send_message_provider.dart`
- **Dependencies**: 1.3, 1.9 (blocks: 1.13)
- **Est. Time**: 25 min
- **Verification**: FutureProvider handles submission, invalidates chatMessagesProvider on success
- **Code Prompt**:
  ```dart
  @riverpod
  Future<void> sendMessage(SendMessageRef ref, String message) async {
    final useCase = ref.watch(sendMessageUseCaseProvider);
    final context = ref.watch(workoutContextProvider);

    await for (final chunk in useCase(message: message, context: context)) {
      ref.read(chatMessagesProvider.notifier).addMessage(chunk);
    }
  }
  ```

**Task 1.11**: Create streamingResponseProvider
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/streaming_response_provider.dart`
- **Dependencies**: 1.3
- **Est. Time**: 20 min
- **Verification**: StreamProvider triggers typing indicator when stream starts
- **Code Prompt**:
  ```dart
  @riverpod
  Stream<bool> streamingResponse(StreamingResponseRef ref) {
    return ref.watch(chatMessagesProvider).whenData((messages) {
      return messages.lastOrNull?.isStreaming ?? false;
    }).asStream();
  }
  ```

**Task 1.12**: Create voiceInputProvider (speech-to-text state)
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/voice_input_provider.dart`
- **Dependencies**: None
- **Est. Time**: 25 min
- **Verification**: StateNotifier tracks recording state (idle/recording/processing), handles permissions
- **Code Prompt**:
  ```dart
  @riverpod
  class VoiceInput extends _$VoiceInput {
    final SpeechToText _speech = SpeechToText();

    @override
    VoiceInputState build() => VoiceInputState.idle();

    Future<void> startRecording() async {
      final available = await _speech.initialize();
      if (!available) {
        state = VoiceInputState.error('Microphone permission denied');
        return;
      }
      state = VoiceInputState.recording();
      _speech.listen(onResult: (result) {
        if (result.finalResult) {
          state = VoiceInputState.completed(result.recognizedWords);
        }
      });
    }
  }
  ```

#### Presentation Layer - UI

**Task 1.13**: Create AICoachChatScreen widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/screens/ai_coach_chat_screen.dart`
- **Dependencies**: 1.9, 1.10, 1.11 (blocks: 1.18)
- **Est. Time**: 50 min
- **Verification**: Scaffold with AppBar, ListView.builder for messages, ChatInputField at bottom
- **Code Prompt**:
  ```dart
  class AICoachChatScreen extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final messagesAsync = ref.watch(chatMessagesProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.aiCoachChat),
          actions: [
            IconButton(
              icon: Icon(AppIcons.delete),
              onPressed: () => ref.read(chatMessagesProvider.notifier).clearHistory(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) => ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) => ChatBubble(message: messages[index]),
                ),
                loading: () => LoadingIndicator(),
                error: (error, _) => ErrorWidget(error),
              ),
            ),
            ChatInputField(),
          ],
        ),
      );
    }
  }
  ```

**Task 1.14**: Build ChatBubble component
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/chat_bubble.dart`
- **Dependencies**: None
- **Est. Time**: 35 min
- **Verification**: User messages aligned right (blue), assistant left (gray), proper padding
- **Code Prompt**:
  ```dart
  class ChatBubble extends StatelessWidget {
    final AIMessage message;

    @override
    Widget build(BuildContext context) {
      final isUser = message.role == MessageRole.user;
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? context.colors.primary : context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? Radius.zero : null,
              bottomLeft: !isUser ? Radius.zero : null,
            ),
          ),
          child: Text(
            message.content,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isUser ? Colors.white : context.colors.onSurface,
            ),
          ),
        ),
      );
    }
  }
  ```

**Task 1.15**: Add TypingIndicator animation
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/typing_indicator.dart`
- **Dependencies**: None
- **Est. Time**: 30 min
- **Verification**: Three animated dots with 200ms interval, shows only when assistant streaming
- **Code Prompt**:
  ```dart
  class TypingIndicator extends HookWidget {
    @override
    Widget build(BuildContext context) {
      final controller = useAnimationController(duration: Duration(milliseconds: 600));

      useEffect(() {
        controller.repeat();
        return controller.dispose;
      }, []);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final offset = (controller.value + index / 3) % 1;
              return Transform.translate(
                offset: Offset(0, -10 * sin(offset * pi * 2)),
                child: Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      );
    }
  }
  ```

**Task 1.16**: Implement VoiceInputButton
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/voice_input_button.dart`
- **Dependencies**: 1.12
- **Est. Time**: 40 min
- **Verification**: Hold to record, release to send, shows animated waveform during recording
- **Code Prompt**:
  ```dart
  class VoiceInputButton extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final voiceState = ref.watch(voiceInputProvider);

      return GestureDetector(
        onLongPressStart: (_) => ref.read(voiceInputProvider.notifier).startRecording(),
        onLongPressEnd: (_) => ref.read(voiceInputProvider.notifier).stopRecording(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: voiceState.isRecording ? context.colors.error : context.colors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            voiceState.isRecording ? AppIcons.micOff : AppIcons.mic,
            color: Colors.white,
            size: AppIconSize.medium,
          ),
        ),
      );
    }
  }
  ```

**Task 1.17**: Add MessageTimestamp widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/message_timestamp.dart`
- **Dependencies**: None
- **Est. Time**: 15 min
- **Verification**: Displays relative time using timeago package, localized
- **Code Prompt**:
  ```dart
  class MessageTimestamp extends StatelessWidget {
    final DateTime timestamp;

    @override
    Widget build(BuildContext context) {
      final locale = Localizations.localeOf(context).languageCode;
      return Text(
        timeago.format(timestamp, locale: locale),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
  }
  ```

**Task 1.18**: Create ChatInputField component
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/chat_input_field.dart`
- **Dependencies**: 1.16 (blocks: 1.13)
- **Est. Time**: 30 min
- **Verification**: TextField with send button, voice button, disables during streaming
- **Code Prompt**:
  ```dart
  class ChatInputField extends HookConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final controller = useTextEditingController();
      final isStreaming = ref.watch(streamingResponseProvider).valueOrNull ?? false;

      return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.colors.outlineVariant)),
        ),
        child: Row(
          children: [
            VoiceInputButton(),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isStreaming,
                decoration: InputDecoration(
                  hintText: context.l10n.chatInputHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(AppIcons.send, size: AppIconSize.medium),
              onPressed: isStreaming ? null : () {
                ref.read(sendMessageProvider(controller.text));
                controller.clear();
              },
            ),
          ],
        ),
      );
    }
  }
  ```

---

### P0.2: Adaptive Notification Engine (10 tasks, ~5.5h)

#### Domain Layer

**Task 2.1**: Create NotificationPrediction entity
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/entities/notification_prediction.dart`
- **Dependencies**: None (blocks: 2.2, 2.3)
- **Est. Time**: 20 min
- **Verification**: Freezed entity with suggestedTime, confidence (0-1), reasons list
- **Code Prompt**:
  ```dart
  @freezed
  class NotificationPrediction with _$NotificationPrediction {
    factory NotificationPrediction({
      required DateTime suggestedTime,
      @Default(0.0) double confidence,
      @Default([]) List<String> reasons,
      Map<String, dynamic>? contextData,
    }) = _NotificationPrediction;
  }
  ```

**Task 2.2**: Define PatternAnalysisRepository
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/repositories/pattern_analysis_repository.dart`
- **Dependencies**: 2.1 (blocks: 2.3, 2.6)
- **Est. Time**: 25 min
- **Verification**: Interface with analyzeWorkoutPatterns, predictBestTime, logDismissal methods
- **Code Prompt**:
  ```dart
  abstract class PatternAnalysisRepository {
    Future<NotificationPrediction> predictBestTime(String userId);
    Future<void> logDismissal(String userId, DateTime dismissedTime);
    Future<Map<String, int>> analyzeWorkoutPatterns(String userId, {int days = 30});
  }
  ```

**Task 2.3**: Create PredictNotificationTimeUseCase
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/usecases/predict_notification_time_usecase.dart`
- **Dependencies**: 2.2
- **Est. Time**: 25 min
- **Verification**: UseCase analyzes last 30 days, applies ML-style weighting
- **Code Prompt**:
  ```dart
  class PredictNotificationTimeUseCase {
    final PatternAnalysisRepository _repository;

    Future<NotificationPrediction> call(String userId) async {
      final patterns = await _repository.analyzeWorkoutPatterns(userId);
      final prediction = await _repository.predictBestTime(userId);

      // Adjust confidence based on pattern consistency
      final consistency = _calculateConsistency(patterns);
      return prediction.copyWith(confidence: prediction.confidence * consistency);
    }

    double _calculateConsistency(Map<String, int> patterns) {
      // Higher consistency = more predictable user = higher confidence
      final values = patterns.values.toList()..sort((a, b) => b.compareTo(a));
      final topPattern = values.first;
      final total = values.reduce((a, b) => a + b);
      return topPattern / total; // 0.0-1.0
    }
  }
  ```

#### Data Layer

**Task 2.4**: Implement local analytics datasource
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/datasources/analytics_local_datasource.dart`
- **Dependencies**: None (blocks: 2.6)
- **Est. Time**: 35 min
- **Verification**: Stores workout times, dismissal events in Hive with timestamp index
- **Code Prompt**:
  ```dart
  class AnalyticsLocalDatasource {
    final Box<Map<String, dynamic>> _analyticsBox;

    Future<void> logWorkoutTime(String userId, DateTime workoutTime) async {
      await _analyticsBox.put('${userId}_${workoutTime.millisecondsSinceEpoch}', {
        'userId': userId,
        'type': 'workout',
        'timestamp': workoutTime.toIso8601String(),
      });
    }

    Future<List<DateTime>> getWorkoutTimes(String userId, {int days = 30}) async {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return _analyticsBox.values
          .where((event) =>
            event['userId'] == userId &&
            event['type'] == 'workout' &&
            DateTime.parse(event['timestamp']).isAfter(cutoff))
          .map((event) => DateTime.parse(event['timestamp']))
          .toList()
        ..sort((a, b) => b.compareTo(a));
    }
  }
  ```

**Task 2.5**: Add weather API integration
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/datasources/weather_remote_datasource.dart`
- **Dependencies**: None (blocks: 2.6)
- **Est. Time**: 30 min
- **Verification**: Fetches current weather from OpenWeatherMap, caches for 6h
- **Code Prompt**:
  ```dart
  class WeatherRemoteDatasource {
    final Dio _client;
    final Box<Map<String, dynamic>> _cacheBox;

    Future<WeatherData> getCurrentWeather(double lat, double lon) async {
      final cacheKey = 'weather_${lat}_${lon}';
      final cached = _cacheBox.get(cacheKey);

      if (cached != null) {
        final cachedTime = DateTime.parse(cached['timestamp']);
        if (DateTime.now().difference(cachedTime) < Duration(hours: 6)) {
          return WeatherData.fromJson(cached['data']);
        }
      }

      final response = await _client.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {'lat': lat, 'lon': lon, 'appid': apiKey},
      );

      await _cacheBox.put(cacheKey, {
        'timestamp': DateTime.now().toIso8601String(),
        'data': response.data,
      });

      return WeatherData.fromJson(response.data);
    }
  }
  ```

**Task 2.6**: Implement PatternAnalysisRepositoryImpl
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/repositories/pattern_analysis_repository_impl.dart`
- **Dependencies**: 2.4, 2.5 (blocks: 2.8)
- **Est. Time**: 50 min
- **Verification**: Weighted algorithm: 50% time of day, 30% day of week, 20% context signals
- **Code Prompt**:
  ```dart
  class PatternAnalysisRepositoryImpl implements PatternAnalysisRepository {
    final AnalyticsLocalDatasource _local;
    final WeatherRemoteDatasource _weather;

    @override
    Future<NotificationPrediction> predictBestTime(String userId) async {
      final workoutTimes = await _local.getWorkoutTimes(userId, days: 30);

      if (workoutTimes.isEmpty) {
        return NotificationPrediction(
          suggestedTime: DateTime.now().copyWith(hour: 18, minute: 0),
          confidence: 0.3,
          reasons: ['Default time (no history)'],
        );
      }

      // Group by hour of day
      final hourCounts = <int, int>{};
      for (final time in workoutTimes) {
        hourCounts[time.hour] = (hourCounts[time.hour] ?? 0) + 1;
      }

      // Find most common hour
      final bestHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final totalWorkouts = workoutTimes.length;
      final bestHourCount = hourCounts[bestHour]!;

      final confidence = (bestHourCount / totalWorkouts) * 0.5 + // Time consistency (50%)
                         (workoutTimes.length / 30) * 0.3 +      // Sample size (30%)
                         0.2;                                     // Context bonus (20%)

      return NotificationPrediction(
        suggestedTime: DateTime.now().copyWith(hour: bestHour, minute: 0),
        confidence: confidence.clamp(0.0, 1.0),
        reasons: [
          'Based on your workout pattern',
          '$bestHourCount of $totalWorkouts workouts at ${bestHour}:00',
        ],
      );
    }
  }
  ```

**Task 2.7**: Create notification explanation formatter
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/utils/notification_reason_formatter.dart`
- **Dependencies**: None
- **Est. Time**: 20 min
- **Verification**: Converts reason list to localized human-readable text
- **Code Prompt**:
  ```dart
  class NotificationReasonFormatter {
    static String format(BuildContext context, List<String> reasons) {
      if (reasons.isEmpty) return context.l10n.notificationReasonDefault;

      return reasons.map((reason) {
        if (reason.contains('workout pattern')) {
          return context.l10n.notificationReasonPattern;
        } else if (reason.contains('weather')) {
          return context.l10n.notificationReasonWeather;
        } else {
          return reason; // Fallback to raw reason
        }
      }).join(' • ');
    }
  }
  ```

#### Presentation Layer

**Task 2.8**: Create notificationPredictionProvider
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/notification_prediction_provider.dart`
- **Dependencies**: 2.3, 2.6 (blocks: 2.10)
- **Est. Time**: 25 min
- **Verification**: FutureProvider refreshes daily at midnight, caches result
- **Code Prompt**:
  ```dart
  @riverpod
  Future<NotificationPrediction> notificationPrediction(NotificationPredictionRef ref) async {
    final userId = ref.watch(currentUserIdProvider);
    final useCase = ref.watch(predictNotificationTimeUseCaseProvider);

    // Auto-refresh at midnight
    ref.onDispose(() {
      Timer.periodic(Duration(hours: 24), (_) => ref.invalidateSelf());
    });

    return useCase(userId);
  }
  ```

**Task 2.9**: Implement logNotificationDismissalProvider
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/log_dismissal_provider.dart`
- **Dependencies**: 2.2
- **Est. Time**: 20 min
- **Verification**: FutureProvider logs dismissal, invalidates notificationPredictionProvider
- **Code Prompt**:
  ```dart
  @riverpod
  Future<void> logNotificationDismissal(LogNotificationDismissalRef ref, DateTime time) async {
    final userId = ref.watch(currentUserIdProvider);
    final repository = ref.watch(patternAnalysisRepositoryProvider);

    await repository.logDismissal(userId, time);
    ref.invalidate(notificationPredictionProvider); // Trigger reanalysis
  }
  ```

**Task 2.10**: Create AdaptiveNotificationScheduler service
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/services/adaptive_notification_scheduler.dart`
- **Dependencies**: 2.8, 2.7
- **Est. Time**: 40 min
- **Verification**: Uses flutter_local_notifications, includes "Why this time?" in body
- **Code Prompt**:
  ```dart
  class AdaptiveNotificationScheduler {
    final FlutterLocalNotificationsPlugin _notifications;

    Future<void> scheduleWorkoutReminder(
      BuildContext context,
      NotificationPrediction prediction,
    ) async {
      final reasons = NotificationReasonFormatter.format(context, prediction.reasons);

      await _notifications.zonedSchedule(
        0,
        context.l10n.workoutReminderTitle,
        '${context.l10n.workoutReminderBody}\n\n$reasons',
        tz.TZDateTime.from(prediction.suggestedTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminders',
            context.l10n.workoutReminders,
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    }
  }
  ```

---

### P0.3: Contextual Insight Delivery (5 tasks, ~2.5h)

#### Presentation Layer

**Task 3.1**: Create InsightBanner widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/insight_banner.dart`
- **Dependencies**: None (blocks: 3.4)
- **Est. Time**: 35 min
- **Verification**: Toast-style banner at top, slide-in animation, auto-dismiss after 10s
- **Code Prompt**:
  ```dart
  class InsightBanner extends HookWidget {
    final InsightData insight;
    final VoidCallback? onDismiss;

    @override
    Widget build(BuildContext context) {
      final animationController = useAnimationController(duration: Duration(milliseconds: 300));
      final slideAnimation = Tween<Offset>(
        begin: Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));

      useEffect(() {
        animationController.forward();
        Timer(Duration(seconds: 10), () {
          animationController.reverse().then((_) => onDismiss?.call());
        });
        return null;
      }, []);

      return SlideTransition(
        position: slideAnimation,
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getSeverityColor(context, insight.severity),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getSeverityIcon(insight.severity),
                color: _getSeverityColor(context, insight.severity),
                size: AppIconSize.medium,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.insightMessage(insight.messageKey),
                  style: context.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: Icon(AppIcons.close, size: AppIconSize.small),
                onPressed: () {
                  animationController.reverse().then((_) => onDismiss?.call());
                },
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

**Task 3.2**: Build real-time rep drop detector provider
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/rep_drop_detector_provider.dart`
- **Dependencies**: None (blocks: 3.3)
- **Est. Time**: 40 min
- **Verification**: StreamProvider monitors active workout, triggers when reps drop >33%
- **Code Prompt**:
  ```dart
  @riverpod
  Stream<InsightData?> repDropDetector(RepDropDetectorRef ref) {
    final workoutStream = ref.watch(activeWorkoutProvider.stream);

    return workoutStream.asyncMap((workout) async {
      if (workout == null || workout.sets.length < 2) return null;

      final currentSet = workout.sets.last;
      final previousSet = workout.sets[workout.sets.length - 2];

      if (currentSet.exerciseId != previousSet.exerciseId) return null; // Different exercise

      final repDrop = (previousSet.reps - currentSet.reps) / previousSet.reps;

      if (repDrop > 0.33) {
        return InsightData(
          id: uuid.v4(),
          userId: workout.userId,
          type: InsightType.warning,
          category: 'form',
          messageKey: 'formDegradationWarning',
          messageArgs: {
            'previousReps': previousSet.reps,
            'currentReps': currentSet.reps,
            'dropPercent': (repDrop * 100).toInt(),
          },
          severity: InsightSeverity.medium,
          timestamp: DateTime.now(),
          sourceAnalyzerId: 'rep_drop_detector',
        );
      }

      return null;
    });
  }
  ```

**Task 3.3**: Create ShowInsightBannerProvider
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/show_insight_banner_provider.dart`
- **Dependencies**: 3.2
- **Est. Time**: 25 min
- **Verification**: StateNotifier controls visibility, queue system for multiple insights
- **Code Prompt**:
  ```dart
  @riverpod
  class ShowInsightBanner extends _$ShowInsightBanner {
    final List<InsightData> _queue = [];

    @override
    InsightData? build() {
      // Listen to rep drop detector
      ref.listen(repDropDetectorProvider, (_, next) {
        next.whenData((insight) {
          if (insight != null) _enqueueInsight(insight);
        });
      });

      return null;
    }

    void _enqueueInsight(InsightData insight) {
      _queue.add(insight);
      if (state == null) _showNext();
    }

    void _showNext() {
      if (_queue.isEmpty) {
        state = null;
      } else {
        state = _queue.removeAt(0);
        // Auto-dismiss after 10s
        Future.delayed(Duration(seconds: 10), () {
          if (state?.id == insight.id) _showNext();
        });
      }
    }

    void dismissCurrent() {
      _showNext();
    }
  }
  ```

**Task 3.4**: Integrate InsightBanner into WorkoutScreen
- **Layer**: Presentation
- **Files**: `lib/features/workout/presentation/screens/workout_screen.dart` (modify)
- **Dependencies**: 3.1, 3.3
- **Est. Time**: 30 min
- **Verification**: Banner appears at top of Stack, doesn't block set logging form
- **Code Prompt**:
  ```dart
  // In WorkoutScreen build method, wrap body with Stack:

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentInsight = ref.watch(showInsightBannerProvider);

    return Scaffold(
      appBar: AppBar(...),
      body: Stack(
        children: [
          // Existing workout UI
          Column(
            children: [
              ExerciseList(),
              SetLoggingForm(),
            ],
          ),
          // Insight banner at top
          if (currentInsight != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: InsightBanner(
                  insight: currentInsight,
                  onDismiss: () => ref.read(showInsightBannerProvider.notifier).dismissCurrent(),
                ),
              ),
            ),
        ],
      ),
    );
  }
  ```

**Task 3.5**: Add insight action tracking
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/providers/insight_action_provider.dart`
- **Dependencies**: 3.4
- **Est. Time**: 20 min
- **Verification**: Logs when user acts on insight, calculates conversion rate
- **Code Prompt**:
  ```dart
  @riverpod
  Future<void> logInsightAction(LogInsightActionRef ref, String insightId, String action) async {
    final repository = ref.watch(feedbackRepositoryProvider);

    await repository.submitFeedback(FeedbackData(
      id: uuid.v4(),
      userId: ref.watch(currentUserIdProvider),
      insightId: insightId,
      insightType: 'contextual',
      insightCategory: 'form',
      feedbackType: FeedbackType.actedUpon,
      timestamp: DateTime.now(),
      comment: 'User adjusted: $action',
    ));

    // Track conversion for analytics
    await ref.watch(analyticsServiceProvider).logEvent('insight_action_taken', {
      'insight_id': insightId,
      'action': action,
    });
  }
  ```

---

### P1.1: AI Coach Onboarding Flow (6 tasks, ~3.5h)

#### Domain Layer

**Task 4.1**: Create OnboardingStep entity
- **Layer**: Domain
- **Files**: `lib/features/ai_coach/domain/entities/onboarding_step.dart`
- **Dependencies**: None (blocks: 4.2)
- **Est. Time**: 15 min
- **Verification**: Freezed entity with stepNumber (1-4), title, description, isCompleted
- **Code Prompt**:
  ```dart
  @freezed
  class OnboardingStep with _$OnboardingStep {
    factory OnboardingStep({
      required int stepNumber,
      required String titleKey,
      required String descriptionKey,
      @Default(false) bool isCompleted,
      Map<String, dynamic>? stepData,
    }) = _OnboardingStep;
  }
  ```

#### Data Layer

**Task 4.2**: Implement OnboardingRepository
- **Layer**: Data
- **Files**: `lib/features/ai_coach/data/repositories/onboarding_repository_impl.dart`
- **Dependencies**: 4.1 (blocks: 4.3)
- **Est. Time**: 25 min
- **Verification**: Persists step completion to Hive, stores quiz answers as JSON
- **Code Prompt**:
  ```dart
  class OnboardingRepositoryImpl {
    final Box<Map<String, dynamic>> _onboardingBox;

    Future<void> completeStep(int stepNumber, Map<String, dynamic>? data) async {
      await _onboardingBox.put('step_$stepNumber', {
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
        'data': data,
      });
    }

    Future<bool> isStepCompleted(int stepNumber) async {
      final step = _onboardingBox.get('step_$stepNumber');
      return step?['completed'] ?? false;
    }

    Future<Map<String, dynamic>?> getStepData(int stepNumber) async {
      final step = _onboardingBox.get('step_$stepNumber');
      return step?['data'];
    }
  }
  ```

#### Presentation Layer

**Task 4.3**: Create AICoachOnboardingScreen
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/screens/ai_coach_onboarding_screen.dart`
- **Dependencies**: 4.1, 4.2 (blocks: 4.4, 4.5, 4.6)
- **Est. Time**: 50 min
- **Verification**: PageView with 4 steps, skip button (hidden on step 1), progress indicator
- **Code Prompt**:
  ```dart
  class AICoachOnboardingScreen extends HookConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final pageController = usePageController();
      final currentPage = useState(0);

      return Scaffold(
        appBar: AppBar(
          actions: [
            if (currentPage.value > 0)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.skip),
              ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: (currentPage.value + 1) / 4),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (page) => currentPage.value = page,
                children: [
                  OnboardingIntroStep(),
                  OnboardingExampleStep(),
                  OnboardingQuizStep(),
                  NotificationPreferenceStep(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  if (currentPage.value < 3) {
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    ref.read(onboardingRepositoryProvider).completeStep(4, null);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  currentPage.value < 3 ? context.l10n.next : context.l10n.done,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
  ```

**Task 4.4**: Build OnboardingIntroStep widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/onboarding_intro_step.dart`
- **Dependencies**: None
- **Est. Time**: 30 min
- **Verification**: Animated intro with Lottie or custom animation, headline, subheading
- **Code Prompt**:
  ```dart
  class OnboardingIntroStep extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.ai,
              size: 120,
              color: context.colors.primary,
            ),
            SizedBox(height: 32),
            Text(
              context.l10n.aiCoachOnboardingTitle,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              context.l10n.aiCoachOnboardingDescription,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
  ```

**Task 4.5**: Create OnboardingQuizStep widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/onboarding_quiz_step.dart`
- **Dependencies**: 4.2
- **Est. Time**: 40 min
- **Verification**: 3 radio options (progression/injury/efficiency), selection persisted
- **Code Prompt**:
  ```dart
  class OnboardingQuizStep extends HookConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final selectedPriority = useState<String?>(null);

      return Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.whatMattersToYou,
              style: context.textTheme.headlineSmall,
            ),
            SizedBox(height: 24),
            RadioListTile<String>(
              title: Text(context.l10n.progressiveOverload),
              subtitle: Text(context.l10n.progressiveOverloadDesc),
              value: 'progression',
              groupValue: selectedPriority.value,
              onChanged: (value) async {
                selectedPriority.value = value;
                await ref.read(onboardingRepositoryProvider).completeStep(3, {
                  'priority': value,
                });
              },
            ),
            RadioListTile<String>(
              title: Text(context.l10n.injuryPrevention),
              subtitle: Text(context.l10n.injuryPreventionDesc),
              value: 'injury',
              groupValue: selectedPriority.value,
              onChanged: (value) async {
                selectedPriority.value = value;
                await ref.read(onboardingRepositoryProvider).completeStep(3, {
                  'priority': value,
                });
              },
            ),
            RadioListTile<String>(
              title: Text(context.l10n.workoutEfficiency),
              subtitle: Text(context.l10n.workoutEfficiencyDesc),
              value: 'efficiency',
              groupValue: selectedPriority.value,
              onChanged: (value) async {
                selectedPriority.value = value;
                await ref.read(onboardingRepositoryProvider).completeStep(3, {
                  'priority': value,
                });
              },
            ),
          ],
        ),
      );
    }
  }
  ```

**Task 4.6**: Build NotificationPreferenceStep widget
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/notification_preference_step.dart`
- **Dependencies**: 4.2
- **Est. Time**: 35 min
- **Verification**: Toggle daily reminders, time picker for preferred time
- **Code Prompt**:
  ```dart
  class NotificationPreferenceStep extends HookConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final notificationsEnabled = useState(true);
      final preferredTime = useState(TimeOfDay(hour: 18, minute: 0));

      return Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.notificationPreferences,
              style: context.textTheme.headlineSmall,
            ),
            SizedBox(height: 24),
            SwitchListTile(
              title: Text(context.l10n.dailyReminders),
              subtitle: Text(context.l10n.dailyRemindersDesc),
              value: notificationsEnabled.value,
              onChanged: (value) async {
                notificationsEnabled.value = value;
                await ref.read(onboardingRepositoryProvider).completeStep(4, {
                  'notificationsEnabled': value,
                  'preferredTime': preferredTime.value.format(context),
                });
              },
            ),
            if (notificationsEnabled.value)
              ListTile(
                leading: Icon(AppIcons.clock),
                title: Text(context.l10n.preferredTime),
                trailing: Text(preferredTime.value.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: preferredTime.value,
                  );
                  if (picked != null) {
                    preferredTime.value = picked;
                    await ref.read(onboardingRepositoryProvider).completeStep(4, {
                      'notificationsEnabled': notificationsEnabled.value,
                      'preferredTime': picked.format(context),
                    });
                  }
                },
              ),
          ],
        ),
      );
    }
  }
  ```

---

### P1.2: Gamification Rebalancing (5 tasks, ~2.5h)

#### Domain Layer

**Task 5.1**: Update Achievement entity (reduce count)
- **Layer**: Domain
- **Files**: `lib/features/achievements/domain/entities/achievement.dart` (modify)
- **Dependencies**: None (blocks: 5.4)
- **Est. Time**: 20 min
- **Verification**: Remove volumeMaster, centurion, quarterGrand constants, update list to 6
- **Code Prompt**:
  ```dart
  // Remove these achievement IDs:
  // - volumeMaster
  // - centurion
  // - quarterGrand

  // Keep only:
  static const firstWorkout = 'first_workout';
  static const tenWorkouts = 'ten_workouts';
  static const hundredWorkouts = 'hundred_workouts';
  static const thousandWorkouts = 'thousand_workouts';
  static const earlyBird = 'early_bird'; // Hidden
  static const nightOwl = 'night_owl';   // Hidden
  ```

**Task 5.2**: Create JourneyMilestone entity
- **Layer**: Domain
- **Files**: `lib/features/achievements/domain/entities/journey_milestone.dart`
- **Dependencies**: None (blocks: 5.3)
- **Est. Time**: 20 min
- **Verification**: Freezed entity with id, type (WEEK_1, MONTH_1, DAY_90), unlockedDate
- **Code Prompt**:
  ```dart
  @freezed
  class JourneyMilestone with _$JourneyMilestone {
    factory JourneyMilestone({
      required String id,
      required JourneyMilestoneType type,
      DateTime? unlockedDate,
      @Default(false) bool isClaimed,
    }) = _JourneyMilestone;
  }

  enum JourneyMilestoneType {
    week1('Week 1 Complete', 7),
    week2('Week 2 Complete', 14),
    month1('Month 1 Complete', 30),
    day90('90-Day Warrior', 90);

    final String displayName;
    final int requiredDays;
    const JourneyMilestoneType(this.displayName, this.requiredDays);
  }
  ```

#### Data Layer

**Task 5.3**: Implement JourneyMilestoneRepository
- **Layer**: Data
- **Files**: `lib/features/achievements/data/repositories/journey_milestone_repository_impl.dart`
- **Dependencies**: 5.2 (blocks: 5.4)
- **Est. Time**: 30 min
- **Verification**: Calculates milestones from workout history, persists unlocks to Hive
- **Code Prompt**:
  ```dart
  class JourneyMilestoneRepositoryImpl {
    final Box<Map<String, dynamic>> _milestoneBox;
    final WorkoutRepository _workoutRepository;

    Future<List<JourneyMilestone>> checkUnlockedMilestones(String userId) async {
      final workouts = await _workoutRepository.getAllWorkouts(userId);
      if (workouts.isEmpty) return [];

      final firstWorkoutDate = workouts.map((w) => w.date).reduce((a, b) => a.isBefore(b) ? a : b);
      final daysSinceFirst = DateTime.now().difference(firstWorkoutDate).inDays;

      final unlocked = <JourneyMilestone>[];

      for (final type in JourneyMilestoneType.values) {
        if (daysSinceFirst >= type.requiredDays) {
          final cached = _milestoneBox.get(type.name);
          if (cached == null) {
            final milestone = JourneyMilestone(
              id: type.name,
              type: type,
              unlockedDate: firstWorkoutDate.add(Duration(days: type.requiredDays)),
            );
            await _milestoneBox.put(type.name, milestone.toJson());
            unlocked.add(milestone);
          }
        }
      }

      return unlocked;
    }
  }
  ```

#### Presentation Layer

**Task 5.4**: Create JourneyScreen
- **Layer**: Presentation
- **Files**: `lib/features/achievements/presentation/screens/journey_screen.dart`
- **Dependencies**: 5.2, 5.3
- **Est. Time**: 50 min
- **Verification**: Timeline view, shows unlocked milestones with dates, locked grayed out
- **Code Prompt**:
  ```dart
  class JourneyScreen extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final milestonesAsync = ref.watch(journeyMilestonesProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.yourJourney),
        ),
        body: milestonesAsync.when(
          data: (milestones) => ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: JourneyMilestoneType.values.length,
            itemBuilder: (context, index) {
              final type = JourneyMilestoneType.values[index];
              final milestone = milestones.firstWhere(
                (m) => m.type == type,
                orElse: () => JourneyMilestone(id: type.name, type: type),
              );

              final isUnlocked = milestone.unlockedDate != null;

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.2,
                isFirst: index == 0,
                isLast: index == JourneyMilestoneType.values.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 40,
                  color: isUnlocked ? context.colors.primary : context.colors.surfaceVariant,
                  iconStyle: IconStyle(
                    iconData: isUnlocked ? Icons.check : Icons.lock,
                    color: Colors.white,
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: isUnlocked ? context.colors.primary : context.colors.surfaceVariant,
                  thickness: 2,
                ),
                endChild: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.displayName,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: isUnlocked ? context.colors.onSurface : context.colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (isUnlocked)
                        Text(
                          context.l10n.unlockedOn(milestone.unlockedDate!),
                          style: context.textTheme.bodySmall,
                        )
                      else
                        Text(
                          context.l10n.daysRemaining(type.requiredDays),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          loading: () => LoadingIndicator(),
          error: (error, _) => ErrorWidget(error),
        ),
      );
    }
  }
  ```

**Task 5.5**: Update AchievementsScreen (remove 3 items)
- **Layer**: Presentation
- **Files**: `lib/features/achievements/presentation/screens/achievements_screen.dart` (modify)
- **Dependencies**: 5.1
- **Est. Time**: 25 min
- **Verification**: Grid displays 6 achievements (not 14), adds "View Journey" button at top
- **Code Prompt**:
  ```dart
  // In AchievementsScreen build method:

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.achievements),
      ),
      body: Column(
        children: [
          // NEW: Journey button at top
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: Icon(AppIcons.timeline),
              label: Text(context.l10n.viewYourJourney),
              onPressed: () => Navigator.pushNamed(context, '/journey'),
            ),
          ),
          Divider(),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6, // CHANGED: was 14
              itemBuilder: (context, index) {
                // Remove AchievementCard for volumeMaster, centurion, quarterGrand
                // Keep only: firstWorkout, tenWorkouts, hundredWorkouts,
                // thousandWorkouts, earlyBird (hidden), nightOwl (hidden)
              },
            ),
          ),
        ],
      ),
    );
  }
  ```

---

### P1.3: Visual Hierarchy Overhaul (4 tasks, ~2h)

#### Presentation Layer

**Task 6.1**: Create SeverityIcon component
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/severity_icon.dart`
- **Dependencies**: None (blocks: 6.2, 6.3)
- **Est. Time**: 35 min
- **Verification**: AnimatedIcon for Critical (pulsing), static icons for others
- **Code Prompt**:
  ```dart
  class SeverityIcon extends HookWidget {
    final InsightSeverity severity;
    final double? size;

    @override
    Widget build(BuildContext context) {
      switch (severity) {
        case InsightSeverity.critical:
          return AnimatedIconPatterns.pulsing(
            icon: AppIcons.warning,
            color: context.iconError,
            size: size ?? AppIconSize.large,
            duration: Duration(milliseconds: 800),
          );

        case InsightSeverity.high:
          return Icon(
            AppIcons.alertTriangle,
            color: context.iconError,
            size: size ?? AppIconSize.medium,
          );

        case InsightSeverity.medium:
          return Icon(
            AppIcons.info,
            color: context.iconWarning,
            size: size ?? AppIconSize.medium,
          );

        case InsightSeverity.low:
          return Icon(
            AppIcons.lightbulb,
            color: context.iconInfo,
            size: size ?? AppIconSize.small,
          );
      }
    }
  }
  ```

**Task 6.2**: Build CriticalInsightModal
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/critical_insight_modal.dart`
- **Dependencies**: 6.1
- **Est. Time**: 40 min
- **Verification**: Full-screen modal, no dismiss button, only "Acknowledge" action
- **Code Prompt**:
  ```dart
  class CriticalInsightModal extends StatelessWidget {
    final InsightData insight;

    @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.colors.surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SeverityIcon(severity: InsightSeverity.critical, size: 80),
                SizedBox(height: 32),
                Text(
                  context.l10n.criticalInsight,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  context.l10n.insightMessage(insight.messageKey),
                  style: context.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.error,
                    minimumSize: Size(double.infinity, 56),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Log acknowledgment
                  },
                  child: Text(
                    context.l10n.acknowledge,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```

**Task 6.3**: Create HighInsightBanner enhancement
- **Layer**: Presentation
- **Files**: `lib/features/ai_coach/presentation/widgets/insight_banner.dart` (modify)
- **Dependencies**: 3.1, 6.1
- **Est. Time**: 30 min
- **Verification**: Uses SeverityIcon, prominent action button for HIGH severity
- **Code Prompt**:
  ```dart
  // In InsightBanner widget, update build method:

  @override
  Widget build(BuildContext context) {
    final isHigh = insight.severity == InsightSeverity.high;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigh ? context.colors.errorContainer : context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSeverityColor(context, insight.severity),
          width: isHigh ? 3 : 2, // Thicker border for HIGH
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SeverityIcon(severity: insight.severity), // NEW: Use SeverityIcon
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.insightMessage(insight.messageKey),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: isHigh ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(AppIcons.close, size: AppIconSize.small),
                onPressed: onDismiss,
              ),
            ],
          ),
          if (isHigh && insight.suggestedAction != null) ...[
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(AppIcons.checkCircle, size: AppIconSize.small),
              label: Text(context.l10n.takeAction),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.error,
                minimumSize: Size(double.infinity, 44),
              ),
              onPressed: () {
                // Handle action
                onDismiss?.call();
              },
            ),
          ],
        ],
      ),
    );
  }
  ```

**Task 6.4**: Add insight visual regression tests
- **Layer**: Testing
- **Files**: `test/features/ai_coach/presentation/widgets/insight_banner_test.dart`
- **Dependencies**: 6.3
- **Est. Time**: 25 min
- **Verification**: Golden tests for critical/high/medium/low severity rendering
- **Code Prompt**:
  ```dart
  void main() {
    testWidgets('InsightBanner renders critical severity correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightBanner(
              insight: InsightData(
                id: '1',
                userId: 'test',
                type: InsightType.warning,
                category: 'form',
                messageKey: 'testMessage',
                severity: InsightSeverity.critical,
                timestamp: DateTime.now(),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(InsightBanner),
        matchesGoldenFile('goldens/insight_banner_critical.png'),
      );
    });

    // Repeat for high, medium, low severities
  }
  ```

---

### Localization Tasks

**Task 7.1**: Add AI Coach strings to EN locale
- **Layer**: Localization
- **Files**: `assets/i18n/app_en.arb` (modify)
- **Dependencies**: All P0/P1 tasks
- **Est. Time**: 25 min
- **Verification**: 50+ new keys for chat, notifications, onboarding, journey, insights
- **Code Prompt**:
  ```json
  {
    "aiCoachChat": "AI Coach Chat",
    "chatInputHint": "Ask me anything...",
    "workoutReminderTitle": "Time to Train!",
    "workoutReminderBody": "You've got this! 💪",
    "workoutReminders": "Workout Reminders",
    "notificationReasonPattern": "Based on your workout pattern",
    "notificationReasonWeather": "Weather is perfect for training",
    "notificationReasonDefault": "It's time to get stronger",
    "formDegradationWarning": "Reps dropped {dropPercent}%. Check your form or reduce weight.",
    "aiCoachOnboardingTitle": "Meet Your AI Coach",
    "aiCoachOnboardingDescription": "I analyze your workouts and provide personalized insights to help you progress faster.",
    "whatMattersToYou": "What matters most to you?",
    "progressiveOverload": "Progressive Overload",
    "progressiveOverloadDesc": "Getting stronger every session",
    "injuryPrevention": "Injury Prevention",
    "injuryPreventionDesc": "Staying healthy and avoiding setbacks",
    "workoutEfficiency": "Workout Efficiency",
    "workoutEfficiencyDesc": "Saving time while maximizing results",
    "notificationPreferences": "Notification Preferences",
    "dailyReminders": "Daily Workout Reminders",
    "dailyRemindersDesc": "Get notified at your preferred time",
    "preferredTime": "Preferred Time",
    "yourJourney": "Your Journey",
    "unlockedOn": "Unlocked on {date}",
    "daysRemaining": "{days} days to unlock",
    "viewYourJourney": "View Your Journey",
    "criticalInsight": "Critical Insight",
    "acknowledge": "I Understand",
    "takeAction": "Take Action",
    "skip": "Skip",
    "next": "Next",
    "done": "Done"
  }
  ```

**Task 7.2**: Add AI Coach strings to IT locale
- **Layer**: Localization
- **Files**: `assets/i18n/app_it.arb` (modify)
- **Dependencies**: 7.1
- **Est. Time**: 25 min
- **Verification**: All EN keys translated with fitness-appropriate Italian
- **Code Prompt**:
  ```json
  {
    "aiCoachChat": "Chat AI Coach",
    "chatInputHint": "Chiedimi qualsiasi cosa...",
    "workoutReminderTitle": "È Ora di Allenarsi!",
    "workoutReminderBody": "Ce la puoi fare! 💪",
    "workoutReminders": "Promemoria Allenamenti",
    "notificationReasonPattern": "Basato sul tuo schema di allenamento",
    "notificationReasonWeather": "Il tempo è perfetto per allenarsi",
    "notificationReasonDefault": "È ora di diventare più forte",
    "formDegradationWarning": "Ripetizioni calate del {dropPercent}%. Controlla la tecnica o riduci il peso.",
    "aiCoachOnboardingTitle": "Incontra il Tuo AI Coach",
    "aiCoachOnboardingDescription": "Analizzo i tuoi allenamenti e fornisco consigli personalizzati per aiutarti a progredire più velocemente.",
    "whatMattersToYou": "Cosa ti interessa di più?",
    "progressiveOverload": "Sovraccarico Progressivo",
    "progressiveOverloadDesc": "Diventare più forte ad ogni sessione",
    "injuryPrevention": "Prevenzione Infortuni",
    "injuryPreventionDesc": "Rimanere in salute ed evitare battute d'arresto",
    "workoutEfficiency": "Efficienza Allenamento",
    "workoutEfficiencyDesc": "Risparmiare tempo massimizzando i risultati",
    "notificationPreferences": "Preferenze Notifiche",
    "dailyReminders": "Promemoria Giornalieri Allenamento",
    "dailyRemindersDesc": "Ricevi notifiche all'ora preferita",
    "preferredTime": "Ora Preferita",
    "yourJourney": "Il Tuo Percorso",
    "unlockedOn": "Sbloccato il {date}",
    "daysRemaining": "{days} giorni per sbloccare",
    "viewYourJourney": "Vedi Il Tuo Percorso",
    "criticalInsight": "Insight Critico",
    "acknowledge": "Ho Capito",
    "takeAction": "Agisci",
    "skip": "Salta",
    "next": "Avanti",
    "done": "Fatto"
  }
  ```

---

## 📊 Implementation Order

### MUST DO FIRST (Blocking Tasks)

**Week 1-2: Conversational AI Foundation**
→ Task 1.1-1.8 (Domain + Data layers) - ~7h
→ Tasks are sequential dependencies for chat UI

**Week 3: Chat UI + State Management**
→ Task 1.9-1.18 (Presentation layer) - ~5h
→ Depends on 1.1-1.8 completion

**Week 4: Adaptive Notifications Foundation**
→ Task 2.1-2.7 (Domain + Data layers) - ~3.5h

**Week 5: Notifications + Contextual Insights**
→ Task 2.8-2.10 (Notification presentation) - ~1.5h
→ Task 3.1-3.5 (Contextual insights) - ~2.5h

**Total Critical Path (P0)**: ~19.5h (5 weeks at 4h/week)

### THEN (Parallel Workable)

**Week 6: Onboarding Flow**
→ Task 4.1-4.6 (All onboarding) - ~3.5h
→ Can work in parallel with Week 7

**Week 7: Gamification Rebalancing**
→ Task 5.1-5.5 (Achievements + Journey) - ~2.5h
→ Can work in parallel with Week 6

**Week 8: Visual Hierarchy + Localization**
→ Task 6.1-6.4 (Visual improvements) - ~2h
→ Task 7.1-7.2 (Localization) - ~1h

**Total P1**: ~9h (3 weeks at 3h/week)

### FINALLY

**Week 8 End: Integration & Testing**
→ E2E testing with all features enabled
→ Performance profiling (LLM response times)
→ User acceptance testing (internal beta)

**Total Effort**: ~28.5h implementation + ~7h testing/polish = **35-40h total**

---

## 📝 Notes & Decisions

### Technical Decisions

**1. LLM Provider Choice**
- **Decision**: OpenAI GPT-4 Turbo (not Google Gemini)
- **Reason**: Better Italian language support, faster API response times, established Flutter packages
- **Alternative**: Can swap to Gemini later (abstracted via ChatRepository interface)

**2. Notification Prediction Algorithm**
- **Decision**: Weighted statistical model (not ML library)
- **Reason**: Faster implementation, explainable results, sufficient accuracy for MVP
- **Future**: Upgrade to TensorFlow Lite for on-device ML predictions

**3. Onboarding Timing**
- **Decision**: Show onboarding after first workout completion (not on app install)
- **Reason**: User has context of what AI Coach analyzes, higher engagement
- **Metrics**: Track completion rate to validate decision

**4. Achievement Reduction Strategy**
- **Decision**: Remove 8 achievements, add 4 Journey Milestones (separate screen)
- **Reason**: Research shows "constant striving = burnout", journey timeline less competitive feel
- **User Testing**: A/B test 6 vs 14 achievements with cohort retention tracking

### Risks & Mitigation

**Risk 1: LLM API Costs**
- **Mitigation**: Implement token limiting (max 150 words per response), cache common responses, rate limiting (5 messages/minute)
- **Monitoring**: Track API usage daily, set budget alerts at $50/month

**Risk 2: Notification Fatigue**
- **Mitigation**: Start with conservative frequency (max 1/day), track dismissal rate, pause if >30% dismissal for 3 days
- **Fallback**: Allow users to disable all notifications in settings

**Risk 3: Onboarding Abandonment**
- **Mitigation**: Keep steps under 60s total, allow skip on all steps except step 1, persist progress between sessions
- **Target**: >85% completion rate (industry benchmark: 60-70%)

**Risk 4: Chat Abuse (Inappropriate Questions)**
- **Mitigation**: System prompt with guardrails ("Answer only fitness-related questions"), content moderation API, report button
- **Escalation**: Flag repeated violations to admin dashboard

### Success Metrics (to track post-launch)

| Metric | Target | Current Baseline | Measurement |
|--------|--------|------------------|-------------|
| Chat Engagement Rate | >40% | N/A (new feature) | % users sending ≥1 message/week |
| Avg Messages/Session | 3-5 | N/A | Mean messages per chat session |
| Notification Open Rate | >50% | ~20% (static) | % notifications tapped |
| Notification Dismissal Rate | <15% | ~40% (static) | % notifications swiped away |
| Onboarding Completion | >85% | N/A | % users completing all 4 steps |
| D7 Retention | +15-20% | 20% | 7-day retention improvement |
| D30 Retention | +10-15% | 10% | 30-day retention improvement |
| App Rating | +0.4 | 4.2 | iOS/Android app store rating |

---

## 🔄 Version History

### v1.0 - 2025-01-19 (Initial Plan)

**Generated by**: task-master.dev (WebFetch API)

**Total Tasks**: 50 atomic tasks
**Estimated Effort**: 35-40 hours (5-8 weeks)

**Breakdown**:
- P0.1 Conversational AI: 18 tasks (~12h)
- P0.2 Adaptive Notifications: 10 tasks (~5.5h)
- P0.3 Contextual Insights: 5 tasks (~2.5h)
- P1.1 Onboarding: 6 tasks (~3.5h)
- P1.2 Gamification: 5 tasks (~2.5h)
- P1.3 Visual Hierarchy: 4 tasks (~2h)
- Localization: 2 tasks (~1h)

**Complexity Justification**: HIGH
- New conversational AI system (never done before in this codebase)
- Multi-layer refactor (Domain/Data/Presentation all touched)
- 50 tasks with complex dependencies (18 blocking tasks in critical path)
- LLM integration (new external dependency)
- Real-time streaming (technical complexity)
- Pattern analysis algorithm (statistical complexity)

**Next Review**: After P0 completion (Week 5, ~2025-02-23)

---

## 📎 Related Documentation

- **Competitive Analysis**: `docs/UX_FLOWS/ai_coach/AI_COACH_UX_COMPETITIVE_ANALYSIS_AND_IMPROVEMENTS.md`
- **AI Coach System Docs**: `docs/AI_COACH_COMPREHENSIVE_DOCUMENTATION.md`
- **Market Strategy**: `docs/STRATEGY/MARKET_AND_RETENTION_STRATEGY.md`
- **User Scenarios**: `docs/AI_COACH_USER_SCENARIOS.md`
- **Critical Implementation Guide**: `docs/AI_COACH_CRITICAL_IMPLEMENTATION_GUIDE.md`
- **Previous Optimization Plan**: `docs/plans/2025-11-16-ai-coach-optimizations-plan.md` (53 tasks, P0-P1 only)

---

**Plan Status**: ✅ Ready for Implementation
**Approval Required**: Product Owner + Tech Lead
**Start Date**: TBD (after approval)
**Target Completion**: 8 weeks from start date

---

**End of Plan Document**
