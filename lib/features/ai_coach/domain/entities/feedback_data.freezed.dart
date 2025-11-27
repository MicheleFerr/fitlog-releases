// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackData {

/// Unique feedback ID
 String get id;/// User ID who provided feedback
 String get userId;/// Insight ID that received feedback
 String get insightId;/// Type of insight that received feedback
 String get insightType;/// Category of insight that received feedback
 String get insightCategory;/// Type of feedback provided
 FeedbackType get feedbackType;/// Reason for dismissing (if feedbackType is notHelpful/dismissed)
 DismissReason? get dismissReason;/// Optional text comment from user
 String? get comment;/// When feedback was provided
 DateTime get timestamp;/// How long insight was shown before feedback (in seconds)
 int get viewDurationSeconds;
/// Create a copy of FeedbackData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackDataCopyWith<FeedbackData> get copyWith => _$FeedbackDataCopyWithImpl<FeedbackData>(this as FeedbackData, _$identity);

  /// Serializes this FeedbackData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackData&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.insightId, insightId) || other.insightId == insightId)&&(identical(other.insightType, insightType) || other.insightType == insightType)&&(identical(other.insightCategory, insightCategory) || other.insightCategory == insightCategory)&&(identical(other.feedbackType, feedbackType) || other.feedbackType == feedbackType)&&(identical(other.dismissReason, dismissReason) || other.dismissReason == dismissReason)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.viewDurationSeconds, viewDurationSeconds) || other.viewDurationSeconds == viewDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,insightId,insightType,insightCategory,feedbackType,dismissReason,comment,timestamp,viewDurationSeconds);

@override
String toString() {
  return 'FeedbackData(id: $id, userId: $userId, insightId: $insightId, insightType: $insightType, insightCategory: $insightCategory, feedbackType: $feedbackType, dismissReason: $dismissReason, comment: $comment, timestamp: $timestamp, viewDurationSeconds: $viewDurationSeconds)';
}


}

/// @nodoc
abstract mixin class $FeedbackDataCopyWith<$Res>  {
  factory $FeedbackDataCopyWith(FeedbackData value, $Res Function(FeedbackData) _then) = _$FeedbackDataCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String insightId, String insightType, String insightCategory, FeedbackType feedbackType, DismissReason? dismissReason, String? comment, DateTime timestamp, int viewDurationSeconds
});




}
/// @nodoc
class _$FeedbackDataCopyWithImpl<$Res>
    implements $FeedbackDataCopyWith<$Res> {
  _$FeedbackDataCopyWithImpl(this._self, this._then);

  final FeedbackData _self;
  final $Res Function(FeedbackData) _then;

/// Create a copy of FeedbackData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? insightId = null,Object? insightType = null,Object? insightCategory = null,Object? feedbackType = null,Object? dismissReason = freezed,Object? comment = freezed,Object? timestamp = null,Object? viewDurationSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,insightId: null == insightId ? _self.insightId : insightId // ignore: cast_nullable_to_non_nullable
as String,insightType: null == insightType ? _self.insightType : insightType // ignore: cast_nullable_to_non_nullable
as String,insightCategory: null == insightCategory ? _self.insightCategory : insightCategory // ignore: cast_nullable_to_non_nullable
as String,feedbackType: null == feedbackType ? _self.feedbackType : feedbackType // ignore: cast_nullable_to_non_nullable
as FeedbackType,dismissReason: freezed == dismissReason ? _self.dismissReason : dismissReason // ignore: cast_nullable_to_non_nullable
as DismissReason?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,viewDurationSeconds: null == viewDurationSeconds ? _self.viewDurationSeconds : viewDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackData].
extension FeedbackDataPatterns on FeedbackData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackData value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackData value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String insightId,  String insightType,  String insightCategory,  FeedbackType feedbackType,  DismissReason? dismissReason,  String? comment,  DateTime timestamp,  int viewDurationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackData() when $default != null:
return $default(_that.id,_that.userId,_that.insightId,_that.insightType,_that.insightCategory,_that.feedbackType,_that.dismissReason,_that.comment,_that.timestamp,_that.viewDurationSeconds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String insightId,  String insightType,  String insightCategory,  FeedbackType feedbackType,  DismissReason? dismissReason,  String? comment,  DateTime timestamp,  int viewDurationSeconds)  $default,) {final _that = this;
switch (_that) {
case _FeedbackData():
return $default(_that.id,_that.userId,_that.insightId,_that.insightType,_that.insightCategory,_that.feedbackType,_that.dismissReason,_that.comment,_that.timestamp,_that.viewDurationSeconds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String insightId,  String insightType,  String insightCategory,  FeedbackType feedbackType,  DismissReason? dismissReason,  String? comment,  DateTime timestamp,  int viewDurationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackData() when $default != null:
return $default(_that.id,_that.userId,_that.insightId,_that.insightType,_that.insightCategory,_that.feedbackType,_that.dismissReason,_that.comment,_that.timestamp,_that.viewDurationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackData implements FeedbackData {
  const _FeedbackData({required this.id, required this.userId, required this.insightId, required this.insightType, required this.insightCategory, required this.feedbackType, this.dismissReason, this.comment, required this.timestamp, this.viewDurationSeconds = 0});
  factory _FeedbackData.fromJson(Map<String, dynamic> json) => _$FeedbackDataFromJson(json);

/// Unique feedback ID
@override final  String id;
/// User ID who provided feedback
@override final  String userId;
/// Insight ID that received feedback
@override final  String insightId;
/// Type of insight that received feedback
@override final  String insightType;
/// Category of insight that received feedback
@override final  String insightCategory;
/// Type of feedback provided
@override final  FeedbackType feedbackType;
/// Reason for dismissing (if feedbackType is notHelpful/dismissed)
@override final  DismissReason? dismissReason;
/// Optional text comment from user
@override final  String? comment;
/// When feedback was provided
@override final  DateTime timestamp;
/// How long insight was shown before feedback (in seconds)
@override@JsonKey() final  int viewDurationSeconds;

/// Create a copy of FeedbackData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackDataCopyWith<_FeedbackData> get copyWith => __$FeedbackDataCopyWithImpl<_FeedbackData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackData&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.insightId, insightId) || other.insightId == insightId)&&(identical(other.insightType, insightType) || other.insightType == insightType)&&(identical(other.insightCategory, insightCategory) || other.insightCategory == insightCategory)&&(identical(other.feedbackType, feedbackType) || other.feedbackType == feedbackType)&&(identical(other.dismissReason, dismissReason) || other.dismissReason == dismissReason)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.viewDurationSeconds, viewDurationSeconds) || other.viewDurationSeconds == viewDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,insightId,insightType,insightCategory,feedbackType,dismissReason,comment,timestamp,viewDurationSeconds);

@override
String toString() {
  return 'FeedbackData(id: $id, userId: $userId, insightId: $insightId, insightType: $insightType, insightCategory: $insightCategory, feedbackType: $feedbackType, dismissReason: $dismissReason, comment: $comment, timestamp: $timestamp, viewDurationSeconds: $viewDurationSeconds)';
}


}

/// @nodoc
abstract mixin class _$FeedbackDataCopyWith<$Res> implements $FeedbackDataCopyWith<$Res> {
  factory _$FeedbackDataCopyWith(_FeedbackData value, $Res Function(_FeedbackData) _then) = __$FeedbackDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String insightId, String insightType, String insightCategory, FeedbackType feedbackType, DismissReason? dismissReason, String? comment, DateTime timestamp, int viewDurationSeconds
});




}
/// @nodoc
class __$FeedbackDataCopyWithImpl<$Res>
    implements _$FeedbackDataCopyWith<$Res> {
  __$FeedbackDataCopyWithImpl(this._self, this._then);

  final _FeedbackData _self;
  final $Res Function(_FeedbackData) _then;

/// Create a copy of FeedbackData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? insightId = null,Object? insightType = null,Object? insightCategory = null,Object? feedbackType = null,Object? dismissReason = freezed,Object? comment = freezed,Object? timestamp = null,Object? viewDurationSeconds = null,}) {
  return _then(_FeedbackData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,insightId: null == insightId ? _self.insightId : insightId // ignore: cast_nullable_to_non_nullable
as String,insightType: null == insightType ? _self.insightType : insightType // ignore: cast_nullable_to_non_nullable
as String,insightCategory: null == insightCategory ? _self.insightCategory : insightCategory // ignore: cast_nullable_to_non_nullable
as String,feedbackType: null == feedbackType ? _self.feedbackType : feedbackType // ignore: cast_nullable_to_non_nullable
as FeedbackType,dismissReason: freezed == dismissReason ? _self.dismissReason : dismissReason // ignore: cast_nullable_to_non_nullable
as DismissReason?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,viewDurationSeconds: null == viewDurationSeconds ? _self.viewDurationSeconds : viewDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FeedbackStats {

/// Insight type or category
 String get identifier;/// Total feedback received
 int get totalFeedback;/// Helpful feedback count
 int get helpfulCount;/// Not helpful feedback count
 int get notHelpfulCount;/// Dismissed feedback count
 int get dismissedCount;/// Acted upon feedback count
 int get actedUponCount;/// Average view duration in seconds
 double get avgViewDuration;/// When stats were last updated
 DateTime? get lastUpdated;
/// Create a copy of FeedbackStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackStatsCopyWith<FeedbackStats> get copyWith => _$FeedbackStatsCopyWithImpl<FeedbackStats>(this as FeedbackStats, _$identity);

  /// Serializes this FeedbackStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackStats&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.totalFeedback, totalFeedback) || other.totalFeedback == totalFeedback)&&(identical(other.helpfulCount, helpfulCount) || other.helpfulCount == helpfulCount)&&(identical(other.notHelpfulCount, notHelpfulCount) || other.notHelpfulCount == notHelpfulCount)&&(identical(other.dismissedCount, dismissedCount) || other.dismissedCount == dismissedCount)&&(identical(other.actedUponCount, actedUponCount) || other.actedUponCount == actedUponCount)&&(identical(other.avgViewDuration, avgViewDuration) || other.avgViewDuration == avgViewDuration)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identifier,totalFeedback,helpfulCount,notHelpfulCount,dismissedCount,actedUponCount,avgViewDuration,lastUpdated);

@override
String toString() {
  return 'FeedbackStats(identifier: $identifier, totalFeedback: $totalFeedback, helpfulCount: $helpfulCount, notHelpfulCount: $notHelpfulCount, dismissedCount: $dismissedCount, actedUponCount: $actedUponCount, avgViewDuration: $avgViewDuration, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $FeedbackStatsCopyWith<$Res>  {
  factory $FeedbackStatsCopyWith(FeedbackStats value, $Res Function(FeedbackStats) _then) = _$FeedbackStatsCopyWithImpl;
@useResult
$Res call({
 String identifier, int totalFeedback, int helpfulCount, int notHelpfulCount, int dismissedCount, int actedUponCount, double avgViewDuration, DateTime? lastUpdated
});




}
/// @nodoc
class _$FeedbackStatsCopyWithImpl<$Res>
    implements $FeedbackStatsCopyWith<$Res> {
  _$FeedbackStatsCopyWithImpl(this._self, this._then);

  final FeedbackStats _self;
  final $Res Function(FeedbackStats) _then;

/// Create a copy of FeedbackStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? totalFeedback = null,Object? helpfulCount = null,Object? notHelpfulCount = null,Object? dismissedCount = null,Object? actedUponCount = null,Object? avgViewDuration = null,Object? lastUpdated = freezed,}) {
  return _then(_self.copyWith(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,totalFeedback: null == totalFeedback ? _self.totalFeedback : totalFeedback // ignore: cast_nullable_to_non_nullable
as int,helpfulCount: null == helpfulCount ? _self.helpfulCount : helpfulCount // ignore: cast_nullable_to_non_nullable
as int,notHelpfulCount: null == notHelpfulCount ? _self.notHelpfulCount : notHelpfulCount // ignore: cast_nullable_to_non_nullable
as int,dismissedCount: null == dismissedCount ? _self.dismissedCount : dismissedCount // ignore: cast_nullable_to_non_nullable
as int,actedUponCount: null == actedUponCount ? _self.actedUponCount : actedUponCount // ignore: cast_nullable_to_non_nullable
as int,avgViewDuration: null == avgViewDuration ? _self.avgViewDuration : avgViewDuration // ignore: cast_nullable_to_non_nullable
as double,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackStats].
extension FeedbackStatsPatterns on FeedbackStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackStats value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackStats value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  int totalFeedback,  int helpfulCount,  int notHelpfulCount,  int dismissedCount,  int actedUponCount,  double avgViewDuration,  DateTime? lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackStats() when $default != null:
return $default(_that.identifier,_that.totalFeedback,_that.helpfulCount,_that.notHelpfulCount,_that.dismissedCount,_that.actedUponCount,_that.avgViewDuration,_that.lastUpdated);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  int totalFeedback,  int helpfulCount,  int notHelpfulCount,  int dismissedCount,  int actedUponCount,  double avgViewDuration,  DateTime? lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _FeedbackStats():
return $default(_that.identifier,_that.totalFeedback,_that.helpfulCount,_that.notHelpfulCount,_that.dismissedCount,_that.actedUponCount,_that.avgViewDuration,_that.lastUpdated);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  int totalFeedback,  int helpfulCount,  int notHelpfulCount,  int dismissedCount,  int actedUponCount,  double avgViewDuration,  DateTime? lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackStats() when $default != null:
return $default(_that.identifier,_that.totalFeedback,_that.helpfulCount,_that.notHelpfulCount,_that.dismissedCount,_that.actedUponCount,_that.avgViewDuration,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackStats implements FeedbackStats {
  const _FeedbackStats({required this.identifier, this.totalFeedback = 0, this.helpfulCount = 0, this.notHelpfulCount = 0, this.dismissedCount = 0, this.actedUponCount = 0, this.avgViewDuration = 0.0, this.lastUpdated});
  factory _FeedbackStats.fromJson(Map<String, dynamic> json) => _$FeedbackStatsFromJson(json);

/// Insight type or category
@override final  String identifier;
/// Total feedback received
@override@JsonKey() final  int totalFeedback;
/// Helpful feedback count
@override@JsonKey() final  int helpfulCount;
/// Not helpful feedback count
@override@JsonKey() final  int notHelpfulCount;
/// Dismissed feedback count
@override@JsonKey() final  int dismissedCount;
/// Acted upon feedback count
@override@JsonKey() final  int actedUponCount;
/// Average view duration in seconds
@override@JsonKey() final  double avgViewDuration;
/// When stats were last updated
@override final  DateTime? lastUpdated;

/// Create a copy of FeedbackStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackStatsCopyWith<_FeedbackStats> get copyWith => __$FeedbackStatsCopyWithImpl<_FeedbackStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackStats&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.totalFeedback, totalFeedback) || other.totalFeedback == totalFeedback)&&(identical(other.helpfulCount, helpfulCount) || other.helpfulCount == helpfulCount)&&(identical(other.notHelpfulCount, notHelpfulCount) || other.notHelpfulCount == notHelpfulCount)&&(identical(other.dismissedCount, dismissedCount) || other.dismissedCount == dismissedCount)&&(identical(other.actedUponCount, actedUponCount) || other.actedUponCount == actedUponCount)&&(identical(other.avgViewDuration, avgViewDuration) || other.avgViewDuration == avgViewDuration)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identifier,totalFeedback,helpfulCount,notHelpfulCount,dismissedCount,actedUponCount,avgViewDuration,lastUpdated);

@override
String toString() {
  return 'FeedbackStats(identifier: $identifier, totalFeedback: $totalFeedback, helpfulCount: $helpfulCount, notHelpfulCount: $notHelpfulCount, dismissedCount: $dismissedCount, actedUponCount: $actedUponCount, avgViewDuration: $avgViewDuration, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$FeedbackStatsCopyWith<$Res> implements $FeedbackStatsCopyWith<$Res> {
  factory _$FeedbackStatsCopyWith(_FeedbackStats value, $Res Function(_FeedbackStats) _then) = __$FeedbackStatsCopyWithImpl;
@override @useResult
$Res call({
 String identifier, int totalFeedback, int helpfulCount, int notHelpfulCount, int dismissedCount, int actedUponCount, double avgViewDuration, DateTime? lastUpdated
});




}
/// @nodoc
class __$FeedbackStatsCopyWithImpl<$Res>
    implements _$FeedbackStatsCopyWith<$Res> {
  __$FeedbackStatsCopyWithImpl(this._self, this._then);

  final _FeedbackStats _self;
  final $Res Function(_FeedbackStats) _then;

/// Create a copy of FeedbackStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? totalFeedback = null,Object? helpfulCount = null,Object? notHelpfulCount = null,Object? dismissedCount = null,Object? actedUponCount = null,Object? avgViewDuration = null,Object? lastUpdated = freezed,}) {
  return _then(_FeedbackStats(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,totalFeedback: null == totalFeedback ? _self.totalFeedback : totalFeedback // ignore: cast_nullable_to_non_nullable
as int,helpfulCount: null == helpfulCount ? _self.helpfulCount : helpfulCount // ignore: cast_nullable_to_non_nullable
as int,notHelpfulCount: null == notHelpfulCount ? _self.notHelpfulCount : notHelpfulCount // ignore: cast_nullable_to_non_nullable
as int,dismissedCount: null == dismissedCount ? _self.dismissedCount : dismissedCount // ignore: cast_nullable_to_non_nullable
as int,actedUponCount: null == actedUponCount ? _self.actedUponCount : actedUponCount // ignore: cast_nullable_to_non_nullable
as int,avgViewDuration: null == avgViewDuration ? _self.avgViewDuration : avgViewDuration // ignore: cast_nullable_to_non_nullable
as double,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
