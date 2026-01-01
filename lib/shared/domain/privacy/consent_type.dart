/// GDPR Consent Types
///
/// Defines the different types of consent that users can grant or deny
/// according to GDPR Article 7 (Conditions for consent)
///
/// Note: Some consent types are for GDPR Art. 9 "special category" data
/// (health data, biometric data) which requires explicit consent.
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

  /// HealthKit/Health Connect data access (GDPR Art. 9 - Health Data)
  /// Requires explicit consent for reading health data from device
  /// Includes: heart rate, steps, sleep, workouts from Apple Health/Google Fit
  healthKitData,

  /// Progress photos storage (GDPR Art. 9 - Potential Biometric Data)
  /// Body photos may be considered biometric data under GDPR
  /// Requires explicit consent before camera access and storage
  progressPhotos,

  /// Body measurements (GDPR Art. 9 - Health Data)
  /// Weight, body fat %, BMI, circumferences are health-related data
  /// Requires explicit consent under GDPR Art. 9(2)(a)
  healthData,
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
      case ConsentType.healthKitData:
        return 'Health Data Sync';
      case ConsentType.progressPhotos:
        return 'Progress Photos';
      case ConsentType.healthData:
        return 'Body Measurements';
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
      case ConsentType.healthKitData:
        return 'Sync workout data with Apple Health or Google Fit. This includes heart rate, steps, and workout data.';
      case ConsentType.progressPhotos:
        return 'Take and store progress photos to track your physical transformation. Photos are stored securely and encrypted.';
      case ConsentType.healthData:
        return 'Store body measurements like weight, body fat %, and circumferences. This data is classified as health data under GDPR.';
    }
  }

  /// Whether this consent is required for the app to function
  bool get isRequired {
    return this == ConsentType.essential;
  }

  /// Whether this consent is for GDPR Article 9 "special category" data
  bool get isSpecialCategory {
    switch (this) {
      case ConsentType.healthKitData:
      case ConsentType.progressPhotos:
      case ConsentType.healthData:
        return true;
      default:
        return false;
    }
  }

  /// Legal basis under GDPR
  String get legalBasis {
    switch (this) {
      case ConsentType.essential:
        return 'Legitimate Interest (GDPR Art. 6(1)(f))';
      case ConsentType.healthKitData:
      case ConsentType.progressPhotos:
      case ConsentType.healthData:
        // Special category data requires explicit consent under Art. 9(2)(a)
        return 'Explicit Consent (GDPR Art. 9(2)(a))';
      case ConsentType.analytics:
      case ConsentType.marketing:
      case ConsentType.personalization:
      case ConsentType.social:
        return 'Consent (GDPR Art. 6(1)(a))';
    }
  }

  /// GDPR Article reference for this consent type
  String get gdprArticle {
    switch (this) {
      case ConsentType.essential:
        return 'Art. 6(1)(f)';
      case ConsentType.healthKitData:
      case ConsentType.progressPhotos:
      case ConsentType.healthData:
        return 'Art. 9(2)(a)';
      case ConsentType.analytics:
      case ConsentType.marketing:
      case ConsentType.personalization:
      case ConsentType.social:
        return 'Art. 6(1)(a)';
    }
  }
}
