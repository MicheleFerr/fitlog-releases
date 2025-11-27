// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_patch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExercisePatch _$ExercisePatchFromJson(Map<String, dynamic> json) {
  return _ExercisePatch.fromJson(json);
}

/// @nodoc
mixin _$ExercisePatch {
  /// Unique patch ID (Firestore document ID)
  String get id => throw _privateConstructorUsedError;

  /// ID of the exercise being patched
  String get exerciseId => throw _privateConstructorUsedError;

  /// User ID who submitted the patch
  String get userId => throw _privateConstructorUsedError;

  /// Name of the field being modified (e.g., "nome", "difficolta", "noteTecniche")
  String get fieldName => throw _privateConstructorUsedError;

  /// Original value before user's modification (from Firestore)
  dynamic get oldValue => throw _privateConstructorUsedError;

  /// New value proposed by user
  dynamic get newValue => throw _privateConstructorUsedError;

  /// Server value at time of patch creation (for conflict detection)
  /// If this differs from current Firestore value, patch is stale
  dynamic get originalValue => throw _privateConstructorUsedError;

  /// User's explanation for the change (required, min 10 chars)
  String get reason => throw _privateConstructorUsedError;

  /// Current status of the patch
  PatchStatus get status => throw _privateConstructorUsedError;

  /// Language version ('it' or 'en')
  String get language => throw _privateConstructorUsedError;

  /// When patch was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When patch will expire (createdAt + 30 days)
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Exercise version at time of patch creation
  /// Used to detect if exercise was updated before patch approval
  int get version => throw _privateConstructorUsedError;

  /// When patch was approved (null if not approved)
  DateTime? get approvedAt => throw _privateConstructorUsedError;

  /// Admin user ID who approved the patch
  String? get approvedBy => throw _privateConstructorUsedError;

  /// When patch was rejected (null if not rejected)
  DateTime? get rejectedAt => throw _privateConstructorUsedError;

  /// Reason for rejection (null if approved or pending)
  String? get rejectReason => throw _privateConstructorUsedError;

  /// Additional notes from admin
  String? get adminNote => throw _privateConstructorUsedError;

  /// Whether patch was auto-expired by TTL cleanup (Cloud Function)
  bool get autoExpired => throw _privateConstructorUsedError;

  /// User email (for admin notification)
  String? get userEmail => throw _privateConstructorUsedError;

  /// User display name (for admin UI)
  String? get userDisplayName => throw _privateConstructorUsedError;

  /// Serializes this ExercisePatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExercisePatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExercisePatchCopyWith<ExercisePatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExercisePatchCopyWith<$Res> {
  factory $ExercisePatchCopyWith(
    ExercisePatch value,
    $Res Function(ExercisePatch) then,
  ) = _$ExercisePatchCopyWithImpl<$Res, ExercisePatch>;
  @useResult
  $Res call({
    String id,
    String exerciseId,
    String userId,
    String fieldName,
    dynamic oldValue,
    dynamic newValue,
    dynamic originalValue,
    String reason,
    PatchStatus status,
    String language,
    DateTime createdAt,
    DateTime expiresAt,
    int version,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? rejectedAt,
    String? rejectReason,
    String? adminNote,
    bool autoExpired,
    String? userEmail,
    String? userDisplayName,
  });
}

/// @nodoc
class _$ExercisePatchCopyWithImpl<$Res, $Val extends ExercisePatch>
    implements $ExercisePatchCopyWith<$Res> {
  _$ExercisePatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExercisePatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? userId = null,
    Object? fieldName = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? originalValue = freezed,
    Object? reason = null,
    Object? status = null,
    Object? language = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? version = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? rejectedAt = freezed,
    Object? rejectReason = freezed,
    Object? adminNote = freezed,
    Object? autoExpired = null,
    Object? userEmail = freezed,
    Object? userDisplayName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fieldName: null == fieldName
                ? _value.fieldName
                : fieldName // ignore: cast_nullable_to_non_nullable
                      as String,
            oldValue: freezed == oldValue
                ? _value.oldValue
                : oldValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            newValue: freezed == newValue
                ? _value.newValue
                : newValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            originalValue: freezed == originalValue
                ? _value.originalValue
                : originalValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            reason: null == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PatchStatus,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            approvedAt: freezed == approvedAt
                ? _value.approvedAt
                : approvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            approvedBy: freezed == approvedBy
                ? _value.approvedBy
                : approvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            rejectedAt: freezed == rejectedAt
                ? _value.rejectedAt
                : rejectedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            rejectReason: freezed == rejectReason
                ? _value.rejectReason
                : rejectReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            adminNote: freezed == adminNote
                ? _value.adminNote
                : adminNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            autoExpired: null == autoExpired
                ? _value.autoExpired
                : autoExpired // ignore: cast_nullable_to_non_nullable
                      as bool,
            userEmail: freezed == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            userDisplayName: freezed == userDisplayName
                ? _value.userDisplayName
                : userDisplayName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExercisePatchImplCopyWith<$Res>
    implements $ExercisePatchCopyWith<$Res> {
  factory _$$ExercisePatchImplCopyWith(
    _$ExercisePatchImpl value,
    $Res Function(_$ExercisePatchImpl) then,
  ) = __$$ExercisePatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String exerciseId,
    String userId,
    String fieldName,
    dynamic oldValue,
    dynamic newValue,
    dynamic originalValue,
    String reason,
    PatchStatus status,
    String language,
    DateTime createdAt,
    DateTime expiresAt,
    int version,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? rejectedAt,
    String? rejectReason,
    String? adminNote,
    bool autoExpired,
    String? userEmail,
    String? userDisplayName,
  });
}

/// @nodoc
class __$$ExercisePatchImplCopyWithImpl<$Res>
    extends _$ExercisePatchCopyWithImpl<$Res, _$ExercisePatchImpl>
    implements _$$ExercisePatchImplCopyWith<$Res> {
  __$$ExercisePatchImplCopyWithImpl(
    _$ExercisePatchImpl _value,
    $Res Function(_$ExercisePatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExercisePatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseId = null,
    Object? userId = null,
    Object? fieldName = null,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? originalValue = freezed,
    Object? reason = null,
    Object? status = null,
    Object? language = null,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? version = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? rejectedAt = freezed,
    Object? rejectReason = freezed,
    Object? adminNote = freezed,
    Object? autoExpired = null,
    Object? userEmail = freezed,
    Object? userDisplayName = freezed,
  }) {
    return _then(
      _$ExercisePatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fieldName: null == fieldName
            ? _value.fieldName
            : fieldName // ignore: cast_nullable_to_non_nullable
                  as String,
        oldValue: freezed == oldValue
            ? _value.oldValue
            : oldValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        newValue: freezed == newValue
            ? _value.newValue
            : newValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        originalValue: freezed == originalValue
            ? _value.originalValue
            : originalValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PatchStatus,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        approvedAt: freezed == approvedAt
            ? _value.approvedAt
            : approvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        approvedBy: freezed == approvedBy
            ? _value.approvedBy
            : approvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        rejectedAt: freezed == rejectedAt
            ? _value.rejectedAt
            : rejectedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        rejectReason: freezed == rejectReason
            ? _value.rejectReason
            : rejectReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        adminNote: freezed == adminNote
            ? _value.adminNote
            : adminNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoExpired: null == autoExpired
            ? _value.autoExpired
            : autoExpired // ignore: cast_nullable_to_non_nullable
                  as bool,
        userEmail: freezed == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        userDisplayName: freezed == userDisplayName
            ? _value.userDisplayName
            : userDisplayName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExercisePatchImpl implements _ExercisePatch {
  const _$ExercisePatchImpl({
    required this.id,
    required this.exerciseId,
    required this.userId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.originalValue,
    required this.reason,
    required this.status,
    required this.language,
    required this.createdAt,
    required this.expiresAt,
    required this.version,
    this.approvedAt,
    this.approvedBy,
    this.rejectedAt,
    this.rejectReason,
    this.adminNote,
    this.autoExpired = false,
    this.userEmail,
    this.userDisplayName,
  });

  factory _$ExercisePatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExercisePatchImplFromJson(json);

  /// Unique patch ID (Firestore document ID)
  @override
  final String id;

  /// ID of the exercise being patched
  @override
  final String exerciseId;

  /// User ID who submitted the patch
  @override
  final String userId;

  /// Name of the field being modified (e.g., "nome", "difficolta", "noteTecniche")
  @override
  final String fieldName;

  /// Original value before user's modification (from Firestore)
  @override
  final dynamic oldValue;

  /// New value proposed by user
  @override
  final dynamic newValue;

  /// Server value at time of patch creation (for conflict detection)
  /// If this differs from current Firestore value, patch is stale
  @override
  final dynamic originalValue;

  /// User's explanation for the change (required, min 10 chars)
  @override
  final String reason;

  /// Current status of the patch
  @override
  final PatchStatus status;

  /// Language version ('it' or 'en')
  @override
  final String language;

  /// When patch was created
  @override
  final DateTime createdAt;

  /// When patch will expire (createdAt + 30 days)
  @override
  final DateTime expiresAt;

  /// Exercise version at time of patch creation
  /// Used to detect if exercise was updated before patch approval
  @override
  final int version;

  /// When patch was approved (null if not approved)
  @override
  final DateTime? approvedAt;

  /// Admin user ID who approved the patch
  @override
  final String? approvedBy;

  /// When patch was rejected (null if not rejected)
  @override
  final DateTime? rejectedAt;

  /// Reason for rejection (null if approved or pending)
  @override
  final String? rejectReason;

  /// Additional notes from admin
  @override
  final String? adminNote;

  /// Whether patch was auto-expired by TTL cleanup (Cloud Function)
  @override
  @JsonKey()
  final bool autoExpired;

  /// User email (for admin notification)
  @override
  final String? userEmail;

  /// User display name (for admin UI)
  @override
  final String? userDisplayName;

  @override
  String toString() {
    return 'ExercisePatch(id: $id, exerciseId: $exerciseId, userId: $userId, fieldName: $fieldName, oldValue: $oldValue, newValue: $newValue, originalValue: $originalValue, reason: $reason, status: $status, language: $language, createdAt: $createdAt, expiresAt: $expiresAt, version: $version, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectedAt: $rejectedAt, rejectReason: $rejectReason, adminNote: $adminNote, autoExpired: $autoExpired, userEmail: $userEmail, userDisplayName: $userDisplayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExercisePatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fieldName, fieldName) ||
                other.fieldName == fieldName) &&
            const DeepCollectionEquality().equals(other.oldValue, oldValue) &&
            const DeepCollectionEquality().equals(other.newValue, newValue) &&
            const DeepCollectionEquality().equals(
              other.originalValue,
              originalValue,
            ) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.rejectReason, rejectReason) ||
                other.rejectReason == rejectReason) &&
            (identical(other.adminNote, adminNote) ||
                other.adminNote == adminNote) &&
            (identical(other.autoExpired, autoExpired) ||
                other.autoExpired == autoExpired) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    exerciseId,
    userId,
    fieldName,
    const DeepCollectionEquality().hash(oldValue),
    const DeepCollectionEquality().hash(newValue),
    const DeepCollectionEquality().hash(originalValue),
    reason,
    status,
    language,
    createdAt,
    expiresAt,
    version,
    approvedAt,
    approvedBy,
    rejectedAt,
    rejectReason,
    adminNote,
    autoExpired,
    userEmail,
    userDisplayName,
  ]);

  /// Create a copy of ExercisePatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExercisePatchImplCopyWith<_$ExercisePatchImpl> get copyWith =>
      __$$ExercisePatchImplCopyWithImpl<_$ExercisePatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExercisePatchImplToJson(this);
  }
}

abstract class _ExercisePatch implements ExercisePatch {
  const factory _ExercisePatch({
    required final String id,
    required final String exerciseId,
    required final String userId,
    required final String fieldName,
    required final dynamic oldValue,
    required final dynamic newValue,
    required final dynamic originalValue,
    required final String reason,
    required final PatchStatus status,
    required final String language,
    required final DateTime createdAt,
    required final DateTime expiresAt,
    required final int version,
    final DateTime? approvedAt,
    final String? approvedBy,
    final DateTime? rejectedAt,
    final String? rejectReason,
    final String? adminNote,
    final bool autoExpired,
    final String? userEmail,
    final String? userDisplayName,
  }) = _$ExercisePatchImpl;

  factory _ExercisePatch.fromJson(Map<String, dynamic> json) =
      _$ExercisePatchImpl.fromJson;

  /// Unique patch ID (Firestore document ID)
  @override
  String get id;

  /// ID of the exercise being patched
  @override
  String get exerciseId;

  /// User ID who submitted the patch
  @override
  String get userId;

  /// Name of the field being modified (e.g., "nome", "difficolta", "noteTecniche")
  @override
  String get fieldName;

  /// Original value before user's modification (from Firestore)
  @override
  dynamic get oldValue;

  /// New value proposed by user
  @override
  dynamic get newValue;

  /// Server value at time of patch creation (for conflict detection)
  /// If this differs from current Firestore value, patch is stale
  @override
  dynamic get originalValue;

  /// User's explanation for the change (required, min 10 chars)
  @override
  String get reason;

  /// Current status of the patch
  @override
  PatchStatus get status;

  /// Language version ('it' or 'en')
  @override
  String get language;

  /// When patch was created
  @override
  DateTime get createdAt;

  /// When patch will expire (createdAt + 30 days)
  @override
  DateTime get expiresAt;

  /// Exercise version at time of patch creation
  /// Used to detect if exercise was updated before patch approval
  @override
  int get version;

  /// When patch was approved (null if not approved)
  @override
  DateTime? get approvedAt;

  /// Admin user ID who approved the patch
  @override
  String? get approvedBy;

  /// When patch was rejected (null if not rejected)
  @override
  DateTime? get rejectedAt;

  /// Reason for rejection (null if approved or pending)
  @override
  String? get rejectReason;

  /// Additional notes from admin
  @override
  String? get adminNote;

  /// Whether patch was auto-expired by TTL cleanup (Cloud Function)
  @override
  bool get autoExpired;

  /// User email (for admin notification)
  @override
  String? get userEmail;

  /// User display name (for admin UI)
  @override
  String? get userDisplayName;

  /// Create a copy of ExercisePatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExercisePatchImplCopyWith<_$ExercisePatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
