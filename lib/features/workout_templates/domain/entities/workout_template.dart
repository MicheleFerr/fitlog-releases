/// 🏋️‍♂️ Community Workout Template Entity
///
/// 📁 Layer: domain
/// 🎯 Feature: workout_templates
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// This is for COMMUNITY/PUBLIC templates (shareable with others).
/// For internal workout templates used during workouts, see:
/// `lib/features/workout/domain/entities/workout_template.dart`
///
/// Dependencies:
/// - Riverpod: None
/// - Firebase: Firestore structure
/// - Hive: None
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

part 'workout_template.freezed.dart';
part 'workout_template.g.dart';

/// @deprecated Use [CommunityWorkoutTemplate] instead to avoid naming conflicts
/// with workout internal WorkoutTemplate entity.
///
/// This typedef exists for backward compatibility during migration.
@Deprecated('Use CommunityWorkoutTemplate instead - avoids naming conflict with workout WorkoutTemplate')
typedef WorkoutTemplate = CommunityWorkoutTemplate;

enum TemplateVisibility {
  private,   // Solo visibile al creatore
  public,    // Visibile a tutti
  friends,   // Visibile agli amici (futuro)
}

enum TemplateCategory {
  strength,
  hypertrophy,
  endurance,
  powerlifting,
  bodybuilding,
  crossfit,
  calisthenics,
  cardio,
  mixed,
  custom,
}

@freezed
abstract class CommunityWorkoutTemplate with _$CommunityWorkoutTemplate {
  const factory CommunityWorkoutTemplate({
    required String id,
    required String userId,
    required String name,
    String? description,
    required List<Exercise> exercises,
    // Default to 'custom' for templates created before category was added
    @Default(TemplateCategory.custom) TemplateCategory category,
    // Default to 'private' for templates created before visibility was added
    @Default(TemplateVisibility.private) TemplateVisibility visibility,
    
    // Metadata
    required DateTime createdAt,
    DateTime? updatedAt,
    
    // Stats pubbliche
    @Default(0) int downloadCount,
    @Default(0) int likeCount,
    @Default(0) int reviewCount,
    @Default(0.0) double averageRating,
    
    // Info autore
    String? authorName,
    String? authorPhotoUrl,
    
    // Tags per ricerca
    @Default([]) List<String> tags,

    // Folder organization (P2-3)
    String? folderId,
    
    // Durata stimata in minuti
    int? estimatedDurationMinutes,
    
    // Livello difficoltà
    String? difficultyLevel, // beginner, intermediate, advanced, expert
    
    // Equipment necessario
    @Default([]) List<String> requiredEquipment,
    
    // Muscoli target
    @Default([]) List<String> targetMuscles,
  }) = _CommunityWorkoutTemplate;

  factory CommunityWorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      _$CommunityWorkoutTemplateFromJson(json);
}

@freezed
abstract class TemplateReview with _$TemplateReview {
  const factory TemplateReview({
    required String id,
    required String templateId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required double rating, // 1-5 stelle
    required String comment,
    required DateTime createdAt,
    @Default(0) int helpfulCount,
    @Default([]) List<String> helpfulVoters,
  }) = _TemplateReview;

  factory TemplateReview.fromJson(Map<String, dynamic> json) =>
      _$TemplateReviewFromJson(json);
}

@freezed
abstract class TemplateComment with _$TemplateComment {
  const factory TemplateComment({
    required String id,
    required String templateId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String text,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default([]) List<String> likedBy,
    String? replyToId, // Per rispondere ad altri commenti
  }) = _TemplateComment;

  factory TemplateComment.fromJson(Map<String, dynamic> json) =>
      _$TemplateCommentFromJson(json);
}