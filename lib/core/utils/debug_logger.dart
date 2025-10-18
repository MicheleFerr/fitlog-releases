import 'package:flutter/foundation.dart';

/// 🛠️ Debug Logger per GymBro
/// Gestisce i log di debug con controllo granulare per categoria
class DebugLogger {
  // ⚙️ CONFIGURAZIONE GLOBALE
  static const bool _enableLogging = kDebugMode; // Solo in debug mode
  
  // 📊 CATEGORIE DI LOG (attiva/disattiva singole categorie)
  static const Map<LogCategory, bool> _categorySettings = {
    LogCategory.lifecycle: false,     // 📱 App lifecycle events
    LogCategory.timer: false,         // ⏰ Timer operations
    LogCategory.notification: false,  // 🔔 Notifications
    LogCategory.liveActivity: false,  // 🔄 Live Activity updates
    LogCategory.audio: false,         // 🔊 Audio playback
    LogCategory.background: false,    // 🔧 Background execution
    LogCategory.sync: false,          // 🔄 Sync operations
    LogCategory.firebase: true,       // 🔥 Firebase operations
    LogCategory.network: true,        // 🌐 Network requests
    LogCategory.error: true,          // ❌ Errors (sempre attivi)
    LogCategory.performance: true,    // 🚀 Performance monitoring
  };

  /// Log con categoria specifica
  static void log(LogCategory category, String message, {String? emoji}) {
    if (!_enableLogging) return;
    if (!(_categorySettings[category] ?? false)) return;
    
    final prefix = emoji ?? _getCategoryEmoji(category);
    // ignore: avoid_print
    if (kDebugMode) {
      debugPrint('$prefix $message');
    }
  }

  /// Log di errore (sempre attivo in debug)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_enableLogging) return;
    // ignore: avoid_print
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
    }
    if (error != null) {
      // ignore: avoid_print
      if (kDebugMode) {
        debugPrint('❌ Details: $error');
      }
    }
    if (stackTrace != null && kDebugMode) {
      // ignore: avoid_print
      if (kDebugMode) {
        debugPrint('❌ Stack trace:\n$stackTrace');
      }
    }
  }

  /// Log di debug generico (solo se tutte le categorie sono attive)
  static void debug(String message) {
    if (!_enableLogging) return;
    if (!kDebugMode) return;
    // ignore: avoid_print
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
    }
  }

  static String _getCategoryEmoji(LogCategory category) {
    switch (category) {
      case LogCategory.lifecycle:
        return '📱';
      case LogCategory.timer:
        return '⏰';
      case LogCategory.notification:
        return '🔔';
      case LogCategory.liveActivity:
        return '🔄';
      case LogCategory.audio:
        return '🔊';
      case LogCategory.background:
        return '🔧';
      case LogCategory.sync:
        return '🔄';
      case LogCategory.firebase:
        return '🔥';
      case LogCategory.network:
        return '🌐';
      case LogCategory.error:
        return '❌';
      case LogCategory.performance:
        return '🚀';
    }
  }
}

/// Categorie di log disponibili
enum LogCategory {
  lifecycle,     // App lifecycle events
  timer,         // Timer operations
  notification,  // Notifications
  liveActivity,  // Live Activity updates
  audio,         // Audio playback
  background,    // Background execution
  sync,          // Sync operations
  firebase,      // Firebase operations
  network,       // Network requests
  error,         // Errors
  performance,   // Performance monitoring
}