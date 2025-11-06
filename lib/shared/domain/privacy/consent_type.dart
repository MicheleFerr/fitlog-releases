/// GDPR Consent Types
///
/// Defines the different types of consent that users can grant or deny
/// according to GDPR Article 7 (Conditions for consent)
enum ConsentType {
  /// Essential functionality - Cannot be disabled
  /// Required for core app features (authentication, data persistence)
  essential,

  /// Analytics and telemetry data collection
  /// Used for app improvement and bug tracking
  analytics,

  /// Marketing communications and promotional content
  /// Email newsletters, push notifications for promotions
  marketing,

  /// Personalization features (workout recommendations, AI suggestions)
  /// Uses workout history to provide personalized content
  personalization,

  /// Social features (sharing templates, public profiles)
  /// Allows user data to be visible to other users
  social,
}

extension ConsentTypeExtension on ConsentType {
  /// Human-readable name for the consent type
  String get displayName {
    switch (this) {
      case ConsentType.essential:
        return 'Essential';
      case ConsentType.analytics:
        return 'Analytics';
      case ConsentType.marketing:
        return 'Marketing';
      case ConsentType.personalization:
        return 'Personalization';
      case ConsentType.social:
        return 'Social Features';
    }
  }

  /// Description of what this consent enables
  String get description {
    switch (this) {
      case ConsentType.essential:
        return 'Required for core app functionality. Cannot be disabled.';
      case ConsentType.analytics:
        return 'Help us improve the app by collecting anonymous usage data.';
      case ConsentType.marketing:
        return 'Receive promotional content and special offers.';
      case ConsentType.personalization:
        return 'Get AI-powered workout recommendations based on your history.';
      case ConsentType.social:
        return 'Share templates and interact with other users.';
    }
  }

  /// Whether this consent is required for the app to function
  bool get isRequired {
    return this == ConsentType.essential;
  }

  /// Legal basis under GDPR
  String get legalBasis {
    switch (this) {
      case ConsentType.essential:
        return 'Legitimate Interest (GDPR Art. 6(1)(f))';
      case ConsentType.analytics:
      case ConsentType.marketing:
      case ConsentType.personalization:
      case ConsentType.social:
        return 'Consent (GDPR Art. 6(1)(a))';
    }
  }
}
