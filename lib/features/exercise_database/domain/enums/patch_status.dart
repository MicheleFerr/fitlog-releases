/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/enums
/// 🎯 Feature: exercise_database
/// 🔧 Type: enum
///
/// Status lifecycle for exercise patches submitted by users
library;

enum PatchStatus {
  /// Patch submitted by user, waiting for admin review
  pending('PENDING'),

  /// Patch approved by admin, will be applied to Firestore
  approved('APPROVED'),

  /// Patch rejected by admin (incorrect, spam, etc.)
  rejected('REJECTED'),

  /// Patch auto-rejected due to version mismatch (exercise was updated)
  autoRejected('AUTO_REJECTED'),

  /// Patch expired after 30 days without admin action
  expired('EXPIRED');

  const PatchStatus(this.value);

  final String value;

  /// Parse from string value (from Firestore)
  static PatchStatus fromString(String value) {
    return PatchStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PatchStatus.pending,
    );
  }

  /// User-friendly display name (for UI)
  String get displayName {
    switch (this) {
      case PatchStatus.pending:
        return 'In attesa';
      case PatchStatus.approved:
        return 'Approvata';
      case PatchStatus.rejected:
        return 'Rifiutata';
      case PatchStatus.autoRejected:
        return 'Rifiutata automaticamente';
      case PatchStatus.expired:
        return 'Scaduta';
    }
  }

  /// Check if patch is still actionable by admin
  bool get isActionable => this == PatchStatus.pending;

  /// Check if patch is final (cannot be changed)
  bool get isFinal => this == PatchStatus.approved ||
                       this == PatchStatus.rejected ||
                       this == PatchStatus.autoRejected ||
                       this == PatchStatus.expired;
}
