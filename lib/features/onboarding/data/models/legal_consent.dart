import 'package:hive_ce/hive.dart';

part 'legal_consent.g.dart';

/// Types of legal consents required for GDPR compliance.
@HiveType(typeId: 11)
enum ConsentType {
  @HiveField(0)
  /// Medical disclaimer acceptance (liability waiver)
  disclaimer,

  @HiveField(1)
  /// Privacy policy acceptance
  privacyPolicy,

  @HiveField(2)
  /// Terms of Service acceptance
  tosAccepted,

  @HiveField(3)
  /// Age verification (birth date recorded)
  ageVerified,

  @HiveField(4)
  /// Firebase DPA acknowledgment
  firebaseDPA,
}

/// Model representing user consent for legal documents.
///
/// Stored in Hive for GDPR compliance (Art. 7 - proof of consent).
/// Records timestamp and IP address for audit trail.
@HiveType(typeId: 10)
class LegalConsent extends HiveObject {
  @HiveField(0)
  final ConsentType type;

  @HiveField(1)
  final bool accepted;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? ipAddress;

  @HiveField(4)
  final String? userAgent;

  @HiveField(5)
  final String? version; // App version at time of consent

  /// Constructor
  // ignore: sort_constructors_first
  LegalConsent({
    required this.type,
    required this.accepted,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.version,
  });

  @override
  String toString() {
    return 'LegalConsent(type: $type, accepted: $accepted, timestamp: $timestamp)';
  }
}
