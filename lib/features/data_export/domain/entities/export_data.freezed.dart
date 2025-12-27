// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExportRequest {

 Set<ExportCategory> get categories; ExportFormat get format; bool get includePhotos; DateTime? get dateFrom; DateTime? get dateTo;
/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportRequestCopyWith<ExportRequest> get copyWith => _$ExportRequestCopyWithImpl<ExportRequest>(this as ExportRequest, _$identity);

  /// Serializes this ExportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportRequest&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.format, format) || other.format == format)&&(identical(other.includePhotos, includePhotos) || other.includePhotos == includePhotos)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories),format,includePhotos,dateFrom,dateTo);

@override
String toString() {
  return 'ExportRequest(categories: $categories, format: $format, includePhotos: $includePhotos, dateFrom: $dateFrom, dateTo: $dateTo)';
}


}

/// @nodoc
abstract mixin class $ExportRequestCopyWith<$Res>  {
  factory $ExportRequestCopyWith(ExportRequest value, $Res Function(ExportRequest) _then) = _$ExportRequestCopyWithImpl;
@useResult
$Res call({
 Set<ExportCategory> categories, ExportFormat format, bool includePhotos, DateTime? dateFrom, DateTime? dateTo
});




}
/// @nodoc
class _$ExportRequestCopyWithImpl<$Res>
    implements $ExportRequestCopyWith<$Res> {
  _$ExportRequestCopyWithImpl(this._self, this._then);

  final ExportRequest _self;
  final $Res Function(ExportRequest) _then;

/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? format = null,Object? includePhotos = null,Object? dateFrom = freezed,Object? dateTo = freezed,}) {
  return _then(_self.copyWith(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as Set<ExportCategory>,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,includePhotos: null == includePhotos ? _self.includePhotos : includePhotos // ignore: cast_nullable_to_non_nullable
as bool,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportRequest].
extension ExportRequestPatterns on ExportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportRequest value)  $default,){
final _that = this;
switch (_that) {
case _ExportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<ExportCategory> categories,  ExportFormat format,  bool includePhotos,  DateTime? dateFrom,  DateTime? dateTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
return $default(_that.categories,_that.format,_that.includePhotos,_that.dateFrom,_that.dateTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<ExportCategory> categories,  ExportFormat format,  bool includePhotos,  DateTime? dateFrom,  DateTime? dateTo)  $default,) {final _that = this;
switch (_that) {
case _ExportRequest():
return $default(_that.categories,_that.format,_that.includePhotos,_that.dateFrom,_that.dateTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<ExportCategory> categories,  ExportFormat format,  bool includePhotos,  DateTime? dateFrom,  DateTime? dateTo)?  $default,) {final _that = this;
switch (_that) {
case _ExportRequest() when $default != null:
return $default(_that.categories,_that.format,_that.includePhotos,_that.dateFrom,_that.dateTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportRequest implements ExportRequest {
  const _ExportRequest({required final  Set<ExportCategory> categories, this.format = ExportFormat.zip, this.includePhotos = true, this.dateFrom, this.dateTo}): _categories = categories;
  factory _ExportRequest.fromJson(Map<String, dynamic> json) => _$ExportRequestFromJson(json);

 final  Set<ExportCategory> _categories;
@override Set<ExportCategory> get categories {
  if (_categories is EqualUnmodifiableSetView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_categories);
}

@override@JsonKey() final  ExportFormat format;
@override@JsonKey() final  bool includePhotos;
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;

/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportRequestCopyWith<_ExportRequest> get copyWith => __$ExportRequestCopyWithImpl<_ExportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportRequest&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.format, format) || other.format == format)&&(identical(other.includePhotos, includePhotos) || other.includePhotos == includePhotos)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),format,includePhotos,dateFrom,dateTo);

@override
String toString() {
  return 'ExportRequest(categories: $categories, format: $format, includePhotos: $includePhotos, dateFrom: $dateFrom, dateTo: $dateTo)';
}


}

/// @nodoc
abstract mixin class _$ExportRequestCopyWith<$Res> implements $ExportRequestCopyWith<$Res> {
  factory _$ExportRequestCopyWith(_ExportRequest value, $Res Function(_ExportRequest) _then) = __$ExportRequestCopyWithImpl;
@override @useResult
$Res call({
 Set<ExportCategory> categories, ExportFormat format, bool includePhotos, DateTime? dateFrom, DateTime? dateTo
});




}
/// @nodoc
class __$ExportRequestCopyWithImpl<$Res>
    implements _$ExportRequestCopyWith<$Res> {
  __$ExportRequestCopyWithImpl(this._self, this._then);

  final _ExportRequest _self;
  final $Res Function(_ExportRequest) _then;

/// Create a copy of ExportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? format = null,Object? includePhotos = null,Object? dateFrom = freezed,Object? dateTo = freezed,}) {
  return _then(_ExportRequest(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as Set<ExportCategory>,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,includePhotos: null == includePhotos ? _self.includePhotos : includePhotos // ignore: cast_nullable_to_non_nullable
as bool,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ExportProgress {

 ExportStatus get status; double get progress; String? get currentStep; String? get errorMessage; String? get exportFilePath; DateTime? get completedAt; Map<ExportCategory, int> get itemCounts;
/// Create a copy of ExportProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportProgressCopyWith<ExportProgress> get copyWith => _$ExportProgressCopyWithImpl<ExportProgress>(this as ExportProgress, _$identity);

  /// Serializes this ExportProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportProgress&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.exportFilePath, exportFilePath) || other.exportFilePath == exportFilePath)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&const DeepCollectionEquality().equals(other.itemCounts, itemCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,progress,currentStep,errorMessage,exportFilePath,completedAt,const DeepCollectionEquality().hash(itemCounts));

@override
String toString() {
  return 'ExportProgress(status: $status, progress: $progress, currentStep: $currentStep, errorMessage: $errorMessage, exportFilePath: $exportFilePath, completedAt: $completedAt, itemCounts: $itemCounts)';
}


}

/// @nodoc
abstract mixin class $ExportProgressCopyWith<$Res>  {
  factory $ExportProgressCopyWith(ExportProgress value, $Res Function(ExportProgress) _then) = _$ExportProgressCopyWithImpl;
@useResult
$Res call({
 ExportStatus status, double progress, String? currentStep, String? errorMessage, String? exportFilePath, DateTime? completedAt, Map<ExportCategory, int> itemCounts
});




}
/// @nodoc
class _$ExportProgressCopyWithImpl<$Res>
    implements $ExportProgressCopyWith<$Res> {
  _$ExportProgressCopyWithImpl(this._self, this._then);

  final ExportProgress _self;
  final $Res Function(ExportProgress) _then;

/// Create a copy of ExportProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? progress = null,Object? currentStep = freezed,Object? errorMessage = freezed,Object? exportFilePath = freezed,Object? completedAt = freezed,Object? itemCounts = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExportStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,currentStep: freezed == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,exportFilePath: freezed == exportFilePath ? _self.exportFilePath : exportFilePath // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,itemCounts: null == itemCounts ? _self.itemCounts : itemCounts // ignore: cast_nullable_to_non_nullable
as Map<ExportCategory, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportProgress].
extension ExportProgressPatterns on ExportProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportProgress value)  $default,){
final _that = this;
switch (_that) {
case _ExportProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ExportProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ExportStatus status,  double progress,  String? currentStep,  String? errorMessage,  String? exportFilePath,  DateTime? completedAt,  Map<ExportCategory, int> itemCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportProgress() when $default != null:
return $default(_that.status,_that.progress,_that.currentStep,_that.errorMessage,_that.exportFilePath,_that.completedAt,_that.itemCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ExportStatus status,  double progress,  String? currentStep,  String? errorMessage,  String? exportFilePath,  DateTime? completedAt,  Map<ExportCategory, int> itemCounts)  $default,) {final _that = this;
switch (_that) {
case _ExportProgress():
return $default(_that.status,_that.progress,_that.currentStep,_that.errorMessage,_that.exportFilePath,_that.completedAt,_that.itemCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ExportStatus status,  double progress,  String? currentStep,  String? errorMessage,  String? exportFilePath,  DateTime? completedAt,  Map<ExportCategory, int> itemCounts)?  $default,) {final _that = this;
switch (_that) {
case _ExportProgress() when $default != null:
return $default(_that.status,_that.progress,_that.currentStep,_that.errorMessage,_that.exportFilePath,_that.completedAt,_that.itemCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportProgress implements ExportProgress {
  const _ExportProgress({required this.status, this.progress = 0.0, this.currentStep, this.errorMessage, this.exportFilePath, this.completedAt, final  Map<ExportCategory, int> itemCounts = const {}}): _itemCounts = itemCounts;
  factory _ExportProgress.fromJson(Map<String, dynamic> json) => _$ExportProgressFromJson(json);

@override final  ExportStatus status;
@override@JsonKey() final  double progress;
@override final  String? currentStep;
@override final  String? errorMessage;
@override final  String? exportFilePath;
@override final  DateTime? completedAt;
 final  Map<ExportCategory, int> _itemCounts;
@override@JsonKey() Map<ExportCategory, int> get itemCounts {
  if (_itemCounts is EqualUnmodifiableMapView) return _itemCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemCounts);
}


/// Create a copy of ExportProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportProgressCopyWith<_ExportProgress> get copyWith => __$ExportProgressCopyWithImpl<_ExportProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportProgress&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.exportFilePath, exportFilePath) || other.exportFilePath == exportFilePath)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&const DeepCollectionEquality().equals(other._itemCounts, _itemCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,progress,currentStep,errorMessage,exportFilePath,completedAt,const DeepCollectionEquality().hash(_itemCounts));

@override
String toString() {
  return 'ExportProgress(status: $status, progress: $progress, currentStep: $currentStep, errorMessage: $errorMessage, exportFilePath: $exportFilePath, completedAt: $completedAt, itemCounts: $itemCounts)';
}


}

/// @nodoc
abstract mixin class _$ExportProgressCopyWith<$Res> implements $ExportProgressCopyWith<$Res> {
  factory _$ExportProgressCopyWith(_ExportProgress value, $Res Function(_ExportProgress) _then) = __$ExportProgressCopyWithImpl;
@override @useResult
$Res call({
 ExportStatus status, double progress, String? currentStep, String? errorMessage, String? exportFilePath, DateTime? completedAt, Map<ExportCategory, int> itemCounts
});




}
/// @nodoc
class __$ExportProgressCopyWithImpl<$Res>
    implements _$ExportProgressCopyWith<$Res> {
  __$ExportProgressCopyWithImpl(this._self, this._then);

  final _ExportProgress _self;
  final $Res Function(_ExportProgress) _then;

/// Create a copy of ExportProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? progress = null,Object? currentStep = freezed,Object? errorMessage = freezed,Object? exportFilePath = freezed,Object? completedAt = freezed,Object? itemCounts = null,}) {
  return _then(_ExportProgress(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ExportStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,currentStep: freezed == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,exportFilePath: freezed == exportFilePath ? _self.exportFilePath : exportFilePath // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,itemCounts: null == itemCounts ? _self._itemCounts : itemCounts // ignore: cast_nullable_to_non_nullable
as Map<ExportCategory, int>,
  ));
}


}


/// @nodoc
mixin _$ExportedData {

 String get exportId; DateTime get exportedAt; String get appVersion; String get userId; List<Map<String, dynamic>> get workouts; List<Map<String, dynamic>> get templates; List<Map<String, dynamic>> get customExercises; List<Map<String, dynamic>> get bodyMeasurements; List<String> get progressPhotoUrls; List<Map<String, dynamic>> get personalRecords; Map<String, dynamic> get settings; List<Map<String, dynamic>> get achievements;
/// Create a copy of ExportedData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportedDataCopyWith<ExportedData> get copyWith => _$ExportedDataCopyWithImpl<ExportedData>(this as ExportedData, _$identity);

  /// Serializes this ExportedData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportedData&&(identical(other.exportId, exportId) || other.exportId == exportId)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.workouts, workouts)&&const DeepCollectionEquality().equals(other.templates, templates)&&const DeepCollectionEquality().equals(other.customExercises, customExercises)&&const DeepCollectionEquality().equals(other.bodyMeasurements, bodyMeasurements)&&const DeepCollectionEquality().equals(other.progressPhotoUrls, progressPhotoUrls)&&const DeepCollectionEquality().equals(other.personalRecords, personalRecords)&&const DeepCollectionEquality().equals(other.settings, settings)&&const DeepCollectionEquality().equals(other.achievements, achievements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportId,exportedAt,appVersion,userId,const DeepCollectionEquality().hash(workouts),const DeepCollectionEquality().hash(templates),const DeepCollectionEquality().hash(customExercises),const DeepCollectionEquality().hash(bodyMeasurements),const DeepCollectionEquality().hash(progressPhotoUrls),const DeepCollectionEquality().hash(personalRecords),const DeepCollectionEquality().hash(settings),const DeepCollectionEquality().hash(achievements));

@override
String toString() {
  return 'ExportedData(exportId: $exportId, exportedAt: $exportedAt, appVersion: $appVersion, userId: $userId, workouts: $workouts, templates: $templates, customExercises: $customExercises, bodyMeasurements: $bodyMeasurements, progressPhotoUrls: $progressPhotoUrls, personalRecords: $personalRecords, settings: $settings, achievements: $achievements)';
}


}

/// @nodoc
abstract mixin class $ExportedDataCopyWith<$Res>  {
  factory $ExportedDataCopyWith(ExportedData value, $Res Function(ExportedData) _then) = _$ExportedDataCopyWithImpl;
@useResult
$Res call({
 String exportId, DateTime exportedAt, String appVersion, String userId, List<Map<String, dynamic>> workouts, List<Map<String, dynamic>> templates, List<Map<String, dynamic>> customExercises, List<Map<String, dynamic>> bodyMeasurements, List<String> progressPhotoUrls, List<Map<String, dynamic>> personalRecords, Map<String, dynamic> settings, List<Map<String, dynamic>> achievements
});




}
/// @nodoc
class _$ExportedDataCopyWithImpl<$Res>
    implements $ExportedDataCopyWith<$Res> {
  _$ExportedDataCopyWithImpl(this._self, this._then);

  final ExportedData _self;
  final $Res Function(ExportedData) _then;

/// Create a copy of ExportedData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exportId = null,Object? exportedAt = null,Object? appVersion = null,Object? userId = null,Object? workouts = null,Object? templates = null,Object? customExercises = null,Object? bodyMeasurements = null,Object? progressPhotoUrls = null,Object? personalRecords = null,Object? settings = null,Object? achievements = null,}) {
  return _then(_self.copyWith(
exportId: null == exportId ? _self.exportId : exportId // ignore: cast_nullable_to_non_nullable
as String,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,templates: null == templates ? _self.templates : templates // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,customExercises: null == customExercises ? _self.customExercises : customExercises // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,bodyMeasurements: null == bodyMeasurements ? _self.bodyMeasurements : bodyMeasurements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,progressPhotoUrls: null == progressPhotoUrls ? _self.progressPhotoUrls : progressPhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,personalRecords: null == personalRecords ? _self.personalRecords : personalRecords // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportedData].
extension ExportedDataPatterns on ExportedData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportedData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportedData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportedData value)  $default,){
final _that = this;
switch (_that) {
case _ExportedData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportedData value)?  $default,){
final _that = this;
switch (_that) {
case _ExportedData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exportId,  DateTime exportedAt,  String appVersion,  String userId,  List<Map<String, dynamic>> workouts,  List<Map<String, dynamic>> templates,  List<Map<String, dynamic>> customExercises,  List<Map<String, dynamic>> bodyMeasurements,  List<String> progressPhotoUrls,  List<Map<String, dynamic>> personalRecords,  Map<String, dynamic> settings,  List<Map<String, dynamic>> achievements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportedData() when $default != null:
return $default(_that.exportId,_that.exportedAt,_that.appVersion,_that.userId,_that.workouts,_that.templates,_that.customExercises,_that.bodyMeasurements,_that.progressPhotoUrls,_that.personalRecords,_that.settings,_that.achievements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exportId,  DateTime exportedAt,  String appVersion,  String userId,  List<Map<String, dynamic>> workouts,  List<Map<String, dynamic>> templates,  List<Map<String, dynamic>> customExercises,  List<Map<String, dynamic>> bodyMeasurements,  List<String> progressPhotoUrls,  List<Map<String, dynamic>> personalRecords,  Map<String, dynamic> settings,  List<Map<String, dynamic>> achievements)  $default,) {final _that = this;
switch (_that) {
case _ExportedData():
return $default(_that.exportId,_that.exportedAt,_that.appVersion,_that.userId,_that.workouts,_that.templates,_that.customExercises,_that.bodyMeasurements,_that.progressPhotoUrls,_that.personalRecords,_that.settings,_that.achievements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exportId,  DateTime exportedAt,  String appVersion,  String userId,  List<Map<String, dynamic>> workouts,  List<Map<String, dynamic>> templates,  List<Map<String, dynamic>> customExercises,  List<Map<String, dynamic>> bodyMeasurements,  List<String> progressPhotoUrls,  List<Map<String, dynamic>> personalRecords,  Map<String, dynamic> settings,  List<Map<String, dynamic>> achievements)?  $default,) {final _that = this;
switch (_that) {
case _ExportedData() when $default != null:
return $default(_that.exportId,_that.exportedAt,_that.appVersion,_that.userId,_that.workouts,_that.templates,_that.customExercises,_that.bodyMeasurements,_that.progressPhotoUrls,_that.personalRecords,_that.settings,_that.achievements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportedData implements ExportedData {
  const _ExportedData({required this.exportId, required this.exportedAt, required this.appVersion, required this.userId, final  List<Map<String, dynamic>> workouts = const [], final  List<Map<String, dynamic>> templates = const [], final  List<Map<String, dynamic>> customExercises = const [], final  List<Map<String, dynamic>> bodyMeasurements = const [], final  List<String> progressPhotoUrls = const [], final  List<Map<String, dynamic>> personalRecords = const [], final  Map<String, dynamic> settings = const {}, final  List<Map<String, dynamic>> achievements = const []}): _workouts = workouts,_templates = templates,_customExercises = customExercises,_bodyMeasurements = bodyMeasurements,_progressPhotoUrls = progressPhotoUrls,_personalRecords = personalRecords,_settings = settings,_achievements = achievements;
  factory _ExportedData.fromJson(Map<String, dynamic> json) => _$ExportedDataFromJson(json);

@override final  String exportId;
@override final  DateTime exportedAt;
@override final  String appVersion;
@override final  String userId;
 final  List<Map<String, dynamic>> _workouts;
@override@JsonKey() List<Map<String, dynamic>> get workouts {
  if (_workouts is EqualUnmodifiableListView) return _workouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workouts);
}

 final  List<Map<String, dynamic>> _templates;
@override@JsonKey() List<Map<String, dynamic>> get templates {
  if (_templates is EqualUnmodifiableListView) return _templates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_templates);
}

 final  List<Map<String, dynamic>> _customExercises;
@override@JsonKey() List<Map<String, dynamic>> get customExercises {
  if (_customExercises is EqualUnmodifiableListView) return _customExercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customExercises);
}

 final  List<Map<String, dynamic>> _bodyMeasurements;
@override@JsonKey() List<Map<String, dynamic>> get bodyMeasurements {
  if (_bodyMeasurements is EqualUnmodifiableListView) return _bodyMeasurements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bodyMeasurements);
}

 final  List<String> _progressPhotoUrls;
@override@JsonKey() List<String> get progressPhotoUrls {
  if (_progressPhotoUrls is EqualUnmodifiableListView) return _progressPhotoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_progressPhotoUrls);
}

 final  List<Map<String, dynamic>> _personalRecords;
@override@JsonKey() List<Map<String, dynamic>> get personalRecords {
  if (_personalRecords is EqualUnmodifiableListView) return _personalRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personalRecords);
}

 final  Map<String, dynamic> _settings;
@override@JsonKey() Map<String, dynamic> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}

 final  List<Map<String, dynamic>> _achievements;
@override@JsonKey() List<Map<String, dynamic>> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}


/// Create a copy of ExportedData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportedDataCopyWith<_ExportedData> get copyWith => __$ExportedDataCopyWithImpl<_ExportedData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportedDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportedData&&(identical(other.exportId, exportId) || other.exportId == exportId)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.appVersion, appVersion) || other.appVersion == appVersion)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._workouts, _workouts)&&const DeepCollectionEquality().equals(other._templates, _templates)&&const DeepCollectionEquality().equals(other._customExercises, _customExercises)&&const DeepCollectionEquality().equals(other._bodyMeasurements, _bodyMeasurements)&&const DeepCollectionEquality().equals(other._progressPhotoUrls, _progressPhotoUrls)&&const DeepCollectionEquality().equals(other._personalRecords, _personalRecords)&&const DeepCollectionEquality().equals(other._settings, _settings)&&const DeepCollectionEquality().equals(other._achievements, _achievements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exportId,exportedAt,appVersion,userId,const DeepCollectionEquality().hash(_workouts),const DeepCollectionEquality().hash(_templates),const DeepCollectionEquality().hash(_customExercises),const DeepCollectionEquality().hash(_bodyMeasurements),const DeepCollectionEquality().hash(_progressPhotoUrls),const DeepCollectionEquality().hash(_personalRecords),const DeepCollectionEquality().hash(_settings),const DeepCollectionEquality().hash(_achievements));

@override
String toString() {
  return 'ExportedData(exportId: $exportId, exportedAt: $exportedAt, appVersion: $appVersion, userId: $userId, workouts: $workouts, templates: $templates, customExercises: $customExercises, bodyMeasurements: $bodyMeasurements, progressPhotoUrls: $progressPhotoUrls, personalRecords: $personalRecords, settings: $settings, achievements: $achievements)';
}


}

/// @nodoc
abstract mixin class _$ExportedDataCopyWith<$Res> implements $ExportedDataCopyWith<$Res> {
  factory _$ExportedDataCopyWith(_ExportedData value, $Res Function(_ExportedData) _then) = __$ExportedDataCopyWithImpl;
@override @useResult
$Res call({
 String exportId, DateTime exportedAt, String appVersion, String userId, List<Map<String, dynamic>> workouts, List<Map<String, dynamic>> templates, List<Map<String, dynamic>> customExercises, List<Map<String, dynamic>> bodyMeasurements, List<String> progressPhotoUrls, List<Map<String, dynamic>> personalRecords, Map<String, dynamic> settings, List<Map<String, dynamic>> achievements
});




}
/// @nodoc
class __$ExportedDataCopyWithImpl<$Res>
    implements _$ExportedDataCopyWith<$Res> {
  __$ExportedDataCopyWithImpl(this._self, this._then);

  final _ExportedData _self;
  final $Res Function(_ExportedData) _then;

/// Create a copy of ExportedData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exportId = null,Object? exportedAt = null,Object? appVersion = null,Object? userId = null,Object? workouts = null,Object? templates = null,Object? customExercises = null,Object? bodyMeasurements = null,Object? progressPhotoUrls = null,Object? personalRecords = null,Object? settings = null,Object? achievements = null,}) {
  return _then(_ExportedData(
exportId: null == exportId ? _self.exportId : exportId // ignore: cast_nullable_to_non_nullable
as String,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,appVersion: null == appVersion ? _self.appVersion : appVersion // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,workouts: null == workouts ? _self._workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,templates: null == templates ? _self._templates : templates // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,customExercises: null == customExercises ? _self._customExercises : customExercises // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,bodyMeasurements: null == bodyMeasurements ? _self._bodyMeasurements : bodyMeasurements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,progressPhotoUrls: null == progressPhotoUrls ? _self._progressPhotoUrls : progressPhotoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,personalRecords: null == personalRecords ? _self._personalRecords : personalRecords // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
