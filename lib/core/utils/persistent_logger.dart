import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

/// Logger persistente che salva su file per debug in release mode
class PersistentLogger {
  factory PersistentLogger() => _instance;
  PersistentLogger._internal();
  static final PersistentLogger _instance = PersistentLogger._internal();

  File? _logFile;
  static const int _maxLogSize = 1024 * 1024; // 1MB max

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/timer_debug.log');
      
      // Rotate log if too large
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > _maxLogSize) {
          // Keep last 100 lines
          final lines = await _logFile!.readAsLines();
          final keepLines = lines.length > 100 ? lines.sublist(lines.length - 100) : lines;
          await _logFile!.writeAsString(keepLines.join('\n'));
        }
      }
      
      await log('=== PersistentLogger initialized ===');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PersistentLogger init failed: $e');
      }
    }
  }

  Future<void> log(String message, {String? category}) async {
    if (_logFile == null) return;
    
    try {
      final timestamp = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
      final prefix = category != null ? '[$category]' : '';
      final logEntry = '[$timestamp]$prefix $message\n';
      
      await _logFile!.writeAsString(
        logEntry,
        mode: FileMode.append,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PersistentLogger write failed: $e');
      }
    }
  }

  Future<String> readLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No logs available';
    }
    
    try {
      return await _logFile!.readAsString();
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.delete();
    }
  }

  Future<File?> getLogFile() async {
    return _logFile;
  }
}

// Global instance for easy access
final persistentLogger = PersistentLogger();