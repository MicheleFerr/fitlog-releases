/// Coach Branding Entity (P2-4)
///
/// Allows coaches to customize their PDF exports with custom branding.
/// This branding is applied to workout template PDFs shared with athletes.
///
/// **Features:**
/// - Custom business name (replaces "FitLog Pro")
/// - Primary and accent colors
/// - Optional logo URL
/// - Contact information
/// - Website and social links
///
/// **Layer**: Domain
/// **Feature**: Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'coach_branding.freezed.dart';
part 'coach_branding.g.dart';

/// Default branding colors (FitLog Pro defaults)
const String kDefaultPrimaryColor = '2196F3'; // Blue
const String kDefaultAccentColor = 'FF9800'; // Orange

@freezed
abstract class CoachBranding with _$CoachBranding {
  const factory CoachBranding({
    /// Unique branding ID
    required String id,

    /// Coach user ID
    required String coachId,

    /// Business/brand name (shown in PDF header)
    required String businessName,

    /// Optional tagline (shown below business name)
    String? tagline,

    /// Primary brand color (hex string, e.g., '2196F3')
    @Default(kDefaultPrimaryColor) String primaryColor,

    /// Accent/secondary brand color (hex string)
    @Default(kDefaultAccentColor) String accentColor,

    /// URL to logo image (PNG/JPG, max 500KB recommended)
    String? logoUrl,

    /// Contact email
    String? email,

    /// Contact phone
    String? phone,

    /// Website URL
    String? website,

    /// Instagram handle (without @)
    String? instagram,

    /// Footer text (e.g., "Powered by Coach Mike")
    String? footerText,

    /// Creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    DateTime? updatedAt,
  }) = _CoachBranding;

  const CoachBranding._();

  factory CoachBranding.fromJson(Map<String, dynamic> json) =>
      _$CoachBrandingFromJson(json);

  /// Whether this branding has a custom logo
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Whether this branding has contact info
  bool get hasContactInfo =>
      (email != null && email!.isNotEmpty) ||
      (phone != null && phone!.isNotEmpty);

  /// Whether this branding has social links
  bool get hasSocialLinks =>
      (website != null && website!.isNotEmpty) ||
      (instagram != null && instagram!.isNotEmpty);

  /// Get formatted contact line for PDF
  String? get contactLine {
    final parts = <String>[];
    if (email != null && email!.isNotEmpty) parts.add(email!);
    if (phone != null && phone!.isNotEmpty) parts.add(phone!);
    return parts.isEmpty ? null : parts.join(' | ');
  }

  /// Get formatted social line for PDF
  String? get socialLine {
    final parts = <String>[];
    if (website != null && website!.isNotEmpty) parts.add(website!);
    if (instagram != null && instagram!.isNotEmpty) parts.add('@$instagram');
    return parts.isEmpty ? null : parts.join(' | ');
  }

  /// Default branding for non-coaches (uses FitLog Pro)
  static CoachBranding get defaultBranding => CoachBranding(
        id: 'default',
        coachId: 'system',
        businessName: 'FitLog Pro',
        tagline: 'Your Personal Fitness Tracker',
        createdAt: DateTime.now(),
      );
}
