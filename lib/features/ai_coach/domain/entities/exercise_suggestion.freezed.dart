// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SuggestedQuestion {

/// Short text displayed in the suggestion dropdown
 String get displayText;/// Full question to send to the AI Coach
 String get fullQuestion;/// Icon displayed next to the question
 IconData get icon;
/// Create a copy of SuggestedQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedQuestionCopyWith<SuggestedQuestion> get copyWith => _$SuggestedQuestionCopyWithImpl<SuggestedQuestion>(this as SuggestedQuestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedQuestion&&(identical(other.displayText, displayText) || other.displayText == displayText)&&(identical(other.fullQuestion, fullQuestion) || other.fullQuestion == fullQuestion)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,displayText,fullQuestion,icon);

@override
String toString() {
  return 'SuggestedQuestion(displayText: $displayText, fullQuestion: $fullQuestion, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $SuggestedQuestionCopyWith<$Res>  {
  factory $SuggestedQuestionCopyWith(SuggestedQuestion value, $Res Function(SuggestedQuestion) _then) = _$SuggestedQuestionCopyWithImpl;
@useResult
$Res call({
 String displayText, String fullQuestion, IconData icon
});




}
/// @nodoc
class _$SuggestedQuestionCopyWithImpl<$Res>
    implements $SuggestedQuestionCopyWith<$Res> {
  _$SuggestedQuestionCopyWithImpl(this._self, this._then);

  final SuggestedQuestion _self;
  final $Res Function(SuggestedQuestion) _then;

/// Create a copy of SuggestedQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayText = null,Object? fullQuestion = null,Object? icon = null,}) {
  return _then(_self.copyWith(
displayText: null == displayText ? _self.displayText : displayText // ignore: cast_nullable_to_non_nullable
as String,fullQuestion: null == fullQuestion ? _self.fullQuestion : fullQuestion // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestedQuestion].
extension SuggestedQuestionPatterns on SuggestedQuestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedQuestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedQuestion value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedQuestion():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedQuestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayText,  String fullQuestion,  IconData icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedQuestion() when $default != null:
return $default(_that.displayText,_that.fullQuestion,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayText,  String fullQuestion,  IconData icon)  $default,) {final _that = this;
switch (_that) {
case _SuggestedQuestion():
return $default(_that.displayText,_that.fullQuestion,_that.icon);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayText,  String fullQuestion,  IconData icon)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedQuestion() when $default != null:
return $default(_that.displayText,_that.fullQuestion,_that.icon);case _:
  return null;

}
}

}

/// @nodoc


class _SuggestedQuestion implements SuggestedQuestion {
  const _SuggestedQuestion({required this.displayText, required this.fullQuestion, required this.icon});
  

/// Short text displayed in the suggestion dropdown
@override final  String displayText;
/// Full question to send to the AI Coach
@override final  String fullQuestion;
/// Icon displayed next to the question
@override final  IconData icon;

/// Create a copy of SuggestedQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedQuestionCopyWith<_SuggestedQuestion> get copyWith => __$SuggestedQuestionCopyWithImpl<_SuggestedQuestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedQuestion&&(identical(other.displayText, displayText) || other.displayText == displayText)&&(identical(other.fullQuestion, fullQuestion) || other.fullQuestion == fullQuestion)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,displayText,fullQuestion,icon);

@override
String toString() {
  return 'SuggestedQuestion(displayText: $displayText, fullQuestion: $fullQuestion, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$SuggestedQuestionCopyWith<$Res> implements $SuggestedQuestionCopyWith<$Res> {
  factory _$SuggestedQuestionCopyWith(_SuggestedQuestion value, $Res Function(_SuggestedQuestion) _then) = __$SuggestedQuestionCopyWithImpl;
@override @useResult
$Res call({
 String displayText, String fullQuestion, IconData icon
});




}
/// @nodoc
class __$SuggestedQuestionCopyWithImpl<$Res>
    implements _$SuggestedQuestionCopyWith<$Res> {
  __$SuggestedQuestionCopyWithImpl(this._self, this._then);

  final _SuggestedQuestion _self;
  final $Res Function(_SuggestedQuestion) _then;

/// Create a copy of SuggestedQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayText = null,Object? fullQuestion = null,Object? icon = null,}) {
  return _then(_SuggestedQuestion(
displayText: null == displayText ? _self.displayText : displayText // ignore: cast_nullable_to_non_nullable
as String,fullQuestion: null == fullQuestion ? _self.fullQuestion : fullQuestion // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,
  ));
}


}

/// @nodoc
mixin _$ExerciseSuggestion {

/// Exercise name exactly as stored in database
 String get exerciseName;/// Number of sessions recorded for this exercise
 int get sessionCount;/// Date of most recent session (null if no sessions)
 DateTime? get lastSessionDate;/// List of suggested questions for this exercise
 List<SuggestedQuestion> get suggestedQuestions;
/// Create a copy of ExerciseSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseSuggestionCopyWith<ExerciseSuggestion> get copyWith => _$ExerciseSuggestionCopyWithImpl<ExerciseSuggestion>(this as ExerciseSuggestion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseSuggestion&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastSessionDate, lastSessionDate) || other.lastSessionDate == lastSessionDate)&&const DeepCollectionEquality().equals(other.suggestedQuestions, suggestedQuestions));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,sessionCount,lastSessionDate,const DeepCollectionEquality().hash(suggestedQuestions));

@override
String toString() {
  return 'ExerciseSuggestion(exerciseName: $exerciseName, sessionCount: $sessionCount, lastSessionDate: $lastSessionDate, suggestedQuestions: $suggestedQuestions)';
}


}

/// @nodoc
abstract mixin class $ExerciseSuggestionCopyWith<$Res>  {
  factory $ExerciseSuggestionCopyWith(ExerciseSuggestion value, $Res Function(ExerciseSuggestion) _then) = _$ExerciseSuggestionCopyWithImpl;
@useResult
$Res call({
 String exerciseName, int sessionCount, DateTime? lastSessionDate, List<SuggestedQuestion> suggestedQuestions
});




}
/// @nodoc
class _$ExerciseSuggestionCopyWithImpl<$Res>
    implements $ExerciseSuggestionCopyWith<$Res> {
  _$ExerciseSuggestionCopyWithImpl(this._self, this._then);

  final ExerciseSuggestion _self;
  final $Res Function(ExerciseSuggestion) _then;

/// Create a copy of ExerciseSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? sessionCount = null,Object? lastSessionDate = freezed,Object? suggestedQuestions = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastSessionDate: freezed == lastSessionDate ? _self.lastSessionDate : lastSessionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,suggestedQuestions: null == suggestedQuestions ? _self.suggestedQuestions : suggestedQuestions // ignore: cast_nullable_to_non_nullable
as List<SuggestedQuestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseSuggestion].
extension ExerciseSuggestionPatterns on ExerciseSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseSuggestion():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  int sessionCount,  DateTime? lastSessionDate,  List<SuggestedQuestion> suggestedQuestions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseSuggestion() when $default != null:
return $default(_that.exerciseName,_that.sessionCount,_that.lastSessionDate,_that.suggestedQuestions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  int sessionCount,  DateTime? lastSessionDate,  List<SuggestedQuestion> suggestedQuestions)  $default,) {final _that = this;
switch (_that) {
case _ExerciseSuggestion():
return $default(_that.exerciseName,_that.sessionCount,_that.lastSessionDate,_that.suggestedQuestions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  int sessionCount,  DateTime? lastSessionDate,  List<SuggestedQuestion> suggestedQuestions)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseSuggestion() when $default != null:
return $default(_that.exerciseName,_that.sessionCount,_that.lastSessionDate,_that.suggestedQuestions);case _:
  return null;

}
}

}

/// @nodoc


class _ExerciseSuggestion extends ExerciseSuggestion {
  const _ExerciseSuggestion({required this.exerciseName, required this.sessionCount, this.lastSessionDate, required final  List<SuggestedQuestion> suggestedQuestions}): _suggestedQuestions = suggestedQuestions,super._();
  

/// Exercise name exactly as stored in database
@override final  String exerciseName;
/// Number of sessions recorded for this exercise
@override final  int sessionCount;
/// Date of most recent session (null if no sessions)
@override final  DateTime? lastSessionDate;
/// List of suggested questions for this exercise
 final  List<SuggestedQuestion> _suggestedQuestions;
/// List of suggested questions for this exercise
@override List<SuggestedQuestion> get suggestedQuestions {
  if (_suggestedQuestions is EqualUnmodifiableListView) return _suggestedQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedQuestions);
}


/// Create a copy of ExerciseSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseSuggestionCopyWith<_ExerciseSuggestion> get copyWith => __$ExerciseSuggestionCopyWithImpl<_ExerciseSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseSuggestion&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.lastSessionDate, lastSessionDate) || other.lastSessionDate == lastSessionDate)&&const DeepCollectionEquality().equals(other._suggestedQuestions, _suggestedQuestions));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseName,sessionCount,lastSessionDate,const DeepCollectionEquality().hash(_suggestedQuestions));

@override
String toString() {
  return 'ExerciseSuggestion(exerciseName: $exerciseName, sessionCount: $sessionCount, lastSessionDate: $lastSessionDate, suggestedQuestions: $suggestedQuestions)';
}


}

/// @nodoc
abstract mixin class _$ExerciseSuggestionCopyWith<$Res> implements $ExerciseSuggestionCopyWith<$Res> {
  factory _$ExerciseSuggestionCopyWith(_ExerciseSuggestion value, $Res Function(_ExerciseSuggestion) _then) = __$ExerciseSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, int sessionCount, DateTime? lastSessionDate, List<SuggestedQuestion> suggestedQuestions
});




}
/// @nodoc
class __$ExerciseSuggestionCopyWithImpl<$Res>
    implements _$ExerciseSuggestionCopyWith<$Res> {
  __$ExerciseSuggestionCopyWithImpl(this._self, this._then);

  final _ExerciseSuggestion _self;
  final $Res Function(_ExerciseSuggestion) _then;

/// Create a copy of ExerciseSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? sessionCount = null,Object? lastSessionDate = freezed,Object? suggestedQuestions = null,}) {
  return _then(_ExerciseSuggestion(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,lastSessionDate: freezed == lastSessionDate ? _self.lastSessionDate : lastSessionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,suggestedQuestions: null == suggestedQuestions ? _self._suggestedQuestions : suggestedQuestions // ignore: cast_nullable_to_non_nullable
as List<SuggestedQuestion>,
  ));
}


}

// dart format on
