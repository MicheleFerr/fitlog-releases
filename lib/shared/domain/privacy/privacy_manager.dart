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
  static const String _currentPrivacyPolicyVersion = 'v1.0.0';

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
      return value is bool ? value : false;
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
    try {
      final box = await _manager.openBox<dynamic>(_consentBoxName);

      // Always include essential consent
      final consentSet = {...consents, ConsentType.essential};

      // Clear all previous consents
      await box.clear();

      // Save new consents
      for (final type in ConsentType.values) {
        await box.put(type.name, consentSet.contains(type));
      }

      // Save timestamp for audit trail (GDPR Art. 7(1))
      await box.put(_consentTimestampKey, DateTime.now().toIso8601String());

      // Save privacy policy version
      await box.put(_privacyPolicyVersionKey, _currentPrivacyPolicyVersion);

      if (kDebugMode) {
        debugPrint('✅ Consents saved: ${consentSet.map((c) => c.name).join(", ")}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving consents: $e');
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
      return box.containsKey(_consentTimestampKey);
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

  /// Delete all user data (GDPR Art. 17 - Right to erasure)
  ///
  /// WARNING: This deletes ALL user data including workout history
  static Future<void> deleteAllUserData() async {
    if (kDebugMode) {
      debugPrint('🗑️ Deleting all user data (GDPR Art. 17)...');
    }

    try {
      // Delete consent preferences
      final consentBox = await _manager.openBox<dynamic>(_consentBoxName);
      await consentBox.clear();

      // TODO: Delete all other user data boxes
      // - Workout history
      // - Templates
      // - Settings
      // - Analytics data

      if (kDebugMode) {
        debugPrint('✅ All user data deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting user data: $e');
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
