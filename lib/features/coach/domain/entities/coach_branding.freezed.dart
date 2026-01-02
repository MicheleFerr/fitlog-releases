// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coach_branding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoachBranding {

/// Unique branding ID
 String get id;/// Coach user ID
 String get coachId;/// Business/brand name (shown in PDF header)
 String get businessName;/// Optional tagline (shown below business name)
 String? get tagline;/// Primary brand color (hex string, e.g., '2196F3')
 String get primaryColor;/// Accent/secondary brand color (hex string)
 String get accentColor;/// URL to logo image (PNG/JPG, max 500KB recommended)
 String? get logoUrl;/// Contact email
 String? get email;/// Contact phone
 String? get phone;/// Website URL
 String? get website;/// Instagram handle (without @)
 String? get instagram;/// Footer text (e.g., "Powered by Coach Mike")
 String? get footerText;/// Creation timestamp
 DateTime get createdAt;/// Last update timestamp
 DateTime? get updatedAt;
/// Create a copy of CoachBranding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachBrandingCopyWith<CoachBranding> get copyWith => _$CoachBrandingCopyWithImpl<CoachBranding>(this as CoachBranding, _$identity);

  /// Serializes this CoachBranding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachBranding&&(identical(other.id, id) || other.id == id)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.footerText, footerText) || other.footerText == footerText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachId,businessName,tagline,primaryColor,accentColor,logoUrl,email,phone,website,instagram,footerText,createdAt,updatedAt);

@override
String toString() {
  return 'CoachBranding(id: $id, coachId: $coachId, businessName: $businessName, tagline: $tagline, primaryColor: $primaryColor, accentColor: $accentColor, logoUrl: $logoUrl, email: $email, phone: $phone, website: $website, instagram: $instagram, footerText: $footerText, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CoachBrandingCopyWith<$Res>  {
  factory $CoachBrandingCopyWith(CoachBranding value, $Res Function(CoachBranding) _then) = _$CoachBrandingCopyWithImpl;
@useResult
$Res call({
 String id, String coachId, String businessName, String? tagline, String primaryColor, String accentColor, String? logoUrl, String? email, String? phone, String? website, String? instagram, String? footerText, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CoachBrandingCopyWithImpl<$Res>
    implements $CoachBrandingCopyWith<$Res> {
  _$CoachBrandingCopyWithImpl(this._self, this._then);

  final CoachBranding _self;
  final $Res Function(CoachBranding) _then;

/// Create a copy of CoachBranding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coachId = null,Object? businessName = null,Object? tagline = freezed,Object? primaryColor = null,Object? accentColor = null,Object? logoUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? instagram = freezed,Object? footerText = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String?,footerText: freezed == footerText ? _self.footerText : footerText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachBranding].
extension CoachBrandingPatterns on CoachBranding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachBranding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachBranding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachBranding value)  $default,){
final _that = this;
switch (_that) {
case _CoachBranding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachBranding value)?  $default,){
final _that = this;
switch (_that) {
case _CoachBranding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String coachId,  String businessName,  String? tagline,  String primaryColor,  String accentColor,  String? logoUrl,  String? email,  String? phone,  String? website,  String? instagram,  String? footerText,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachBranding() when $default != null:
return $default(_that.id,_that.coachId,_that.businessName,_that.tagline,_that.primaryColor,_that.accentColor,_that.logoUrl,_that.email,_that.phone,_that.website,_that.instagram,_that.footerText,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String coachId,  String businessName,  String? tagline,  String primaryColor,  String accentColor,  String? logoUrl,  String? email,  String? phone,  String? website,  String? instagram,  String? footerText,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CoachBranding():
return $default(_that.id,_that.coachId,_that.businessName,_that.tagline,_that.primaryColor,_that.accentColor,_that.logoUrl,_that.email,_that.phone,_that.website,_that.instagram,_that.footerText,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String coachId,  String businessName,  String? tagline,  String primaryColor,  String accentColor,  String? logoUrl,  String? email,  String? phone,  String? website,  String? instagram,  String? footerText,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CoachBranding() when $default != null:
return $default(_that.id,_that.coachId,_that.businessName,_that.tagline,_that.primaryColor,_that.accentColor,_that.logoUrl,_that.email,_that.phone,_that.website,_that.instagram,_that.footerText,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachBranding extends CoachBranding {
  const _CoachBranding({required this.id, required this.coachId, required this.businessName, this.tagline, this.primaryColor = kDefaultPrimaryColor, this.accentColor = kDefaultAccentColor, this.logoUrl, this.email, this.phone, this.website, this.instagram, this.footerText, required this.createdAt, this.updatedAt}): super._();
  factory _CoachBranding.fromJson(Map<String, dynamic> json) => _$CoachBrandingFromJson(json);

/// Unique branding ID
@override final  String id;
/// Coach user ID
@override final  String coachId;
/// Business/brand name (shown in PDF header)
@override final  String businessName;
/// Optional tagline (shown below business name)
@override final  String? tagline;
/// Primary brand color (hex string, e.g., '2196F3')
@override@JsonKey() final  String primaryColor;
/// Accent/secondary brand color (hex string)
@override@JsonKey() final  String accentColor;
/// URL to logo image (PNG/JPG, max 500KB recommended)
@override final  String? logoUrl;
/// Contact email
@override final  String? email;
/// Contact phone
@override final  String? phone;
/// Website URL
@override final  String? website;
/// Instagram handle (without @)
@override final  String? instagram;
/// Footer text (e.g., "Powered by Coach Mike")
@override final  String? footerText;
/// Creation timestamp
@override final  DateTime createdAt;
/// Last update timestamp
@override final  DateTime? updatedAt;

/// Create a copy of CoachBranding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachBrandingCopyWith<_CoachBranding> get copyWith => __$CoachBrandingCopyWithImpl<_CoachBranding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachBrandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachBranding&&(identical(other.id, id) || other.id == id)&&(identical(other.coachId, coachId) || other.coachId == coachId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.footerText, footerText) || other.footerText == footerText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachId,businessName,tagline,primaryColor,accentColor,logoUrl,email,phone,website,instagram,footerText,createdAt,updatedAt);

@override
String toString() {
  return 'CoachBranding(id: $id, coachId: $coachId, businessName: $businessName, tagline: $tagline, primaryColor: $primaryColor, accentColor: $accentColor, logoUrl: $logoUrl, email: $email, phone: $phone, website: $website, instagram: $instagram, footerText: $footerText, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CoachBrandingCopyWith<$Res> implements $CoachBrandingCopyWith<$Res> {
  factory _$CoachBrandingCopyWith(_CoachBranding value, $Res Function(_CoachBranding) _then) = __$CoachBrandingCopyWithImpl;
@override @useResult
$Res call({
 String id, String coachId, String businessName, String? tagline, String primaryColor, String accentColor, String? logoUrl, String? email, String? phone, String? website, String? instagram, String? footerText, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CoachBrandingCopyWithImpl<$Res>
    implements _$CoachBrandingCopyWith<$Res> {
  __$CoachBrandingCopyWithImpl(this._self, this._then);

  final _CoachBranding _self;
  final $Res Function(_CoachBranding) _then;

/// Create a copy of CoachBranding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coachId = null,Object? businessName = null,Object? tagline = freezed,Object? primaryColor = null,Object? accentColor = null,Object? logoUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? instagram = freezed,Object? footerText = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_CoachBranding(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachId: null == coachId ? _self.coachId : coachId // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as String?,footerText: freezed == footerText ? _self.footerText : footerText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
