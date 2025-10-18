// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 2;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      nome: fields[1] as String,
      focus: (fields[2] as List).cast<String>(),
      imageUrl: fields[3] as String?,
      muscoliSecondari: (fields[4] as List).cast<String>(),
      difficolta: fields[5] as String,
      tipoEsercizio: fields[6] as String,
      attrezzatura: fields[7] as String,
      patternMovimento: fields[8] as String,
      rangeRipetizioni: fields[9] as String,
      noteTecniche: fields[10] as String?,
      mobilitaPre: fields[11] as String?,
      attivazionePre: fields[12] as String?,
      warmupSets: fields[13] as String?,
      tempoWarmup: fields[14] as String?,
      drillTecnico: fields[15] as String?,
      prevenzioneInfortuni: fields[16] as String?,
      cooldownConsigliato: fields[17] as String?,
      spiegazioneTermini: fields[18] as String?,
      tempoEsecuzione: fields[19] as String?,
      tempoNote: fields[20] as String?,
      aliases: (fields[21] as List).cast<String>(),
      normalizedNome: fields[22] as String?,
      searchableFields: (fields[23] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.focus)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.muscoliSecondari)
      ..writeByte(5)
      ..write(obj.difficolta)
      ..writeByte(6)
      ..write(obj.tipoEsercizio)
      ..writeByte(7)
      ..write(obj.attrezzatura)
      ..writeByte(8)
      ..write(obj.patternMovimento)
      ..writeByte(9)
      ..write(obj.rangeRipetizioni)
      ..writeByte(10)
      ..write(obj.noteTecniche)
      ..writeByte(11)
      ..write(obj.mobilitaPre)
      ..writeByte(12)
      ..write(obj.attivazionePre)
      ..writeByte(13)
      ..write(obj.warmupSets)
      ..writeByte(14)
      ..write(obj.tempoWarmup)
      ..writeByte(15)
      ..write(obj.drillTecnico)
      ..writeByte(16)
      ..write(obj.prevenzioneInfortuni)
      ..writeByte(17)
      ..write(obj.cooldownConsigliato)
      ..writeByte(18)
      ..write(obj.spiegazioneTermini)
      ..writeByte(19)
      ..write(obj.tempoEsecuzione)
      ..writeByte(20)
      ..write(obj.tempoNote)
      ..writeByte(21)
      ..write(obj.aliases)
      ..writeByte(22)
      ..write(obj.normalizedNome)
      ..writeByte(23)
      ..write(obj.searchableFields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
