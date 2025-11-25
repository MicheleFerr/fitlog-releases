/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/usecases
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: use_case
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// RECORD CONSENT USE CASE - GDPR Article 7.1 compliance
library;

import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';

/// Use case for recording user consent (GDPR Article 7.1)
///
/// **GDPR Requirement**: Explicit consent before processing personal data
///
/// **Article 7.1**:
/// "Where processing is based on consent, the controller shall be able to
///  demonstrate that the data subject has consented to processing of his
///  or her personal data."
///
/// **Evidence Required**:
/// - Timestamp when consent given (consentTimestamp)
/// - Version of consent agreement (consentVersion)
/// - User action that triggered consent (opt-in checkbox)
///
/// **Consent Flow** (see Task 3.3 - Presentation Layer UX):
/// 1. User completes onboarding
/// 2. Step 4: GDPR Consent Page
/// 3. User checks "I agree to data collection" (unchecked by default)
/// 4. User taps "Agree and Continue"
/// 5. → This use case executed → consentTimestamp recorded
class RecordConsent {

  RecordConsent(this._repository);
  final NotificationSettingsRepository _repository;

  /// Execute consent recording
  ///
  /// **Parameters**:
  /// - consentVersion: Version of consent agreement (e.g., '1.0', '1.1', '2.0')
  ///   Increment when consent terms change (requires re-consent)
  ///
  /// **Effect**:
  /// - Set consentTimestamp to DateTime.now()
  /// - Set consentVersion to provided version
  /// - Sync to Firestore immediately (no debounce - GDPR compliance critical)
  ///
  /// **Returns**: void
  Future<void> execute(String consentVersion) async {
    await _repository.recordConsent(consentVersion);
  }

  /// Check if user has given valid consent
  ///
  /// **Returns**: true if consentTimestamp is not null
  ///
  /// **Use case**: Guard analytics data collection
  /// ```dart
  /// if (await recordConsent.hasConsent()) {
  ///   // OK to collect analytics
  ///   await logEvent('notification_delivered');
  /// }
  /// ```
  Future<bool> hasConsent() async {
    return await _repository.hasValidConsent();
  }
}
