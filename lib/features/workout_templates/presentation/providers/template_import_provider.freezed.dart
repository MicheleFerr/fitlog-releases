// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_import_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateImportState {

 List<ImportParsingResult> get parsingResults; List<ExerciseDisambiguation> get exerciseDisambiguations; List<PercentageConversion> get percentageConversions; List<ImportWarning> get warnings; List<ImportError> get errors; double get progress; String? get currentStep; ImportPhase? get currentPhase; List<WorkoutTemplateImportData> get finalTemplates;
/// Create a copy of TemplateImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateImportStateCopyWith<TemplateImportState> get copyWith => _$TemplateImportStateCopyWithImpl<TemplateImportState>(this as TemplateImportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateImportState&&const DeepCollectionEquality().equals(other.parsingResults, parsingResults)&&const DeepCollectionEquality().equals(other.exerciseDisambiguations, exerciseDisambiguations)&&const DeepCollectionEquality().equals(other.percentageConversions, percentageConversions)&&const DeepCollectionEquality().equals(other.warnings, warnings)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&const DeepCollectionEquality().equals(other.finalTemplates, finalTemplates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(parsingResults),const DeepCollectionEquality().hash(exerciseDisambiguations),const DeepCollectionEquality().hash(percentageConversions),const DeepCollectionEquality().hash(warnings),const DeepCollectionEquality().hash(errors),progress,currentStep,currentPhase,const DeepCollectionEquality().hash(finalTemplates));

@override
String toString() {
  return 'TemplateImportState(parsingResults: $parsingResults, exerciseDisambiguations: $exerciseDisambiguations, percentageConversions: $percentageConversions, warnings: $warnings, errors: $errors, progress: $progress, currentStep: $currentStep, currentPhase: $currentPhase, finalTemplates: $finalTemplates)';
}


}

/// @nodoc
abstract mixin class $TemplateImportStateCopyWith<$Res>  {
  factory $TemplateImportStateCopyWith(TemplateImportState value, $Res Function(TemplateImportState) _then) = _$TemplateImportStateCopyWithImpl;
@useResult
$Res call({
 List<ImportParsingResult> parsingResults, List<ExerciseDisambiguation> exerciseDisambiguations, List<PercentageConversion> percentageConversions, List<ImportWarning> warnings, List<ImportError> errors, double progress, String? currentStep, ImportPhase? currentPhase, List<WorkoutTemplateImportData> finalTemplates
});




}
/// @nodoc
class _$TemplateImportStateCopyWithImpl<$Res>
    implements $TemplateImportStateCopyWith<$Res> {
  _$TemplateImportStateCopyWithImpl(this._self, this._then);

  final TemplateImportState _self;
  final $Res Function(TemplateImportState) _then;

/// Create a copy of TemplateImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? parsingResults = null,Object? exerciseDisambiguations = null,Object? percentageConversions = null,Object? warnings = null,Object? errors = null,Object? progress = null,Object? currentStep = freezed,Object? currentPhase = freezed,Object? finalTemplates = null,}) {
  return _then(_self.copyWith(
parsingResults: null == parsingResults ? _self.parsingResults : parsingResults // ignore: cast_nullable_to_non_nullable
as List<ImportParsingResult>,exerciseDisambiguations: null == exerciseDisambiguations ? _self.exerciseDisambiguations : exerciseDisambiguations // ignore: cast_nullable_to_non_nullable
as List<ExerciseDisambiguation>,percentageConversions: null == percentageConversions ? _self.percentageConversions : percentageConversions // ignore: cast_nullable_to_non_nullable
as List<PercentageConversion>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ImportWarning>,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<ImportError>,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,currentStep: freezed == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String?,currentPhase: freezed == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as ImportPhase?,finalTemplates: null == finalTemplates ? _self.finalTemplates : finalTemplates // ignore: cast_nullable_to_non_nullable
as List<WorkoutTemplateImportData>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateImportState].
extension TemplateImportStatePatterns on TemplateImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateImportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateImportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateImportState value)  $default,){
final _that = this;
switch (_that) {
case _TemplateImportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateImportState value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateImportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ImportParsingResult> parsingResults,  List<ExerciseDisambiguation> exerciseDisambiguations,  List<PercentageConversion> percentageConversions,  List<ImportWarning> warnings,  List<ImportError> errors,  double progress,  String? currentStep,  ImportPhase? currentPhase,  List<WorkoutTemplateImportData> finalTemplates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateImportState() when $default != null:
return $default(_that.parsingResults,_that.exerciseDisambiguations,_that.percentageConversions,_that.warnings,_that.errors,_that.progress,_that.currentStep,_that.currentPhase,_that.finalTemplates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ImportParsingResult> parsingResults,  List<ExerciseDisambiguation> exerciseDisambiguations,  List<PercentageConversion> percentageConversions,  List<ImportWarning> warnings,  List<ImportError> errors,  double progress,  String? currentStep,  ImportPhase? currentPhase,  List<WorkoutTemplateImportData> finalTemplates)  $default,) {final _that = this;
switch (_that) {
case _TemplateImportState():
return $default(_that.parsingResults,_that.exerciseDisambiguations,_that.percentageConversions,_that.warnings,_that.errors,_that.progress,_that.currentStep,_that.currentPhase,_that.finalTemplates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ImportParsingResult> parsingResults,  List<ExerciseDisambiguation> exerciseDisambiguations,  List<PercentageConversion> percentageConversions,  List<ImportWarning> warnings,  List<ImportError> errors,  double progress,  String? currentStep,  ImportPhase? currentPhase,  List<WorkoutTemplateImportData> finalTemplates)?  $default,) {final _that = this;
switch (_that) {
case _TemplateImportState() when $default != null:
return $default(_that.parsingResults,_that.exerciseDisambiguations,_that.percentageConversions,_that.warnings,_that.errors,_that.progress,_that.currentStep,_that.currentPhase,_that.finalTemplates);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateImportState implements TemplateImportState {
  const _TemplateImportState({final  List<ImportParsingResult> parsingResults = const [], final  List<ExerciseDisambiguation> exerciseDisambiguations = const [], final  List<PercentageConversion> percentageConversions = const [], final  List<ImportWarning> warnings = const [], final  List<ImportError> errors = const [], this.progress = 0.0, this.currentStep, this.currentPhase, final  List<WorkoutTemplateImportData> finalTemplates = const []}): _parsingResults = parsingResults,_exerciseDisambiguations = exerciseDisambiguations,_percentageConversions = percentageConversions,_warnings = warnings,_errors = errors,_finalTemplates = finalTemplates;
  

 final  List<ImportParsingResult> _parsingResults;
@override@JsonKey() List<ImportParsingResult> get parsingResults {
  if (_parsingResults is EqualUnmodifiableListView) return _parsingResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parsingResults);
}

 final  List<ExerciseDisambiguation> _exerciseDisambiguations;
@override@JsonKey() List<ExerciseDisambiguation> get exerciseDisambiguations {
  if (_exerciseDisambiguations is EqualUnmodifiableListView) return _exerciseDisambiguations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseDisambiguations);
}

 final  List<PercentageConversion> _percentageConversions;
@override@JsonKey() List<PercentageConversion> get percentageConversions {
  if (_percentageConversions is EqualUnmodifiableListView) return _percentageConversions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_percentageConversions);
}

 final  List<ImportWarning> _warnings;
@override@JsonKey() List<ImportWarning> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}

 final  List<ImportError> _errors;
@override@JsonKey() List<ImportError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

@override@JsonKey() final  double progress;
@override final  String? currentStep;
@override final  ImportPhase? currentPhase;
 final  List<WorkoutTemplateImportData> _finalTemplates;
@override@JsonKey() List<WorkoutTemplateImportData> get finalTemplates {
  if (_finalTemplates is EqualUnmodifiableListView) return _finalTemplates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_finalTemplates);
}


/// Create a copy of TemplateImportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateImportStateCopyWith<_TemplateImportState> get copyWith => __$TemplateImportStateCopyWithImpl<_TemplateImportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateImportState&&const DeepCollectionEquality().equals(other._parsingResults, _parsingResults)&&const DeepCollectionEquality().equals(other._exerciseDisambiguations, _exerciseDisambiguations)&&const DeepCollectionEquality().equals(other._percentageConversions, _percentageConversions)&&const DeepCollectionEquality().equals(other._warnings, _warnings)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&const DeepCollectionEquality().equals(other._finalTemplates, _finalTemplates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_parsingResults),const DeepCollectionEquality().hash(_exerciseDisambiguations),const DeepCollectionEquality().hash(_percentageConversions),const DeepCollectionEquality().hash(_warnings),const DeepCollectionEquality().hash(_errors),progress,currentStep,currentPhase,const DeepCollectionEquality().hash(_finalTemplates));

@override
String toString() {
  return 'TemplateImportState(parsingResults: $parsingResults, exerciseDisambiguations: $exerciseDisambiguations, percentageConversions: $percentageConversions, warnings: $warnings, errors: $errors, progress: $progress, currentStep: $currentStep, currentPhase: $currentPhase, finalTemplates: $finalTemplates)';
}


}

/// @nodoc
abstract mixin class _$TemplateImportStateCopyWith<$Res> implements $TemplateImportStateCopyWith<$Res> {
  factory _$TemplateImportStateCopyWith(_TemplateImportState value, $Res Function(_TemplateImportState) _then) = __$TemplateImportStateCopyWithImpl;
@override @useResult
$Res call({
 List<ImportParsingResult> parsingResults, List<ExerciseDisambiguation> exerciseDisambiguations, List<PercentageConversion> percentageConversions, List<ImportWarning> warnings, List<ImportError> errors, double progress, String? currentStep, ImportPhase? currentPhase, List<WorkoutTemplateImportData> finalTemplates
});




}
/// @nodoc
class __$TemplateImportStateCopyWithImpl<$Res>
    implements _$TemplateImportStateCopyWith<$Res> {
  __$TemplateImportStateCopyWithImpl(this._self, this._then);

  final _TemplateImportState _self;
  final $Res Function(_TemplateImportState) _then;

/// Create a copy of TemplateImportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? parsingResults = null,Object? exerciseDisambiguations = null,Object? percentageConversions = null,Object? warnings = null,Object? errors = null,Object? progress = null,Object? currentStep = freezed,Object? currentPhase = freezed,Object? finalTemplates = null,}) {
  return _then(_TemplateImportState(
parsingResults: null == parsingResults ? _self._parsingResults : parsingResults // ignore: cast_nullable_to_non_nullable
as List<ImportParsingResult>,exerciseDisambiguations: null == exerciseDisambiguations ? _self._exerciseDisambiguations : exerciseDisambiguations // ignore: cast_nullable_to_non_nullable
as List<ExerciseDisambiguation>,percentageConversions: null == percentageConversions ? _self._percentageConversions : percentageConversions // ignore: cast_nullable_to_non_nullable
as List<PercentageConversion>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<ImportWarning>,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<ImportError>,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,currentStep: freezed == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String?,currentPhase: freezed == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as ImportPhase?,finalTemplates: null == finalTemplates ? _self._finalTemplates : finalTemplates // ignore: cast_nullable_to_non_nullable
as List<WorkoutTemplateImportData>,
  ));
}


}

// dart format on
