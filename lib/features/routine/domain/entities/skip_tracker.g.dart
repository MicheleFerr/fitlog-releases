// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skip_tracker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SkipEntryImpl _$$SkipEntryImplFromJson(Map<String, dynamic> json) =>
    _$SkipEntryImpl(
      date: DateTime.parse(json['date'] as String),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      skippedAt: DateTime.parse(json['skippedAt'] as String),
    );

Map<String, dynamic> _$$SkipEntryImplToJson(_$SkipEntryImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'reason': instance.reason,
      'notes': instance.notes,
      'skippedAt': instance.skippedAt.toIso8601String(),
    };

_$RecoveryEntryImpl _$$RecoveryEntryImplFromJson(Map<String, dynamic> json) =>
    _$RecoveryEntryImpl(
      originalDate: DateTime.parse(json['originalDate'] as String),
      recoveryDate: DateTime.parse(json['recoveryDate'] as String),
      notes: json['notes'] as String?,
      recoveredAt: DateTime.parse(json['recoveredAt'] as String),
    );

Map<String, dynamic> _$$RecoveryEntryImplToJson(_$RecoveryEntryImpl instance) =>
    <String, dynamic>{
      'originalDate': instance.originalDate.toIso8601String(),
      'recoveryDate': instance.recoveryDate.toIso8601String(),
      'notes': instance.notes,
      'recoveredAt': instance.recoveredAt.toIso8601String(),
    };

_$SkipTrackerImpl _$$SkipTrackerImplFromJson(Map<String, dynamic> json) =>
    _$SkipTrackerImpl(
      skippedDays: (json['skippedDays'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, SkipEntry.fromJson(e as Map<String, dynamic>)),
      ),
      recoveredDays: (json['recoveredDays'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, RecoveryEntry.fromJson(e as Map<String, dynamic>)),
      ),
      totalSkips: (json['totalSkips'] as num?)?.toInt() ?? 0,
      totalRecoveries: (json['totalRecoveries'] as num?)?.toInt() ?? 0,
      currentSkipStreak: (json['currentSkipStreak'] as num?)?.toInt() ?? 0,
      longestSkipStreak: (json['longestSkipStreak'] as num?)?.toInt() ?? 0,
      lastSkipDate: json['lastSkipDate'] == null
          ? null
          : DateTime.parse(json['lastSkipDate'] as String),
      mostCommonReason: json['mostCommonReason'] as String?,
    );

Map<String, dynamic> _$$SkipTrackerImplToJson(_$SkipTrackerImpl instance) =>
    <String, dynamic>{
      'skippedDays':
          instance.skippedDays.map((k, e) => MapEntry(k, e.toJson())),
      'recoveredDays':
          instance.recoveredDays.map((k, e) => MapEntry(k, e.toJson())),
      'totalSkips': instance.totalSkips,
      'totalRecoveries': instance.totalRecoveries,
      'currentSkipStreak': instance.currentSkipStreak,
      'longestSkipStreak': instance.longestSkipStreak,
      'lastSkipDate': instance.lastSkipDate?.toIso8601String(),
      'mostCommonReason': instance.mostCommonReason,
    };
