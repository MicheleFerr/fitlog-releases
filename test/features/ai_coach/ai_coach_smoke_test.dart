// Smoke test per verificare che AI Coach sia implementato correttamente
import 'package:flutter_test/flutter_test.dart';

// Import tutti i componenti chiave
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_message.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/rate_limit_result.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/ai_coach_service.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_tool_executor.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/services/ai_system_prompt.dart';

void main() {
  group('AI Coach Implementation Smoke Test', () {
    test('Domain entities import correctly', () {
      // Verifica che entities siano importabili
      expect(AIContext, isNotNull);
      expect(AIMessage, isNotNull);
      expect(RateLimitResult, isNotNull);
    });

    test('AI Coach service interface exists', () {
      expect(AICoachService, isNotNull);
    });

    test('AI Tool Executor exists', () {
      expect(AIToolExecutor, isNotNull);
    });

    test('System prompt is defined', () {
      expect(aiSystemPrompt, isNotEmpty);
      expect(aiSystemPrompt, contains('Personal Trainer AI'));
    });

    test('Rate limit result has correct statuses', () {
      expect(RateLimitStatus.allowed, isNotNull);
      expect(RateLimitStatus.throttled, isNotNull);
      expect(RateLimitStatus.blocked, isNotNull);
    });
  });
}
