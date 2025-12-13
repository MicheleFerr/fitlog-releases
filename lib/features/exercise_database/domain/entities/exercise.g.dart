// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseDefinitionAdapter extends TypeAdapter<ExerciseDefinition> {
  @override
  final typeId = 2;

  @override
  ExerciseDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseDefinition(
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
      aliases: fields[21] == null
          ? const []
          : (fields[21] as List).cast<String>(),
      normalizedNome: fields[22] as String?,
      searchableFields: (fields[23] as List?)?.cast<String>(),
      warmupSuggestions: (fields[24] as List?)?.cast<WarmupSuggestion>(),
      countingMode: fields[25] == null
          ? ExerciseCountingMode.weighted
          : fields[25] as ExerciseCountingMode,
      tempoEsecuzione: fields[26] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseDefinition obj) {
    writer
      ..writeByte(19)
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
      ..writeByte(21)
      ..write(obj.aliases)
      ..writeByte(22)
      ..write(obj.normalizedNome)
      ..writeByte(23)
      ..write(obj.searchableFields)
      ..writeByte(24)
      ..write(obj.warmupSuggestions)
      ..writeByte(25)
      ..write(obj.countingMode)
      ..writeByte(26)
      ..write(obj.tempoEsecuzione);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDefinitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
