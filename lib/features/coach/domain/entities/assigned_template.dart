/// Assigned Template Entity
///
/// Represents a template assigned to an athlete by their coach.
/// Stored in athlete's subcollection, references the coach's template.
///
/// **Layer**: Domain
/// **Feature**: Coach
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'assigned_template.freezed.dart';
part 'assigned_template.g.dart';

/// A reference to a coach template assigned to an athlete
@freezed
abstract class AssignedTemplate with _$AssignedTemplate {
  const factory AssignedTemplate({
    /// Unique ID for this assignment
    required String id,

    /// Reference to the coach's template
    required String coachTemplateId,

    /// Coach who assigned this template
    required String coachId,

    /// When this template was assigned
    required DateTime assignedAt,

    /// When the template was last synced (for detecting updates)
    required DateTime lastSyncedAt,

    /// Optional notes from the athlete (local to their copy)
    String? athleteNotes,

    // Denormalized fields for display (avoids extra reads)
    /// Template name (cached from coach template)
    String? templateName,

    /// Coach name (cached for display)
    String? coachName,

    /// Number of exercises (cached for display)
    int? exerciseCount,

    /// Estimated duration (cached for display)
    int? estimatedDuration,
  }) = _AssignedTemplate;

  const AssignedTemplate._();

  /// Whether this assignment has local notes
  bool get hasAthleteNotes => athleteNotes != null && athleteNotes!.isNotEmpty;

  /// Whether the template might need sync (assigned more than 1 day ago)
  bool get mightNeedSync {
    final daysSinceSync = DateTime.now().difference(lastSyncedAt).inDays;
    return daysSinceSync > 1;
  }

  factory AssignedTemplate.fromJson(Map<String, dynamic> json) =>
      _$AssignedTemplateFromJson(json);
}
