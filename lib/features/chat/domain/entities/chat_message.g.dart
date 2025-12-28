// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutLinkMetadata _$WorkoutLinkMetadataFromJson(Map<String, dynamic> json) =>
    _WorkoutLinkMetadata(
      workoutId: json['workoutId'] as String,
      workoutName: json['workoutName'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      exerciseCount: (json['exerciseCount'] as num?)?.toInt(),
      totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WorkoutLinkMetadataToJson(
  _WorkoutLinkMetadata instance,
) => <String, dynamic>{
  'workoutId': instance.workoutId,
  'workoutName': instance.workoutName,
  'durationMinutes': instance.durationMinutes,
  'completedAt': instance.completedAt.toIso8601String(),
  'exerciseCount': instance.exerciseCount,
  'totalVolumeKg': instance.totalVolumeKg,
};

_ImageMetadata _$ImageMetadataFromJson(Map<String, dynamic> json) =>
    _ImageMetadata(
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      storagePath: json['storagePath'] as String,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImageMetadataToJson(_ImageMetadata instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'storagePath': instance.storagePath,
      'fileSizeBytes': instance.fileSizeBytes,
      'width': instance.width,
      'height': instance.height,
    };

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  text: json['text'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  workoutMetadata: json['workoutMetadata'] == null
      ? null
      : WorkoutLinkMetadata.fromJson(
          json['workoutMetadata'] as Map<String, dynamic>,
        ),
  imageMetadata: json['imageMetadata'] == null
      ? null
      : ImageMetadata.fromJson(json['imageMetadata'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'text': instance.text,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'workoutMetadata': instance.workoutMetadata?.toJson(),
      'imageMetadata': instance.imageMetadata?.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.workoutLink: 'workoutLink',
};
