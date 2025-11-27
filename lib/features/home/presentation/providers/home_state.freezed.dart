// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 String get greeting; WorkoutSection get workoutSection; AICoachSection get aiCoachSection; StreakSection get streakSection; LoadingPhase get loadingPhase; Map<String, Duration> get sectionLoadTimes; DateTime? get lastRefresh; bool get hasError; String? get errorMessage;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.workoutSection, workoutSection) || other.workoutSection == workoutSection)&&(identical(other.aiCoachSection, aiCoachSection) || other.aiCoachSection == aiCoachSection)&&(identical(other.streakSection, streakSection) || other.streakSection == streakSection)&&(identical(other.loadingPhase, loadingPhase) || other.loadingPhase == loadingPhase)&&const DeepCollectionEquality().equals(other.sectionLoadTimes, sectionLoadTimes)&&(identical(other.lastRefresh, lastRefresh) || other.lastRefresh == lastRefresh)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,greeting,workoutSection,aiCoachSection,streakSection,loadingPhase,const DeepCollectionEquality().hash(sectionLoadTimes),lastRefresh,hasError,errorMessage);

@override
String toString() {
  return 'HomeState(greeting: $greeting, workoutSection: $workoutSection, aiCoachSection: $aiCoachSection, streakSection: $streakSection, loadingPhase: $loadingPhase, sectionLoadTimes: $sectionLoadTimes, lastRefresh: $lastRefresh, hasError: $hasError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 String greeting, WorkoutSection workoutSection, AICoachSection aiCoachSection, StreakSection streakSection, LoadingPhase loadingPhase, Map<String, Duration> sectionLoadTimes, DateTime? lastRefresh, bool hasError, String? errorMessage
});


$WorkoutSectionCopyWith<$Res> get workoutSection;$AICoachSectionCopyWith<$Res> get aiCoachSection;$StreakSectionCopyWith<$Res> get streakSection;

}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? greeting = null,Object? workoutSection = null,Object? aiCoachSection = null,Object? streakSection = null,Object? loadingPhase = null,Object? sectionLoadTimes = null,Object? lastRefresh = freezed,Object? hasError = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
greeting: null == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String,workoutSection: null == workoutSection ? _self.workoutSection : workoutSection // ignore: cast_nullable_to_non_nullable
as WorkoutSection,aiCoachSection: null == aiCoachSection ? _self.aiCoachSection : aiCoachSection // ignore: cast_nullable_to_non_nullable
as AICoachSection,streakSection: null == streakSection ? _self.streakSection : streakSection // ignore: cast_nullable_to_non_nullable
as StreakSection,loadingPhase: null == loadingPhase ? _self.loadingPhase : loadingPhase // ignore: cast_nullable_to_non_nullable
as LoadingPhase,sectionLoadTimes: null == sectionLoadTimes ? _self.sectionLoadTimes : sectionLoadTimes // ignore: cast_nullable_to_non_nullable
as Map<String, Duration>,lastRefresh: freezed == lastRefresh ? _self.lastRefresh : lastRefresh // ignore: cast_nullable_to_non_nullable
as DateTime?,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSectionCopyWith<$Res> get workoutSection {
  
  return $WorkoutSectionCopyWith<$Res>(_self.workoutSection, (value) {
    return _then(_self.copyWith(workoutSection: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AICoachSectionCopyWith<$Res> get aiCoachSection {
  
  return $AICoachSectionCopyWith<$Res>(_self.aiCoachSection, (value) {
    return _then(_self.copyWith(aiCoachSection: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakSectionCopyWith<$Res> get streakSection {
  
  return $StreakSectionCopyWith<$Res>(_self.streakSection, (value) {
    return _then(_self.copyWith(streakSection: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String greeting,  WorkoutSection workoutSection,  AICoachSection aiCoachSection,  StreakSection streakSection,  LoadingPhase loadingPhase,  Map<String, Duration> sectionLoadTimes,  DateTime? lastRefresh,  bool hasError,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.greeting,_that.workoutSection,_that.aiCoachSection,_that.streakSection,_that.loadingPhase,_that.sectionLoadTimes,_that.lastRefresh,_that.hasError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String greeting,  WorkoutSection workoutSection,  AICoachSection aiCoachSection,  StreakSection streakSection,  LoadingPhase loadingPhase,  Map<String, Duration> sectionLoadTimes,  DateTime? lastRefresh,  bool hasError,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.greeting,_that.workoutSection,_that.aiCoachSection,_that.streakSection,_that.loadingPhase,_that.sectionLoadTimes,_that.lastRefresh,_that.hasError,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String greeting,  WorkoutSection workoutSection,  AICoachSection aiCoachSection,  StreakSection streakSection,  LoadingPhase loadingPhase,  Map<String, Duration> sectionLoadTimes,  DateTime? lastRefresh,  bool hasError,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.greeting,_that.workoutSection,_that.aiCoachSection,_that.streakSection,_that.loadingPhase,_that.sectionLoadTimes,_that.lastRefresh,_that.hasError,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({required this.greeting, required this.workoutSection, required this.aiCoachSection, required this.streakSection, this.loadingPhase = LoadingPhase.initial, final  Map<String, Duration> sectionLoadTimes = const {}, this.lastRefresh, this.hasError = false, this.errorMessage}): _sectionLoadTimes = sectionLoadTimes;
  

@override final  String greeting;
@override final  WorkoutSection workoutSection;
@override final  AICoachSection aiCoachSection;
@override final  StreakSection streakSection;
@override@JsonKey() final  LoadingPhase loadingPhase;
 final  Map<String, Duration> _sectionLoadTimes;
@override@JsonKey() Map<String, Duration> get sectionLoadTimes {
  if (_sectionLoadTimes is EqualUnmodifiableMapView) return _sectionLoadTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sectionLoadTimes);
}

@override final  DateTime? lastRefresh;
@override@JsonKey() final  bool hasError;
@override final  String? errorMessage;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.workoutSection, workoutSection) || other.workoutSection == workoutSection)&&(identical(other.aiCoachSection, aiCoachSection) || other.aiCoachSection == aiCoachSection)&&(identical(other.streakSection, streakSection) || other.streakSection == streakSection)&&(identical(other.loadingPhase, loadingPhase) || other.loadingPhase == loadingPhase)&&const DeepCollectionEquality().equals(other._sectionLoadTimes, _sectionLoadTimes)&&(identical(other.lastRefresh, lastRefresh) || other.lastRefresh == lastRefresh)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,greeting,workoutSection,aiCoachSection,streakSection,loadingPhase,const DeepCollectionEquality().hash(_sectionLoadTimes),lastRefresh,hasError,errorMessage);

@override
String toString() {
  return 'HomeState(greeting: $greeting, workoutSection: $workoutSection, aiCoachSection: $aiCoachSection, streakSection: $streakSection, loadingPhase: $loadingPhase, sectionLoadTimes: $sectionLoadTimes, lastRefresh: $lastRefresh, hasError: $hasError, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 String greeting, WorkoutSection workoutSection, AICoachSection aiCoachSection, StreakSection streakSection, LoadingPhase loadingPhase, Map<String, Duration> sectionLoadTimes, DateTime? lastRefresh, bool hasError, String? errorMessage
});


@override $WorkoutSectionCopyWith<$Res> get workoutSection;@override $AICoachSectionCopyWith<$Res> get aiCoachSection;@override $StreakSectionCopyWith<$Res> get streakSection;

}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? greeting = null,Object? workoutSection = null,Object? aiCoachSection = null,Object? streakSection = null,Object? loadingPhase = null,Object? sectionLoadTimes = null,Object? lastRefresh = freezed,Object? hasError = null,Object? errorMessage = freezed,}) {
  return _then(_HomeState(
greeting: null == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String,workoutSection: null == workoutSection ? _self.workoutSection : workoutSection // ignore: cast_nullable_to_non_nullable
as WorkoutSection,aiCoachSection: null == aiCoachSection ? _self.aiCoachSection : aiCoachSection // ignore: cast_nullable_to_non_nullable
as AICoachSection,streakSection: null == streakSection ? _self.streakSection : streakSection // ignore: cast_nullable_to_non_nullable
as StreakSection,loadingPhase: null == loadingPhase ? _self.loadingPhase : loadingPhase // ignore: cast_nullable_to_non_nullable
as LoadingPhase,sectionLoadTimes: null == sectionLoadTimes ? _self._sectionLoadTimes : sectionLoadTimes // ignore: cast_nullable_to_non_nullable
as Map<String, Duration>,lastRefresh: freezed == lastRefresh ? _self.lastRefresh : lastRefresh // ignore: cast_nullable_to_non_nullable
as DateTime?,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkoutSectionCopyWith<$Res> get workoutSection {
  
  return $WorkoutSectionCopyWith<$Res>(_self.workoutSection, (value) {
    return _then(_self.copyWith(workoutSection: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AICoachSectionCopyWith<$Res> get aiCoachSection {
  
  return $AICoachSectionCopyWith<$Res>(_self.aiCoachSection, (value) {
    return _then(_self.copyWith(aiCoachSection: value));
  });
}/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakSectionCopyWith<$Res> get streakSection {
  
  return $StreakSectionCopyWith<$Res>(_self.streakSection, (value) {
    return _then(_self.copyWith(streakSection: value));
  });
}
}

/// @nodoc
mixin _$WorkoutSection {

 bool get hasActiveWorkout; String? get workoutName; double? get progress; int? get exercisesCompleted; int? get totalExercises;
/// Create a copy of WorkoutSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSectionCopyWith<WorkoutSection> get copyWith => _$WorkoutSectionCopyWithImpl<WorkoutSection>(this as WorkoutSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSection&&(identical(other.hasActiveWorkout, hasActiveWorkout) || other.hasActiveWorkout == hasActiveWorkout)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.exercisesCompleted, exercisesCompleted) || other.exercisesCompleted == exercisesCompleted)&&(identical(other.totalExercises, totalExercises) || other.totalExercises == totalExercises));
}


@override
int get hashCode => Object.hash(runtimeType,hasActiveWorkout,workoutName,progress,exercisesCompleted,totalExercises);

@override
String toString() {
  return 'WorkoutSection(hasActiveWorkout: $hasActiveWorkout, workoutName: $workoutName, progress: $progress, exercisesCompleted: $exercisesCompleted, totalExercises: $totalExercises)';
}


}

/// @nodoc
abstract mixin class $WorkoutSectionCopyWith<$Res>  {
  factory $WorkoutSectionCopyWith(WorkoutSection value, $Res Function(WorkoutSection) _then) = _$WorkoutSectionCopyWithImpl;
@useResult
$Res call({
 bool hasActiveWorkout, String? workoutName, double? progress, int? exercisesCompleted, int? totalExercises
});




}
/// @nodoc
class _$WorkoutSectionCopyWithImpl<$Res>
    implements $WorkoutSectionCopyWith<$Res> {
  _$WorkoutSectionCopyWithImpl(this._self, this._then);

  final WorkoutSection _self;
  final $Res Function(WorkoutSection) _then;

/// Create a copy of WorkoutSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasActiveWorkout = null,Object? workoutName = freezed,Object? progress = freezed,Object? exercisesCompleted = freezed,Object? totalExercises = freezed,}) {
  return _then(_self.copyWith(
hasActiveWorkout: null == hasActiveWorkout ? _self.hasActiveWorkout : hasActiveWorkout // ignore: cast_nullable_to_non_nullable
as bool,workoutName: freezed == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,exercisesCompleted: freezed == exercisesCompleted ? _self.exercisesCompleted : exercisesCompleted // ignore: cast_nullable_to_non_nullable
as int?,totalExercises: freezed == totalExercises ? _self.totalExercises : totalExercises // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSection].
extension WorkoutSectionPatterns on WorkoutSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSection value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSection value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasActiveWorkout,  String? workoutName,  double? progress,  int? exercisesCompleted,  int? totalExercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSection() when $default != null:
return $default(_that.hasActiveWorkout,_that.workoutName,_that.progress,_that.exercisesCompleted,_that.totalExercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasActiveWorkout,  String? workoutName,  double? progress,  int? exercisesCompleted,  int? totalExercises)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSection():
return $default(_that.hasActiveWorkout,_that.workoutName,_that.progress,_that.exercisesCompleted,_that.totalExercises);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasActiveWorkout,  String? workoutName,  double? progress,  int? exercisesCompleted,  int? totalExercises)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSection() when $default != null:
return $default(_that.hasActiveWorkout,_that.workoutName,_that.progress,_that.exercisesCompleted,_that.totalExercises);case _:
  return null;

}
}

}

/// @nodoc


class _WorkoutSection extends WorkoutSection {
  const _WorkoutSection({required this.hasActiveWorkout, this.workoutName, this.progress, this.exercisesCompleted, this.totalExercises}): super._();
  

@override final  bool hasActiveWorkout;
@override final  String? workoutName;
@override final  double? progress;
@override final  int? exercisesCompleted;
@override final  int? totalExercises;

/// Create a copy of WorkoutSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSectionCopyWith<_WorkoutSection> get copyWith => __$WorkoutSectionCopyWithImpl<_WorkoutSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSection&&(identical(other.hasActiveWorkout, hasActiveWorkout) || other.hasActiveWorkout == hasActiveWorkout)&&(identical(other.workoutName, workoutName) || other.workoutName == workoutName)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.exercisesCompleted, exercisesCompleted) || other.exercisesCompleted == exercisesCompleted)&&(identical(other.totalExercises, totalExercises) || other.totalExercises == totalExercises));
}


@override
int get hashCode => Object.hash(runtimeType,hasActiveWorkout,workoutName,progress,exercisesCompleted,totalExercises);

@override
String toString() {
  return 'WorkoutSection(hasActiveWorkout: $hasActiveWorkout, workoutName: $workoutName, progress: $progress, exercisesCompleted: $exercisesCompleted, totalExercises: $totalExercises)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSectionCopyWith<$Res> implements $WorkoutSectionCopyWith<$Res> {
  factory _$WorkoutSectionCopyWith(_WorkoutSection value, $Res Function(_WorkoutSection) _then) = __$WorkoutSectionCopyWithImpl;
@override @useResult
$Res call({
 bool hasActiveWorkout, String? workoutName, double? progress, int? exercisesCompleted, int? totalExercises
});




}
/// @nodoc
class __$WorkoutSectionCopyWithImpl<$Res>
    implements _$WorkoutSectionCopyWith<$Res> {
  __$WorkoutSectionCopyWithImpl(this._self, this._then);

  final _WorkoutSection _self;
  final $Res Function(_WorkoutSection) _then;

/// Create a copy of WorkoutSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasActiveWorkout = null,Object? workoutName = freezed,Object? progress = freezed,Object? exercisesCompleted = freezed,Object? totalExercises = freezed,}) {
  return _then(_WorkoutSection(
hasActiveWorkout: null == hasActiveWorkout ? _self.hasActiveWorkout : hasActiveWorkout // ignore: cast_nullable_to_non_nullable
as bool,workoutName: freezed == workoutName ? _self.workoutName : workoutName // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,exercisesCompleted: freezed == exercisesCompleted ? _self.exercisesCompleted : exercisesCompleted // ignore: cast_nullable_to_non_nullable
as int?,totalExercises: freezed == totalExercises ? _self.totalExercises : totalExercises // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$AICoachSection {

 String get message; String? get suggestion; String? get imageUrl;
/// Create a copy of AICoachSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AICoachSectionCopyWith<AICoachSection> get copyWith => _$AICoachSectionCopyWithImpl<AICoachSection>(this as AICoachSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AICoachSection&&(identical(other.message, message) || other.message == message)&&(identical(other.suggestion, suggestion) || other.suggestion == suggestion)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,message,suggestion,imageUrl);

@override
String toString() {
  return 'AICoachSection(message: $message, suggestion: $suggestion, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $AICoachSectionCopyWith<$Res>  {
  factory $AICoachSectionCopyWith(AICoachSection value, $Res Function(AICoachSection) _then) = _$AICoachSectionCopyWithImpl;
@useResult
$Res call({
 String message, String? suggestion, String? imageUrl
});




}
/// @nodoc
class _$AICoachSectionCopyWithImpl<$Res>
    implements $AICoachSectionCopyWith<$Res> {
  _$AICoachSectionCopyWithImpl(this._self, this._then);

  final AICoachSection _self;
  final $Res Function(AICoachSection) _then;

/// Create a copy of AICoachSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? suggestion = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AICoachSection].
extension AICoachSectionPatterns on AICoachSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AICoachSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AICoachSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AICoachSection value)  $default,){
final _that = this;
switch (_that) {
case _AICoachSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AICoachSection value)?  $default,){
final _that = this;
switch (_that) {
case _AICoachSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  String? suggestion,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AICoachSection() when $default != null:
return $default(_that.message,_that.suggestion,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  String? suggestion,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _AICoachSection():
return $default(_that.message,_that.suggestion,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  String? suggestion,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _AICoachSection() when $default != null:
return $default(_that.message,_that.suggestion,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _AICoachSection extends AICoachSection {
  const _AICoachSection({required this.message, this.suggestion, this.imageUrl}): super._();
  

@override final  String message;
@override final  String? suggestion;
@override final  String? imageUrl;

/// Create a copy of AICoachSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AICoachSectionCopyWith<_AICoachSection> get copyWith => __$AICoachSectionCopyWithImpl<_AICoachSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AICoachSection&&(identical(other.message, message) || other.message == message)&&(identical(other.suggestion, suggestion) || other.suggestion == suggestion)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,message,suggestion,imageUrl);

@override
String toString() {
  return 'AICoachSection(message: $message, suggestion: $suggestion, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$AICoachSectionCopyWith<$Res> implements $AICoachSectionCopyWith<$Res> {
  factory _$AICoachSectionCopyWith(_AICoachSection value, $Res Function(_AICoachSection) _then) = __$AICoachSectionCopyWithImpl;
@override @useResult
$Res call({
 String message, String? suggestion, String? imageUrl
});




}
/// @nodoc
class __$AICoachSectionCopyWithImpl<$Res>
    implements _$AICoachSectionCopyWith<$Res> {
  __$AICoachSectionCopyWithImpl(this._self, this._then);

  final _AICoachSection _self;
  final $Res Function(_AICoachSection) _then;

/// Create a copy of AICoachSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? suggestion = freezed,Object? imageUrl = freezed,}) {
  return _then(_AICoachSection(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,suggestion: freezed == suggestion ? _self.suggestion : suggestion // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$StreakSection {

 int get currentStreak; int get bestStreak; DateTime? get lastWorkoutDate;
/// Create a copy of StreakSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakSectionCopyWith<StreakSection> get copyWith => _$StreakSectionCopyWithImpl<StreakSection>(this as StreakSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakSection&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,bestStreak,lastWorkoutDate);

@override
String toString() {
  return 'StreakSection(currentStreak: $currentStreak, bestStreak: $bestStreak, lastWorkoutDate: $lastWorkoutDate)';
}


}

/// @nodoc
abstract mixin class $StreakSectionCopyWith<$Res>  {
  factory $StreakSectionCopyWith(StreakSection value, $Res Function(StreakSection) _then) = _$StreakSectionCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int bestStreak, DateTime? lastWorkoutDate
});




}
/// @nodoc
class _$StreakSectionCopyWithImpl<$Res>
    implements $StreakSectionCopyWith<$Res> {
  _$StreakSectionCopyWithImpl(this._self, this._then);

  final StreakSection _self;
  final $Res Function(StreakSection) _then;

/// Create a copy of StreakSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? bestStreak = null,Object? lastWorkoutDate = freezed,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakSection].
extension StreakSectionPatterns on StreakSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakSection value)  $default,){
final _that = this;
switch (_that) {
case _StreakSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakSection value)?  $default,){
final _that = this;
switch (_that) {
case _StreakSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int bestStreak,  DateTime? lastWorkoutDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakSection() when $default != null:
return $default(_that.currentStreak,_that.bestStreak,_that.lastWorkoutDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int bestStreak,  DateTime? lastWorkoutDate)  $default,) {final _that = this;
switch (_that) {
case _StreakSection():
return $default(_that.currentStreak,_that.bestStreak,_that.lastWorkoutDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int bestStreak,  DateTime? lastWorkoutDate)?  $default,) {final _that = this;
switch (_that) {
case _StreakSection() when $default != null:
return $default(_that.currentStreak,_that.bestStreak,_that.lastWorkoutDate);case _:
  return null;

}
}

}

/// @nodoc


class _StreakSection extends StreakSection {
  const _StreakSection({required this.currentStreak, required this.bestStreak, this.lastWorkoutDate}): super._();
  

@override final  int currentStreak;
@override final  int bestStreak;
@override final  DateTime? lastWorkoutDate;

/// Create a copy of StreakSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakSectionCopyWith<_StreakSection> get copyWith => __$StreakSectionCopyWithImpl<_StreakSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakSection&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate));
}


@override
int get hashCode => Object.hash(runtimeType,currentStreak,bestStreak,lastWorkoutDate);

@override
String toString() {
  return 'StreakSection(currentStreak: $currentStreak, bestStreak: $bestStreak, lastWorkoutDate: $lastWorkoutDate)';
}


}

/// @nodoc
abstract mixin class _$StreakSectionCopyWith<$Res> implements $StreakSectionCopyWith<$Res> {
  factory _$StreakSectionCopyWith(_StreakSection value, $Res Function(_StreakSection) _then) = __$StreakSectionCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int bestStreak, DateTime? lastWorkoutDate
});




}
/// @nodoc
class __$StreakSectionCopyWithImpl<$Res>
    implements _$StreakSectionCopyWith<$Res> {
  __$StreakSectionCopyWithImpl(this._self, this._then);

  final _StreakSection _self;
  final $Res Function(_StreakSection) _then;

/// Create a copy of StreakSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? bestStreak = null,Object? lastWorkoutDate = freezed,}) {
  return _then(_StreakSection(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
