// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_branding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoachBranding _$CoachBrandingFromJson(Map<String, dynamic> json) =>
    _CoachBranding(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      businessName: json['businessName'] as String,
      tagline: json['tagline'] as String?,
      primaryColor: json['primaryColor'] as String? ?? kDefaultPrimaryColor,
      accentColor: json['accentColor'] as String? ?? kDefaultAccentColor,
      logoUrl: json['logoUrl'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
      footerText: json['footerText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CoachBrandingToJson(_CoachBranding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachId': instance.coachId,
      'businessName': instance.businessName,
      'tagline': instance.tagline,
      'primaryColor': instance.primaryColor,
      'accentColor': instance.accentColor,
      'logoUrl': instance.logoUrl,
      'email': instance.email,
      'phone': instance.phone,
      'website': instance.website,
      'instagram': instance.instagram,
      'footerText': instance.footerText,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
