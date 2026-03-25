import 'package:gymbro_flutter_new/shared/data/services/tracking_authorization_service.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/consent_type.dart';
import 'package:gymbro_flutter_new/shared/domain/privacy/privacy_manager.dart';

/// Central privacy gate for analytics or ad-related tracking collection.
abstract final class AnalyticsCollectionGuard {
  static Future<bool> canCollectAnalytics() async {
    try {
      final hasAnalyticsConsent = await PrivacyManager.hasConsent(
        ConsentType.analytics,
      );
      if (!hasAnalyticsConsent) {
        return false;
      }

      return TrackingAuthorizationService.allowsTrackingAccess();
    } catch (_) {
      return false;
    }
  }
}
