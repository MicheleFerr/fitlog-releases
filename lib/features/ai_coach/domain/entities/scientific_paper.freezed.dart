// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scientific_paper.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScientificPaper {

 String get id; String get title; List<String> get authors; int get year; String get doi; String get abstract; String get summary;// Short 1-2 sentence summary for AI
 String get url; String get license; List<String> get categories;// ['hypertrophy', 'strength', etc.]
 List<String> get keywords; DateTime get uploadedAt; DateTime get updatedAt; bool get active; Map<String, dynamic>? get metadata;
/// Create a copy of ScientificPaper
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScientificPaperCopyWith<ScientificPaper> get copyWith => _$ScientificPaperCopyWithImpl<ScientificPaper>(this as ScientificPaper, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScientificPaper&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.authors, authors)&&(identical(other.year, year) || other.year == year)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.url, url) || other.url == url)&&(identical(other.license, license) || other.license == license)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(authors),year,doi,abstract,summary,url,license,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(keywords),uploadedAt,updatedAt,active,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ScientificPaper(id: $id, title: $title, authors: $authors, year: $year, doi: $doi, abstract: $abstract, summary: $summary, url: $url, license: $license, categories: $categories, keywords: $keywords, uploadedAt: $uploadedAt, updatedAt: $updatedAt, active: $active, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ScientificPaperCopyWith<$Res>  {
  factory $ScientificPaperCopyWith(ScientificPaper value, $Res Function(ScientificPaper) _then) = _$ScientificPaperCopyWithImpl;
@useResult
$Res call({
 String id, String title, List<String> authors, int year, String doi, String abstract, String summary, String url, String license, List<String> categories, List<String> keywords, DateTime uploadedAt, DateTime updatedAt, bool active, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ScientificPaperCopyWithImpl<$Res>
    implements $ScientificPaperCopyWith<$Res> {
  _$ScientificPaperCopyWithImpl(this._self, this._then);

  final ScientificPaper _self;
  final $Res Function(ScientificPaper) _then;

/// Create a copy of ScientificPaper
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? authors = null,Object? year = null,Object? doi = null,Object? abstract = null,Object? summary = null,Object? url = null,Object? license = null,Object? categories = null,Object? keywords = null,Object? uploadedAt = null,Object? updatedAt = null,Object? active = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self.authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,abstract: null == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScientificPaper].
extension ScientificPaperPatterns on ScientificPaper {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScientificPaper value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScientificPaper() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScientificPaper value)  $default,){
final _that = this;
switch (_that) {
case _ScientificPaper():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScientificPaper value)?  $default,){
final _that = this;
switch (_that) {
case _ScientificPaper() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  List<String> authors,  int year,  String doi,  String abstract,  String summary,  String url,  String license,  List<String> categories,  List<String> keywords,  DateTime uploadedAt,  DateTime updatedAt,  bool active,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScientificPaper() when $default != null:
return $default(_that.id,_that.title,_that.authors,_that.year,_that.doi,_that.abstract,_that.summary,_that.url,_that.license,_that.categories,_that.keywords,_that.uploadedAt,_that.updatedAt,_that.active,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  List<String> authors,  int year,  String doi,  String abstract,  String summary,  String url,  String license,  List<String> categories,  List<String> keywords,  DateTime uploadedAt,  DateTime updatedAt,  bool active,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ScientificPaper():
return $default(_that.id,_that.title,_that.authors,_that.year,_that.doi,_that.abstract,_that.summary,_that.url,_that.license,_that.categories,_that.keywords,_that.uploadedAt,_that.updatedAt,_that.active,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  List<String> authors,  int year,  String doi,  String abstract,  String summary,  String url,  String license,  List<String> categories,  List<String> keywords,  DateTime uploadedAt,  DateTime updatedAt,  bool active,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ScientificPaper() when $default != null:
return $default(_that.id,_that.title,_that.authors,_that.year,_that.doi,_that.abstract,_that.summary,_that.url,_that.license,_that.categories,_that.keywords,_that.uploadedAt,_that.updatedAt,_that.active,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _ScientificPaper extends ScientificPaper {
  const _ScientificPaper({required this.id, required this.title, required final  List<String> authors, required this.year, required this.doi, required this.abstract, required this.summary, required this.url, required this.license, required final  List<String> categories, required final  List<String> keywords, required this.uploadedAt, required this.updatedAt, required this.active, final  Map<String, dynamic>? metadata}): _authors = authors,_categories = categories,_keywords = keywords,_metadata = metadata,super._();
  

@override final  String id;
@override final  String title;
 final  List<String> _authors;
@override List<String> get authors {
  if (_authors is EqualUnmodifiableListView) return _authors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authors);
}

@override final  int year;
@override final  String doi;
@override final  String abstract;
@override final  String summary;
// Short 1-2 sentence summary for AI
@override final  String url;
@override final  String license;
 final  List<String> _categories;
@override List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

// ['hypertrophy', 'strength', etc.]
 final  List<String> _keywords;
// ['hypertrophy', 'strength', etc.]
@override List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

@override final  DateTime uploadedAt;
@override final  DateTime updatedAt;
@override final  bool active;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ScientificPaper
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScientificPaperCopyWith<_ScientificPaper> get copyWith => __$ScientificPaperCopyWithImpl<_ScientificPaper>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScientificPaper&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._authors, _authors)&&(identical(other.year, year) || other.year == year)&&(identical(other.doi, doi) || other.doi == doi)&&(identical(other.abstract, abstract) || other.abstract == abstract)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.url, url) || other.url == url)&&(identical(other.license, license) || other.license == license)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_authors),year,doi,abstract,summary,url,license,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_keywords),uploadedAt,updatedAt,active,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ScientificPaper(id: $id, title: $title, authors: $authors, year: $year, doi: $doi, abstract: $abstract, summary: $summary, url: $url, license: $license, categories: $categories, keywords: $keywords, uploadedAt: $uploadedAt, updatedAt: $updatedAt, active: $active, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ScientificPaperCopyWith<$Res> implements $ScientificPaperCopyWith<$Res> {
  factory _$ScientificPaperCopyWith(_ScientificPaper value, $Res Function(_ScientificPaper) _then) = __$ScientificPaperCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, List<String> authors, int year, String doi, String abstract, String summary, String url, String license, List<String> categories, List<String> keywords, DateTime uploadedAt, DateTime updatedAt, bool active, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ScientificPaperCopyWithImpl<$Res>
    implements _$ScientificPaperCopyWith<$Res> {
  __$ScientificPaperCopyWithImpl(this._self, this._then);

  final _ScientificPaper _self;
  final $Res Function(_ScientificPaper) _then;

/// Create a copy of ScientificPaper
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? authors = null,Object? year = null,Object? doi = null,Object? abstract = null,Object? summary = null,Object? url = null,Object? license = null,Object? categories = null,Object? keywords = null,Object? uploadedAt = null,Object? updatedAt = null,Object? active = null,Object? metadata = freezed,}) {
  return _then(_ScientificPaper(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,authors: null == authors ? _self._authors : authors // ignore: cast_nullable_to_non_nullable
as List<String>,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,doi: null == doi ? _self.doi : doi // ignore: cast_nullable_to_non_nullable
as String,abstract: null == abstract ? _self.abstract : abstract // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,license: null == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
