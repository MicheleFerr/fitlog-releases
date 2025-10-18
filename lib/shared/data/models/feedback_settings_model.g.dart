// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedbackSettingsModelAdapter extends TypeAdapter<FeedbackSettingsModel> {
  @override
  final int typeId = 52;

  @override
  FeedbackSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedbackSettingsModel(
      hapticEnabled: fields[0] as bool,
      hapticIntensity: fields[1] as HapticIntensityModel,
    );
  }

  @override
  void write(BinaryWriter writer, FeedbackSettingsModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.hapticEnabled)
      ..writeByte(1)
      ..write(obj.hapticIntensity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HapticIntensityModelAdapter extends TypeAdapter<HapticIntensityModel> {
  @override
  final int typeId = 53;

  @override
  HapticIntensityModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HapticIntensityModel.light;
      case 1:
        return HapticIntensityModel.medium;
      case 2:
        return HapticIntensityModel.heavy;
      default:
        return HapticIntensityModel.light;
    }
  }

  @override
  void write(BinaryWriter writer, HapticIntensityModel obj) {
    switch (obj) {
      case HapticIntensityModel.light:
        writer.writeByte(0);
        break;
      case HapticIntensityModel.medium:
        writer.writeByte(1);
        break;
      case HapticIntensityModel.heavy:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HapticIntensityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
