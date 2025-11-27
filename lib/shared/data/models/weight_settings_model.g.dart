// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightSettingsModelAdapter extends TypeAdapter<WeightSettingsModel> {
  @override
  final typeId = 50;

  @override
  WeightSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightSettingsModel(
      defaultIncrement: (fields[0] as num).toDouble(),
      customIncrement: (fields[1] as num).toDouble(),
      useCustomIncrement: fields[2] as bool,
      availablePlates: (fields[3] as List).cast<PlateOptionModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeightSettingsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.defaultIncrement)
      ..writeByte(1)
      ..write(obj.customIncrement)
      ..writeByte(2)
      ..write(obj.useCustomIncrement)
      ..writeByte(3)
      ..write(obj.availablePlates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlateOptionModelAdapter extends TypeAdapter<PlateOptionModel> {
  @override
  final typeId = 51;

  @override
  PlateOptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlateOptionModel(
      weight: (fields[0] as num).toDouble(),
      count: (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, PlateOptionModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlateOptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
