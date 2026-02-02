/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// EXERCISE AVATAR - Circular exercise image widget (48px)
///
/// Displays exercise image in a circular avatar format:
/// - Primary: Exercise imageUrl from database
/// - Fallback: Muscle group icon
/// - Placeholder: Generic dumbbell icon
///
/// Example:
/// ```dart
/// ExerciseAvatar(
///   exerciseId: 'bench-press',
///   exerciseName: 'Bench Press',
///   muscleGroup: 'chest',
///   size: 48,
/// )
/// ```
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/shared/data/services/gif_cache_manager.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Circular avatar widget for exercise images
///
/// Standard size: 48px (follows Material Design avatar guidelines)
/// Used in: PR cards, e1RM tracker, exercise lists
class ExerciseAvatar extends ConsumerWidget {
  const ExerciseAvatar({
    required this.exerciseId,
    required this.exerciseName,
    this.muscleGroup,
    this.size = 48.0,
    this.backgroundColor,
    super.key,
  });

  /// Exercise ID from database (used to fetch imageUrl)
  final String exerciseId;

  /// Exercise name (used for semantic label)
  final String exerciseName;

  /// Primary muscle group (used for fallback icon)
  final String? muscleGroup;

  /// Avatar size in logical pixels (default: 48)
  final double size;

  /// Optional background color (defaults to surfaceContainerHighest)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch exercise data to get imageUrl
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));

    return Semantics(
      label: exerciseName,
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? context.colors.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: exerciseAsync.when(
          data: (exercise) => _buildAvatar(context, exercise?.imageUrl),
          loading: () => _buildPlaceholder(context),
          error: (_, __) => _buildFallbackIcon(context),
        ),
      ),
    );
  }

  /// Build avatar with image or fallback
  Widget _buildAvatar(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildFallbackIcon(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: GifCacheManager.instance,
      fit: BoxFit.cover,
      width: size,
      height: size,
      placeholder: (_, __) => _buildPlaceholder(context),
      errorWidget: (_, __, ___) => _buildFallbackIcon(context),
    );
  }

  /// Placeholder while loading
  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  /// Fallback icon based on muscle group
  Widget _buildFallbackIcon(BuildContext context) {
    final icon = _getMuscleGroupIcon();
    final iconSize = size * 0.5;

    return Center(
      child: Icon(icon, size: iconSize, color: context.colors.onSurfaceVariant),
    );
  }

  /// Get icon based on muscle group
  IconData _getMuscleGroupIcon() {
    final group = muscleGroup?.toLowerCase() ?? '';

    // Map muscle groups to icons
    // Note: AppIcons.workout = dumbbell icon
    return switch (group) {
      'chest' || 'petto' || 'pettorali' => AppIcons.workout,
      'back' || 'schiena' || 'dorsali' => AppIcons.workout,
      'shoulders' || 'spalle' || 'deltoidi' => AppIcons.workout,
      'legs' || 'gambe' || 'quadricipiti' || 'glutei' => AppIcons.workout,
      'arms' || 'braccia' || 'bicipiti' || 'tricipiti' => AppIcons.workout,
      'core' || 'addome' || 'addominali' => AppIcons.workout,
      _ => AppIcons.workout, // Default: dumbbell icon
    };
  }
}

/// Compact version of ExerciseAvatar for smaller contexts
///
/// Same functionality but with smaller default size (36px)
class ExerciseAvatarSmall extends ExerciseAvatar {
  const ExerciseAvatarSmall({
    required super.exerciseId,
    required super.exerciseName,
    super.muscleGroup,
    super.size = 36.0,
    super.backgroundColor,
    super.key,
  });
}

/// Large version of ExerciseAvatar for detail views
///
/// Same functionality but with larger default size (64px)
class ExerciseAvatarLarge extends ExerciseAvatar {
  const ExerciseAvatarLarge({
    required super.exerciseId,
    required super.exerciseName,
    super.muscleGroup,
    super.size = 64.0,
    super.backgroundColor,
    super.key,
  });
}
