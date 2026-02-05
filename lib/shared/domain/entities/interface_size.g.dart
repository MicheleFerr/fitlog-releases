// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface_size.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterfaceSizeAdapter extends TypeAdapter<InterfaceSize> {
  @override
  final typeId = 100;

  @override
  InterfaceSize read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InterfaceSize.extraSmall;
      case 1:
        return InterfaceSize.medium;
      case 2:
        return InterfaceSize.large;
      case 3:
        return InterfaceSize.small;
      case 4:
        return InterfaceSize.mediumLarge;
      default:
        return InterfaceSize.extraSmall;
    }
  }

  @override
  void write(BinaryWriter writer, InterfaceSize obj) {
    switch (obj) {
      case InterfaceSize.extraSmall:
        writer.writeByte(0);
      case InterfaceSize.medium:
        writer.writeByte(1);
      case InterfaceSize.large:
        writer.writeByte(2);
      case InterfaceSize.small:
        writer.writeByte(3);
      case InterfaceSize.mediumLarge:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterfaceSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
