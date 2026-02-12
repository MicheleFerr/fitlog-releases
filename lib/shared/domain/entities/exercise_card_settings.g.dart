// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_card_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseCardSettingsAdapter extends TypeAdapter<ExerciseCardSettings> {
  @override
  final typeId = 104;

  @override
  ExerciseCardSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseCardSettings(
      gifSize: fields[0] == null
          ? ExerciseGifSize.medium
          : fields[0] as ExerciseGifSize,
      density: fields[1] == null
          ? ExerciseCardDensity.standard
          : fields[1] as ExerciseCardDensity,
      showInsight: fields[2] == null ? true : fields[2] as bool,
      showTimer: fields[3] == null ? true : fields[3] as bool,
      showPlates: fields[4] == null ? true : fields[4] as bool,
      showRpe: fields[5] == null ? true : fields[5] as bool,
      footerElements: fields[6] == null
          ? const [
              ExerciseFooterElement.tips,
              ExerciseFooterElement.tut,
              ExerciseFooterElement.notes,
            ]
          : (fields[6] as List).cast<ExerciseFooterElement>(),
      footerExpanded: fields[7] == null ? false : fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseCardSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.gifSize)
      ..writeByte(1)
      ..write(obj.density)
      ..writeByte(2)
      ..write(obj.showInsight)
      ..writeByte(3)
      ..write(obj.showTimer)
      ..writeByte(4)
      ..write(obj.showPlates)
      ..writeByte(5)
      ..write(obj.showRpe)
      ..writeByte(6)
      ..write(obj.footerElements)
      ..writeByte(7)
      ..write(obj.footerExpanded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCardSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseGifSizeAdapter extends TypeAdapter<ExerciseGifSize> {
  @override
  final typeId = 101;

  @override
  ExerciseGifSize read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseGifSize.small;
      case 1:
        return ExerciseGifSize.medium;
      case 2:
        return ExerciseGifSize.large;
      case 3:
        return ExerciseGifSize.hidden;
      default:
        return ExerciseGifSize.small;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseGifSize obj) {
    switch (obj) {
      case ExerciseGifSize.small:
        writer.writeByte(0);
      case ExerciseGifSize.medium:
        writer.writeByte(1);
      case ExerciseGifSize.large:
        writer.writeByte(2);
      case ExerciseGifSize.hidden:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseGifSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseCardDensityAdapter extends TypeAdapter<ExerciseCardDensity> {
  @override
  final typeId = 102;

  @override
  ExerciseCardDensity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseCardDensity.compact;
      case 1:
        return ExerciseCardDensity.standard;
      case 2:
        return ExerciseCardDensity.extended;
      default:
        return ExerciseCardDensity.compact;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseCardDensity obj) {
    switch (obj) {
      case ExerciseCardDensity.compact:
        writer.writeByte(0);
      case ExerciseCardDensity.standard:
        writer.writeByte(1);
      case ExerciseCardDensity.extended:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCardDensityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseFooterElementAdapter extends TypeAdapter<ExerciseFooterElement> {
  @override
  final typeId = 103;

  @override
  ExerciseFooterElement read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseFooterElement.tips;
      case 1:
        return ExerciseFooterElement.tut;
      case 2:
        return ExerciseFooterElement.notes;
      default:
        return ExerciseFooterElement.tips;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseFooterElement obj) {
    switch (obj) {
      case ExerciseFooterElement.tips:
        writer.writeByte(0);
      case ExerciseFooterElement.tut:
        writer.writeByte(1);
      case ExerciseFooterElement.notes:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFooterElementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
