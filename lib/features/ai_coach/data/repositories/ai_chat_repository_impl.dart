/// AI Chat Repository Implementation
///
/// Concrete implementation using Firebase Callable Function.
/// OpenRouter API key stays on backend (Cloud Functions).
///
/// **Layer**: Data - Repository Implementation
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/exceptions/ai_coach_exception.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/ai_chat_repository.dart';

/// Cloud Function implementation of AI chat repository
class AIChatRepositoryImpl implements AIChatRepository {
  AIChatRepositoryImpl({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<AIChatRepositoryResponse> sendMessage({
    required String model,
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    try {
      _debugLog(
        '[AI_CHAT_REPO] ☁️ Calling aiCoachChatCompletion Cloud Function...',
      );
      _debugLog('[AI_CHAT_REPO] Model: $model');
      _debugLog('[AI_CHAT_REPO] Messages count: ${messages.length}');
      _debugLog('[AI_CHAT_REPO] Tools available: ${tools?.length ?? 0}');

      final callable = _functions.httpsCallable(
        'aiCoachChatCompletion',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 110)),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'model': model,
        'messages': messages,
        if (tools != null && tools.isNotEmpty) 'tools': tools,
        'maxTokens': 1000,
      });

      final data = _toMap(result.data);
      final quota = _parseQuota(data['quota']);
      final toolCallsRaw = data['toolCalls'];

      if (toolCallsRaw is List && toolCallsRaw.isNotEmpty) {
        final toolCallsJson = toolCallsRaw
            .map(_toMap)
            .where((toolCall) => toolCall.isNotEmpty)
            .toList();
        return AIChatRepositoryResponse(
          payload: '__TOOL_CALLS__:${jsonEncode(toolCallsJson)}',
          quota: quota,
        );
      }

      final content = data['content'] as String? ?? '';
      _debugLog('[AI_CHAT_REPO] ✅ Got response from Cloud Function');
      return AIChatRepositoryResponse(payload: content, quota: quota);
    } on FirebaseFunctionsException catch (e, stackTrace) {
      _debugLog(
        '[AI_CHAT_REPO] ❌ Cloud Function error: ${e.code} - ${e.message}',
      );
      final mappedError = _mapFunctionsException(e);

      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI chat Cloud Function error in AI Coach',
        information: [
          'code: ${e.code}',
          'message: ${e.message}',
          'model: $model',
          'messagesCount: ${messages.length}',
          'hasQuotaDetails: ${mappedError.quota != null}',
        ],
      );

      throw mappedError;
    } catch (e, stackTrace) {
      _debugLog('[AI_CHAT_REPO] ❌ AI backend error: $e');
      _debugLog('[AI_CHAT_REPO] Stack trace: $stackTrace');

      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'AI backend error in AI Coach',
        information: ['model: $model', 'messagesCount: ${messages.length}'],
      );

      throw const AICoachException(
        code: 'unknown',
        userMessage: 'AI Coach non disponibile al momento. Riprova tra poco.',
      );
    }
  }

  AICoachException _mapFunctionsException(FirebaseFunctionsException e) {
    final details = _toMap(e.details);
    final source = details['source'] as String?;
    final quota = _parseQuota(details['quota']);

    switch (e.code) {
      case 'resource-exhausted':
        if (source == 'daily_quota') {
          if (quota != null) {
            return AICoachException(
              code: e.code,
              userMessage:
                  'Limite giornaliero AI Coach raggiunto: '
                  '${quota.usedToday}/${quota.limitPerDay}. Riprova domani.',
              technicalMessage: e.message,
              quota: quota,
            );
          }
          return AICoachException(
            code: e.code,
            userMessage:
                'Hai raggiunto il limite giornaliero di AI Coach. Riprova domani.',
            technicalMessage: e.message,
          );
        }
        return AICoachException(
          code: e.code,
          userMessage:
              'AI Coach è temporaneamente sovraccarico. Riprova tra qualche secondo.',
          technicalMessage: e.message,
          quota: quota,
        );
      case 'unauthenticated':
        return AICoachException(
          code: e.code,
          userMessage: 'Sessione scaduta. Effettua di nuovo il login.',
          technicalMessage: e.message,
          quota: quota,
        );
      case 'invalid-argument':
        return AICoachException(
          code: e.code,
          userMessage:
              'Richiesta non valida per AI Coach. Prova con un messaggio più breve.',
          technicalMessage: e.message,
          quota: quota,
        );
      case 'failed-precondition':
        return AICoachException(
          code: e.code,
          userMessage:
              'Verifica di sicurezza non riuscita. Riavvia l\'app e riprova.',
          technicalMessage: e.message,
          quota: quota,
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return AICoachException(
          code: e.code,
          userMessage:
              'Servizio AI Coach non raggiungibile al momento. Riprova tra poco.',
          technicalMessage: e.message,
          quota: quota,
        );
      case 'permission-denied':
        return AICoachException(
          code: e.code,
          userMessage: 'Non hai i permessi per usare AI Coach.',
          technicalMessage: e.message,
          quota: quota,
        );
      default:
        return AICoachException(
          code: e.code,
          userMessage: 'Errore temporaneo AI Coach. Riprova tra pochi secondi.',
          technicalMessage: e.message,
          quota: quota,
        );
    }
  }

  AIQuota? _parseQuota(dynamic rawQuota) {
    final map = _toMap(rawQuota);
    if (map.isEmpty) {
      return null;
    }

    final tier = map['accountTier'] as String?;
    final usedToday = _toInt(map['usedToday']);
    final limitPerDay = _toInt(map['limitPerDay']);
    final remainingToday = _toInt(map['remainingToday']);

    if (tier == null ||
        usedToday == null ||
        limitPerDay == null ||
        remainingToday == null) {
      return null;
    }

    return AIQuota(
      accountTier: tier,
      usedToday: usedToday,
      limitPerDay: limitPerDay,
      remainingToday: remainingToday,
    );
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return <String, dynamic>{};
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
