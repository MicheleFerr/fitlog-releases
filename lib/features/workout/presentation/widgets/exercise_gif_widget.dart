/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ No text to localize
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal design
///
/// Widget per mostrare GIF animate degli esercizi con fallback e espansione
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_fullscreen.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseGifWidget extends StatelessWidget {

  const ExerciseGifWidget({
    super.key,
    required this.gifUrl,
    required this.exerciseName,
    this.size = 56.0,
    this.backgroundColor,
    this.iconColor,
  });
  final String? gifUrl;
  final String exerciseName;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final icColor = iconColor ?? colorScheme.primary;

    // Debug: log URL
    if (kDebugMode) {
      debugPrint('🎬 ExerciseGifWidget: $exerciseName -> URL: $gifUrl');
    }

    // Se non c'è URL, mostra icona fallback
    if (gifUrl == null || gifUrl!.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ No GIF URL for $exerciseName, showing fallback icon');
      }
      return _buildFallbackIcon(bgColor, icColor);
    }

    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: CircleAvatar(
        backgroundColor: bgColor,
        radius: size / 2,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: gifUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            // Memory cache limits to prevent excessive memory usage
            memCacheHeight: (size * 2).toInt(),
            memCacheWidth: (size * 2).toInt(),
            // Disk cache configuration
            cacheKey: 'exercise_gif_${exerciseName.replaceAll(' ', '_')}_${size.toInt()}',
            maxHeightDiskCache: (size * 3).toInt(),
            maxWidthDiskCache: (size * 3).toInt(),
            // Loading placeholder
            placeholder: (context, url) {
              if (kDebugMode) {
                debugPrint('⏳ Loading GIF for $exerciseName from $url');
              }
              return Container(
                width: size,
                height: size,
                color: bgColor,
                child: Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(icColor),
                    ),
                  ),
                ),
              );
            },
            // Error fallback
            errorWidget: (context, url, error) {
              if (kDebugMode) {
                debugPrint('❌ Error loading GIF for $exerciseName: $error');
              }
              return Container(
                width: size,
                height: size,
                color: bgColor,
                child: Center(
                  child: Icon(
                    AppIcons.workout,
                    color: icColor,
                    size: size * 0.5,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color bgColor, Color iconColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        AppIcons.workout,
        color: iconColor,
        size: size * 0.5,
      ),
    );
  }

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (context) => ExerciseGifFullscreen(
        gifUrl: gifUrl!,
        exerciseName: exerciseName,
      ),
    );
  }
}
