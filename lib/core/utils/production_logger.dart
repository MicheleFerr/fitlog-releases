/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: core/utils
 * 🎯 Feature: logging
 * 🔧 Type: utility
 * 📱 Platform: Universal
 * 
 * Production-safe logging that automatically disables verbose logs in release builds
 */

import 'package:flutter/foundation.dart';

/// Production-optimized logger that respects build modes
class ProductionLogger {
  // ⚙️ PRODUCTION CONFIGURATION
  static const bool _debugLogsEnabled = kDebugMode;
  static const bool _verboseLogsEnabled = kDebugMode;
  static const bool _performanceLogsEnabled = kDebugMode;
  
  // 🚨 Critical logs (always enabled for monitoring)
  static const bool _errorLogsEnabled = true;
  static const bool _warningLogsEnabled = true;
  
  /// Debug logs - only in debug builds
  static void debug(String message, {String? category}) {
    if (!_debugLogsEnabled) return;
    _log('🔍 DEBUG', message, category);
  }
  
  /// Verbose/analytics logs - only in debug builds
  static void verbose(String message, {String? category}) {
    if (!_verboseLogsEnabled) return;
    _log('📊 VERBOSE', message, category);
  }
  
  /// Performance logs - only in debug builds
  static void performance(String message, {String? category}) {
    if (!_performanceLogsEnabled) return;
    _log('⚡ PERF', message, category);
  }
  
  /// Analytics processing logs - only in debug builds
  static void analytics(String message, {String? category}) {
    if (!_verboseLogsEnabled) return;
    _log('📈 ANALYTICS', message, category);
  }
  
  /// Warning logs - enabled in all builds for monitoring
  static void warning(String message, {String? category}) {
    if (!_warningLogsEnabled) return;
    _log('⚠️ WARNING', message, category);
  }
  
  /// Error logs - always enabled for crash reporting
  static void error(String message, {String? category, Object? error}) {
    if (!_errorLogsEnabled) return;
    _log('❌ ERROR', message, category);
    if (error != null && kDebugMode) {
      debugPrint('❌ Details: $error');
    }
  }
  
  /// Critical logs - always enabled, sent to crash reporting
  static void critical(String message, {String? category, Object? error}) {
    _log('🚨 CRITICAL', message, category);
    if (error != null) {
      debugPrint('🚨 Critical Error Details: $error');
      // In production, this would also send to crash reporting service
    }
  }
  
  static void _log(String level, String message, String? category) {
    final timestamp = DateTime.now().toIso8601String();
    final categoryText = category != null ? '[$category]' : '';
    final logMessage = '$level $categoryText $message';
    
    if (kDebugMode) {
      debugPrint('[$timestamp] $logMessage');
    } else {
      // In production, only errors and warnings go to system logs
      if (level.contains('ERROR') || level.contains('WARNING') || level.contains('CRITICAL')) {
        debugPrint('[$timestamp] $logMessage');
      }
    }
  }
  
  /// Configure Firebase logging to reduce verbosity in production
  static void configureFirebaseLogging() {
    // Firebase logging is automatically reduced in release builds
    // Additional configuration can be added here if needed
    if (kDebugMode) {
      debug('Firebase logging configured for debug mode');
    }
  }
  
  /// Get current logging configuration info
  static Map<String, bool> getLoggingConfig() {
    return {
      'debugEnabled': _debugLogsEnabled,
      'verboseEnabled': _verboseLogsEnabled,
      'performanceEnabled': _performanceLogsEnabled,
      'errorEnabled': _errorLogsEnabled,
      'warningEnabled': _warningLogsEnabled,
      'isDebugMode': kDebugMode,
      'isReleaseMode': kReleaseMode,
    };
  }
}

/// Extension to easily replace debugPrint calls
extension SafeDebugPrint on String {
  /// Safe debug print that only works in debug mode
  void debugLog({String? category}) {
    ProductionLogger.debug(this, category: category);
  }
  
  /// Log as analytics processing
  void analyticsLog({String? category}) {
    ProductionLogger.analytics(this, category: category);
  }
  
  /// Log as performance metric
  void performanceLog({String? category}) {
    ProductionLogger.performance(this, category: category);
  }
}