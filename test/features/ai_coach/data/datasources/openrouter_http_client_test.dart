import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/datasources/openrouter_http_client.dart';

void main() {
  group('ToolCall.fromJson', () {
    test('should handle null arguments field gracefully', () {
      // Arrange: Simulate OpenRouter response with null arguments
      final json = {
        'id': 'call_123',
        'function': {
          'name': 'get_workout_stats',
          'arguments': null, // This was causing the crash
        },
      };

      // Act: Parse without crashing
      final toolCall = ToolCall.fromJson(json);

      // Assert: Should use empty object as default
      expect(toolCall.id, 'call_123');
      expect(toolCall.name, 'get_workout_stats');
      expect(toolCall.arguments, {});
    });

    test('should handle missing function field', () {
      // Arrange: Malformed response without function
      final json = {
        'id': 'call_456',
        'function': null,
      };

      // Act
      final toolCall = ToolCall.fromJson(json);

      // Assert: Should use defaults
      expect(toolCall.id, 'call_456');
      expect(toolCall.name, 'unknown');
      expect(toolCall.arguments, {});
    });

    test('should handle completely null id', () {
      // Arrange
      final json = {
        'id': null,
        'function': {
          'name': 'some_tool',
          'arguments': '{}',
        },
      };

      // Act
      final toolCall = ToolCall.fromJson(json);

      // Assert
      expect(toolCall.id, '');
      expect(toolCall.name, 'some_tool');
      expect(toolCall.arguments, {});
    });

    test('should parse valid tool call correctly', () {
      // Arrange: Proper OpenRouter response
      final json = {
        'id': 'call_789',
        'function': {
          'name': 'get_user_streak',
          'arguments': '{"user_id": "test123"}',
        },
      };

      // Act
      final toolCall = ToolCall.fromJson(json);

      // Assert
      expect(toolCall.id, 'call_789');
      expect(toolCall.name, 'get_user_streak');
      expect(toolCall.arguments, {'user_id': 'test123'});
    });

    test('should handle empty arguments string', () {
      // Arrange
      final json = {
        'id': 'call_empty',
        'function': {
          'name': 'ping',
          'arguments': '',
        },
      };

      // Act & Assert: Should not crash (jsonDecode('') throws, but we handle it)
      expect(
        () => ToolCall.fromJson(json),
        throwsFormatException, // jsonDecode('') is invalid JSON
      );
    });

    test('should handle invalid JSON in arguments', () {
      // Arrange
      final json = {
        'id': 'call_invalid',
        'function': {
          'name': 'test',
          'arguments': '{invalid json}',
        },
      };

      // Act & Assert
      expect(
        () => ToolCall.fromJson(json),
        throwsFormatException, // jsonDecode will throw
      );
    });
  });

  group('OpenRouterResponse', () {
    test('should have empty tool calls by default', () {
      // Arrange
      const response = OpenRouterResponse(content: 'Hello');

      // Assert
      expect(response.toolCalls, isEmpty);
      expect(response.hasToolCalls, false);
    });

    test('should detect tool calls presence', () {
      // Arrange
      const response = OpenRouterResponse(
        content: null,
        toolCalls: [
          ToolCall(
            id: 'call_1',
            name: 'test',
            arguments: {},
          ),
        ],
      );

      // Assert
      expect(response.hasToolCalls, true);
    });
  });
}
