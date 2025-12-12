// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stress_index_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StressIndexState _$StressIndexStateFromJson(Map<String, dynamic> json) =>
    _StressIndexState(
      latestResult: json['latestResult'] == null
          ? null
          : StressIndexResult.fromJson(
              json['latestResult'] as Map<String, dynamic>,
            ),
      muscleRecovery: (json['muscleRecovery'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          MuscleRecoveryStatus.fromJson(e as Map<String, dynamic>),
        ),
      ),
      history: (json['history'] as List<dynamic>)
          .map((e) => StressIndexResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StressIndexStateToJson(_StressIndexState instance) =>
    <String, dynamic>{
      'latestResult': instance.latestResult?.toJson(),
      'muscleRecovery': instance.muscleRecovery.map(
        (k, e) => MapEntry(k, e.toJson()),
      ),
      'history': instance.history.map((e) => e.toJson()).toList(),
    };
