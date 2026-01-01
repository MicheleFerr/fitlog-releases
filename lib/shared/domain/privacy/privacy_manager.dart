import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/consent_type.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';

/// GDPR-Compliant Privacy and Consent Management
///
/// Manages user consent preferences according to GDPR Article 7
/// - Stores consent choices locally (Hive)
/// - Provides granular consent control
/// - Implements "consent withdrawal" (GDPR Art. 7(3))
/// - Data minimization by default
class PrivacyManager {
  // Singleton instance for global access (initialized in main.dart)
  static HiveBoxManagerEnhanced? _boxManager;

  /// Initialize Privacy Manager with HiveBoxManagerEnhanced
  ///
  /// MUST be called in main.dart before using PrivacyManager
  static Future<void> initialize({HiveBoxManagerEnhanced? boxManager}) async {
    _boxManager = boxManager ?? HiveBoxManagerEnhanced();
  }

  static const String _consentBoxName = 'user_consents';
  static const String _consentTimestampKey = 'consent_timestamp';
  static const String _privacyPolicyVersionKey = 'privacy_policy_version';
  static const String _currentPrivacyPolicyVersion = 'v1.1.0';

  // GDPR Art. 18: Right to Restriction of Processing
  static const String _processingRestrictedKey = 'processing_restricted';
  static const String _restrictionReasonKey = 'restriction_reason';
  static const String _restrictionTimestampKey = 'restriction_timestamp';

  /// Get the box manager (throws if not initialized)
  static HiveBoxManagerEnhanced get _manager {
    if (_boxManager == null) {
      throw StateError(
        'PrivacyManager not initialized. Call PrivacyManager.initialize() in main.dart',
      );
    }
    return _boxManager!;
  }

  /// Check if user has granted a specific consent
  ///
  /// Returns true if consent was granted, false otherwise
  /// Essential consent is always true (cannot be disabled)
  static Future<bool> hasConsent(ConsentType type) async {
    // Essential consent is always granted
    if (type.isRequired) return true;

    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      final value = box.get(type.name, defaultValue: false);
      final result = value is bool ? value : false;
      if (kDebugMode) {
        debugPrint('🔐 [PrivacyManager] hasConsent(${type.name}): $result (raw value: $value)');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error checking consent for ${type.name}: $e');
      }
      // Fail safe: deny consent if error
      return false;
    }
  }

  /// Save user consent choices
  ///
  /// Stores consent preferences and timestamp for audit trail
  /// Automatically adds essential consent
  static Future<void> saveConsents(Set<ConsentType> consents) async {
    if (kDebugMode) {
      debugPrint('🔐 [PrivacyManager] saveConsents called with: ${consents.map((c) => c.name).join(", ")}');
    }
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      if (kDebugMode) {
        debugPrint('🔐 [PrivacyManager] Box opened: $_consentBoxName');
      }

      // Always include essential consent
      final consentSet = {...consents, ConsentType.essential};

      // Clear all previous consents
      await box.clear();

      // Save new consents
      for (final type in ConsentType.values) {
        await box.put(type.name, consentSet.contains(type));
        if (kDebugMode) {
          debugPrint('🔐 [PrivacyManager] Saved ${type.name} = ${consentSet.contains(type)}');
        }
      }

      // Save timestamp for audit trail (GDPR Art. 7(1))
      final timestamp = DateTime.now().toIso8601String();
      await box.put(_consentTimestampKey, timestamp);

      // Save privacy policy version
      await box.put(_privacyPolicyVersionKey, _currentPrivacyPolicyVersion);

      if (kDebugMode) {
        debugPrint('✅ [PrivacyManager] Consents saved: ${consentSet.map((c) => c.name).join(", ")}');
        debugPrint('🔐 [PrivacyManager] Timestamp: $timestamp');

        // Verify save worked
        final verifyTimestamp = box.get(_consentTimestampKey);
        final verifyAnalytics = box.get('analytics');
        debugPrint('🔐 [PrivacyManager] VERIFY - timestamp in box: $verifyTimestamp');
        debugPrint('🔐 [PrivacyManager] VERIFY - analytics in box: $verifyAnalytics');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PrivacyManager] Error saving consents: $e');
      }
      rethrow;
    }
  }

  /// Get all granted consents
  ///
  /// Returns a set of ConsentType that the user has granted
  static Future<Set<ConsentType>> getGrantedConsents() async {
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      final granted = <ConsentType>{};

      for (final type in ConsentType.values) {
        final value = box.get(type.name, defaultValue: type.isRequired);
        final hasGranted = value is bool ? value : type.isRequired;
        if (hasGranted) {
          granted.add(type);
        }
      }

      return granted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error getting granted consents: $e');
      }
      // Fail safe: return only essential consent
      return {ConsentType.essential};
    }
  }

  /// Withdraw a specific consent (GDPR Art. 7(3))
  ///
  /// User has the right to withdraw consent at any time
  /// Cannot withdraw essential consent
  static Future<void> withdrawConsent(ConsentType type) async {
    if (type.isRequired) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot withdraw essential consent');
      }
      return;
    }

    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      await box.put(type.name, false);

      if (kDebugMode) {
        debugPrint('✅ Consent withdrawn: ${type.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error withdrawing consent: $e');
      }
      rethrow;
    }
  }

  /// Check if user has provided any consent choices
  ///
  /// Used to determine if we need to show the consent dialog
  static Future<bool> hasProvidedConsent() async {
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      final hasTimestamp = box.containsKey(_consentTimestampKey);
      if (kDebugMode) {
        debugPrint('🔐 [PrivacyManager] hasProvidedConsent check:');
        debugPrint('   - Box keys: ${box.keys.toList()}');
        debugPrint('   - Has timestamp key: $hasTimestamp');
        if (hasTimestamp) {
          debugPrint('   - Timestamp value: ${box.get(_consentTimestampKey)}');
        }
      }
      return hasTimestamp;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error checking if consent provided: $e');
      }
      return false;
    }
  }

  /// Check if consent needs to be re-requested
  ///
  /// Required if:
  /// - Privacy policy version has changed
  /// - Consent is older than 12 months (best practice)
  static Future<bool> needsConsentUpdate() async {
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);

      // Check privacy policy version
      final savedVersion = box.get(_privacyPolicyVersionKey);
      if (savedVersion is String && savedVersion != _currentPrivacyPolicyVersion) {
        return true;
      }
      if (savedVersion == null) return true;

      // Check consent age (12 months)
      final timestampStr = box.get(_consentTimestampKey);
      if (timestampStr is! String) return true;

      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      if (age.inDays > 365) {
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error checking consent update needed: $e');
      }
      // Fail safe: request consent if error
      return true;
    }
  }

  /// Get consent timestamp for audit trail
  static Future<DateTime?> getConsentTimestamp() async {
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      final timestampStr = box.get(_consentTimestampKey);
      if (timestampStr is! String) return null;
      return DateTime.parse(timestampStr);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error getting consent timestamp: $e');
      }
      return null;
    }
  }

  // ========================================
  // GDPR Article 18: Right to Restriction of Processing
  // ========================================

  /// Request restriction of processing (GDPR Art. 18)
  ///
  /// User can request restriction when:
  /// - Accuracy of data is contested (Art. 18(1)(a))
  /// - Processing is unlawful (Art. 18(1)(b))
  /// - Controller no longer needs data (Art. 18(1)(c))
  /// - User objected pending verification (Art. 18(1)(d))
  ///
  /// When restricted, data can only be stored, not processed.
  static Future<void> requestProcessingRestriction(String reason) async {
    if (kDebugMode) {
      debugPrint('🔐 [GDPR Art.18] Processing restriction requested: $reason');
    }

    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);

      await box.put(_processingRestrictedKey, true);
      await box.put(_restrictionReasonKey, reason);
      await box.put(_restrictionTimestampKey, DateTime.now().toIso8601String());

      if (kDebugMode) {
        debugPrint('✅ [GDPR Art.18] Processing restriction activated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GDPR Art.18] Error requesting restriction: $e');
      }
      rethrow;
    }
  }

  /// Lift processing restriction (GDPR Art. 18(3))
  ///
  /// Must inform user before lifting restriction
  static Future<void> liftProcessingRestriction() async {
    if (kDebugMode) {
      debugPrint('🔐 [GDPR Art.18] Lifting processing restriction');
    }

    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);

      await box.put(_processingRestrictedKey, false);
      await box.delete(_restrictionReasonKey);
      await box.delete(_restrictionTimestampKey);

      if (kDebugMode) {
        debugPrint('✅ [GDPR Art.18] Processing restriction lifted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GDPR Art.18] Error lifting restriction: $e');
      }
      rethrow;
    }
  }

  /// Check if processing is restricted (GDPR Art. 18)
  ///
  /// When true, app should only store data, not process it:
  /// - No analytics
  /// - No personalization
  /// - No AI recommendations
  /// - Data stored but not used for any purpose
  static Future<bool> isProcessingRestricted() async {
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      final isRestricted = box.get(_processingRestrictedKey, defaultValue: false);
      return isRestricted is bool ? isRestricted : false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [GDPR Art.18] Error checking restriction: $e');
      }
      // Fail safe: assume restricted if error
      return true;
    }
  }

  /// Get restriction details (for audit/display)
  static Future<Map<String, dynamic>?> getRestrictionDetails() async {
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);
      final isRestricted = box.get(_processingRestrictedKey, defaultValue: false);

      if (isRestricted != true) return null;

      return {
        'isRestricted': true,
        'reason': box.get(_restrictionReasonKey),
        'timestamp': box.get(_restrictionTimestampKey),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [GDPR Art.18] Error getting restriction details: $e');
      }
      return null;
    }
  }

  /// Delete all local user data (GDPR Art. 17 - Right to erasure)
  ///
  /// WARNING: This deletes ALL local user data including workout history.
  /// For complete account deletion (including Firestore and Firebase Auth),
  /// use AuthService.deleteAccount() instead.
  ///
  /// This method clears all Hive boxes:
  /// - Consent preferences
  /// - Workout history cache
  /// - Templates cache
  /// - User settings
  /// - Analytics cache
  /// - Body measurements cache
  /// - Exercise cache
  static Future<void> deleteAllUserData() async {
    if (kDebugMode) {
      debugPrint('🗑️ Deleting all local user data (GDPR Art. 17)...');
    }

    try {
      // List of all Hive boxes to clear
      const boxesToClear = [
        _consentBoxName,           // user_consents
        'workout_history',         // Cached workout history
        'templates',               // Cached templates
        'user_settings',           // User preferences
        'analytics_cache',         // Analytics data cache
        'body_measurements',       // Body measurements cache
        'exercise_cache',          // Exercise database cache
        'user_profile_cache',      // User profile cache
        'stress_index_cache',      // Stress index cache
        'personal_records',        // PR cache
        'progress_photos_cache',   // Progress photos metadata
      ];

      // Clear each box
      for (final boxName in boxesToClear) {
        try {
          final box = await _manager.openBox<dynamic>(boxName);
          await box.clear();
          if (kDebugMode) {
            debugPrint('  ✓ Cleared box: $boxName');
          }
        } catch (e) {
          // Box might not exist, continue
          if (kDebugMode) {
            debugPrint('  ⚠️ Could not clear box $boxName: $e');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ All local user data deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting local user data: $e');
      }
      rethrow;
    }
  }

  /// Export user data (GDPR Art. 20 - Right to data portability)
  ///
  /// Returns a JSON string with all user data
  static Future<String> exportUserData() async {
    if (kDebugMode) {
      debugPrint('📦 Exporting user data (GDPR Art. 20)...');
    }

    try {
      final consentBox = await _manager.openBox<dynamic>(_consentBoxName);
      final consents = <String, dynamic>{};

      for (final type in ConsentType.values) {
        final value = consentBox.get(type.name, defaultValue: false);
        consents[type.name] = value is bool ? value : false;
      }

      consents['timestamp'] = consentBox.get(_consentTimestampKey);
      consents['privacy_policy_version'] = consentBox.get(_privacyPolicyVersionKey);

      // TODO: Add other user data (workouts, templates, settings)

      final json = {
        'export_date': DateTime.now().toIso8601String(),
        'consents': consents,
        // Add other data categories here
      };

      return json.toString();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error exporting user data: $e');
      }
      rethrow;
    }
  }
}
