// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_equipment_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymEquipmentProfileAdapter extends TypeAdapter<GymEquipmentProfile> {
  @override
  final typeId = 110;

  @override
  GymEquipmentProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymEquipmentProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      defaultBarbellWeight: fields[2] == null
          ? 20.0
          : (fields[2] as num?)?.toDouble(),
      availablePlates: fields[3] == null
          ? const [25, 20, 15, 10, 5, 2.5, 1.25]
          : (fields[3] as List).cast<double>(),
      isDefault: fields[4] == null ? false : fields[4] as bool,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GymEquipmentProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.defaultBarbellWeight)
      ..writeByte(3)
      ..write(obj.availablePlates)
      ..writeByte(4)
      ..write(obj.isDefault)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymEquipmentProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
