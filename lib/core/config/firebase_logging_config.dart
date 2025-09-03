/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: core/config
 * 🎯 Feature: logging
 * 🔧 Type: configuration
 * 📱 Platform: Universal
 * 
 * Firebase logging configuration for production optimization
 */

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseLoggingConfig {
  /// Configure Firebase logging for production builds
  static void configureForProduction() {
    if (kReleaseMode) {
      // Firebase automatically reduces logging in release builds
      // This method can be extended for additional configuration
      _disableVerboseFirebaseLogging();
    } else if (kDebugMode) {
      _configureDebugLogging();
    }
  }
  
  /// Disable verbose Firebase logging in production
  static void _disableVerboseFirebaseLogging() {
    // Firebase SDK automatically handles this, but we can add
    // additional configuration here if needed in the future
    
    // Note: Firebase logging levels are controlled by the SDK
    // and automatically reduced in release builds
  }
  
  /// Configure debug logging for development
  static void _configureDebugLogging() {
    // In debug mode, allow normal Firebase logging
    // This helps with development and debugging
  }
  
  /// Check if Firebase verbose logging is enabled
  static bool get isVerboseLoggingEnabled {
    return kDebugMode;
  }
  
  /// Get current Firebase logging configuration
  static Map<String, dynamic> getLoggingInfo() {
    return {
      'firebaseVerboseEnabled': isVerboseLoggingEnabled,
      'buildMode': kDebugMode ? 'debug' : (kReleaseMode ? 'release' : 'profile'),
      'loggingLevel': kDebugMode ? 'verbose' : 'minimal',
    };
  }
}