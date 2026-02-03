# AI Coach Implementation Plan

**Based on:** docs/AI_COACH_DESIGN.md
**Execution:** Autonomous (100% completion)
**Batch Size:** 3 tasks per batch

---

## Batch 1: Dependencies & Project Structure

### Task 1.1: Add Dependencies to pubspec.yaml
**File:** `pubspec.yaml`
**Action:** Add 3 new packages
```yaml
dependencies:
  openrouter_api: ^1.0.0
  limit: ^1.0.0
  flutter_markdown: ^0.7.0
```
**Verification:** `flutter pub get` succeeds with no errors

### Task 1.2: Create Feature Directory Structure
**Action:** Create all directories for clean architecture
```
lib/features/ai_coach/
├── domain/entities/
├── domain/repositories/
├── domain/services/
├── data/datasources/
├── data/repositories/
├── data/services/
└── presentation/providers/
└── presentation/screens/
└── presentation/widgets/
```
**Verification:** All directories exist

### Task 1.3: Create Barrel Export File
**File:** `lib/features/ai_coach/ai_coach.dart`
**Action:** Create feature barrel export
**Verification:** File exists and compiles

---

## Batch 2: Domain Entities (Freezed)

### Task 2.1: Create AIMessage Entity
**File:** `lib/features/ai_coach/domain/entities/ai_message.dart`
**Content:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

enum MessageRole { user, assistant, system, tool }

@freezed
class AIToolCall with _$AIToolCall {
  const factory AIToolCall({
    required String name,
    required Map<String, dynamic> arguments,
    String? result,
  }) = _AIToolCall;

  factory AIToolCall.fromJson(Map<String, dynamic> json) =>
      _$AIToolCallFromJson(json);
}

@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required MessageRole role,
    required String content,
    required DateTime timestamp,
    AIToolCall? toolCall,
    @Default(false) bool isTyping,
    String? error,
  }) = _AIMessage;

  const AIMessage._();

  bool get isVisible => role == MessageRole.user || role == MessageRole.assistant;
  bool get hasToolCall => toolCall != null;

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
}
```
**Verification:** `flutter pub run build_runner build` generates freezed files

### Task 2.2: Create AIContext Entity
**File:** `lib/features/ai_coach/domain/entities/ai_context.dart`
**Content:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_context.freezed.dart';
part 'ai_context.g.dart';

enum RecoveryStatus { green, amber, red }

@freezed
class WorkoutSummary with _$WorkoutSummary {
  const factory WorkoutSummary({
    required String id,
    required String name,
    required DateTime completedAt,
    int? durationMinutes,
    int? exerciseCount,
  }) = _WorkoutSummary;

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSummaryFromJson(json);
}

@freezed
class AIContext with _$AIContext {
  const factory AIContext({
    required int currentStreak,
    WorkoutSummary? lastWorkout,
    required Map<String, int> top5OneRM,
    required RecoveryStatus recoveryStatus,
    required String userTier,
  }) = _AIContext;

  const AIContext._();

  String toPromptString() {
    final buffer = StringBuffer();
    buffer.writeln('## User Context');
    buffer.writeln('- Streak: $currentStreak days');

    if (lastWorkout != null) {
      final hoursAgo = DateTime.now().difference(lastWorkout!.completedAt).inHours;
      buffer.writeln('- Last workout: ${lastWorkout!.name} (${hoursAgo}h ago)');
    } else {
      buffer.writeln('- Last workout: Never');
    }

    buffer.writeln('- Top 1RM:');
    top5OneRM.forEach((exercise, kg) {
      buffer.writeln('  - $exercise: ${kg}kg');
    });

    buffer.writeln('- Recovery: ${recoveryStatus.name.toUpperCase()}');

    return buffer.toString();
  }

  factory AIContext.fromJson(Map<String, dynamic> json) =>
      _$AIContextFromJson(json);
}
```
**Verification:** `flutter pub run build_runner build` succeeds

### Task 2.3: Create RateLimitResult Entity
**File:** `lib/features/ai_coach/domain/entities/rate_limit_result.dart`
**Content:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rate_limit_result.freezed.dart';

enum RateLimitStatus { allowed, throttled, blocked }

@freezed
class RateLimitResult with _$RateLimitResult {
  const factory RateLimitResult({
    required RateLimitStatus status,
    required String message,
    @Default(0) int waitSeconds,
  }) = _RateLimitResult;

  const RateLimitResult._();

  bool get isAllowed => status == RateLimitStatus.allowed;
  bool get isThrottled => status == RateLimitStatus.throttled;
  bool get isBlocked => status == RateLimitStatus.blocked;

  factory RateLimitResult.allowed() => const RateLimitResult(
    status: RateLimitStatus.allowed,
    message: '',
  );

  factory RateLimitResult.blocked({required String message}) => RateLimitResult(
    status: RateLimitStatus.blocked,
    message: message,
  );

  factory RateLimitResult.throttled({
    required String message,
    required int waitSeconds,
  }) => RateLimitResult(
    status: RateLimitStatus.throttled,
    message: message,
    waitSeconds: waitSeconds,
  );
}
```
**Verification:** `flutter pub run build_runner build` succeeds

---

## Batch 3: Domain Interfaces

### Task 3.1: Create AICoachService Interface
**File:** `lib/features/ai_coach/domain/services/ai_coach_service.dart`
**Content:**
```dart
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';

abstract class AICoachService {
  Future<AIServiceResponse> sendMessage({
    required String userMessage,
    required List<AIMessage> conversationHistory,
  });
}

class AIServiceResponse {
  final String content;
  final AIToolCall? toolCall;

  const AIServiceResponse({
    required this.content,
    this.toolCall,
  });
}
```
**Verification:** File compiles with no errors

### Task 3.2: Create AIChatRepository Interface
**File:** `lib/features/ai_coach/domain/repositories/ai_chat_repository.dart`
**Content:**
```dart
abstract class AIChatRepository {
  Future<String> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  });
}
```
**Verification:** File compiles with no errors

### Task 3.3: Run Build Runner for All Entities
**Action:** Generate all freezed/json_serializable files
**Command:** `flutter pub run build_runner build --delete-conflicting-outputs`
**Verification:** All `.freezed.dart` and `.g.dart` files generated, no errors

---

## Batch 4: Data Layer - OpenRouter Client

### Task 4.1: Create OpenRouter Repository Implementation
**File:** `lib/features/ai_coach/data/repositories/ai_chat_repository_impl.dart`
**Content:**
```dart
import 'package:openrouter_api/openrouter_api.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/ai_chat_repository.dart';

class AIChatRepositoryImpl implements AIChatRepository {
  AIChatRepositoryImpl({required String apiKey})
      : _client = OpenRouter.inference(key: apiKey);

  final OpenRouter _client;

  @override
  Future<String> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    try {
      final response = await _client.getCompletion(
        model: model,
        messages: messages.map((m) => Message.fromJson(m)).toList(),
        tools: tools,
        temperature: 0.7,
        maxTokens: 1000,
      );

      return response.choices.first.message.content ?? '';
    } catch (e) {
      throw Exception('OpenRouter error: $e');
    }
  }
}
```
**Verification:** File compiles with `openrouter_api` import

### Task 4.2: Create Analytics Aggregator DataSource
**File:** `lib/features/ai_coach/data/datasources/analytics_aggregator.dart`
**Content:**
```dart
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';

class AnalyticsAggregator {
  AnalyticsAggregator({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.recoveryRepo,
    required this.streakRepo,
  });

  final dynamic analyticsRepo;
  final dynamic historyRepo;
  final dynamic recoveryRepo;
  final dynamic streakRepo;

  Future<AIContext> aggregateContext({required String userId}) async {
    // TODO: Implement actual aggregation from repositories
    // Placeholder implementation
    return const AIContext(
      currentStreak: 0,
      top5OneRM: {},
      recoveryStatus: RecoveryStatus.green,
      userTier: 'free',
    );
  }

  Future<Map<String, int>> getTop5OneRM(String userId) async {
    // TODO: Query analytics repository
    return {};
  }
}
```
**Verification:** File compiles

### Task 4.3: Create Tool Executor Service
**File:** `lib/features/ai_coach/data/services/ai_tool_executor.dart`
**Content:**
```dart
import 'dart:convert';

class AIToolExecutor {
  AIToolExecutor({
    required this.analyticsRepo,
    required this.historyRepo,
    required this.recoveryRepo,
  });

  final dynamic analyticsRepo;
  final dynamic historyRepo;
  final dynamic recoveryRepo;

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
        throw Exception('Unknown tool: $toolName');
    }
  }

  // Placeholder implementations
  Future<String> _get1RMHistory(Map<String, dynamic> args) async {
    return jsonEncode({'message': 'Tool not implemented yet'});
  }

  Future<String> _getWeeklyVolume(Map<String, dynamic> args) async {
    return jsonEncode({'message': 'Tool not implemented yet'});
  }

  Future<String> _analyzeMuscleBalance(Map<String, dynamic> args) async {
    return jsonEncode({'message': 'Tool not implemented yet'});
  }

  Future<String> _getRecoveryData(Map<String, dynamic> args) async {
    return jsonEncode({'message': 'Tool not implemented yet'});
  }

  Future<String> _suggestWorkout(Map<String, dynamic> args) async {
    return jsonEncode({'message': 'Tool not implemented yet'});
  }

  Future<String> _compareToStandards(Map<String, dynamic> args) async {
    return jsonEncode({'message': 'Tool not implemented yet'});
  }
}
```
**Verification:** File compiles

---

## Batch 5: Service Implementation

### Task 5.1: Create AICoachService Implementation
**File:** `lib/features/ai_coach/data/services/ai_coach_service_impl.dart`
**Content:** Full service implementation with medical keyword blocking, system prompt, tool calling
**Verification:** File compiles, imports resolve

### Task 5.2: Add System Prompt Constants
**File:** `lib/features/ai_coach/data/services/ai_system_prompt.dart`
**Content:** Full Chain-of-Thought prompt from design doc
**Verification:** File compiles

### Task 5.3: Add Medical Keywords Constants
**File:** `lib/features/ai_coach/data/services/ai_safety_keywords.dart`
**Content:** Medical keyword list for blocking
**Verification:** File compiles

---

## Batch 6: Riverpod 3.0 Providers

### Task 6.1: Create AI Chat Provider (Riverpod 3.0)
**File:** `lib/features/ai_coach/presentation/providers/ai_chat_provider.dart`
**Content:** Using `@riverpod` and `AsyncNotifier` (NOT StateNotifier)
**Verification:** File uses Riverpod 3.0 syntax, compiles

### Task 6.2: Create AI Context Provider
**File:** `lib/features/ai_coach/presentation/providers/ai_context_provider.dart`
**Content:** Aggregates from streak, analytics, recovery providers
**Verification:** File compiles, imports existing providers

### Task 6.3: Create Rate Limit Provider
**File:** `lib/features/ai_coach/presentation/providers/ai_rate_limit_provider.dart`
**Content:** Uses `limit` package for token bucket
**Verification:** File compiles, uses `limit` package correctly

---

## Batch 7: UI Widgets - Part 1

### Task 7.1: Create AIMessageBubble Widget
**File:** `lib/features/ai_coach/presentation/widgets/ai_message_bubble.dart`
**Content:** DecoratedBox-based (NOT Container), Markdown support
**Verification:** Widget compiles, uses DecoratedBox

### Task 7.2: Create AITypingIndicator Widget
**File:** `lib/features/ai_coach/presentation/widgets/ai_typing_indicator.dart`
**Content:** Staggered animation (0.2s delay between dots)
**Verification:** Widget compiles, animation works

### Task 7.3: Create AIInputBar Widget
**File:** `lib/features/ai_coach/presentation/widgets/ai_input_bar.dart`
**Content:** Text field + send button
**Verification:** Widget compiles

---

## Batch 8: UI Widgets - Part 2

### Task 8.1: Create AIRateLimitBanner Widget
**File:** `lib/features/ai_coach/presentation/widgets/ai_rate_limit_banner.dart`
**Content:** Warning banner for 80%/95% quota
**Verification:** Widget compiles

### Task 8.2: Create AICoachScreen
**File:** `lib/features/ai_coach/presentation/screens/ai_coach_screen.dart`
**Content:** Main screen with ListView, input bar, typing indicator
**Verification:** Screen compiles, all widgets integrated

### Task 8.3: Add Localization Strings
**File:** `lib/shared/presentation/l10n/app_en.arb` and `app_it.arb`
**Content:** Add all AI Coach strings
**Verification:** `flutter gen-l10n` succeeds

---

## Batch 9: Integration & Bottom Nav

### Task 9.1: Add AI Icon to AppIcons
**File:** `lib/shared/presentation/theme/app_icons.dart`
**Content:** Add `static const ai = Icons.psychology;`
**Verification:** Icon accessible

### Task 9.2: Add AI Coach Tab to Bottom Navigation
**File:** `lib/main.dart` (or wherever bottom nav is)
**Content:** Add 5th tab "AI Coach"
**Verification:** Tab visible in bottom nav

### Task 9.3: Wire Up Providers
**File:** Update provider exports
**Content:** Export all AI Coach providers from barrel file
**Verification:** Providers accessible app-wide

---

## Batch 10: Testing

### Task 10.1: Unit Test - AI Chat Provider
**File:** `test/features/ai_coach/presentation/providers/ai_chat_provider_test.dart`
**Content:** Test sendMessage, rate limiting, error handling
**Verification:** Tests pass

### Task 10.2: Widget Test - AICoachScreen
**File:** `test/features/ai_coach/presentation/screens/ai_coach_screen_test.dart`
**Content:** Test disclaimer shows, input works
**Verification:** Tests pass

### Task 10.3: Run All Tests
**Command:** `flutter test`
**Verification:** All new tests pass, no regressions

---

## Batch 11: Final Verification

### Task 11.1: Run Flutter Analyze
**Command:** `flutter analyze`
**Verification:** No errors, warnings acceptable

### Task 11.2: Test on Device
**Action:** Build and run on iOS simulator
**Verification:** App runs, AI Coach tab accessible

### Task 11.3: Manual Smoke Test
**Action:**
1. Open AI Coach tab
2. See disclaimer
3. Send test message "Ciao"
4. Check rate limiting works
**Verification:** All core flows work

---

## Success Criteria

- [ ] All 33 tasks completed (11 batches × 3 tasks)
- [ ] `flutter analyze` passes
- [ ] All tests pass
- [ ] Feature accessible in app
- [ ] No crashes or runtime errors
- [ ] Rate limiting works (20 msg/day)
- [ ] OpenRouter integration works (requires API key)

---

## Notes

- **API Key**: Store in environment variable `OPENROUTER_API_KEY`
- **Tools**: Implement actual repository queries in Batch 12 (post-MVP)
- **Testing**: Mock OpenRouter in tests to avoid API costs
- **Performance**: Monitor with DevTools, optimize if needed
