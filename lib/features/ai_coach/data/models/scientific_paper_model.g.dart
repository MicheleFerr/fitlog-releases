// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scientific_paper_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScientificPaperModelAdapter extends TypeAdapter<ScientificPaperModel> {
  @override
  final typeId = 10;

  @override
  ScientificPaperModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScientificPaperModel(
      id: fields[0] as String,
      title: fields[1] as String,
      authors: (fields[2] as List).cast<String>(),
      year: (fields[3] as num).toInt(),
      doi: fields[4] as String,
      abstract: fields[5] as String,
      summary: fields[6] as String,
      url: fields[7] as String,
      license: fields[8] as String,
      categories: (fields[9] as List).cast<String>(),
      keywords: (fields[10] as List).cast<String>(),
      uploadedAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      active: fields[13] as bool,
      metadata: fields[14] == null
          ? const {}
          : (fields[14] as Map).cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScientificPaperModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.authors)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.doi)
      ..writeByte(5)
      ..write(obj.abstract)
      ..writeByte(6)
      ..write(obj.summary)
      ..writeByte(7)
      ..write(obj.url)
      ..writeByte(8)
      ..write(obj.license)
      ..writeByte(9)
      ..write(obj.categories)
      ..writeByte(10)
      ..write(obj.keywords)
      ..writeByte(11)
      ..write(obj.uploadedAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.active)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScientificPaperModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
