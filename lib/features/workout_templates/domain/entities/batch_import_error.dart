/// Error severity level for import operations
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error that occurred during batch import
class BatchImportError {

  const BatchImportError({
    required this.message,
    required this.severity,
    required this.source,
    this.originalError,
  });
  final String message;
  final ErrorSeverity severity;
  final String source;
  final dynamic originalError;

  @override
  String toString() => '[$severity] $message (source: $source)';
}
