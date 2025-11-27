import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/onboarding/data/models/legal_consent.dart';

/// Repository for storing and retrieving user legal consents.
///
/// GDPR Art. 7 requires proof of consent:
/// - Timestamp of consent
/// - What user consented to (type)
/// - How consent was given (app version)
/// - Optional: IP address for audit trail
///
/// Stored locally in Hive (not uploaded to Firebase for privacy).
///
/// **Note**: This is for LEGAL consents (Privacy Policy, TOS, Disclaimer).
/// For body measurement GDPR consents, see:
/// `lib/features/body_measurements/domain/repositories/consent_repository.dart`
class LegalConsentRepository {
  static const String _boxName = 'legal_consents';
  late Box<LegalConsent> _box;

  /// Initialize Hive box for consent storage.
  Future<void> initialize() async {
    _box = await Hive.openBox<LegalConsent>(_boxName);
  }

  /// Save or update a consent record.
  Future<void> saveConsent(LegalConsent consent) async {
    await _box.put(consent.type.name, consent);
  }

  /// Get consent record by type.
  Future<LegalConsent?> getConsent(ConsentType type) async {
    return _box.get(type.name);
  }

  /// Check if user has accepted all required consents.
  ///
  /// Required consents:
  /// - Disclaimer
  /// - Privacy Policy
  /// - Terms of Service
  Future<bool> hasAcceptedAllRequired() async {
    final requiredTypes = [
      ConsentType.disclaimer,
      ConsentType.privacyPolicy,
      ConsentType.tosAccepted,
    ];

    for (final type in requiredTypes) {
      final consent = await getConsent(type);
      if (consent == null || !consent.accepted) {
        return false;
      }
    }

    return true;
  }

  /// Get all consent records (for export/audit).
  Future<List<LegalConsent>> getAllConsents() async {
    return _box.values.toList();
  }

  /// Delete all consents (for account deletion).
  Future<void> clearAllConsents() async {
    await _box.clear();
  }

  /// Dispose repository and close Hive box.
  Future<void> dispose() async {
    await _box.close();
  }
}
