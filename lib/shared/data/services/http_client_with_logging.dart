import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:voo_logging/voo_logging.dart';

/// HTTP Logging utilities that integrate with VooLogger.
///
/// VooLogger provides a `networkRequest` method for logging HTTP traffic.
/// This file demonstrates how to use it in your services.
///
/// Usage example:
/// ```dart
/// // Log outgoing request
/// await VooLogger.networkRequest(
///   'GET https://api.example.com/data',
///   'REQUEST',
///   headers: {'Authorization': '[REDACTED]'},
///   metadata: {'timestamp': DateTime.now().toIso8601String()},
/// );
///
/// // After response
/// await VooLogger.networkRequest(
///   '200 OK https://api.example.com/data',
///   'RESPONSE',
///   headers: {'content-type': 'application/json'},
///   metadata: {'duration_ms': '150'},
/// );
/// ```
///
/// View logs in Flutter DevTools console or use `flutter logs`.
class HttpLogger {
  /// Log an HTTP request to VooLogger
  static Future<void> logRequest({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    String? body,
  }) async {
    if (!kDebugMode) return;

    final sanitizedHeaders = _sanitizeHeaders(headers ?? {});

    await VooLogger.networkRequest(
      '$method ${url.toString()}',
      'REQUEST',
      headers: sanitizedHeaders,
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
        if (body != null && body.isNotEmpty) 'body_preview': _truncateBody(body),
      },
    );
  }

  /// Log an HTTP response to VooLogger
  static Future<void> logResponse({
    required String method,
    required Uri url,
    required int statusCode,
    required Duration duration,
    Map<String, String>? headers,
    String? body,
  }) async {
    if (!kDebugMode) return;

    final statusLabel = _getStatusLabel(statusCode);
    final sanitizedHeaders = _sanitizeHeaders(headers ?? {});

    await VooLogger.networkRequest(
      '$statusLabel $statusCode ${url.toString()}',
      'RESPONSE',
      headers: sanitizedHeaders,
      metadata: {
        'method': method,
        'duration_ms': '${duration.inMilliseconds}',
        'timestamp': DateTime.now().toIso8601String(),
        if (body != null && body.isNotEmpty) 'body_preview': _truncateBody(body),
      },
    );
  }

  /// Log an HTTP error to VooLogger
  static Future<void> logError({
    required String method,
    required Uri url,
    required Object error,
    required Duration duration,
    StackTrace? stackTrace,
  }) async {
    if (!kDebugMode) return;

    await VooLogger.error(
      'HTTP Error: $method ${url.toString()}',
      error: error,
      stackTrace: stackTrace,
      tag: 'HTTP',
      metadata: {
        'duration_ms': duration.inMilliseconds,
      },
    );
  }

  static String _getStatusLabel(int statusCode) {
    if (statusCode >= 500) return '5xx';
    if (statusCode >= 400) return '4xx';
    if (statusCode >= 300) return '3xx';
    if (statusCode >= 200) return '2xx';
    return '1xx';
  }

  /// Sanitize headers to remove sensitive data (auth tokens, API keys)
  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    const sensitiveKeys = ['authorization', 'x-api-key', 'cookie', 'set-cookie'];

    for (final key in sanitized.keys.toList()) {
      if (sensitiveKeys.any((sk) => key.toLowerCase().contains(sk))) {
        sanitized[key] = '[REDACTED]';
      }
    }

    return sanitized;
  }

  /// Truncate body to prevent huge logs
  static String _truncateBody(String body, {int maxLength = 500}) {
    // Try to pretty-print JSON
    try {
      final jsonData = jsonDecode(body);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);
      if (prettyJson.length > maxLength) {
        return '${prettyJson.substring(0, maxLength)}...[TRUNCATED]';
      }
      return prettyJson;
    } catch (_) {
      // Not JSON, return as-is
      if (body.length > maxLength) {
        return '${body.substring(0, maxLength)}...[TRUNCATED]';
      }
      return body;
    }
  }
}

/// Example usage demonstrating HTTP monitoring with VooLogger
///
/// This can be used as a reference for integrating HTTP monitoring
/// in any service that makes HTTP requests.
///
/// ```dart
/// // In your Dio interceptor:
/// class VooLoggerInterceptor extends Interceptor {
///   @override
///   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
///     HttpLogger.logRequest(
///       method: options.method,
///       url: options.uri,
///       headers: options.headers.map((k, v) => MapEntry(k, v.toString())),
///       body: options.data?.toString(),
///     );
///     handler.next(options);
///   }
///
///   @override
///   void onResponse(Response response, ResponseInterceptorHandler handler) {
///     HttpLogger.logResponse(
///       method: response.requestOptions.method,
///       url: response.requestOptions.uri,
///       statusCode: response.statusCode ?? 0,
///       duration: Duration.zero, // Calculate from request time
///       body: response.data?.toString(),
///     );
///     handler.next(response);
///   }
///
///   @override
///   void onError(DioException err, ErrorInterceptorHandler handler) {
///     HttpLogger.logError(
///       method: err.requestOptions.method,
///       url: err.requestOptions.uri,
///       error: err,
///       duration: Duration.zero,
///     );
///     handler.next(err);
///   }
/// }
///
/// // To view HTTP logs:
/// // 1. Run app in debug mode
/// // 2. Open Flutter DevTools -> Logging
/// // 3. Filter by "HTTP" or "VooLogger" tag
/// ```
