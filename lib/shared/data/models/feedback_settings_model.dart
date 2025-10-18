import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/feedback_settings.dart';

part 'feedback_settings_model.g.dart';

/// Hive Adapter for HapticIntensity enum
@HiveType(typeId: 53)
enum HapticIntensityModel {
  @HiveField(0)
  light,

  @HiveField(1)
  medium,

  @HiveField(2)
  heavy,
}

/// Extension to convert between domain and model enums
extension HapticIntensityX on HapticIntensity {
  HapticIntensityModel toModel() {
    switch (this) {
      case HapticIntensity.light:
        return HapticIntensityModel.light;
      case HapticIntensity.medium:
        return HapticIntensityModel.medium;
      case HapticIntensity.heavy:
        return HapticIntensityModel.heavy;
    }
  }
}

extension HapticIntensityModelX on HapticIntensityModel {
  HapticIntensity toDomain() {
    switch (this) {
      case HapticIntensityModel.light:
        return HapticIntensity.light;
      case HapticIntensityModel.medium:
        return HapticIntensity.medium;
      case HapticIntensityModel.heavy:
        return HapticIntensity.heavy;
    }
  }
}

/// Hive Model for FeedbackSettings
@HiveType(typeId: 52)
class FeedbackSettingsModel extends HiveObject {
  FeedbackSettingsModel({
    required this.hapticEnabled,
    required this.hapticIntensity,
  });

  @HiveField(0)
  bool hapticEnabled;

  @HiveField(1)
  HapticIntensityModel hapticIntensity;

  /// Convert to domain entity
  FeedbackSettings toEntity() {
    return FeedbackSettings(
      hapticEnabled: hapticEnabled,
      hapticIntensity: hapticIntensity.toDomain(),
    );
  }

  /// Create from domain entity
  factory FeedbackSettingsModel.fromEntity(FeedbackSettings entity) {
    return FeedbackSettingsModel(
      hapticEnabled: entity.hapticEnabled,
      hapticIntensity: entity.hapticIntensity.toModel(),
    );
  }
}
