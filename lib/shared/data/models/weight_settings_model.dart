import 'package:hive/hive.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_increment.dart';

part 'weight_settings_model.g.dart';

/// Hive Model for WeightSettings
@HiveType(typeId: 50) // ⚠️ Ensure unique typeId
class WeightSettingsModel extends HiveObject {

  WeightSettingsModel({
    required this.defaultIncrement,
    required this.customIncrement,
    required this.useCustomIncrement,
    required this.availablePlates,
  });

  /// From Domain Entity
  factory WeightSettingsModel.fromEntity(WeightSettings entity) {
    return WeightSettingsModel(
      defaultIncrement: entity.defaultIncrement.value,
      customIncrement: entity.customIncrement.value,
      useCustomIncrement: entity.useCustomIncrement,
      availablePlates: entity.availablePlates
          .map((p) => PlateOptionModel.fromEntity(p))
          .toList(),
    );
  }

  /// From JSON (for Firebase)
  factory WeightSettingsModel.fromJson(Map<String, dynamic> json) {
    return WeightSettingsModel(
      defaultIncrement: (json['defaultIncrement'] as num).toDouble(),
      customIncrement: (json['customIncrement'] as num).toDouble(),
      useCustomIncrement: json['useCustomIncrement'] as bool,
      availablePlates: (json['availablePlates'] as List)
          .map((p) => PlateOptionModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
  @HiveField(0)
  double defaultIncrement;

  @HiveField(1)
  double customIncrement;

  @HiveField(2)
  bool useCustomIncrement;

  @HiveField(3)
  List<PlateOptionModel> availablePlates;

  /// To Domain Entity
  WeightSettings toEntity() {
    return WeightSettings(
      defaultIncrement: WeightIncrement(defaultIncrement),
      customIncrement: WeightIncrement(customIncrement),
      useCustomIncrement: useCustomIncrement,
      availablePlates: availablePlates.map((p) => p.toEntity()).toList(),
    );
  }

  /// To JSON (for Firebase)
  Map<String, dynamic> toJson() {
    return {
      'defaultIncrement': defaultIncrement,
      'customIncrement': customIncrement,
      'useCustomIncrement': useCustomIncrement,
      'availablePlates': availablePlates.map((p) => p.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 51)
class PlateOptionModel extends HiveObject {

  PlateOptionModel({
    required this.weight,
    required this.count,
  });

  factory PlateOptionModel.fromEntity(PlateOption entity) {
    return PlateOptionModel(
      weight: entity.weight,
      count: entity.count,
    );
  }

  factory PlateOptionModel.fromJson(Map<String, dynamic> json) {
    return PlateOptionModel(
      weight: (json['weight'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
  @HiveField(0)
  double weight;

  @HiveField(1)
  int count;

  PlateOption toEntity() {
    return PlateOption(
      weight: weight,
      count: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'count': count,
    };
  }
}
