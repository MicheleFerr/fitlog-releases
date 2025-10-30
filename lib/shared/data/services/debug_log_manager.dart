/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/data/services
/// 🎯 Feature: Debug Log Manager (STUB)
/// 🔧 Type: Service
///
/// Temporary stub to prevent compilation errors
library;

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/log_category.dart';

class DebugLogManager {
  DebugLogManager._();
  static final DebugLogManager instance = DebugLogManager._();

  void log(LogCategory category, String message) {
    if (kDebugMode) {
      debugPrint('[$category] $message');
    }
  }
}

/// Global debug log function
void debugLog(LogCategory category, String message) {
  DebugLogManager.instance.log(category, message);
}
