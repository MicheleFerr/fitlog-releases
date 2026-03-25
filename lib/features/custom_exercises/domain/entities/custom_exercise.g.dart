// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomExerciseAdapter extends TypeAdapter<CustomExercise> {
  @override
  final typeId = 75;

  @override
  CustomExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomExercise(
      id: fields[0] as String,
      nome: fields[1] as String,
      baseExerciseId: fields[2] as String?,
      inclinazioneGradi: (fields[12] as num?)?.toInt(),
      focus: (fields[3] as List).cast<String>(),
      muscoliSecondari: (fields[4] as List).cast<String>(),
      tipoEsercizio: fields[5] as String,
      patternMovimento: fields[6] as String,
      attrezzatura: fields[7] as String,
      createdAt: fields[8] as DateTime,
      unlockedUntil: fields[9] as DateTime?,
      isModifiedFromBase: fields[10] == null ? false : fields[10] as bool,
      userId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomExercise obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.baseExerciseId)
      ..writeByte(3)
      ..write(obj.focus)
      ..writeByte(4)
      ..write(obj.muscoliSecondari)
      ..writeByte(5)
      ..write(obj.tipoEsercizio)
      ..writeByte(6)
      ..write(obj.patternMovimento)
      ..writeByte(7)
      ..write(obj.attrezzatura)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.unlockedUntil)
      ..writeByte(10)
      ..write(obj.isModifiedFromBase)
      ..writeByte(11)
      ..write(obj.userId)
      ..writeByte(12)
      ..write(obj.inclinazioneGradi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
