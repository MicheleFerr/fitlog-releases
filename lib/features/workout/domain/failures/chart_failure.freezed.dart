// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChartFailure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) dataNotFound,
    required TResult Function(String message, String? details) invalidInput,
    required TResult Function(String message, Object? error) cacheFailure,
    required TResult Function(String message, Object? error) serverFailure,
    required TResult Function(
            String message, Object? error, StackTrace? stackTrace)
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? dataNotFound,
    TResult? Function(String message, String? details)? invalidInput,
    TResult? Function(String message, Object? error)? cacheFailure,
    TResult? Function(String message, Object? error)? serverFailure,
    TResult? Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? dataNotFound,
    TResult Function(String message, String? details)? invalidInput,
    TResult Function(String message, Object? error)? cacheFailure,
    TResult Function(String message, Object? error)? serverFailure,
    TResult Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataNotFound value) dataNotFound,
    required TResult Function(InvalidInput value) invalidInput,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(UnknownFailure value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataNotFound value)? dataNotFound,
    TResult? Function(InvalidInput value)? invalidInput,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(UnknownFailure value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataNotFound value)? dataNotFound,
    TResult Function(InvalidInput value)? invalidInput,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChartFailureCopyWith<ChartFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartFailureCopyWith<$Res> {
  factory $ChartFailureCopyWith(
          ChartFailure value, $Res Function(ChartFailure) then) =
      _$ChartFailureCopyWithImpl<$Res, ChartFailure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$ChartFailureCopyWithImpl<$Res, $Val extends ChartFailure>
    implements $ChartFailureCopyWith<$Res> {
  _$ChartFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DataNotFoundImplCopyWith<$Res>
    implements $ChartFailureCopyWith<$Res> {
  factory _$$DataNotFoundImplCopyWith(
          _$DataNotFoundImpl value, $Res Function(_$DataNotFoundImpl) then) =
      __$$DataNotFoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DataNotFoundImplCopyWithImpl<$Res>
    extends _$ChartFailureCopyWithImpl<$Res, _$DataNotFoundImpl>
    implements _$$DataNotFoundImplCopyWith<$Res> {
  __$$DataNotFoundImplCopyWithImpl(
      _$DataNotFoundImpl _value, $Res Function(_$DataNotFoundImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$DataNotFoundImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DataNotFoundImpl implements DataNotFound {
  const _$DataNotFoundImpl({this.message = 'No data found for chart'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'ChartFailure.dataNotFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataNotFoundImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataNotFoundImplCopyWith<_$DataNotFoundImpl> get copyWith =>
      __$$DataNotFoundImplCopyWithImpl<_$DataNotFoundImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) dataNotFound,
    required TResult Function(String message, String? details) invalidInput,
    required TResult Function(String message, Object? error) cacheFailure,
    required TResult Function(String message, Object? error) serverFailure,
    required TResult Function(
            String message, Object? error, StackTrace? stackTrace)
        unknown,
  }) {
    return dataNotFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? dataNotFound,
    TResult? Function(String message, String? details)? invalidInput,
    TResult? Function(String message, Object? error)? cacheFailure,
    TResult? Function(String message, Object? error)? serverFailure,
    TResult? Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
  }) {
    return dataNotFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? dataNotFound,
    TResult Function(String message, String? details)? invalidInput,
    TResult Function(String message, Object? error)? cacheFailure,
    TResult Function(String message, Object? error)? serverFailure,
    TResult Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (dataNotFound != null) {
      return dataNotFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataNotFound value) dataNotFound,
    required TResult Function(InvalidInput value) invalidInput,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return dataNotFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataNotFound value)? dataNotFound,
    TResult? Function(InvalidInput value)? invalidInput,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return dataNotFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataNotFound value)? dataNotFound,
    TResult Function(InvalidInput value)? invalidInput,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (dataNotFound != null) {
      return dataNotFound(this);
    }
    return orElse();
  }
}

abstract class DataNotFound implements ChartFailure {
  const factory DataNotFound({final String message}) = _$DataNotFoundImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$DataNotFoundImplCopyWith<_$DataNotFoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InvalidInputImplCopyWith<$Res>
    implements $ChartFailureCopyWith<$Res> {
  factory _$$InvalidInputImplCopyWith(
          _$InvalidInputImpl value, $Res Function(_$InvalidInputImpl) then) =
      __$$InvalidInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? details});
}

/// @nodoc
class __$$InvalidInputImplCopyWithImpl<$Res>
    extends _$ChartFailureCopyWithImpl<$Res, _$InvalidInputImpl>
    implements _$$InvalidInputImplCopyWith<$Res> {
  __$$InvalidInputImplCopyWithImpl(
      _$InvalidInputImpl _value, $Res Function(_$InvalidInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(_$InvalidInputImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$InvalidInputImpl implements InvalidInput {
  const _$InvalidInputImpl(
      {this.message = 'Invalid input parameters', this.details});

  @override
  @JsonKey()
  final String message;
  @override
  final String? details;

  @override
  String toString() {
    return 'ChartFailure.invalidInput(message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvalidInputImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, details);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InvalidInputImplCopyWith<_$InvalidInputImpl> get copyWith =>
      __$$InvalidInputImplCopyWithImpl<_$InvalidInputImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) dataNotFound,
    required TResult Function(String message, String? details) invalidInput,
    required TResult Function(String message, Object? error) cacheFailure,
    required TResult Function(String message, Object? error) serverFailure,
    required TResult Function(
            String message, Object? error, StackTrace? stackTrace)
        unknown,
  }) {
    return invalidInput(message, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? dataNotFound,
    TResult? Function(String message, String? details)? invalidInput,
    TResult? Function(String message, Object? error)? cacheFailure,
    TResult? Function(String message, Object? error)? serverFailure,
    TResult? Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
  }) {
    return invalidInput?.call(message, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? dataNotFound,
    TResult Function(String message, String? details)? invalidInput,
    TResult Function(String message, Object? error)? cacheFailure,
    TResult Function(String message, Object? error)? serverFailure,
    TResult Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (invalidInput != null) {
      return invalidInput(message, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataNotFound value) dataNotFound,
    required TResult Function(InvalidInput value) invalidInput,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return invalidInput(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataNotFound value)? dataNotFound,
    TResult? Function(InvalidInput value)? invalidInput,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return invalidInput?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataNotFound value)? dataNotFound,
    TResult Function(InvalidInput value)? invalidInput,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (invalidInput != null) {
      return invalidInput(this);
    }
    return orElse();
  }
}

abstract class InvalidInput implements ChartFailure {
  const factory InvalidInput({final String message, final String? details}) =
      _$InvalidInputImpl;

  @override
  String get message;
  String? get details;
  @override
  @JsonKey(ignore: true)
  _$$InvalidInputImplCopyWith<_$InvalidInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $ChartFailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
          _$CacheFailureImpl value, $Res Function(_$CacheFailureImpl) then) =
      __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? error});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$ChartFailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
      _$CacheFailureImpl _value, $Res Function(_$CacheFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? error = freezed,
  }) {
    return _then(_$CacheFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error ? _value.error : error,
    ));
  }
}

/// @nodoc

class _$CacheFailureImpl implements CacheFailure {
  const _$CacheFailureImpl({this.message = 'Cache error', this.error});

  @override
  @JsonKey()
  final String message;
  @override
  final Object? error;

  @override
  String toString() {
    return 'ChartFailure.cacheFailure(message: $message, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) dataNotFound,
    required TResult Function(String message, String? details) invalidInput,
    required TResult Function(String message, Object? error) cacheFailure,
    required TResult Function(String message, Object? error) serverFailure,
    required TResult Function(
            String message, Object? error, StackTrace? stackTrace)
        unknown,
  }) {
    return cacheFailure(message, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? dataNotFound,
    TResult? Function(String message, String? details)? invalidInput,
    TResult? Function(String message, Object? error)? cacheFailure,
    TResult? Function(String message, Object? error)? serverFailure,
    TResult? Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
  }) {
    return cacheFailure?.call(message, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? dataNotFound,
    TResult Function(String message, String? details)? invalidInput,
    TResult Function(String message, Object? error)? cacheFailure,
    TResult Function(String message, Object? error)? serverFailure,
    TResult Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (cacheFailure != null) {
      return cacheFailure(message, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataNotFound value) dataNotFound,
    required TResult Function(InvalidInput value) invalidInput,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return cacheFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataNotFound value)? dataNotFound,
    TResult? Function(InvalidInput value)? invalidInput,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return cacheFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataNotFound value)? dataNotFound,
    TResult Function(InvalidInput value)? invalidInput,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (cacheFailure != null) {
      return cacheFailure(this);
    }
    return orElse();
  }
}

abstract class CacheFailure implements ChartFailure {
  const factory CacheFailure({final String message, final Object? error}) =
      _$CacheFailureImpl;

  @override
  String get message;
  Object? get error;
  @override
  @JsonKey(ignore: true)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $ChartFailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
          _$ServerFailureImpl value, $Res Function(_$ServerFailureImpl) then) =
      __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? error});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$ChartFailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
      _$ServerFailureImpl _value, $Res Function(_$ServerFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? error = freezed,
  }) {
    return _then(_$ServerFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error ? _value.error : error,
    ));
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl({this.message = 'Server error', this.error});

  @override
  @JsonKey()
  final String message;
  @override
  final Object? error;

  @override
  String toString() {
    return 'ChartFailure.serverFailure(message: $message, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) dataNotFound,
    required TResult Function(String message, String? details) invalidInput,
    required TResult Function(String message, Object? error) cacheFailure,
    required TResult Function(String message, Object? error) serverFailure,
    required TResult Function(
            String message, Object? error, StackTrace? stackTrace)
        unknown,
  }) {
    return serverFailure(message, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? dataNotFound,
    TResult? Function(String message, String? details)? invalidInput,
    TResult? Function(String message, Object? error)? cacheFailure,
    TResult? Function(String message, Object? error)? serverFailure,
    TResult? Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
  }) {
    return serverFailure?.call(message, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? dataNotFound,
    TResult Function(String message, String? details)? invalidInput,
    TResult Function(String message, Object? error)? cacheFailure,
    TResult Function(String message, Object? error)? serverFailure,
    TResult Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (serverFailure != null) {
      return serverFailure(message, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataNotFound value) dataNotFound,
    required TResult Function(InvalidInput value) invalidInput,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return serverFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataNotFound value)? dataNotFound,
    TResult? Function(InvalidInput value)? invalidInput,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return serverFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataNotFound value)? dataNotFound,
    TResult Function(InvalidInput value)? invalidInput,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (serverFailure != null) {
      return serverFailure(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements ChartFailure {
  const factory ServerFailure({final String message, final Object? error}) =
      _$ServerFailureImpl;

  @override
  String get message;
  Object? get error;
  @override
  @JsonKey(ignore: true)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $ChartFailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(_$UnknownFailureImpl value,
          $Res Function(_$UnknownFailureImpl) then) =
      __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? error, StackTrace? stackTrace});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$ChartFailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
      _$UnknownFailureImpl _value, $Res Function(_$UnknownFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? error = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_$UnknownFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error ? _value.error : error,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl(
      {this.message = 'Unknown error occurred', this.error, this.stackTrace});

  @override
  @JsonKey()
  final String message;
  @override
  final Object? error;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'ChartFailure.unknown(message: $message, error: $error, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message,
      const DeepCollectionEquality().hash(error), stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) dataNotFound,
    required TResult Function(String message, String? details) invalidInput,
    required TResult Function(String message, Object? error) cacheFailure,
    required TResult Function(String message, Object? error) serverFailure,
    required TResult Function(
            String message, Object? error, StackTrace? stackTrace)
        unknown,
  }) {
    return unknown(message, error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? dataNotFound,
    TResult? Function(String message, String? details)? invalidInput,
    TResult? Function(String message, Object? error)? cacheFailure,
    TResult? Function(String message, Object? error)? serverFailure,
    TResult? Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
  }) {
    return unknown?.call(message, error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? dataNotFound,
    TResult Function(String message, String? details)? invalidInput,
    TResult Function(String message, Object? error)? cacheFailure,
    TResult Function(String message, Object? error)? serverFailure,
    TResult Function(String message, Object? error, StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, error, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DataNotFound value) dataNotFound,
    required TResult Function(InvalidInput value) invalidInput,
    required TResult Function(CacheFailure value) cacheFailure,
    required TResult Function(ServerFailure value) serverFailure,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DataNotFound value)? dataNotFound,
    TResult? Function(InvalidInput value)? invalidInput,
    TResult? Function(CacheFailure value)? cacheFailure,
    TResult? Function(ServerFailure value)? serverFailure,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DataNotFound value)? dataNotFound,
    TResult Function(InvalidInput value)? invalidInput,
    TResult Function(CacheFailure value)? cacheFailure,
    TResult Function(ServerFailure value)? serverFailure,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements ChartFailure {
  const factory UnknownFailure(
      {final String message,
      final Object? error,
      final StackTrace? stackTrace}) = _$UnknownFailureImpl;

  @override
  String get message;
  Object? get error;
  StackTrace? get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
