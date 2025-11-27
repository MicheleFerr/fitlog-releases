// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_consent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LegalConsentAdapter extends TypeAdapter<LegalConsent> {
  @override
  final typeId = 10;

  @override
  LegalConsent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LegalConsent(
      type: fields[0] as ConsentType,
      accepted: fields[1] as bool,
      timestamp: fields[2] as DateTime,
      ipAddress: fields[3] as String?,
      userAgent: fields[4] as String?,
      version: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LegalConsent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.accepted)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.ipAddress)
      ..writeByte(4)
      ..write(obj.userAgent)
      ..writeByte(5)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalConsentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConsentTypeAdapter extends TypeAdapter<ConsentType> {
  @override
  final typeId = 11;

  @override
  ConsentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConsentType.disclaimer;
      case 1:
        return ConsentType.privacyPolicy;
      case 2:
        return ConsentType.tosAccepted;
      case 3:
        return ConsentType.ageVerified;
      case 4:
        return ConsentType.firebaseDPA;
      default:
        return ConsentType.disclaimer;
    }
  }

  @override
  void write(BinaryWriter writer, ConsentType obj) {
    switch (obj) {
      case ConsentType.disclaimer:
        writer.writeByte(0);
      case ConsentType.privacyPolicy:
        writer.writeByte(1);
      case ConsentType.tosAccepted:
        writer.writeByte(2);
      case ConsentType.ageVerified:
        writer.writeByte(3);
      case ConsentType.firebaseDPA:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
