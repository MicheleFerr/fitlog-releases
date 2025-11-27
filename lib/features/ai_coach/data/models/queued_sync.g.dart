// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queued_sync.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedSyncAdapter extends TypeAdapter<QueuedSync> {
  @override
  final typeId = 10;

  @override
  QueuedSync read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedSync(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      healthMetrics: (fields[2] as Map).cast<String, dynamic>(),
      error: fields[3] as String,
      retryCount: fields[4] == null ? 0 : (fields[4] as num).toInt(),
      retryable: fields[5] == null ? true : fields[5] as bool,
      nextRetryAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedSync obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.healthMetrics)
      ..writeByte(3)
      ..write(obj.error)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.retryable)
      ..writeByte(6)
      ..write(obj.nextRetryAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedSyncAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QueuedSync _$QueuedSyncFromJson(Map<String, dynamic> json) => _QueuedSync(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  healthMetrics: json['healthMetrics'] as Map<String, dynamic>,
  error: json['error'] as String,
  retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
  retryable: json['retryable'] as bool? ?? true,
  nextRetryAt: json['nextRetryAt'] == null
      ? null
      : DateTime.parse(json['nextRetryAt'] as String),
);

Map<String, dynamic> _$QueuedSyncToJson(_QueuedSync instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'healthMetrics': instance.healthMetrics,
      'error': instance.error,
      'retryCount': instance.retryCount,
      'retryable': instance.retryable,
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
    };
