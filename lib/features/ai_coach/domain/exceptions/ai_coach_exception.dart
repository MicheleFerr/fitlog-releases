library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_quota.dart';

/// Domain-level error for AI Coach backend failures.
class AICoachException implements Exception {
  const AICoachException({
    required this.code,
    required this.userMessage,
    this.technicalMessage,
    this.quota,
  });

  final String code;
  final String userMessage;
  final String? technicalMessage;
  final AIQuota? quota;

  @override
  String toString() => 'AICoachException(code: $code, message: $userMessage)';
}
