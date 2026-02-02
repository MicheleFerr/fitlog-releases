/// Account Mode Entity
///
/// Defines the three operating modes for user accounts:
/// - Solo: Independent user (default)
/// - Coached: User training with a coach
/// - Coach: Personal trainer managing athletes
///
/// **Layer**: Domain
/// **Feature**: Coach
library;

/// Account operating modes
enum AccountMode {
  /// Independent user - default mode
  /// User trains alone, full control over their workouts
  solo('solo'),

  /// User training with a coach
  /// Receives workout assignments, limited template creation
  coached('coached'),

  /// Personal trainer mode
  /// Manages athletes, assigns workouts, views athlete data
  coach('coach');

  const AccountMode(this.value);

  /// String value for Firestore storage
  final String value;

  /// Parse from string (Firestore/preferences)
  static AccountMode fromString(String? value) {
    if (value == null) return AccountMode.solo;
    return AccountMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => AccountMode.solo,
    );
  }

  /// Check if user can create templates
  bool get canCreateTemplates => this != AccountMode.coached;

  /// Check if user has coach features
  bool get isCoach => this == AccountMode.coach;

  /// Check if user is being coached
  bool get isCoached => this == AccountMode.coached;

  /// Check if user is in solo mode
  bool get isSolo => this == AccountMode.solo;

  /// Display name for UI (use l10n in presentation layer)
  String get displayKey => switch (this) {
    AccountMode.solo => 'accountModeSolo',
    AccountMode.coached => 'accountModeCoached',
    AccountMode.coach => 'accountModeCoach',
  };
}

/// Extension on UserProfile preferences for account mode
extension AccountModePreferences on Map<String, dynamic> {
  /// Get account mode from preferences map
  AccountMode get accountMode =>
      AccountMode.fromString(this['accountMode'] as String?);

  /// Get coach code (for coaches)
  String? get coachCode => this['coachCode'] as String?;

  /// Get linked coach ID (for coached users)
  String? get linkedCoachId => this['linkedCoachId'] as String?;

  /// Get linked coach email (for coached users)
  String? get linkedCoachEmail => this['linkedCoachEmail'] as String?;

  /// Check if user has completed coach onboarding
  bool get hasCompletedCoachOnboarding =>
      this['hasCompletedCoachOnboarding'] as bool? ?? false;
}
