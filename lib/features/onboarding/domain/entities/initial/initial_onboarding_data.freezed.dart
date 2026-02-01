// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'initial_onboarding_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InitialOnboardingData {

// Step 1: Goal
 TrainingGoalUI get goal;// Step 2: Personal Info
 BiologicalSex get sex; int get age;// Step 3: Body data
 double get heightCm; double get bodyweightKg;// Step 4: Experience
 ExperienceLevelUI get experience;// Step 5: HealthKit (tracking only, not persisted)
 bool get healthKitConnected; List<String> get healthKitPermissionsGranted;// Step 5: Frequency
 int get workoutsPerWeek;// Meta
 DateTime? get completedAt;
/// Create a copy of InitialOnboardingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitialOnboardingDataCopyWith<InitialOnboardingData> get copyWith => _$InitialOnboardingDataCopyWithImpl<InitialOnboardingData>(this as InitialOnboardingData, _$identity);

  /// Serializes this InitialOnboardingData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitialOnboardingData&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.age, age) || other.age == age)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.bodyweightKg, bodyweightKg) || other.bodyweightKg == bodyweightKg)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.healthKitConnected, healthKitConnected) || other.healthKitConnected == healthKitConnected)&&const DeepCollectionEquality().equals(other.healthKitPermissionsGranted, healthKitPermissionsGranted)&&(identical(other.workoutsPerWeek, workoutsPerWeek) || other.workoutsPerWeek == workoutsPerWeek)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,goal,sex,age,heightCm,bodyweightKg,experience,healthKitConnected,const DeepCollectionEquality().hash(healthKitPermissionsGranted),workoutsPerWeek,completedAt);

@override
String toString() {
  return 'InitialOnboardingData(goal: $goal, sex: $sex, age: $age, heightCm: $heightCm, bodyweightKg: $bodyweightKg, experience: $experience, healthKitConnected: $healthKitConnected, healthKitPermissionsGranted: $healthKitPermissionsGranted, workoutsPerWeek: $workoutsPerWeek, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $InitialOnboardingDataCopyWith<$Res>  {
  factory $InitialOnboardingDataCopyWith(InitialOnboardingData value, $Res Function(InitialOnboardingData) _then) = _$InitialOnboardingDataCopyWithImpl;
@useResult
$Res call({
 TrainingGoalUI goal, BiologicalSex sex, int age, double heightCm, double bodyweightKg, ExperienceLevelUI experience, bool healthKitConnected, List<String> healthKitPermissionsGranted, int workoutsPerWeek, DateTime? completedAt
});




}
/// @nodoc
class _$InitialOnboardingDataCopyWithImpl<$Res>
    implements $InitialOnboardingDataCopyWith<$Res> {
  _$InitialOnboardingDataCopyWithImpl(this._self, this._then);

  final InitialOnboardingData _self;
  final $Res Function(InitialOnboardingData) _then;

/// Create a copy of InitialOnboardingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? goal = null,Object? sex = null,Object? age = null,Object? heightCm = null,Object? bodyweightKg = null,Object? experience = null,Object? healthKitConnected = null,Object? healthKitPermissionsGranted = null,Object? workoutsPerWeek = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as TrainingGoalUI,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as BiologicalSex,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,bodyweightKg: null == bodyweightKg ? _self.bodyweightKg : bodyweightKg // ignore: cast_nullable_to_non_nullable
as double,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as ExperienceLevelUI,healthKitConnected: null == healthKitConnected ? _self.healthKitConnected : healthKitConnected // ignore: cast_nullable_to_non_nullable
as bool,healthKitPermissionsGranted: null == healthKitPermissionsGranted ? _self.healthKitPermissionsGranted : healthKitPermissionsGranted // ignore: cast_nullable_to_non_nullable
as List<String>,workoutsPerWeek: null == workoutsPerWeek ? _self.workoutsPerWeek : workoutsPerWeek // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InitialOnboardingData].
extension InitialOnboardingDataPatterns on InitialOnboardingData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitialOnboardingData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitialOnboardingData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitialOnboardingData value)  $default,){
final _that = this;
switch (_that) {
case _InitialOnboardingData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitialOnboardingData value)?  $default,){
final _that = this;
switch (_that) {
case _InitialOnboardingData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrainingGoalUI goal,  BiologicalSex sex,  int age,  double heightCm,  double bodyweightKg,  ExperienceLevelUI experience,  bool healthKitConnected,  List<String> healthKitPermissionsGranted,  int workoutsPerWeek,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitialOnboardingData() when $default != null:
return $default(_that.goal,_that.sex,_that.age,_that.heightCm,_that.bodyweightKg,_that.experience,_that.healthKitConnected,_that.healthKitPermissionsGranted,_that.workoutsPerWeek,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrainingGoalUI goal,  BiologicalSex sex,  int age,  double heightCm,  double bodyweightKg,  ExperienceLevelUI experience,  bool healthKitConnected,  List<String> healthKitPermissionsGranted,  int workoutsPerWeek,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _InitialOnboardingData():
return $default(_that.goal,_that.sex,_that.age,_that.heightCm,_that.bodyweightKg,_that.experience,_that.healthKitConnected,_that.healthKitPermissionsGranted,_that.workoutsPerWeek,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrainingGoalUI goal,  BiologicalSex sex,  int age,  double heightCm,  double bodyweightKg,  ExperienceLevelUI experience,  bool healthKitConnected,  List<String> healthKitPermissionsGranted,  int workoutsPerWeek,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _InitialOnboardingData() when $default != null:
return $default(_that.goal,_that.sex,_that.age,_that.heightCm,_that.bodyweightKg,_that.experience,_that.healthKitConnected,_that.healthKitPermissionsGranted,_that.workoutsPerWeek,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitialOnboardingData extends InitialOnboardingData {
  const _InitialOnboardingData({required this.goal, required this.sex, required this.age, required this.heightCm, required this.bodyweightKg, required this.experience, this.healthKitConnected = false, final  List<String> healthKitPermissionsGranted = const [], this.workoutsPerWeek = 3, this.completedAt}): _healthKitPermissionsGranted = healthKitPermissionsGranted,super._();
  factory _InitialOnboardingData.fromJson(Map<String, dynamic> json) => _$InitialOnboardingDataFromJson(json);

// Step 1: Goal
@override final  TrainingGoalUI goal;
// Step 2: Personal Info
@override final  BiologicalSex sex;
@override final  int age;
// Step 3: Body data
@override final  double heightCm;
@override final  double bodyweightKg;
// Step 4: Experience
@override final  ExperienceLevelUI experience;
// Step 5: HealthKit (tracking only, not persisted)
@override@JsonKey() final  bool healthKitConnected;
 final  List<String> _healthKitPermissionsGranted;
@override@JsonKey() List<String> get healthKitPermissionsGranted {
  if (_healthKitPermissionsGranted is EqualUnmodifiableListView) return _healthKitPermissionsGranted;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_healthKitPermissionsGranted);
}

// Step 5: Frequency
@override@JsonKey() final  int workoutsPerWeek;
// Meta
@override final  DateTime? completedAt;

/// Create a copy of InitialOnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitialOnboardingDataCopyWith<_InitialOnboardingData> get copyWith => __$InitialOnboardingDataCopyWithImpl<_InitialOnboardingData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitialOnboardingDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitialOnboardingData&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.age, age) || other.age == age)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.bodyweightKg, bodyweightKg) || other.bodyweightKg == bodyweightKg)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.healthKitConnected, healthKitConnected) || other.healthKitConnected == healthKitConnected)&&const DeepCollectionEquality().equals(other._healthKitPermissionsGranted, _healthKitPermissionsGranted)&&(identical(other.workoutsPerWeek, workoutsPerWeek) || other.workoutsPerWeek == workoutsPerWeek)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,goal,sex,age,heightCm,bodyweightKg,experience,healthKitConnected,const DeepCollectionEquality().hash(_healthKitPermissionsGranted),workoutsPerWeek,completedAt);

@override
String toString() {
  return 'InitialOnboardingData(goal: $goal, sex: $sex, age: $age, heightCm: $heightCm, bodyweightKg: $bodyweightKg, experience: $experience, healthKitConnected: $healthKitConnected, healthKitPermissionsGranted: $healthKitPermissionsGranted, workoutsPerWeek: $workoutsPerWeek, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$InitialOnboardingDataCopyWith<$Res> implements $InitialOnboardingDataCopyWith<$Res> {
  factory _$InitialOnboardingDataCopyWith(_InitialOnboardingData value, $Res Function(_InitialOnboardingData) _then) = __$InitialOnboardingDataCopyWithImpl;
@override @useResult
$Res call({
 TrainingGoalUI goal, BiologicalSex sex, int age, double heightCm, double bodyweightKg, ExperienceLevelUI experience, bool healthKitConnected, List<String> healthKitPermissionsGranted, int workoutsPerWeek, DateTime? completedAt
});




}
/// @nodoc
class __$InitialOnboardingDataCopyWithImpl<$Res>
    implements _$InitialOnboardingDataCopyWith<$Res> {
  __$InitialOnboardingDataCopyWithImpl(this._self, this._then);

  final _InitialOnboardingData _self;
  final $Res Function(_InitialOnboardingData) _then;

/// Create a copy of InitialOnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? goal = null,Object? sex = null,Object? age = null,Object? heightCm = null,Object? bodyweightKg = null,Object? experience = null,Object? healthKitConnected = null,Object? healthKitPermissionsGranted = null,Object? workoutsPerWeek = null,Object? completedAt = freezed,}) {
  return _then(_InitialOnboardingData(
goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as TrainingGoalUI,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as BiologicalSex,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double,bodyweightKg: null == bodyweightKg ? _self.bodyweightKg : bodyweightKg // ignore: cast_nullable_to_non_nullable
as double,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as ExperienceLevelUI,healthKitConnected: null == healthKitConnected ? _self.healthKitConnected : healthKitConnected // ignore: cast_nullable_to_non_nullable
as bool,healthKitPermissionsGranted: null == healthKitPermissionsGranted ? _self._healthKitPermissionsGranted : healthKitPermissionsGranted // ignore: cast_nullable_to_non_nullable
as List<String>,workoutsPerWeek: null == workoutsPerWeek ? _self.workoutsPerWeek : workoutsPerWeek // ignore: cast_nullable_to_non_nullable
as int,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
