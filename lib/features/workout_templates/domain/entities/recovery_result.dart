/// Result of an error recovery attempt
library;

class RecoveryResult<T> {

  const RecoveryResult({
    required this.success,
    this.data,
    required this.appliedFixes,
    required this.confidence,
    this.error,
  });

  factory RecoveryResult.success({
    required T data,
    required List<String> appliedFixes,
    required double confidence,
  }) {
    return RecoveryResult<T>(
      success: true,
      data: data,
      appliedFixes: appliedFixes,
      confidence: confidence,
    );
  }

  factory RecoveryResult.failure({
    required String error,
    List<String>? appliedFixes,
  }) {
    return RecoveryResult<T>(
      success: false,
      error: error,
      appliedFixes: appliedFixes ?? [],
      confidence: 0.0,
    );
  }
  final bool success;
  final T? data;
  final List<String> appliedFixes;
  final double confidence;
  final String? error;
}
